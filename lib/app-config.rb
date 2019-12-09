require 'yaml'
require 'monkey-hash'
require 'pry-byebug'
require_relative 'settings-hash'

module App
  class Config < SettingsHash
    ##
    # Создаёт корневой словарь настроек.
    # Автоматически создаёт глобальную переменную Cfg.
    # Отдельный конструктор нужен, чтобы правильно проинициализировать потомок Hashie

    def self.create( approot = Pathname( __FILE__ ) )
      instance = allocate
      instance.send :initialize
      instance.root     = approot.dirname.expand_path.to_s
      instance.env      = ( ENV['APP_ENV'] || 'development' ).to_sym.freeze
      instance.loglevel = Kernel.const_get("Logger::#{ ENV['LOG_LEVEL'].upcase }") rescue ( instance.env == :production ? Logger::WARN : Logger::DEBUG )
      # Dir.chdir instance.root
      # Все настройки приложения + роуты
      configfile = "#{ instance.root }/config/cfg.#{ instance.env }.yml"
      amqp_routesfile = "#{ instance.root }/config/amqp.#{ instance.env }.yml"
      http_routesfile = "#{ instance.root }/config/http.#{ instance.env }.yml"

      raise ArgumentError.new("Не найден #{ configfile }!") unless File.exist?( configfile )
      raise ArgumentError.new("Не найден #{ amqp_routesfile }!") unless File.exist?( amqp_routesfile )

      Kernel.const_set('Cfg', instance) unless defined?( ::Cfg )
      instance.merge! YAML.load_file( configfile ).symbolize_keys
      instance.merge!({
        amqproutes: YAML.load_file( amqp_routesfile ).symbolize_keys,
        httproutes: File.exist?(http_routesfile) ? YAML.load_file( http_routesfile ).symbolize_keys : {}
      })
      $0 += "[ #{ instance.app.id } ]" if instance.app && instance.app.id

      instance.app.id  ||= $0
      instance.app.log ||= nil
      instance
    end

  end
end
