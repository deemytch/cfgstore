# Configuration loader

* Автоматически грузит `config/cfg.$env.yml`, `config/amqp.$env.yml` и `config/http.$env.yml`.
* Создаёт глобальные переменные `Cfg`, `Log`, `MQLog`.

## Как этим пользоваться

Распознаются переменные окружения `APP_ENV` и `LOG_LEVEL`.

Значения `APP_ENV` -- любые, важно совпадение с именами файлов. По умолчанию при отсутствии переменной выставляется `:development`. Значение рабочего окружения присваивается переменной `Cfg.env`.

Значения `LOG_LEVEL` -- стандартные уровни Logger.

**По умолчанию** при `Cfg.env == :production` `LOG_LEVEL == 'INFO'`, во всех остальных случаях -- `'DEBUG'`.

Хэш (с настройками) загружается из файла `config/cfg.#{ environment }.yml` в глобальную переменную `Cfg`.

Затем в `Cfg.amqproutes` подгружаются роуты из файла `config/amqp.#{ environment }.yml`.

Затем в `Cfg.httproutes` подгружаются роуты из файла `config/http.#{ environment }.yml` при наличии данного файла.

При настройке логирования предполагается наличие в настройках ключа `Cfg.app.log == (nil == stderr|stdout|имя-файла)`.

Доступ к значениям настроек может быть через [:symbol], ['string'] или через точку. То есть эти записи равнозначны: `Cfg.app.id, Cfg[:app][:id], Cfg['app']['id'], Cfg.app[:id]`.

И можно писать в лог:
  
    > Log.debug{"связь"}
    D°47211598772580°11357°            eval:387°03/12-00:24:55 -- связь

Для изменения формата вывода логов необходимо перегрузить методы `App::Logger#base_formatter и mq_formatter`.

## Готовый кот

    require 'app-config'
    require 'app-logger'
    App::Config.init approot: Pathname( __dir__ ) # Relative path to the project root
    App::Logger.new

## Подробные параметры запуска

### App::Config

    approot: nil,          # обязательный
    configdir: 'config',
    filename: 'cfg',
    env: ( ENV['APP_ENV'] || 'development' )

### App::Logger

    dest = nil, # По умолчанию берётся из Cfg.app.log;
                # допустимые значения: stderr, stdout, имя-файла (распознаётся абсолютный и относительный путь)
                # default: $stdout
    formatter: nil,      # Proc, по умолчанию #base_formatter
    bunny_formatter: nil # Proc  по умолчанию #mq_formatter

### YAML config example

    app:
      id: my-prog # look at it `ps ax|grep my-prog`
      log: stdout
