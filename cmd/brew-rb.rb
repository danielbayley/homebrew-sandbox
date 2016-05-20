if ARGV.any?
  begin
    exec eval *ARGV.filter { |arg| arg != "-e" }
  rescue
    nil
  end
end
