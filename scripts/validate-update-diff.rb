#!/usr/bin/env ruby
# frozen_string_literal: true

require "open3"

def usage!
  abort "Usage: #{File.basename($PROGRAM_NAME)} <cask|formula> <recipe-path> <current-version> <latest-version>"
end

package_type, recipe, expected_current, expected_latest = ARGV
usage! unless %w[cask formula].include?(package_type) &&
              recipe &&
              expected_current &&
              expected_latest

abort "Missing recipe: #{recipe}" unless File.file?(recipe)
abort "Current and latest versions must differ" if expected_current == expected_latest

base, status = Open3.capture2("git", "show", "HEAD:#{recipe}")
abort "Unable to read #{recipe} from HEAD" unless status.success?

current = File.read(recipe)

abort "No changes detected in #{recipe}" if base == current

if package_type == "formula"
  abort <<~MSG
    Automatic Formula diff validation is not implemented yet.
    Refusing to continue automatically; update this package manually.
  MSG
end

def parse_cask(source)
  lines = source.lines
  normalized = []
  versions = []
  sha256_stanzas = []
  latest_version_index = nil
  i = 0

  while i < lines.length
    line = lines[i]

    if line.match?(/^\s*version\s+/)
      match = line.match(/^(\s*)version\s+"([^"]+)"\s*$/)
      abort "Unsupported cask version stanza at line #{i + 1}: #{line.strip}" unless match

      versions << {
        value: match[2],
        line: i + 1,
      }
      latest_version_index = versions.length - 1
      normalized << "#{match[1]}version __AUTO_BUMP_VERSION__\n"
      i += 1
      next
    end

    if line.match?(/^\s*sha256\b/)
      abort "sha256 stanza at line #{i + 1} has no preceding version stanza" if latest_version_index.nil?

      indent = line[/^\s*/]
      stanza_start_line = i + 1
      stanza_lines = [line]
      previous = line
      i += 1

      while previous.rstrip.end_with?(",") && i < lines.length
        previous = lines[i]
        stanza_lines << previous
        i += 1
      end

      sha256_stanzas << {
        text: stanza_lines.join,
        line: stanza_start_line,
        version_index: latest_version_index,
      }
      normalized << "#{indent}sha256 __AUTO_BUMP_SHA256__\n"
      next
    end

    normalized << line
    i += 1
  end

  {
    normalized: normalized.join,
    versions: versions,
    sha256_stanzas: sha256_stanzas,
  }
end

base_cask = parse_cask(base)
current_cask = parse_cask(current)

unless base_cask[:normalized] == current_cask[:normalized]
  warn "Automatic cask update changed content outside the allowed version/sha256 fields."
  warn
  system("git", "--no-pager", "diff", "--", recipe)
  exit 1
end

unless base_cask[:versions].length == current_cask[:versions].length &&
       base_cask[:sha256_stanzas].length == current_cask[:sha256_stanzas].length
  abort "Automatic cask update changed the number of version or sha256 stanzas"
end

target_version_indexes = []

base_cask[:versions].each_with_index do |base_version, index|
  updated_version = current_cask[:versions].fetch(index)

  if base_version[:value] == expected_current
    unless updated_version[:value] == expected_latest
      abort <<~MSG
        Expected current version #{expected_current.inspect} at line #{base_version[:line]} to become
        #{expected_latest.inspect}, but found #{updated_version[:value].inspect}.
      MSG
    end

    target_version_indexes << index
  elsif updated_version[:value] != base_version[:value]
    abort <<~MSG
      Refusing to modify non-current version at line #{base_version[:line]}:
      #{base_version[:value].inspect} -> #{updated_version[:value].inspect}.
      Only #{expected_current.inspect} may change.
    MSG
  end
end

abort "No version stanza matching current version #{expected_current.inspect} was found" if target_version_indexes.empty?

sha_indexes_by_version = Hash.new { |hash, key| hash[key] = [] }

base_cask[:sha256_stanzas].each_with_index do |base_sha, index|
  updated_sha = current_cask[:sha256_stanzas].fetch(index)

  unless base_sha[:version_index] == updated_sha[:version_index]
    abort "Automatic cask update changed sha256/version stanza association near line #{base_sha[:line]}"
  end

  sha_indexes_by_version[base_sha[:version_index]] << index

  next if base_sha[:text] == updated_sha[:text]

  unless target_version_indexes.include?(base_sha[:version_index])
    version = base_cask[:versions].fetch(base_sha[:version_index])
    abort <<~MSG
      Refusing to modify sha256 stanza at line #{base_sha[:line]} because its associated
      version #{version[:value].inspect} is not the current version #{expected_current.inspect}.
    MSG
  end
end

target_version_indexes.each do |version_index|
  sha_indexes = sha_indexes_by_version.fetch(version_index, [])

  if sha_indexes.empty?
    version = base_cask[:versions].fetch(version_index)
    abort "Current version stanza at line #{version[:line]} has no associated sha256 stanza"
  end

  unchanged_sha = sha_indexes.find do |sha_index|
    base_cask[:sha256_stanzas][sha_index][:text] == current_cask[:sha256_stanzas][sha_index][:text]
  end

  next unless unchanged_sha

  sha = base_cask[:sha256_stanzas].fetch(unchanged_sha)
  abort "sha256 stanza at line #{sha[:line]} did not change with version #{expected_current.inspect} -> #{expected_latest.inspect}"
end

puts "Automatic update diff is safe:"
puts "- #{target_version_indexes.length} version stanza(s) changed #{expected_current.inspect} -> #{expected_latest.inspect}"
puts "- all non-current version stanzas remained unchanged"
puts "- sha256 changes are limited to and present for the updated version stanzas"
