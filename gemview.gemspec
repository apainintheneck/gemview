# frozen_string_literal: true

require_relative "lib/gemview/version"

Gem::Specification.new do |spec|
  spec.name = "gemview"
  spec.version = Gemview::VERSION
  spec.authors = ["apainintheneck"]
  spec.email = ["apainintheneck@gmail.com"]

  spec.summary = "An unofficial CLI interface to browse rubygems.org"
  spec.description = <<~DESCRIPTION
    An unofficial CLI interface to browse rubygems.org. Search for gems by name, see which ones have been recently updated and look at their dependencies.
  DESCRIPTION
  spec.homepage = "https://github.com/apainintheneck/gemview"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/apainintheneck/gemview/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ assets/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Direct dependencies
  spec.add_dependency "dry-cli", "~> 1.2.0"
  spec.add_dependency "dry-struct", "~> 1.6.0"
  spec.add_dependency "gems", "~> 1.3.0"
  spec.add_dependency "strings", "~> 0.2.1"
  spec.add_dependency "tty-markdown", "~> 0.7.2"
  spec.add_dependency "tty-pager", "~> 0.14.0"
  spec.add_dependency "tty-prompt", "~> 0.23.1"

  # Transitive dependencies
  spec.add_dependency "zeitwerk", "< 2.7"
end
