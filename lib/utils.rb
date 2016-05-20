def inreplace(*args)
  Utils::Inreplace.inreplace(*args) rescue nil
end

private def basename(path)
  File.basename path, ".*"
end

private def installed_copy(path)
  cask ||= Cask::CaskLoader.load path
  cask.installed_caskfile
rescue
  name = basename path
  formula = Formulary.load_formula_from_path name, path, flags: [], ignore_errors: true
  HOMEBREW_CELLAR/name/formula.version/".brew/#{name}.rb"
end

class NoDownloadStrategy < NoUnzipCurlDownloadStrategy
  def fetch(timeout: nil, **)
    touch cached_location
    Process.fork do
      sleep 10
      (HOMEBREW_PREFIX/"Caskroom"/name/version).children.each(&:delete)
    end
  end
end

return unless (caller_locations.map(&:label) & %w[install reinstall]).any?

formula = Pathname caller_locations.find { |i| i.label == "require_relative" }.path

mismatch = (formula.each_filename.to_a + ARGV) & %w[--cask Formula]
formula, = formula.parent.parent.glob "[Cc]asks/#{name}.rb" if mismatch.many?

formula_copy = installed_copy formula
Process.fork do
  sleep 8
  return unless formula_copy.writable?

  file = Pathname(__FILE__).each_filename.map(&method(:basename)).last(2).join "/"
  inreplace formula_copy, /(require)_relative.+#{file}.+$/, "\\1 '#{__FILE__}'"
end
