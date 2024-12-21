# frozen_string_literal: true

require "dry-struct"

module Gemview
  class Gem < Dry::Struct
    module Types
      include Dry.Types()
    end

    transform_keys(&:to_sym)

    # resolve default types on nil
    transform_types do |type|
      if type.default?
        type.constructor do |value|
          value.nil? ? Dry::Types::Undefined : value
        end
      else
        type
      end
    end

    attribute :name, Types::Strict::String
    attribute :downloads, Types::Strict::Integer
    attribute :version, Types::Strict::String
    attribute :version_downloads, Types::Strict::Integer
    # Note: This is not returned by `Gems.search`.
    attribute? :version_created_at, Types::Params::Time
    attribute :authors, Types::Strict::String
    attribute :info, Types::Strict::String
    # Note: This is occasionally nil so a default value is required.
    attribute :licenses, Types::Array.of(Types::Strict::String).default([].freeze)
    attribute :project_uri, Types::Strict::String
    attribute :homepage_uri, Types::String.optional
    attribute :source_code_uri, Types::String.optional
    attribute :changelog_uri, Types::String.optional

    class Dependency < Dry::Struct
      transform_keys(&:to_sym)

      attribute :name, Types::Strict::String
      attribute :requirements, Types::Strict::String

      def to_str
        %(gem "#{name}", "#{requirements}")
      end
    end

    # Note: This is not returned by `Gems.search`.
    attribute? :dependencies do
      attribute :development, Types::Strict::Array.of(Dependency)
      attribute :runtime, Types::Strict::Array.of(Dependency)
    end

    class Version < Dry::Struct
      transform_keys(&:to_sym)

      # resolve default types on nil
      transform_types do |type|
        if type.default?
          type.constructor do |value|
            value.nil? ? Dry::Types::Undefined : value
          end
        else
          type
        end
      end

      attribute :number, Types::Strict::String
      alias_method :version, :number

      attribute :downloads_count, Types::Strict::Integer
      alias_method :downloads, :downloads_count

      attribute :created_at, Types::Params::Time

      attribute :ruby_version, Types::String.optional.default("(unknown)")

      # @return [Date]
      def release_date = created_at.to_date
    end

    # Ex. 1234567890 -> "1,234,567,890"
    # @return [String]
    def humanized_downloads
      Number.humanized_integer(downloads)
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
      info_lines = Strings.wrap(info, 80).lines.map(&:strip)
      info_lines = info_lines.take(3).append("...") if info_lines.size > 3

      header = <<~HEADER
        ## [#{version}] #{name}
        
        ```
        #{info_lines.join("\n")}
        ```

        | Updated at       | #{version_created_at}  |
        | Total Downloads  | #{humanized_downloads} |
        | Authors          | #{authors}             |
        | Licenses         | #{licenses}            |
        | Project URI      | #{project_uri}         |
      HEADER

      Terminal.prettify_markdown(header)
    end

    # @return [String]
    def dependencies_str
      runtime_deps_str = dependencies.runtime.join("\n").strip
      runtime_deps_str = if runtime_deps_str.empty?
        "(none)"
      else
        "```rb\n#{runtime_deps_str}\n```"
      end

      dev_deps_str = dependencies.development.join("\n").strip
      dev_deps_str = if dev_deps_str.empty?
        "(none)"
      else
        "```rb\n#{dev_deps_str}\n```"
      end

      dependencies = <<~DEPENDENCIES
        ## [Dependencies]

        ### Runtime Dependencies:
        #{runtime_deps_str}

        ### Development Dependencies:
        #{dev_deps_str}
      DEPENDENCIES

      Terminal.prettify_markdown(dependencies)
    end

    def versions_str
      rows = self.class.versions(name: name).map do |version|
        pretty_downloads = Number.humanized_integer(version.downloads)
        "| #{version.release_date} | #{version.version} | #{pretty_downloads} | #{version.ruby_version}"
      end

      table = <<~TABLE
        ## [Versions]

        | *Release Date* | *Gem Version* | *Downloads* | *Ruby Version* |
        |----------------|---------------|-------------|----------------|
        #{rows.join("\n")}
      TABLE

      Terminal.prettify_markdown(table)
    end

    # @return [Gemview::GitRepo|nil]
    def git_repo
      return @git_repo if defined? @git_repo

      @git_repo = GitRepo.from_urls(
        homepage_uri: homepage_uri,
        source_code_uri: source_code_uri,
        changelog_uri: changelog_uri,
        version: version
      )
    end

    # @return [Boolean]
    def git_repo? = !git_repo.nil?

    # @return [String|nil]
    def fetch_readme
      git_repo&.readme || "Info: Unable to find a valid readme based on available gem info"
    end

    # @return [String|nil]
    def fetch_changelog
      git_repo&.changelog || "Info: Unable to find a valid changelog based on available gem info"
    end

    # @param name [String]
    # @param version [String|nil] will default to latest if not provided
    # @return [Gemview::Gem]
    def self.find(name:, version: nil)
      @find ||= {}
      @find[[name, version]] ||= new case version
                                 when String
                                   Client.v2.info(name, version)
                                 else
                                   Client.v1.info(name)
                                 end
    end

    # @param term [String] search term
    # @return [Array<Gemview::Gem>]
    def self.search(term:)
      Client.v1.search(term).map { |gem_hash| new gem_hash }
    end

    # @param username [String] rubygems.org username
    # @return [Array<Gemview::Gem>]
    def self.author(username:)
      Client.v1.gems(username).map { |gem_hash| new gem_hash }
    end

    # @return [Array<Gemview::Gem>]
    def self.latest
      Client.v1.latest.map { |gem_hash| new gem_hash }
    end

    # @return [Array<Gemview::Gem>]
    def self.just_updated
      Client.v1.just_updated.map { |gem_hash| new gem_hash }
    end

    # @param name [String] gem name
    # @return [Array<Gemview::Gem::Version>]
    def self.versions(name:)
      @versions ||= {}
      @versions[name] ||= Client.v1.versions(name).map { |gem_hash| Version.new gem_hash }
    end
  end
end
