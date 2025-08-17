# frozen_string_literal: true"

module Gemview
  class Gem
    attr_reader(
      :name,
      :downloads,
      :version,
      :version_downloads,
      :version_created_at,
      :authors,
      :info,
      :licenses,
      :project_uri,
      :homepage_uri,
      :source_code_uri,
      :changelog_uri,
      :development_dependencies,
      :runtime_dependencies
    )

    # @param options [Hash]
    def initialize(options)
      @name = options.fetch("name")
      @downloads = options.fetch("downloads")
      @version = options.fetch("version")
      @version_downloads = options.fetch("version_downloads")
      # Note: This is not returned by `Gems.search`.
      @version_created_at = options["version_created_at"]
        &.then { |time| Time.parse(time) }
      @authors = options.fetch("authors")
      @info = options.fetch("info")
      # Note: This is occasionally nil so a default value is required.
      @licenses = (options.fetch("licenses") || []).freeze
      @project_uri = options.fetch("project_uri")
      @homepage_uri = options.fetch("homepage_uri")
      @source_code_uri = options.fetch("source_code_uri")
      @changelog_uri = options.fetch("changelog_uri")
      # Note: Dependencies are not returned by `Gems.search`.
      @development_dependencies = options
        .dig("dependencies", "development")
        &.map { |hash| Dependency.new(hash).freeze }
        &.freeze
      @runtime_dependencies = options
        .dig("dependencies", "runtime")
        &.map { |hash| Dependency.new(hash).freeze }
        &.freeze
    end

    class Dependency
      attr_reader :name, :requirements

      # @param options [Hash]
      def initialize(options)
        @name = options.fetch("name")
        @requirements = options.fetch("requirements")
      end

      def to_str
        %(gem "#{name}", "#{requirements}")
      end
    end

    class Version
      attr_reader :version, :downloads, :release_date, :ruby_version

      # @param options [Hash]
      def initialize(options)
        @version = options.fetch("number")
        @downloads = options.fetch("downloads_count")
        @release_date = Date.parse(options.fetch("created_at"))
        @ruby_version = options.fetch("ruby_version") || "(unknown)"
      end
    end

    # Ex. 1234567890 -> "1,234,567,890"
    # @return [String]
    def humanized_downloads
      Number.humanized_integer(downloads)
    end

    # @return [String]
    def selector_str
      one_line_info = info.lines.map(&:strip).reject(&:empty?).join(" ").strip

      <<~SELECT
        #{name} [#{version}]
          -- #{Strings.truncate(one_line_info, 75)}
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

    # @return [Boolean]
    def dependencies?
      !runtime_dependencies.nil? && !development_dependencies.nil?
    end

    # @return [String]
    def dependencies_str
      runtime_deps_str = runtime_dependencies.join("\n").strip
      runtime_deps_str = if runtime_deps_str.empty?
        "(none)"
      else
        "```rb\n#{runtime_deps_str}\n```"
      end

      dev_deps_str = development_dependencies.join("\n").strip
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

    # @return [String]
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

    # @return [Gemview::GitRepo, nil]
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

    # @return [Boolean]
    def readme? = git_repo? && git_repo.readme?

    # @return [String, nil]
    def readme = git_repo&.readme

    # @return [Boolean]
    def changelog? = git_repo? && git_repo.changelog?

    # @return [String, nil]
    def changelog = git_repo&.changelog

    # @param name [String]
    # @param version [String, nil] will default to latest if not provided
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
      Client.v1.search(term).map { |gem_hash| new(gem_hash) }
    end

    # @param username [String] rubygems.org username
    # @return [Array<Gemview::Gem>]
    def self.author(username:)
      Client.v1.gems(username).map { |gem_hash| new(gem_hash) }
    end

    # @return [Array<Gemview::Gem>]
    def self.latest
      Client.v1.latest.map { |gem_hash| new(gem_hash) }
    end

    # @return [Array<Gemview::Gem>]
    def self.just_updated
      Client.v1.just_updated.map { |gem_hash| new(gem_hash) }
    end

    # @param name [String] gem name
    # @return [Array<Gemview::Gem::Version>]
    def self.versions(name:)
      @versions ||= {}
      @versions[name] ||= Client.v1.versions(name).map { |gem_hash| Version.new(gem_hash).freeze }.freeze
    end
  end
end
