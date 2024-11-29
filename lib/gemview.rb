# frozen_string_literal: true

require_relative "gemview/version"

module Gemview
  class Error < StandardError; end
  
  autoload :Commands, "gemview/commands"
  autoload :Gem, "gemview/gem"
  autoload :GitRepo, "gemview/git_repo"
  autoload :Terminal, "gemview/terminal"
  autoload :Version, "gemview/version"
  autoload :View, "gemview/view"
end
