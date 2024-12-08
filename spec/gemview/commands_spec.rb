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
    it "completes search" do
      expect(Gemview::Terminal)
        .to receive(:choose)
        .with(
          message: "What gem would you like to look at?",
          choices: an_instance_of(Hash)
        )

      VCR.use_cassette("search-for-bluetooth") do
        described_class.start(arguments: %w[search bluetooth])
      end
    end
  end

  describe "author" do
    it "shows gems for an author" do
      expect(Gemview::Terminal)
        .to receive(:choose)
        .with(
          message: "What gem would you like to look at?",
          choices: an_instance_of(Hash)
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
