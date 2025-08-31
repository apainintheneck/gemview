# frozen_string_literal: true

require_relative "gemview/version"

module Gemview
  class Error < StandardError; end

  # Internal
  autoload :Client, "gemview/client"
  autoload :Commands, "gemview/commands"
  autoload :Gem, "gemview/gem"
  autoload :GitRepo, "gemview/git_repo"
  autoload :Number, "gemview/number"
  autoload :Terminal, "gemview/terminal"
  autoload :View, "gemview/view"
end

# External
autoload :Gems, "gems"
autoload :Strings, "strings"

module TTY
  autoload :Markdown, "tty-markdown"
  autoload :Pager, "tty-pager"
  autoload :Prompt, "tty-prompt"
end
