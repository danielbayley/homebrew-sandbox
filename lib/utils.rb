# typed: false
# frozen_string_literal: true

def require_fix
  sleep 8
  rb, = Pathname.glob HOMEBREW_PREFIX/"C*/#{@name}/{.metadata/,}#{version}/{.brew,*/Casks}/#{@name}.rb"

  inreplace rb, /(require)_relative.+utils.+$/, "\\1 '#{__FILE__}'"
end

def inreplace(*args)
  begin
    Utils::Inreplace.inreplace(*args)
  rescue
    nil
  end
  Process.fork &method(:require_fix) if @meta.nil?
end

class NoDownloadStrategy < NoUnzipCurlDownloadStrategy
  def fetch(timeout: nil, **)
    touch cached_location

    Process.fork do
      require_fix
      rm_r Dir[HOMEBREW_PREFIX/"Caskroom/#{name}/#{version}/*"]
    end
  end
end
