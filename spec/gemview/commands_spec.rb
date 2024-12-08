# frozen_string_literal: true

RSpec.describe Gemview::Commands do
  describe "info" do
    it "shows gem info" do
      expect(Gemview::Terminal)
        .to receive(:choose)
        .with(
          message: match_snapshot("standard-gem-header"),
          choices: %w[Readme Changelog Dependencies Versions]
        )

      VCR.use_cassette("find-standard-gem") do
        described_class.start(arguments: %w[info standard --version 1.42.1])
      end
    end

    it "shows gem info + readme" do
      expect(Gemview::Terminal)
        .to receive(:choose)
        .with(
          message: match_snapshot("standard-gem-header"),
          choices: %w[Readme Changelog Dependencies Versions]
        )
        .and_yield("Readme")

      expect(Gemview::Terminal)
        .to receive(:page)
        .with(match_snapshot("standard-gem-readme-view"))

      VCR.use_cassette("find-standard-gem") do
        VCR.use_cassette("standard-gem-readme") do
          described_class.start(arguments: %w[info standard --version 1.42.1])
        end
      end
    end

    it "shows gem info + changelog" do
      expect(Gemview::Terminal)
        .to receive(:choose)
        .with(
          message: match_snapshot("standard-gem-header"),
          choices: %w[Readme Changelog Dependencies Versions]
        )
        .and_yield("Changelog")

      expect(Gemview::Terminal)
        .to receive(:page)
        .with(match_snapshot("standard-gem-changelog-view"))

      VCR.use_cassette("find-standard-gem") do
        VCR.use_cassette("standard-gem-changelog") do
          described_class.start(arguments: %w[info standard --version 1.42.1])
        end
      end
    end

    it "shows gem info + dependencies" do
      expect(Gemview::Terminal)
        .to receive(:choose)
        .with(
          message: match_snapshot("standard-gem-header"),
          choices: %w[Readme Changelog Dependencies Versions]
        )
        .and_yield("Dependencies")

      expect(Gemview::Terminal)
        .to receive(:page)
        .with(match_snapshot("standard-gem-dependencies-view"))

      VCR.use_cassette("find-standard-gem") do
        described_class.start(arguments: %w[info standard --version 1.42.1])
      end
    end

    it "shows gem info + versions" do
      expect(Gemview::Terminal)
        .to receive(:choose)
        .with(
          message: match_snapshot("standard-gem-header"),
          choices: %w[Readme Changelog Dependencies Versions]
        )
        .and_yield("Versions")

      expect(Gemview::Terminal)
        .to receive(:page)
        .with(match_snapshot("standard-gem-versions-view"))

      VCR.use_cassette("find-standard-gem") do
        VCR.use_cassette("gem-versions-for-standard") do
          described_class.start(arguments: %w[info standard --version 1.42.1])
        end
      end
    end
  end

  describe "search" do
    let(:birdbrain_selector) do
      "birdbrain [0.9.6]\n  -- This Ruby library allows students to use Ruby to read sensors and set mot…\n"
    end
    let(:birdbrain_gem) do
      Gemview::Gem.new({
        "documentation_uri": nil,
        "metadata": {
          "homepage_uri": "https://github.com/fmorton/BirdBrain-Ruby-Library",
          "allowed_push_host": "https://rubygems.org",
          "changelog_uri": "https://github.com/fmorton/BirdBrain-Ruby-Library/CHANGELOG.md",
          "source_code_uri": "https://github.com/fmorton/BirdBrain-Ruby-Library"
        },
        "homepage_uri": "https://github.com/fmorton/BirdBrain-Ruby-Library",
        "funding_uri": nil,
        "bug_tracker_uri": nil,
        "project_uri": "https://rubygems.org/gems/birdbrain",
        "version": "0.9.6",
        "sha": "c5bdeae5072c0c4e80acbd6c06d4242ef299a22d8254d458ecc6cff89cf05a21",
        "platform": "ruby",
        "changelog_uri": "https://github.com/fmorton/BirdBrain-Ruby-Library/CHANGELOG.md",
        "source_code_uri": "https://github.com/fmorton/BirdBrain-Ruby-Library",
        "licenses": [
          "MIT"
        ],
        "gem_uri": "https://rubygems.org/gems/birdbrain-0.9.6.gem",
        "downloads": 13313,
        "mailing_list_uri": nil,
        "name": "birdbrain",
        "wiki_uri": nil,
        "version_downloads": 2520,
        "info": "This Ruby library allows students to use Ruby to read sensors and set motors and LEDs with the Birdbrain Technologies Hummingbird Bit and Finch 2. To use Ruby with the Hummingbird Bit or Finch 2, you must connect via bluetooth with the BlueBird Connector.",
        "authors": "fmorton"
      })
    end

    it "completes search" do
      expect(Gemview::Terminal)
        .to receive(:choose)
        .with(
          message: "What gem would you like to look at?",
          choices: hash_including(birdbrain_selector => birdbrain_gem)
        )
        .and_yield(birdbrain_gem)

      expect(Gemview::Terminal)
        .to receive(:choose)
        .with(
          message: match_snapshot("birdbrain-gem-header"),
          choices: %w[Readme Changelog Dependencies Versions]
        )

      VCR.use_cassette("search-for-bluetooth") do
        VCR.use_cassette("find-birdbrain-gem") do
          described_class.start(arguments: %w[search bluetooth])
        end
      end
    end
  end

  describe "author" do
    let(:rubocop_selector) do
      "rubocop [1.69.1]\n  -- RuboCop is a Ruby code style checking and code formatting tool. It aims t…\n"
    end
    let(:rubocop_gem) do
      Gemview::Gem.new({
        "name": "rubocop",
        "downloads": 480421146,
        "version": "1.69.1",
        "version_created_at": "2024-12-03T09:03:08.778Z",
        "version_downloads": 279434,
        "platform": "ruby",
        "authors": "Bozhidar Batsov, Jonas Arvidsson, Yuji Nakayama",
        "info": "RuboCop is a Ruby code style checking and code formatting tool.\nIt aims to enforce the community-driven Ruby Style Guide.\n",
        "licenses": [
          "MIT"
        ],
        "metadata": {
          "homepage_uri": "https://rubocop.org/",
          "changelog_uri": "https://github.com/rubocop/rubocop/releases/tag/v1.69.1",
          "bug_tracker_uri": "https://github.com/rubocop/rubocop/issues",
          "source_code_uri": "https://github.com/rubocop/rubocop/",
          "documentation_uri": "https://docs.rubocop.org/rubocop/1.69/",
          "rubygems_mfa_required": "true"
        },
        "yanked": false,
        "sha": "339d1b884f5c86be9c70a24c635988679f129996d14048e9ffcde8924a14a2e8",
        "spec_sha": "a27328f4627ae89eece81606e32c6fe05098bb16472e23bb5cffdeb39ab3c21e",
        "project_uri": "https://rubygems.org/gems/rubocop",
        "gem_uri": "https://rubygems.org/gems/rubocop-1.69.1.gem",
        "homepage_uri": "https://rubocop.org/",
        "wiki_uri": nil,
        "documentation_uri": "https://docs.rubocop.org/rubocop/1.69/",
        "mailing_list_uri": nil,
        "source_code_uri": "https://github.com/rubocop/rubocop/",
        "bug_tracker_uri": "https://github.com/rubocop/rubocop/issues",
        "changelog_uri": "https://github.com/rubocop/rubocop/releases/tag/v1.69.1",
        "funding_uri": nil,
        "dependencies": {
          "development": [],
          "runtime": [
            {
              "name": "json",
              "requirements": "~> 2.3"
            },
            {
              "name": "language_server-protocol",
              "requirements": ">= 3.17.0"
            },
            {
              "name": "parallel",
              "requirements": "~> 1.10"
            },
            {
              "name": "parser",
              "requirements": ">= 3.3.0.2"
            },
            {
              "name": "rainbow",
              "requirements": ">= 2.2.2, < 4.0"
            },
            {
              "name": "regexp_parser",
              "requirements": ">= 2.9.3, < 3.0"
            },
            {
              "name": "rubocop-ast",
              "requirements": ">= 1.36.2, < 2.0"
            },
            {
              "name": "ruby-progressbar",
              "requirements": "~> 1.7"
            },
            {
              "name": "unicode-display_width",
              "requirements": ">= 2.4.0, < 4.0"
            }
          ]
        }
      })
    end

    it "shows gems for an author" do
      expect(Gemview::Terminal)
        .to receive(:choose)
        .with(
          message: "What gem would you like to look at?",
          choices: hash_including(rubocop_selector => rubocop_gem)
        )
        .and_yield(rubocop_gem)

      expect(Gemview::Terminal)
        .to receive(:choose)
        .with(
          message: match_snapshot("rubocop-gem-header"),
          choices: %w[Readme Changelog Dependencies Versions]
        )

      VCR.use_cassette("gems-by-author-bbatsov") do
        described_class.start(arguments: %w[author bbatsov])
      end
    end
  end

  describe "releases" do
    it "shows recently released gems" do
      expect(Gemview::Terminal)
        .to receive(:choose)
        .with(
          message: "What gem would you like to look at?",
          choices: an_instance_of(Hash)
        )

      VCR.use_cassette("latest-gems") do
        described_class.start(arguments: %w[releases])
      end
    end
  end

  describe "updates" do
    it "shows recently updated gems" do
      expect(Gemview::Terminal)
        .to receive(:choose)
        .with(
          message: "What gem would you like to look at?",
          choices: an_instance_of(Hash)
        )

      VCR.use_cassette("just-updated-gems") do
        described_class.start(arguments: %w[updates])
      end
    end
  end

  describe "version" do
    it "prints the expected version" do
      expect { described_class.start(arguments: %w[version]) }
        .to output("#{Gemview::VERSION}\n").to_stdout
        .and not_output.to_stderr
    end
  end
end
