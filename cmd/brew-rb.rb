# typed: false
# frozen_string_literal: true

if ARGV.any?
  begin
    exec eval(*ARGV.filter { |arg| arg != "-e" }) # rubocop:disable Security/Eval
  rescue
    nil
  end
end
