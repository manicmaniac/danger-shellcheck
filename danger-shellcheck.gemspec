# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shellcheck/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'danger-shellcheck'
  spec.version       = Shellcheck::VERSION
  spec.authors       = ['David Brooks']
  spec.email         = ['dbrooks@intrepid.io']
  spec.description   = 'Show formatted static analysis report in your PRs for shell scripts'
  spec.summary       = 'A [Danger](https://danger.systems) plugin that shows ' \
                        'warnings and errors generated from the ShellCheck ' \
                        'static analysis tool for shell scripts.'
  spec.homepage      = 'https://github.com/IntrepidPursuits/danger-shellcheck'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'danger-plugin-api', '~> 1.0'
end
