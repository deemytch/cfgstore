require 'yaml'
require 'monkey-hash'
require 'pry-byebug'
require_relative 'settings-hash'

module App
  class Config < SettingsHash
    ##
    # Создаёт корневой словарь настроек.
    # Автоматически создаёт глобальную переменную Cfg.
    def self.create( approot = Pathname( __FILE__ ) )
      instance = allocate
      instance.send :initialize
      instance.root     = approot.dirname.expand_path.to_s
      instance.env      = ( ENV['APP_ENV'] || 'development' ).to_sym.freeze
      instance.loglevel = Kernel.const_get("Logger::#{ ENV['LOG_LEVEL'].upcase }") rescue ( instance.env == :production ? Logger::WARN : Logger::DEBUG )
      # Dir.chdir instance.root
      # Все настройки приложения + роуты
      configfile = "#{ instance.root }/config/cfg.#{ instance.env }.yml"
      routesfile = "#{ instance.root }/config/routes.#{ instance.env }.yml"

      raise ArgumentError.new("Не найден #{ configfile }!") unless File.exist?( configfile )
      raise ArgumentError.new("Не найден #{ routesfile }!") unless File.exist?( routesfile )

      Kernel.const_set('Cfg', instance) unless defined?( ::Cfg )
      instance.merge! YAML.load_file( configfile ).symbolize_keys
      instance.routes = YAML.load_file("#{ instance.root }/config/routes.#{ instance.env }.yml").symbolize_keys
      $0 += "[ #{ instance.app.id } ]" if instance.app && instance.app.id
      instance.app.id ||= $0
      instance
    end

  end
end
