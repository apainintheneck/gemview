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

    it "falls back to current version" do
      expect(Gemview::Terminal)
        .to receive(:confirm)
        .with(question: "Search for the most recent version?")
        .and_return(true)

      expect(Gemview::Terminal)
        .to receive(:choose)
        .with(
          message: match_snapshot("rails-gem-header"),
          choices: %w[Readme Changelog Dependencies Versions]
        )

      VCR.use_cassette("find-rails-gem") do
        VCR.use_cassette("find-invalid-rails-gem") do
          expect { described_class.start(arguments: %w[info rails --version 250.0.1]) }
            .to output("Error: No gem found with the name 'rails' and the version '250.0.1'\n").to_stderr
            .and not_output.to_stdout
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
        documentation_uri: nil,
        metadata: {
          homepage_uri: "https://github.com/fmorton/BirdBrain-Ruby-Library",
          allowed_push_host: "https://rubygems.org",
          changelog_uri: "https://github.com/fmorton/BirdBrain-Ruby-Library/CHANGELOG.md",
          source_code_uri: "https://github.com/fmorton/BirdBrain-Ruby-Library"
        },
        homepage_uri: "https://github.com/fmorton/BirdBrain-Ruby-Library",
        funding_uri: nil,
        bug_tracker_uri: nil,
        project_uri: "https://rubygems.org/gems/birdbrain",
        version: "0.9.6",
        sha: "c5bdeae5072c0c4e80acbd6c06d4242ef299a22d8254d458ecc6cff89cf05a21",
        platform: "ruby",
        changelog_uri: "https://github.com/fmorton/BirdBrain-Ruby-Library/CHANGELOG.md",
        source_code_uri: "https://github.com/fmorton/BirdBrain-Ruby-Library",
        licenses: [
          "MIT"
        ],
        gem_uri: "https://rubygems.org/gems/birdbrain-0.9.6.gem",
        downloads: 13313,
        mailing_list_uri: nil,
        name: "birdbrain",
        wiki_uri: nil,
        version_downloads: 2520,
        info: "This Ruby library allows students to use Ruby to read sensors and set motors and LEDs with the Birdbrain Technologies Hummingbird Bit and Finch 2. To use Ruby with the Hummingbird Bit or Finch 2, you must connect via bluetooth with the BlueBird Connector.",
        authors: "fmorton"
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
        name: "rubocop",
        downloads: 480421146,
        version: "1.69.1",
        version_created_at: "2024-12-03T09:03:08.778Z",
        version_downloads: 279434,
        platform: "ruby",
        authors: "Bozhidar Batsov, Jonas Arvidsson, Yuji Nakayama",
        info: "RuboCop is a Ruby code style checking and code formatting tool.\nIt aims to enforce the community-driven Ruby Style Guide.\n",
        licenses: [
          "MIT"
        ],
        metadata: {
          homepage_uri: "https://rubocop.org/",
          changelog_uri: "https://github.com/rubocop/rubocop/releases/tag/v1.69.1",
          bug_tracker_uri: "https://github.com/rubocop/rubocop/issues",
          source_code_uri: "https://github.com/rubocop/rubocop/",
          documentation_uri: "https://docs.rubocop.org/rubocop/1.69/",
          rubygems_mfa_required: "true"
        },
        yanked: false,
        sha: "339d1b884f5c86be9c70a24c635988679f129996d14048e9ffcde8924a14a2e8",
        spec_sha: "a27328f4627ae89eece81606e32c6fe05098bb16472e23bb5cffdeb39ab3c21e",
        project_uri: "https://rubygems.org/gems/rubocop",
        gem_uri: "https://rubygems.org/gems/rubocop-1.69.1.gem",
        homepage_uri: "https://rubocop.org/",
        wiki_uri: nil,
        documentation_uri: "https://docs.rubocop.org/rubocop/1.69/",
        mailing_list_uri: nil,
        source_code_uri: "https://github.com/rubocop/rubocop/",
        bug_tracker_uri: "https://github.com/rubocop/rubocop/issues",
        changelog_uri: "https://github.com/rubocop/rubocop/releases/tag/v1.69.1",
        funding_uri: nil,
        dependencies: {
          development: [],
          runtime: [
            {
              name: "json",
              requirements: "~> 2.3"
            },
            {
              name: "language_server-protocol",
              requirements: ">= 3.17.0"
            },
            {
              name: "parallel",
              requirements: "~> 1.10"
            },
            {
              name: "parser",
              requirements: ">= 3.3.0.2"
            },
            {
              name: "rainbow",
              requirements: ">= 2.2.2, < 4.0"
            },
            {
              name: "regexp_parser",
              requirements: ">= 2.9.3, < 3.0"
            },
            {
              name: "rubocop-ast",
              requirements: ">= 1.36.2, < 2.0"
            },
            {
              name: "ruby-progressbar",
              requirements: "~> 1.7"
            },
            {
              name: "unicode-display_width",
              requirements: ">= 2.4.0, < 4.0"
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
    let(:builder_rails_cache_selector) do
      "builder-rails_cache [0.1.1]\n  -- Provides convenience method `with_cache` for caching API response JSON\n"
    end
    let(:builder_rails_cache_gem) do
      Gemview::Gem.new({
        name: "builder-rails_cache",
        downloads: 50,
        version: "0.1.1",
        version_created_at: "2024-11-30T22:19:13.595Z",
        version_downloads: 50,
        platform: "ruby",
        authors: "Alistair Davidson",
        info: "Provides convenience method `with_cache` for caching API response JSON",
        licenses: [],
        metadata: {
          homepage_uri: "https://gitlab.builder.ai/cte/alistair-davidson/builder-rails_cache",
          source_code_uri: "https://gitlab.builder.ai/cte/alistair-davidson/builder-rails_cache"
        },
        yanked: false,
        sha: "eef4c18cc4b28a496a3943ee09a53e4b2d2aff0dd08f7138949688578fcd300f",
        spec_sha: "b57f7c271e696e5bb083b90371624ea11f8d269298fd0e6c6a44b509356c2e12",
        project_uri: "https://rubygems.org/gems/builder-rails_cache",
        gem_uri: "https://rubygems.org/gems/builder-rails_cache-0.1.1.gem",
        homepage_uri: "https://gitlab.builder.ai/cte/alistair-davidson/builder-rails_cache",
        wiki_uri: nil,
        documentation_uri: nil,
        mailing_list_uri: nil,
        source_code_uri: "https://gitlab.builder.ai/cte/alistair-davidson/builder-rails_cache",
        bug_tracker_uri: nil,
        changelog_uri: nil,
        funding_uri: nil,
        dependencies: {
          development: [
            {
              name: "byebug",
              requirements: ">= 0"
            }
          ],
          runtime: [
            {
              name: "rails",
              requirements: ">= 4.0"
            }
          ]
        }
      })
    end

    it "shows recently released gems" do
      expect(Gemview::Terminal)
        .to receive(:choose)
        .with(
          message: "What gem would you like to look at?",
          choices: hash_including(builder_rails_cache_selector => builder_rails_cache_gem)
        )
        .and_yield(builder_rails_cache_gem)

      expect(Gemview::Terminal)
        .to receive(:choose)
        .with(
          message: match_snapshot("builder-rails-cache-gem-header"),
          choices: %w[Readme Changelog Dependencies Versions]
        )

      VCR.use_cassette("latest-gems") do
        described_class.start(arguments: %w[releases])
      end
    end
  end

  describe "updates" do
    let(:active_model_serializers_selector) do
      "active_model_serializers [0.10.15]\n  -- ActiveModel::Serializers allows you to generate your JSON in an object-or…\n"
    end
    let(:active_model_serializers_gem) do
      Gemview::Gem.new({
        name: "active_model_serializers",
        downloads: 102108393,
        version: "0.10.15",
        version_created_at: "2024-12-01T00:56:35.774Z",
        version_downloads: 0,
        platform: "ruby",
        authors: "Steve Klabnik",
        info: "ActiveModel::Serializers allows you to generate your JSON in an object-oriented and convention-driven manner.",
        licenses: [
          "MIT"
        ],
        metadata: {},
        yanked: false,
        sha: "08275b2083ab4e8304279d838b99af546878e0d879a8154f731b0d16cb8b0c4c",
        spec_sha: "22257af7785b8761544ead058b23bdbb19f96d998121a153ee986cfc44178a13",
        project_uri: "https://rubygems.org/gems/active_model_serializers",
        gem_uri: "https://rubygems.org/gems/active_model_serializers-0.10.15.gem",
        homepage_uri: "https://github.com/rails-api/active_model_serializers",
        wiki_uri: "",
        documentation_uri: "http://rubydoc.info/gems/active_model_serializers",
        mailing_list_uri: "https://groups.google.com/forum/#!forum/rails-api-core",
        source_code_uri: "http://github.com/rails-api/active_model_serializers",
        bug_tracker_uri: "http://github.com/rails-api/active_model_serializers/issues",
        changelog_uri: nil,
        funding_uri: nil,
        dependencies: {
          development: [
            {
              name: "activerecord",
              requirements: ">= 4.1"
            },
            {
              name: "bundler",
              requirements: ">= 0"
            },
            {
              name: "grape",
              requirements: ">= 0.13"
            },
            {
              name: "json_schema",
              requirements: ">= 0"
            },
            {
              name: "kaminari",
              requirements: "~> 0.16.3"
            },
            {
              name: "minitest",
              requirements: "~> 5.0, < 5.11"
            },
            {
              name: "railties",
              requirements: ">= 4.1"
            },
            {
              name: "rake",
              requirements: ">= 10.0"
            },
            {
              name: "timecop",
              requirements: "~> 0.7"
            },
            {
              name: "will_paginate",
              requirements: "~> 3.0, >= 3.0.7"
            }
          ],
          runtime: [
            {
              name: "actionpack",
              requirements: ">= 4.1"
            },
            {
              name: "activemodel",
              requirements: ">= 4.1"
            },
            {
              name: "case_transform",
              requirements: ">= 0.2"
            },
            {
              name: "jsonapi-renderer",
              requirements: ">= 0.1.1.beta1, < 0.3"
            }
          ]
        }
      })
    end

    it "shows recently updated gems" do
      expect(Gemview::Terminal)
        .to receive(:choose)
        .with(
          message: "What gem would you like to look at?",
          choices: hash_including(active_model_serializers_selector => active_model_serializers_gem)
        )
        .and_yield(active_model_serializers_gem)

      expect(Gemview::Terminal)
        .to receive(:choose)
        .with(
          message: match_snapshot("active-model-serializers-gem-header"),
          choices: %w[Readme Changelog Dependencies Versions]
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
