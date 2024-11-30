# frozen_string_literal: true

RSpec.describe Gemview::GitRepo do
  describe ".from_urls" do
    it "parses github urls", :aggregate_failures do
      %w[
        http://github.com/rails/rails/releases/tag/v8.0.0
        https://github.com/rails/rails/releases/tag/v8.0.0
        http://github.com/rails/rails/tree/v8.0.0
        https://github.com/rails/rails/tree/v8.0.0
        http://github.com/rails/rails
        https://github.com/rails/rails
      ].each do |url|
        git_repo = described_class.from_urls(
          urls: [url],
          version: "1.2.3.4"
        )
        expect(git_repo).to have_attributes(
          base_url: eq("http://github.com/rails/rails") | eq("https://github.com/rails/rails"),
          git_host: :github,
          version: "1.2.3.4"
        )
      end
    end

    it "parses gitlab urls", :aggregate_failures do
      %w[
        http://gitlab.com/gems-rb/makit
        https://gitlab.com/gems-rb/makit
        http://gitlab.com/gems-rb/makit/CHANGELOG.md
        https://gitlab.com/gems-rb/makit/CHANGELOG.md
      ].each do |url|
        git_repo = described_class.from_urls(
          urls: [url],
          version: "1.2.3.4"
        )
        expect(git_repo).to have_attributes(
          base_url: eq("http://gitlab.com/gems-rb/makit") | eq("https://gitlab.com/gems-rb/makit"),
          git_host: :gitlab,
          version: "1.2.3.4"
        )
      end
    end
  end
end
