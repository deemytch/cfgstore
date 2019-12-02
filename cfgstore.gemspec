Gem::Specification.new do |lib|
  lib.name = 'cfgstore'
  lib.version = '1.0.0'
  lib.date = '2019-11-31'
  lib.summary = 'Хранение настроек твоей программы.'

  lib.files = %w[
    lib/app-config.rb
  ]
  lib.require_paths = %w[lib]
  lib.authors = %w[
    'Dimitri Pekarovsky'
  ]
  lib.email = 'dimitri@pekarovsky.name'
  lib.licenses    = ['GPLv2']

  lib.add_runtime_dependency 'hashie'
  lib.add_runtime_dependency 'monkey-hash'
end
