# frozen_string_literal: true

RSpec.describe Gemview::Gem do
  describe ".find" do
    context "without version" do
      it "loads the rails gem" do
        VCR.use_cassette("find-rails-gem") do
          gem = described_class.find(name: "rails")

          expect(gem).to have_attributes(
            authors: "David Heinemeier Hansson",
            changelog_uri: "https://github.com/rails/rails/releases/tag/v8.0.0",
            dependencies: have_attributes(
              development: [],
              runtime: [
                have_attributes(name: "actioncable", requirements: "= 8.0.0"),
                have_attributes(name: "actionmailbox", requirements: "= 8.0.0"),
                have_attributes(name: "actionmailer", requirements: "= 8.0.0"),
                have_attributes(name: "actionpack", requirements: "= 8.0.0"),
                have_attributes(name: "actiontext", requirements: "= 8.0.0"),
                have_attributes(name: "actionview", requirements: "= 8.0.0"),
                have_attributes(name: "activejob", requirements: "= 8.0.0"),
                have_attributes(name: "activemodel", requirements: "= 8.0.0"),
                have_attributes(name: "activerecord", requirements: "= 8.0.0"),
                have_attributes(name: "activestorage", requirements: "= 8.0.0"),
                have_attributes(name: "activesupport", requirements: "= 8.0.0"),
                have_attributes(name: "bundler", requirements: ">= 1.15.0"),
                have_attributes(name: "railties", requirements: "= 8.0.0")
              ]
            ),
            downloads: 567406953,
            homepage_uri: "https://rubyonrails.org",
            info: "Ruby on Rails is a full-stack web framework optimized for programmer happiness and sustainable productivity. It encourages beautiful code by favoring convention over configuration.",
            licenses: ["MIT"],
            name: "rails",
            project_uri: "https://rubygems.org/gems/rails",
            source_code_uri: "https://github.com/rails/rails/tree/v8.0.0",
            version: "8.0.0",
            version_created_at: Time.parse("2024-11-07 22:30:42.971000000 +0000")
          )
        end
      end

      it "generates the expected text", :aggregate_failures do
        VCR.use_cassette("find-rails-gem") do
          gem = described_class.find(name: "rails")

          expect(gem.humanized_downloads).to eq "567,406,953"
          expect(gem.selector_str).to eq <<~SELECTOR
            rails [8.0.0]
              -- Ruby on Rails is a full-stack web framework optimized for programmer happ…
          SELECTOR
          expect(gem.header_str).to match_snapshot("rails-header-str")
          expect(gem.dependencies_str).to match_snapshot("rails-dependencies-str")
        end
      end
    end

    context "with version" do
      it "loads the standard gem" do
        VCR.use_cassette("find-standard-gem") do
          gem = described_class.find(name: "standard", version: "1.42.1")

          expect(gem).to have_attributes(
            authors: "Justin Searls",
            changelog_uri: "https://github.com/standardrb/standard/blob/main/CHANGELOG.md",
            dependencies: have_attributes(
              development: [],
              runtime: [
                have_attributes(name: "language_server-protocol", requirements: "~> 3.17.0.2"),
                have_attributes(name: "lint_roller", requirements: "~> 1.0"),
                have_attributes(name: "rubocop", requirements: "~> 1.68.0"),
                have_attributes(name: "standard-custom", requirements: "~> 1.0.0"),
                have_attributes(name: "standard-performance", requirements: "~> 1.5")
              ]
            ),
            downloads: 22791345,
            homepage_uri: "https://github.com/standardrb/standard",
            info: "Ruby Style Guide, with linter & automatic code fixer",
            licenses: [],
            name: "standard",
            project_uri: "https://rubygems.org/gems/standard",
            source_code_uri: "https://github.com/standardrb/standard",
            version: "1.42.1",
            version_created_at: Time.parse("2024-11-19 00:56:52.880000000 +0000")
          )
        end
      end

      it "generates the expected text", :aggregate_failures do
        VCR.use_cassette("find-standard-gem") do
          gem = described_class.find(name: "standard", version: "1.42.1")

          expect(gem.humanized_downloads).to eq "22,791,345"
          expect(gem.selector_str).to eq <<~SELECTOR
            standard [1.42.1]
              -- Ruby Style Guide, with linter & automatic code fixer
          SELECTOR
          expect(gem.header_str).to match_snapshot("standard-header-str")
          expect(gem.dependencies_str).to match_snapshot("standard-dependencies-str")
        end
      end
    end
  end

  describe "#readme" do
    context "when it exists" do
      it "fetches readme" do
        gem = VCR.use_cassette("find-ble-gem") do
          described_class.find(name: "ble")
        end

        VCR.use_cassette("ble-gem-readme") do
          expect(gem.fetch_readme).to match_snapshot("ble-gem-readme")
        end
      end
    end

    context "when it's missing" do
      it "returns an error message" do
        gem = VCR.use_cassette("find-json-pointer-gem") do
          described_class.find(name: "json-pointer")
        end

        VCR.use_cassette("json-pointer-gem-readme") do
          expect(gem.fetch_changelog).to eq("Info: Unable to find a valid changelog based on available gem info")
        end
      end
    end
  end

  describe "#changelog" do
    context "when it exists" do
      it "fetches changelog" do
        gem = VCR.use_cassette("find-standard-gem") do
          described_class.find(name: "standard", version: "1.42.1")
        end

        VCR.use_cassette("standard-gem-changelog") do
          expect(gem.fetch_changelog).to match_snapshot("standard-gem-changelog")
        end
      end
    end

    context "when it's missing" do
      it "returns an error message" do
        gem = VCR.use_cassette("find-ble-gem") do
          described_class.find(name: "ble")
        end

        VCR.use_cassette("ble-gem-changelog") do
          expect(gem.fetch_changelog).to eq("Info: Unable to find a valid changelog based on available gem info")
        end
      end
    end
  end

  describe ".search" do
    it "returns search results as gems" do
      VCR.use_cassette("search-for-bluetooth") do
        gems = described_class.search(term: "bluetooth")

        expect(gems.size).to eq 30
        expect(JSON.pretty_generate(gems.map(&:to_h))).to match_snapshot("bluetooth-gem-search")
      end
    end
  end

  describe ".latest" do
    it "returns the latest gem releases" do
      VCR.use_cassette("latest-gems") do
        gems = described_class.latest

        expect(gems.size).to eq 50
        expect(gems).to all(be_a(described_class))
        expect(JSON.pretty_generate(gems.map(&:to_h))).to match_snapshot("latest-gems")
      end
    end
  end

  describe ".just_updated" do
    it "returns the most recently updated gems" do
      VCR.use_cassette("just-updated-gems") do
        gems = described_class.just_updated

        expect(gems.size).to eq 50
        expect(gems).to all(be_a(described_class))
        expect(JSON.pretty_generate(gems.map(&:to_h))).to match_snapshot("just-updated-gems")
      end
    end
  end
end