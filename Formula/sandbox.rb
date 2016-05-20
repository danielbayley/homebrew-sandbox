require_relative "../lib/utils"

class Sandbox < Formula
  repo = URI GitHub.user["html_url"] + "/homebrew-#{name.demodulize.downcase}"

  desc "#{name.demodulize} repository for testing"
  homepage "https://#{repo.host + repo.path}#readme"
  url "#{repo}/archive/#{Utils.git_branch}.tar.gz", using: NoDownloadStrategy
  version "latest"
  sha256 :no_check
  head "#{repo}.git", branch: Utils.git_branch

  def install
    readme = "README.md"
    inreplace readme, /^=+/, "-" * name.demodulize.length
    doc.install readme
  end

  test do
    File.read(doc/"README.md").lines.grep(/#{desc}/).any?
  end
end
