# frozen_string_literal: true

require_relative "gemview/version"

module Gemview
  class Error < StandardError; end
  
  # Internal
  autoload :Commands, "gemview/commands"
  autoload :Gem, "gemview/gem"
  autoload :GitRepo, "gemview/git_repo"
  autoload :Terminal, "gemview/terminal"
  autoload :Version, "gemview/version"
  autoload :View, "gemview/view"
end

# External
autoload :Gems, "gems"
autoload :Strings, "strings"
module Net
  autoload :HTTP, "net/http"
end
module TTY
  autoload :Markdown, "tty-markdown"
  autoload :Pager, "tty-pager"
  autoload :Prompt, "tty-prompt"
end
