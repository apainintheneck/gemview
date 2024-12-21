# frozen_string_literal: true

module Gemview
  module Terminal
    # Clears the screen using escape codes.
    def self.clear_screen
      print "\e[2J\e[f"
    end

    # @param question [String]
    # @return [Boolean]
    def self.confirm(question:)
      TTY::Prompt.new.yes?(question)
    end

    # @param content [String]
    def self.page(content)
      # Override the default pager so that it is top justified to match the choice menus.
      ENV["PAGER"] = "less -c -r +gg"
      TTY::Pager.page(content)
    end

    # @param prompt [String]
    # @param choices [Array<String, Hash>, Proc] where all choices are unique
    # @yield [String] yields until the user exits the prompt gracefully
    def self.choose(message:, choices:, per_page: 6)
      previous_choice = nil

      loop do
        choice_list = choices.is_a?(Proc) ? choices.call : choices
        choice = selector.select(message, choice_list, previous_choice, per_page)
        break unless choice

        yield (previous_choice = choice)
      end
    end

    TTY_COLOR = ENV["NO_COLOR"] ? :never : :auto
    private_constant :TTY_COLOR

    # A best effort attempt to format and highlight markdown text.
    # If it's unsuccessful, it will return the original text.
    #
    # @param text [String]
    # @return [String]
    def self.prettify_markdown(text)
      TTY::Markdown.parse(text, color: TTY_COLOR)
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
      # @param choices [Array<String, Hash>] where all choices are unique
      # @param previous_choice [String, nil] defaults to first element
      # @param per_page [Integer] results per page
      # @return [String, nil]
      def select(message, choices, previous_choice, per_page)
        previous_choice = nil if disabled_choice?(previous_choice, choices)

        choice = @prompt.select(
          message,
          choices,
          per_page: per_page,
          help: "(Press Enter to select and Escape to leave)",
          show_help: :always,
          default: previous_choice
        )

        choice unless @exit
      ensure
        @exit = false
      end

      private

      # @param choice [String, nil]
      # @param choices [Array<String, Hash>]
      # @return [Boolean]
      def disabled_choice?(choice, choices)
        choices.any? do |possible_choice|
          possible_choice in {name: ^choice, disabled: String}
        end
      end
    end
    private_constant :Selector
  end
end
