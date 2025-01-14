# frozen_string_literal: true

module Gemview
  class GitRepo
    HOSTS = [
      GITHUB = :github,
      GITLAB = :gitlab,
      CODEBERG = :codeberg
    ].freeze

    HTTPS_PORT = 443

    # @param homepage_uri [String, nil]
    # @param source_code_uri [String, nil]
    # @param changelog_uri [String, nil]
    # @param version [String]
    # @return [Gemview::GitRepo, nil]
    def self.from_urls(homepage_uri:, source_code_uri:, changelog_uri:, version:)
      [homepage_uri, source_code_uri, changelog_uri].compact.each do |uri|
        base_uri, git_host = parse_base_uri(uri)
        if base_uri && git_host
          return new(
            base_uri: base_uri,
            changelog_uri: changelog_uri,
            git_host: git_host,
            version: version
          )
        end
      end
      nil
    end

    # @param [String]
    # @return [base_uri as `String` and git_host as `Symbol`] or nil if unsuccessful
    def self.parse_base_uri(uri)
      github_base_uri = uri[%r{^https?://github\.com/[^/]+/[^/]+}, 0]
      return [github_base_uri, GITHUB] if github_base_uri

      gitlab_base_uri = uri[%r{^https?://gitlab\.com/[^/]+/[^/]+}, 0]
      return [gitlab_base_uri, GITLAB] if gitlab_base_uri

      codeberg_base_uri = uri[%r{^https?://codeberg\.org/[^/]+/[^/]+}, 0]
      [codeberg_base_uri, CODEBERG] if codeberg_base_uri
    end

    private_class_method :new

    attr_reader :base_uri, :changelog_uri, :git_host, :version

    # @param base_uri [String] base Git repo uri for `HOSTS`
    # @param changelog_uri [String, nil] from the gem metadata
    # @param git_host [Symbol] from `HOSTS`
    # @param version [String]
    def initialize(base_uri:, changelog_uri:, git_host:, version:)
      raise ArgumentError, "Invalid host: #{git_host}" unless HOSTS.include?(git_host)

      @base_uri = base_uri.dup.freeze
      @changelog_uri = changelog_uri.dup.freeze
      @git_host = git_host
      @version = version.dup.freeze
    end

    # @return [Boolean]
    def readme? = !defined?(@readme) || !readme.nil?

    # @return [String, nil]
    def readme
      return @readme if defined?(@readme)

      @readme = fetch_raw_file("README.md")
    end

    # @return [Boolean]
    def changelog? = !defined?(@changelog) || !changelog.nil?

    # @return [String, nil]
    def changelog
      return @changelog if defined?(@changelog)

      filenames = [changelog_filename, "CHANGELOG.md"].compact.uniq
      filenames.each do |filename|
        break if (@changelog = fetch_raw_file(filename))
      end

      @changelog
    end

    private

    def changelog_filename
      return unless @changelog_uri&.end_with?(".md")

      changelog_base_uri, changelog_git_host = self.class.parse_base_uri(@changelog_uri)
      return if changelog_base_uri != base_uri
      return if changelog_git_host != git_host

      @changelog_uri.split("/").last
    end

    # @param filename [String]
    # @return [String, nil]
    def fetch_raw_file(filename)
      case @git_host
      when GITHUB then github_raw_file(filename)
      when GITLAB then gitlab_raw_file(filename)
      when CODEBERG then codeberg_raw_file(filename)
      end
    end

    # @param filename [String]
    # @return [String, nil]
    def github_raw_file(filename)
      # From: `https://github.com/charmbracelet/bubbles`
      # To: `https://raw.githubusercontent.com/charmbracelet/bubbles/refs/tags/v0.20.0/README.md`
      path = @base_uri.sub(%r{^https?://github\.com}, "")

      fetch_markdown(
        host: "raw.githubusercontent.com",
        tag_paths: [
          "#{path}/refs/tags/v#{@version}/#{filename}",
          "#{path}/refs/tags/#{@version}/#{filename}"
        ],
        head_paths: [
          "#{path}/refs/heads/main/#{filename}",
          "#{path}/refs/heads/master/#{filename}"
        ]
      )
    end

    # @param filename [String]
    # @return [String, nil]
    def gitlab_raw_file(filename)
      # From: `https://gitlab.com/gitlab-org/gitlab`
      # To: `https://gitlab.com/gitlab-org/gitlab/-/raw/v17.5.1-ee/README.md`
      path = @base_uri.sub(%r{^https?://gitlab\.com}, "")

      fetch_markdown(
        host: "gitlab.com",
        tag_paths: [
          "#{path}/-/raw/v#{@version}/#{filename}",
          "#{path}/-/raw/#{@version}/#{filename}"
        ],
        head_paths: [
          "#{path}/-/raw/main/#{filename}",
          "#{path}/-/raw/master/#{filename}"
        ]
      )
    end

    # @param filename [String]
    # @return [String, nil]
    def codeberg_raw_file(filename)
      # From: `https://codeberg.org/bendangelo/wiktionary_api`
      # To: `https://codeberg.org/bendangelo/wiktionary_api/raw/tag/v0.1.1/README.md`
      path = @base_uri.sub(%r{^https?://codeberg\.org}, "")

      fetch_markdown(
        host: "codeberg.org",
        tag_paths: [
          "#{path}/raw/tag/v#{@version}/#{filename}",
          "#{path}/raw/tag/#{@version}/#{filename}"
        ],
        head_paths: [
          "#{path}/raw/branch/main/#{filename}",
          "#{path}/raw/branch/master/#{filename}"
        ]
      )
    end

    # @param host [String]
    # @param tag_paths [Array<String>]
    # @param head_paths [Array<String>]
    # @return [String, nil]
    def fetch_markdown(host:, tag_paths:, head_paths:)
      body = nil

      Net::HTTP.start(host, HTTPS_PORT, use_ssl: true, open_timeout: 2, read_timeout: 2) do |http|
        tag_paths.each do |path|
          response = http.get(path)
          if response.is_a?(Net::HTTPSuccess)
            body = response.body.force_encoding("UTF-8")
            break
          end
        end

        unless body
          head_paths.each do |path|
            response = http.get(path)
            if response.is_a?(Net::HTTPSuccess)
              body = <<~BODY
                *FYI*: This was fetched from the HEAD branch of the Git repository.

                #{response.body.force_encoding("UTF-8")}
              BODY
              break
            end
          end
        end
      end

      Terminal.prettify_markdown(body) if body
    rescue Net::OpenTimeout, Net::ReadTimeout
      nil # this is best effort so we silence network errors here
    end
  end
end
