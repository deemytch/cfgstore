require 'logger'
require 'monkey-hash'
##
# Печататель протоколов с удобной настройкой вывода и фильтрацией спама от Bunny.
# Использует предварительно настроенный Cfg

module App
  class Logger < ::Logger

    attr_accessor :main_formatter, :amqp_formatter, :logdev

    def base_formatter
      return proc { |severity, datetime, progname, msg|
#        "#{ severity[0] }°#{ datetime.strftime '%d/%m-%H:%M:%S' }°#{ Thread.current.object_id }°#{ Process.pid }°#{ "%20s" % caller_locations[0..4].last.label }:#{ "%03d" % caller_locations[0..4].last.lineno.to_i }—#{ msg }\n"
          "#{ severity[0] } #{ datetime.strftime '%d/%m-%H:%M:%S' }  #{ msg }\n"
      }
    end
    def mq_formatter
      # Убираем некоторую вредность из логгера Кролика
      return proc { |severity, datetime, progname, msg|
        if msg !~ /Using TLS but/ && severity != 'DEBUG'
          msg.force_encoding('UTF-8')
          if severity == 'ERROR'
            msg += <<~BACKTACE

              Thread #{ Thread.current.inspect }
              Process #{ Process.pid }
              #{ "===BACKTACE:===\n" + caller.join("\n")  + "\n===" }
            BACKTACE
          end
          base_formatter.call(severity, datetime, progname, '(ѣ)' + msg )
        end
      }
    end

    def initialize( dest = nil, formatter: nil, bunny_formatter: nil )
      raise 'Log уже есть.' if defined?( ::Log )
      raise 'Сначала нужны настройки.' unless defined?( ::Cfg )

      @main_formatter = formatter || base_formatter
      @amqp_formatter = bunny_formatter || mq_formatter || @main_formatter

      raise 'formatter должны быть Proc' if ! @main_formatter.is_a?(Proc) || ! @amqp_formatter.is_a?(Proc)

      @logdev = 
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
      super @logdev, progname: Cfg.app.progname, level: Cfg.loglevel, formatter: @main_formatter
      Kernel.const_set 'Log', self
      Kernel.const_set 'MQLog', ::Logger.new( @logdev, progname: "#{ Cfg.app.progname }+Bunny", level: Cfg.loglevel, formatter: @amqp_formatter )
      Log.info{"#{ Cfg.env } started. thread #{ Thread.current.object_id }."}
      self
    end
  end

end
