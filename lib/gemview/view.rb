# frozen_string_literal: true

module Gemview
  module View
    def self.info(gem:)
      gem = Gem.find(name: gem.name, version: gem.version) unless gem.dependencies?
      prompt = <<~PROMPT.chomp
        #{gem.header_str}
        More info:
      PROMPT

      choices_proc = proc do
        [
          {name: "Readme", disabled: gem.readme? ? nil : "(missing)"},
          {name: "Changelog", disabled: gem.changelog? ? nil : "(missing)"},
          "Dependencies",
          "Versions"
        ]
      end

      Terminal.clear_screen
      Terminal.choose(message: prompt, choices: choices_proc) do |choice|
        title = gem.title_str(subsection: choice)
        case choice
        when "Readme"
          Terminal.page([title, gem.readme].join("\n")) if gem.readme
        when "Changelog"
          Terminal.page([title, gem.changelog].join("\n")) if gem.changelog
        when "Dependencies"
          Terminal.page([title, gem.dependencies_str].join("\n"))
        when "Versions"
          Terminal.page([title, gem.versions_str].join("\n"))
        else
          raise ArgumentError, "Unknown choice: #{choice}"
        end
      end
    end

    def self.list(gems:)
      gems_by_description = gems.to_h do |gem|
        [gem.selector_str, gem]
      end

      Terminal.clear_screen
      Terminal.choose(message: "Choose a gem:", choices: gems_by_description.keys) do |description|
        info(gem: gems_by_description.fetch(description))
      end
    end
  end
end
