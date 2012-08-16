# -*- encoding: utf-8 -*-
require File.expand_path('../lib/eq/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jens Bissinger"]
  gem.email         = ["mail@jens-bissinger.de"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "eq"
  gem.require_paths = ["lib"]
  gem.version       = EQ::VERSION

  gem.add_dependency "sqlite3"
  gem.add_dependency "sequel"
  gem.add_dependency "celluloid"
  gem.add_development_dependency "guard"
  gem.add_development_dependency "guard-rspec"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rake"
end
