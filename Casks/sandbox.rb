require_relative "../lib/utils"

cask "sandbox" do
  version :latest
  sha256 :no_check

  path = cask.tap&.path&.basename
  repo = GitHub.user["html_url"] + "/#{path}"

  url "#{repo}/archive/main.zip"
  name token.capitalize
  desc "#{name.first} repository for testing"
  homepage "#{repo}#readme"

  stage_only true

  preflight do
    branch = File.basename @cask.url.uri.path, ".*"
    Dir.chdir staged_path
    system "mv */{.[A-z0-9],}* . && rm -r #{path}-#{branch}"
  end
end
