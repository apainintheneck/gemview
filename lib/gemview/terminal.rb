# frozen_string_literal: true

module Gemview
  module Terminal
    # @param content [String]
    def self.page(content)
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

    TTY_COLOR = ENV["NO_COLOR"] ? :never : :auto
    TTY_WIDTH = 80
    private_constant :TTY_COLOR, :TTY_WIDTH

    # A best effort attempt to format and highlight markdown text.
    # If it's unsuccessful, it will return the original text.
    #
    # @param text [String]
    # @return [String]
    def self.prettify_markdown(text)
      TTY::Markdown.parse(text, color: TTY_COLOR, width: TTY_WIDTH)
    rescue # Return the raw markdown if parsing fails
      text
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
        @prompt = TTY::Prompt.new(
          quiet: true,
          track_history: false,
          interrupt: :exit,
          symbols: {marker: ">"},
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
