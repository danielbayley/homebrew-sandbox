require_relative "../lib/utils"

class Sandbox < Formula
  repo = GitHub.user["html_url"] + "/homebrew-#{name.demodulize.downcase}"

  desc "#{name.demodulize} repository for testing"
  homepage "#{repo}#readme"
  url "#{repo}/archive/main.zip"
  version "latest"

  def install
    doc.install "README.md"
  end

  test do
    File.read(doc/"README.md").lines.grep(/#{desc}/).any?
  end
end
