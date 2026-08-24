#!/usr/bin/env ruby
# frozen_string_literal: true

require "open3"

def usage!
  abort "Usage: #{File.basename($PROGRAM_NAME)} <cask|formula> <recipe-path>"
end

package_type, recipe = ARGV
usage! unless %w[cask formula].include?(package_type) && recipe

abort "Missing recipe: #{recipe}" unless File.file?(recipe)

base, status = Open3.capture2("git", "show", "HEAD:#{recipe}")
abort "Unable to read #{recipe} from HEAD" unless status.success?

current = File.read(recipe)

if base == current
  abort "No changes detected in #{recipe}"
end

if package_type == "formula"
  abort <<~MSG
    Automatic Formula diff validation is not implemented yet.
    Refusing to continue automatically; update this package manually.
  MSG
end

def normalize_cask(source)
  lines = source.lines
  normalized = []
  i = 0

  while i < lines.length
    line = lines[i]

    if line.match?(/^\s*version\s+/)
      indent = line[/^\s*/]
      normalized << "#{indent}version __AUTO_BUMP_VERSION__\n"
      i += 1
      next
    end

    if line.match?(/^\s*sha256\b/)
      indent = line[/^\s*/]
      normalized << "#{indent}sha256 __AUTO_BUMP_SHA256__\n"

      # A multi-architecture sha256 stanza may continue across multiple lines.
      # Consume continuation lines while the previous physical line ends in a comma.
      previous = line
      i += 1

      while previous.rstrip.end_with?(",") && i < lines.length
        previous = lines[i]
        i += 1
      end

      next
    end

    normalized << line
    i += 1
  end

  normalized.join
end

normalized_base = normalize_cask(base)
normalized_current = normalize_cask(current)

unless normalized_base == normalized_current
  warn "Automatic cask update changed content outside the allowed version/sha256 fields."
  warn
  system("git", "--no-pager", "diff", "--", recipe)
  exit 1
end

puts "Automatic update diff is safe: only cask version/sha256 fields changed."
