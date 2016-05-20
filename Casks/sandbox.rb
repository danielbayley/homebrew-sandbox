require_relative "../lib/utils"

cask "sandbox" do
  version :latest
  sha256 :no_check

  repo = File.join GitHub.user["html_url"], cask.tap.path.basename
  url "#{repo}/archive/main.zip"
  name token.capitalize
  desc "#{name.first} repository for testing"
  homepage "#{repo}#readme"

  preflight do
    branch = File.basename @cask.url.uri.path, ".*"
    pp staged_path/""
    #{staged_path}/#{@cask.tap.path.basename}-#{branch}"
  end

  stage_only true
end
