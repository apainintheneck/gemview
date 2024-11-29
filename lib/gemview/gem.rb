# frozen_string_literal: true

require "dry-struct"
require "gems"
require "strings"

module Gemview
  class Gem < Dry::Struct
    module Types
      include Dry.Types()
    end

    transform_keys(&:to_sym)

    attribute :name, Types::Strict::String
    attribute :downloads, Types::Strict::Integer
    attribute :version, Types::Strict::String
    # Note: This is not returned by `Gems.search`.
    attribute? :version_created_at, Types::Params::Time
    attribute :authors, Types::Strict::String
    attribute :info, Types::Strict::String
    attribute :licenses, Types::Strict::Array.of(Types::Strict::String)
    attribute :project_uri, Types::Strict::String
    attribute :homepage_uri, Types::String.optional
    attribute :source_code_uri, Types::String.optional
    attribute :changelog_uri, Types::String.optional

    class Dependency < Dry::Struct
      transform_keys(&:to_sym)

      attribute :name, Types::Strict::String
      attribute :requirements, Types::Strict::String

      def to_str
        %{gem "#{name}", "#{requirements}"}
      end
    end

    # Note: This is not returned by `Gems.search`.
    attribute? :dependencies do
      attribute :development, Types::Strict::Array.of(Dependency)
      attribute :runtime, Types::Strict::Array.of(Dependency)
    end

    # Ex. 1234567890 -> "1,234,567,890"
    # @return [String]
    def humanized_downloads
      downloads
        .to_s
        .chars
        .reverse
        .each_slice(3)
        .map(&:join)
        .join(",")
        .reverse
    end

    # @return [String]
    def selector_str
      <<~SELECT
        #{name} [#{version}]
          -- #{Strings.truncate(info.lines.map(&:strip).join(" "), 75)}
      SELECT
    end

    # @return [String]
    def header_str
      <<~HEADER
        [#{version}] #{name}
        
        #{Strings.wrap(info, 80).chomp}

        +#{"-" * 78}+
        | Updated at       : #{version_created_at}
        | Total Downloads  : #{humanized_downloads}
        | Authors          : #{authors}
        | Licenses         : #{licenses}
        | Project URI      : #{project_uri}
        +#{"-" * 78}+
      HEADER
    end

    # @return [String]
    def dependencies_str
      runtime_deps_str = dependencies.runtime.map { _1.to_str.prepend("- ") }.join("\n")
      runtime_deps_str = "(none)" if runtime_deps_str.empty?
      dev_deps_str = dependencies.development.map { _1.to_str.prepend("- ") }.join("\n")
      dev_deps_str = "(none)" if dev_deps_str.empty?

      <<~DEPENDENCIES
        [Dependencies]

        Runtime Dependencies:
        #{runtime_deps_str}

        Development Dependencies:
        #{dev_deps_str}
      DEPENDENCIES
    end

    # @return [Array<String>]
    def urls
      [
        homepage_uri,
        source_code_uri,
        changelog_uri
      ].compact
    end

    # @return [String|nil]
    def fetch_readme
      GitRepo.from_urls(urls: urls, version: version)&.readme ||
        "Info: Unable to find a valid readme based on available gem info"
    end

    # @return [String|nil]
    def fetch_changelog
      GitRepo.from_urls(urls: urls, version: version)&.changelog ||
        "Info: Unable to find a valid changelog based on available gem info"
    end

    # @param name [String]
    # @param version [String|nil] will default to latest if not provided
    # @return [Gemview::Gem]
    def self.find(name:, version:)
      @find ||= {}
      @find[[name, version]] ||= begin
        new case version
        when String
          Gems::V2.info(name, version)
        else
          Gems.info(name)
        end
      end
    end

    # @param term [String] search term
    # @return [Array<Gemview::Gem>]
    def self.search(term:)
      Gems.search(term).map { |gem_hash| new gem_hash }
    end

    # @return [Array<Gemview::Gem>]
    def self.latest
      Gems.latest.map { |gem_hash| new gem_hash }
    end

    # @return [Array<Gemview::Gem>]
    def self.just_updated
      Gems.just_updated.map { |gem_hash| new gem_hash }
    end

    def self.clear
      @find = {}
      nil
    end
  end
end