require 'yaml'
require 'singleton'
require 'pathname'
require 'monkey-hash'
require_relative 'settings-hash'

module App

  ##
  # Удобный прокси к SettingsHash
  # СДЕЛАТЬ: автоперезагрузку при изменении файла.

  module Config

    ##
    # Создаёт корневой словарь настроек.
    # Автоматически создаёт глобальную переменную Cfg.
    # Автоматически подгружает AMQP и HTTP роуты.

    module_function
    def init( approot: nil, configdir: 'config', filename: 'cfg', env: ( ENV['APP_ENV'] || 'development' ) )
      raise NoMethodError.new('Config already defined.') if defined?( ::Cfg )

      root     ||= Pathname( approot || Pathname( __FILE__ ).dirname ).expand_path.to_s
      env      ||= env.to_sym.freeze
      loglevel ||= Kernel.const_get("Logger::#{ ENV['LOG_LEVEL'].upcase }") rescue ( env == :production ? Logger::WARN : Logger::DEBUG )
      config   ||= SettingsHash.new
      # Все настройки приложения + роуты
      configfile = "#{ root }/#{ configdir }/#{ filename }.#{ env }.yml"
      amqp_routesfile = "#{ root }/#{ configdir }/amqp.#{ env }.yml"
      http_routesfile = "#{ root }/#{ configdir }/http.#{ env }.yml"

      # raise ArgumentError.new("Не найден #{ configfile }!") unless File.exist?( configfile )
      # raise ArgumentError.new("Не найден #{ amqp_routesfile }!") unless File.exist?( amqp_routesfile )
      # Кто первый встал, того и тапки.      
      Kernel.const_set('Cfg', config)
      config.merge!( YAML.load_file( configfile ).symbolize_keys ) rescue nil
      $0 += "[ #{ config.app.id } ]" if config.app && config.app.id
      config.app.id  ||= $0
      config.app.log ||= ENV['APP_LOG']

      config.merge!({
        root: root,
        env:  env,
        loglevel: loglevel,
        amqproutes: File.exist?( amqp_routesfile ) ? YAML.load_file( amqp_routesfile ).symbolize_keys : {},
        httproutes: File.exist?( http_routesfile ) ? YAML.load_file( http_routesfile ).symbolize_keys : {}
      })
      config
    end

  end
end
