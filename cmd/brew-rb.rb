# typed: false
# frozen_string_literal: false

exec(*ARGV.filter { |arg| arg != "-e" }) rescue nil if ARGV.any?
