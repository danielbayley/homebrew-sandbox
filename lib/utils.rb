# typed: false
# frozen_string_literal: true

def inreplace(*args)
  Utils::Inreplace.inreplace(*args)
rescue
  nil
end

def basename(path)
  File.basename path, ".*"
end

class NoDownloadStrategy < NoUnzipCurlDownloadStrategy
  def fetch(timeout: nil, **)
    touch cached_location
    Process.fork do
      sleep 10
      rm_r Dir[HOMEBREW_PREFIX/"Caskroom"/name/version/"*"]
    end
  end
end

return unless caller_locations.map(&:label).include? "install"

path = Pathname caller_locations.find { |i| i.label == "require_relative" }.path
name = basename path

if (path.each_filename.to_a + ARGV & %w[--cask Formula]).many?
  path, = path.parent.parent.glob "[Cc]asks/#{name}.rb"
end

begin
  cask ||= Cask::CaskLoader.load path
rescue
  formula = Formulary.load_formula_from_path name, path, flags: [], ignore_errors: false
  rb = HOMEBREW_CELLAR/name/formula.version/".brew/#{name}.rb"
end
Process.fork do
  sleep 8
  rb ||= cask.installed_caskfile
  inreplace rb, /(require)_relative\s.+#{basename __FILE__}.+$/, "\\1 '#{__FILE__}'"
end
