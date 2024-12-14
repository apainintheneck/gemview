# frozen_string_literal: true

require "dry/cli"

module Gemview
  module Commands
    extend Dry::CLI::Registry

    class Info < Dry::CLI::Command
      desc "Show gem info"

      argument :name, type: :string, required: true, desc: "Gem name"

      option :version, type: :string, desc: "Gem version"

      example %w[rubocop bundler]

      def call(name:, version: nil, **)
        begin
          gem = Gem.find(name: name, version: version)
        rescue Gems::NotFound
          if version
            warn("Error: No gem found with the name '#{name}' and the version '#{version}'")
            exit(1) unless Terminal.confirm(question: "Search for the most recent version?")
            begin
              gem = Gem.find(name: name, version: nil)
            rescue Gems::NotFound
              abort("Error: No gem found with the name: #{name}")
            end
          else
            abort("Error: No gem found with the name: #{name}")
          end
        end
        View.info(gem: gem)
      end
    end

    class Search < Dry::CLI::Command
      desc "Search for gems"

      argument :term, type: :string, required: true, desc: "Search term"

      option :downloads, values: %w[total version], desc: "Sort results by most downloads"

      example ["cli", "json --downloads=total"]

      def call(term:, downloads: nil, **)
        gems = Gem.search(term: term)

        if gems.empty?
          abort("Error: No gems found for the search term: #{term}")
        end

        case downloads
        when "total"
          gems.sort_by! { |gem| -gem.downloads }
        when "version"
          gems.sort_by! { |gem| -gem.version_downloads }
        end

        View.list(gems: gems)
      end
    end

    class Author < Dry::CLI::Command
      desc "Find gems by rubygems.org username"

      argument :username, type: :string, required: true, desc: "rubygems.org username"

      def call(username:, **)
        gems = Gem.author(username: username)

        if gems.empty?
          abort("Error: No gems found for the rubygems.org username: #{username}")
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
    register "author", Author
    register "releases", Releases
    register "updates", Updates
    register "version", Version

    # @param arguments [Array<String>] defaults to ARGV
    def self.start(arguments: ARGV)
      Dry::CLI.new(self).call(arguments: arguments)
    end
  end
end
