# frozen_string_literal: true

require "dry/cli"

module Gemview
  module Commands
    extend Dry::CLI::Registry

    class Info < Dry::CLI::Command
      desc "Show gem info"

      argument :name, type: :string, required: true, desc: "Gem name"

      example %w[rubocop bundler]

      def call(name:, **)
        gem = Gem.find(name: name, version: nil)
        View.info(gem: gem)
      rescue Gems::NotFound
        abort("Error: No gem found with the name: #{name}")
      end
    end

    class Search < Dry::CLI::Command
      desc "Search for gems"

      argument :term, type: :string, required: true, desc: "Search term"

      example %w[cli json]

      def call(term:, **)
        gems = Gem.search(term: term)

        if gems.empty?
          abort("Error: No gems found for the search term: #{term}")
        end

        View.list(gems: gems)
      end
    end

    class Releases < Dry::CLI::Command
      desc "List the most recent new gem releases"

      def call(**)
        gems = Gem.latest

        if gems.empty?
          abort("Error: Unable to retrieve latest gem list")
        end

        View.list(gems: gems)
      end
    end

    class Updates < Dry::CLI::Command
      desc "List the most recent gem updates"

      def call(**)
        gems = Gem.just_updated

        if gems.empty?
          abort("Error: Unable to retrieve latest gem list")
        end

        View.list(gems: gems)
      end
    end

    class Version < Dry::CLI::Command
      desc "Print version"

      def call(*)
        puts Gemview::VERSION
      end
    end

    register "info", Info
    register "search", Search
    register "releases", Releases
    register "updates", Updates
    register "version", Version, aliases: ["v", "-v", "--version"]

    def self.start
      Dry::CLI.new(self).call
    end
  end
end
