require_relative 'app-config'
require_relative 'app-logger'

module App
  class Main
    # когда true -- выходим неспешно
    @@shutdown = false

    def initialize( approot = Pathname( __FILE__ ) )
      raise 'App уже есть.' if defined?( ::Main )

      App::Config.create( approot )
      App::Logger.new
      Kernel.const_set('Main', self)

      self
    end
  end

  def self.shutdown
    @@shutdown
  end

  def self.shutdown=( v )
    @@shutdown = !!v
  end
end

trap('INT')  { Main.shutdown = true }
trap('TERM') { Main.shutdown = true }
