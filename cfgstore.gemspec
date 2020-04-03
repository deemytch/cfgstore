Gem::Specification.new do |lib|
  lib.name          = 'cfgstore'
  lib.version       = '2.2.0'
  lib.date          = '2020-04-03'
  lib.description   = 'Loads from yaml, determines defaults and serves settings for the small program.'
  lib.summary       = 'Loads and serves configs.'
  lib.files         = Dir[ 'lib/*.rb' ]
  lib.require_paths = %w[lib]
  lib.author        = 'deemytch'
  lib.email         = 'aspamkiller@yandex.ru'
  lib.license       = 'GPL-2.0'

  lib.add_runtime_dependency 'hashie'
  lib.add_runtime_dependency 'monkey-hash'
end
