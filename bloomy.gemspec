# frozen_string_literal: true

require_relative "lib/bloomy/version"

Gem::Specification.new do |spec|
  spec.name = "bloomy"
  spec.version = Bloomy::VERSION
  spec.authors = ["Franccesco Orozco"]
  spec.email = ["franccesco@thatai.dev"]

  spec.summary = "Manage your Bloom Growth account from the command line."
  spec.homepage = "https://github.com/franccesco/bloomy"
  spec.required_ruby_version = ">= 2.6.0"
  spec.licenses = ["Apache-2.0"]

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "faraday", "~> 2.9"
  spec.add_development_dependency "rspec", "~> 3.13"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
