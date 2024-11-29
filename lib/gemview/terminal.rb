# frozen_string_literal: true

module Gemview
  module Terminal
    # @param content [String]
    def self.page(content)
      require "tty-pager"
      TTY::Pager.page(content)
    end

    # @param prompt [String]
    # @param choices [Array<String>] where all choices are unique
    # @yield [String] yields until the user exits the prompt gracefully
    def self.choose(message, choices, per_page: 6)
      while (choice = selector.select(message, choices, per_page))
        yield choice
      end
    end

    # @return [Selector]
    def self.selector
      @selector ||= Selector.new
    end
    private_class_method :selector

    # Wrapper around `TTY::Prompt` that adds Vim keybindings and
    # the ability to gracefully exit the prompt.
    class Selector
      def initialize
        require "tty-prompt"
        @prompt = TTY::Prompt.new(
          quiet: true,
          track_history: false,
          interrupt: :exit,
          symbols: { marker: ">" },
          enable_color: !ENV["NO_COLOR"]
        )

        # Indicate user intention to exit
        @exit = false

        # vim keybindings
        @prompt.on(:keypress) do |event|
          case event.value
          when "j" # Move down
            @prompt.trigger(:keydown)
          when "k" # Move up
            @prompt.trigger(:keyup)
          when "h" # Move left
            @prompt.trigger(:keyleft)
          when "l" # Move right
            @prompt.trigger(:keyright)
          when "q" # Exit
            @exit = true
            @prompt.trigger(:keyenter)
          end
        end

        # Exit on escape
        @prompt.on(:keyescape) do
          @exit = true
          @prompt.trigger(:keyenter)
        end
      end

      # @param prompt [String]
      # @param choices [Array<String>] where all choices are unique
      # @param per_page [Integer] results per page
      # @return [String|nil]
      def select(message, choices, per_page)
        choice = @prompt.select(
          message,
          choices,
          per_page: per_page,
          help: "(Press Enter to select and Escape to leave)",
          show_help: :always
        )
        choice unless @exit
      ensure
        @exit = false
      end
    end
    private_constant :Selector
  end
end
