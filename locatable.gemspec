# frozen_string_literal: true

require_relative "lib/locatable/version"

Gem::Specification.new do |spec|
  spec.name = "locatable"
  spec.version = Locatable::VERSION
  spec.authors = ["simon"]
  spec.email = ["simonrmurcia@gmail.com"]

  spec.summary = "Location scopes for Active Record models."
  spec.description = "Location scopes for Active Record models backed by PostGIS."
  spec.homepage = "https://github.com/simon/locatable"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/simon/locatable"
  spec.metadata["changelog_uri"] = "https://github.com/simon/locatable/blob/main/CHANGELOG.md"

  spec.add_dependency "activerecord-postgis-adapter"
  spec.add_dependency "pg"
  spec.add_dependency "railties"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .github/ .standard.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.license = "MIT"

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
