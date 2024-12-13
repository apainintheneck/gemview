# frozen_string_literal: true

RSpec.describe Gemview::GitRepo do
  describe ".from_urls" do
    it "parses github urls" do
      git_repo = described_class.from_urls(
        homepage_uri: "https://rubyonrails.org",
        source_code_uri: "https://github.com/rails/rails/tree/v8.0.0.1",
        changelog_uri: "https://github.com/rails/rails/releases/tag/v8.0.0.1",
        version: "8.0.0.1"
      )
      expect(git_repo).to have_attributes(
        base_uri: "https://github.com/rails/rails",
        changelog_uri: "https://github.com/rails/rails/releases/tag/v8.0.0.1",
        git_host: :github,
        version: "8.0.0.1"
      )
    end

    it "parses gitlab urls" do
      git_repo = described_class.from_urls(
        homepage_uri: "https://gitlab.com/gems-rb/makit",
        source_code_uri: "https://gitlab.com/gems-rb/makit",
        changelog_uri: "https://gitlab.com/gems-rb/makit/CHANGELOG.md",
        version: "0.0.40"
      )
      expect(git_repo).to have_attributes(
        base_uri: "https://gitlab.com/gems-rb/makit",
        changelog_uri: "https://gitlab.com/gems-rb/makit/CHANGELOG.md",
        git_host: :gitlab,
        version: "0.0.40"
      )
    end
  end
end
