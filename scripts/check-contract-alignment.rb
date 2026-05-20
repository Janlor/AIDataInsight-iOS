#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"

ROOT = File.expand_path("..", __dir__)
MANIFEST_PATH = File.join(ROOT, "docs/cross-platform/contracts/contract-manifest.yaml")

def usage
  warn "Usage: scripts/check-contract-alignment.sh [app-ios|app-android|app-harmony|app-web|app-apple|all]"
  exit 1
end

target = ARGV[0] || "all"
usage if ["-h", "--help", "help"].include?(target)

manifest = YAML.load_file(MANIFEST_PATH)
current_version = manifest.fetch("contractVersion")
current_migrations = manifest.fetch("currentMigrations", [])
alignment_files = manifest.fetch("clientAlignmentFiles")

selected =
  if target == "all"
    alignment_files
  elsif alignment_files.key?(target)
    { target => alignment_files.fetch(target) }
  else
    usage
  end

puts "Contract package: #{manifest.fetch("contractPackage")}"
puts "Current contract version: #{current_version}"
puts "Manifest: #{MANIFEST_PATH.sub(ROOT + "/", "")}"
puts

selected.each do |app, relative_path|
  path = File.join(ROOT, relative_path)
  unless File.exist?(path)
    puts "#{app}: missing alignment file at #{relative_path}"
    next
  end

  alignment = JSON.parse(File.read(path))
  app_version = alignment.fetch("contractVersion", "0.0.0")
  status = alignment.fetch("status", "unknown")
  pending = Array(alignment["pendingMigrations"])

  manifest_pending = current_migrations.map do |migration|
    id = migration.fetch("id")
    id unless alignment.fetch("lastAppliedMigration", nil) == id || app_version == current_version
  end.compact

  unresolved = (pending + manifest_pending).uniq

  puts "#{app}"
  puts "  alignment file: #{relative_path}"
  puts "  app contract version: #{app_version}"
  puts "  status: #{status}"

  if app_version == current_version && unresolved.empty? && status == "aligned"
    puts "  result: aligned"
  else
    puts "  result: needs attention"
    puts "  pending migrations:"
    unresolved.each { |migration| puts "    - #{migration}" }
  end

  puts "  minimal read set:"
  puts "    - docs/ai-entrypoint.md"
  puts "    - docs/cross-platform/contracts/contract-manifest.yaml"
  unresolved.each do |migration_id|
    migration = current_migrations.find { |item| item.fetch("id") == migration_id }
    puts "    - #{migration.fetch("file")}" if migration
  end
  puts "    - #{relative_path}"
  puts
end
