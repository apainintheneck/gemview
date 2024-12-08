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
  end

  describe "author" do
  end

  describe "releases" do
  end

  describe "updates" do
  end

  describe "version" do
    it "prints the expected version" do
      expect { described_class.start(arguments: %w[version]) }
        .to output("#{Gemview::VERSION}\n").to_stdout
        .and not_output.to_stderr
    end
  end
end
