# frozen_string_literal: true

module Gemview
  module View
    def self.info(gem:)
      gem = Gem.find(name: gem.name, version: gem.version) if gem.dependencies.nil?
      prompt = <<~PROMPT.chomp
        #{gem.header_str}
        More info:
      PROMPT

      Terminal.choose(prompt, %w[Readme Changelog Dependencies]) do |choice|
        case choice
        when "Readme"
          Terminal.page([gem.header_str, gem.fetch_readme].join("\n"))
        when "Changelog"
          Terminal.page([gem.header_str, gem.fetch_changelog].join("\n"))
        when "Dependencies"
          Terminal.page([gem.header_str, gem.dependencies_str].join("\n"))
        else
          raise ArgumentError, "Unknown choice: #{choice}"
        end
      end
    end

    def self.list(gems:)
      gems_by_description = gems.to_h do |gem|
        [gem.selector_str, gem]
      end

      Terminal.choose("What gem would you like to look at?", gems_by_description) do |gem|
        info(gem: gem)
      end
    end
  end
end
