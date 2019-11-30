require_relative 'app-cfg'
require_relative 'app-log'

module App
  class App
    attr_accessor :bbs, :shutdown

    def initialize
      raise 'App уже есть.' if defined?('App')
      @shutdown = false # когда true -- выходим неспешно

      # Список семафоров для ожидания ответов от сервисов.
      @bbs = {}
      
      App::Cfg.new
      App::Log.new
      
      self
    end
  end

end
