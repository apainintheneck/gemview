# frozen_string_literal: true

require "net/http"

module Gemview
  class GitRepo
    HOSTS = [
      GITHUB = :github,
      GITLAB = :gitlab
    ].freeze

    # @param urls [Array<String>]
    # @param version [String]
    # @return [Gemview::GitRepo|nil]
    def self.from_urls(urls:, version:)
      @from_urls ||= {}
      base_url, git_host = nil
      
      urls.each do |url|
        base_url, git_host = parse_base_url(url)
        break if base_url && git_host
      end
      return unless base_url && git_host

      @from_urls[base_url] ||= new(base_url: base_url, git_host: git_host, version: version)
    end

    # @param [String]
    # @return [base_url as `String` and git_host as `Symbol`] or nil if unsuccessful
    def self.parse_base_url(url)
      github_base_url = url[%r{^https://github.com/[^/]+/[^/]+}, 0]
      return [github_base_url, GITHUB] if github_base_url

      gitlab_base_url = url[%r{^https://gitlab.com/[^/]+/[^/]+}, 0]
      return [gitlab_base_url, GITLAB] if gitlab_base_url
    end

    private_class_method :new, :parse_base_url

    def initialize(base_url:, git_host:, version:)
      raise ArgumentError, "Invalid host: #{git_host}" unless HOSTS.include?(git_host)

      @base_url = base_url
      @git_host = git_host
      @version = version
    end

    def readme
      return @readme if defined?(@readme)

      @readme = fetch_raw_file("README.md")
    end

    def changelog
      return @changelog if defined?(@changelog)

      @changelog = fetch_raw_file("CHANGELOG.md")
    end

    private

    def fetch_raw_file(filename)
      case @git_host
      when GITHUB then github_raw_file(filename)
      when GITLAB then gitlab_raw_file(filename)
      end
    end

    def github_raw_file(filename)
      # From: `https://github.com/charmbracelet/bubbles`
      # To: `https://raw.githubusercontent.com/charmbracelet/bubbles/refs/tags/v0.20.0/README.md`
      path = @base_url.delete_prefix("https://github.com")
      readme_url = "https://raw.githubusercontent.com#{path}/refs/tags/v#{@version}/#{filename}"
      fetch(readme_url)
    end

    def gitlab_raw_file(filename)
      # From: `https://gitlab.com/gitlab-org/gitlab`
      # To: `https://gitlab.com/gitlab-org/gitlab/-/raw/v17.5.1-ee/README.md?ref_type=tags&inline=false`
      readme_url = "#{@base_url}/-/raw/#{@version}/#{filename}?ref_type=tags&inline=false"
      fetch(readme_url)
    end

    def fetch(url)
      response = Net::HTTP.get_response(URI(url))
      response.body if response.is_a?(Net::HTTPSuccess)
    rescue Net::HTTPError
      nil
    end
  end
end
