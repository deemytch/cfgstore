Gem::Specification.new do |lib|
  lib.name = 'cfgstore'
  lib.version = '1.0.3'
  lib.date = '2019-12-04'
  lib.summary = 'Хранение настроек твоей программы.'

  lib.files = Dir[ 'lib/*.rb' ]
    lib.require_paths = %w[lib]
  lib.authors = [ 'deemytch' ]
  lib.email = 'aspamkiller@yandex.ru'
  lib.licenses    = ['GPL-2.0']

  lib.add_runtime_dependency 'hashie'
  lib.add_runtime_dependency 'monkey-hash'
end
