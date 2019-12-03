require 'logger'
require_relative 'app-config'

##
# Печататель протоколов с удобной настройкой вывода и фильтрацией спама от Bunny.
# Использует предварительно настроенный Cfg -> App::Cfg
# Значения logdev == stderr, syslog, nil -> stderr | stdout | filename

module App
  class Logger < Logger
    def self.base_formatter
      return proc { |severity, datetime, progname, msg|
        "#{ severity[0] }°#{ Thread.current.object_id }°#{ Process.pid }°#{ "%16s" % caller_locations[0..4].last.label }:#{ "%03d" % caller_locations[0..4].last.lineno.to_i }°#{ datetime.strftime '%d/%m-%H:%M:%S' } -- #{ msg }\n"
      }
    end

    def self.mq_formatter
      # Убираем некоторую вредность из логгера Кролика
      return proc { |severity, datetime, progname, msg|
        if msg !~ /Using TLS but/ && severity != 'DEBUG'
          msg.force_encoding('UTF-8')
          msg += "\n===BACKTACE:===\n#{ caller.join("\n") }\n===" if severity == 'ERROR'
          base_formatter.call(severity, datetime, progname, '(ѣ)' + msg )
        end
      }
    end

    def initialize( dest = nil )
      raise 'Log уже есть.' if defined?( ::Log )
      raise 'Сначала нужны настройки.' unless defined?( ::Cfg )

      logdev = 
      case dest ||= Cfg.app.log
        when 'stderr', 'syslog', nil
          $stdout.close
          $stdout = $stderr
        when 'stdout'
          $stderr.close
          $stderr = $stdout
        else
          Cfg.app.log = "#{ Cfg.root }/#{ Cfg.app.log }" unless Cfg.app.log =~ %r{^/}
          FileUtils.mkdir_p Pathname.new( Cfg.app.log ).dirname
          logf = File.open( Cfg.app.log, 'a' )
          logf.sync = true
          $stderr.reopen logf
          $stdout.reopen logf
          logf
      end
      super logdev, progname: Cfg.app.progname, level: Cfg.loglevel, formatter: App::Logger.base_formatter
      Kernel.const_set 'Log', self
      Kernel.const_set 'MQLog', ::Logger.new( logdev, progname: "#{ Cfg.app.progname }+Bunny", level: Cfg.loglevel, formatter: App::Logger.mq_formatter )
      Log.info{"#{ Cfg.env } started. thread #{ Thread.current.object_id }."}
      self
    end
  end

end
