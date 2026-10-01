#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"

# Parses `brew livecheck --json` output and prints "current latest outdated".
# Homebrew reports livecheck failures as JSON without a `version` member, so
# those must fail explicitly instead of being read as missing version data.

package = ARGV[0]
abort "Usage: #{File.basename($PROGRAM_NAME)} <package-name>  (reads `brew livecheck --json` on stdin)" if package.nil?

begin
  data = JSON.parse(STDIN.read)
rescue JSON::ParserError => e
  abort "#{package} livecheck returned invalid JSON: #{e.message}"
end

result = data.is_a?(Array) ? data.first : nil
abort "#{package} livecheck returned no result" unless result.is_a?(Hash)

version = result["version"]

if result["status"] == "error" || !version.is_a?(Hash)
  messages = result["messages"]
  detail = messages.is_a?(Array) && !messages.empty? ? messages.join("; ") : "no version data returned"
  abort "#{package} livecheck failed: #{detail}"
end

current = version["current"]
latest = version["latest"]
outdated = version["outdated"]

abort "#{package} livecheck returned no version.current" unless current.is_a?(String) && !current.empty?
abort "#{package} livecheck returned no version.latest" unless latest.is_a?(String) && !latest.empty?
abort "#{package} livecheck returned an invalid version.outdated" unless [true, false].include?(outdated)

puts "#{current} #{latest} #{outdated}"
