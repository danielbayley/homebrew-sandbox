require_relative "../lib/utils"

cask "sandbox" do
  version :latest
  sha256 :no_check

  repo = GitHub.user["html_url"] + "/#{cask.tap&.path&.basename}"

  url "#{repo}/archive/main.tar.gz", using: NoDownloadStrategy
  name token.capitalize
  desc "#{name.first} repository for testing"
  homepage "#{repo}#readme"

  stage_only true
end
