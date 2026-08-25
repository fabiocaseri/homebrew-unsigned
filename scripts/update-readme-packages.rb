#!/usr/bin/env ruby
# frozen_string_literal: true

require "uri"
require "yaml"

METADATA_FILE = "packages.yml"
README_FILE = "README.md"
START_MARKER = "<!-- PACKAGES:START -->"
END_MARKER = "<!-- PACKAGES:END -->"

def escape_cell(value)
  value.to_s.gsub("|", "\\|").gsub(/\s+/, " ").strip
end

def recipe_path(package)
  type = package.fetch("type")
  name = package.fetch("name")

  type == "cask" ? "Casks/#{name}.rb" : "Formula/#{name}.rb"
end

def display_name(package)
  path = recipe_path(package)
  source = File.read(path)

  if package.fetch("type") == "cask"
    match = source.match(/^\s*name\s+"([^"]+)"/)
    return match[1] if match
  end

  package.fetch("name")
end

def upstream_label(url)
  uri = URI.parse(url)

  if uri.host&.downcase == "github.com"
    path = uri.path.sub(%r{\A/}, "").sub(%r{/\z}, "")
    return path unless path.empty?
  end

  uri.host || url
end

def status_for(package)
  package.fetch("update").fetch("enabled") ? "Maintained" : "Manual updates"
end

def gatekeeper_context_for(package)
  context = package.dig("gatekeeper", "upstream_context")
  return "—" unless context.is_a?(Array) && !context.empty?

  context.map do |entry|
    label = entry.fetch("status").tr("_", " ")
    url = entry.fetch("url")
    "[#{escape_cell(label)}](#{url})"
  end.join(" · ")
end

abort "Missing #{METADATA_FILE}" unless File.file?(METADATA_FILE)
abort "Missing #{README_FILE}" unless File.file?(README_FILE)

data = YAML.safe_load(File.read(METADATA_FILE), aliases: false)
packages = data.fetch("packages")

rows = packages
  .sort_by { |package| package.fetch("name") }
  .map do |package|
    upstream_url = package.fetch("upstream").fetch("url")

    [
      escape_cell(display_name(package)),
      escape_cell(package.fetch("type").capitalize),
      "[#{escape_cell(upstream_label(upstream_url))}](#{upstream_url})",
      escape_cell(status_for(package)),
      gatekeeper_context_for(package),
    ]
  end

table = [
  "| Package | Type | Upstream | Status | Gatekeeper context |",
  "| --- | --- | --- | --- | --- |",
  *rows.map { |row| "| #{row.join(' | ')} |" },
].join("\n")

readme = File.read(README_FILE)

start_index = readme.index(START_MARKER)
end_index = readme.index(END_MARKER)

abort "Missing #{START_MARKER} in #{README_FILE}" unless start_index
abort "Missing #{END_MARKER} in #{README_FILE}" unless end_index
abort "#{END_MARKER} appears before #{START_MARKER}" if end_index < start_index

replacement = "#{START_MARKER}\n\n#{table}\n\n#{END_MARKER}"

updated = readme[0...start_index] +
          replacement +
          readme[(end_index + END_MARKER.length)..]

File.write(README_FILE, updated)

puts "Updated #{README_FILE} package table (#{packages.length} package(s))."
