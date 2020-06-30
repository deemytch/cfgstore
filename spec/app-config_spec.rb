require_relative '../lib/app-config'
require 'logger'

RSpec.describe App::Config do

  context 'всё' do
    before :all do
      App::Config.init( approot: Pathname(__FILE__).dirname.expand_path,
                       configdir: 'settings',
                       filename: 'config',
                       env: :testingtest )
    end

    it 'загружает yaml файл по указанному маршруту' do
      expect( Cfg.app.id ).to eq 'cfgsettings'
      expect( Cfg.services ).to be_a Hash
    end

    it 'Можно получить доступ к данным разными способами' do
      expect( Cfg[:app][:id] == Cfg.app.id ).to be_truthy
    end

    it 'Можно спросить, если ли ключ разными способами' do
      expect( Cfg.app.id? ).to be_truthy
      expect( Cfg.app.key?( :id )).to be_truthy
      expect( Cfg[ :app ] ).to be_a Hash
      expect( Cfg[:non] ).to be_nil
      expect( Cfg.non? ).to be_falsy
    end

    it 'можно присвоить значение разными способами' do
      expect( Cfg.app.loglevel ).to be_nil
      Cfg.app.loglevel = 'WARN'
      expect( Cfg.app.loglevel ).to eq 'WARN'
      Cfg.app[:loglevel] = 'INFO'
      expect( Cfg.app.loglevel ).to eq 'INFO'
      Cfg[:app][:loglevel] = 'DEBUG'
      expect( Cfg.app.loglevel ).to eq 'DEBUG'
    end

    it 'числа не коверкаются' do
      expect( Cfg.services.usersrb.publish[ 1024 ] ).to eq 1024
      expect( Cfg.services[:usersrb][:validations].first ).to eq 1
      Cfg.services[:usersrb][:validations][0] = 81
      expect( Cfg.services[:usersrb][:validations][0] ).to eq 81
      Cfg.services.usersrb.publish[1024] = 2048
      expect( Cfg.services.usersrb.publish[1024] ).to eq 2048
    end

    it 'верно установлены переменные root, env, loglevel' do
      expect( Cfg.root.to_s ).to eq Pathname(__FILE__).dirname.expand_path.to_s
      expect( Cfg.env ).to eq :testingtest
      expect( Cfg.loglevel ).to eq Logger::DEBUG
    end
  end

  context 'loglevel' do
    before{ App::Config.remove }
    after { App::Config.remove }

    it 'распознаёт из файла настроек' do
      expect{ App::Config.init(
                  approot: Pathname(__FILE__).dirname.expand_path,
                  configdir: 'settings',
                  filename: 'loglevel',
                  env: 'test' ) }.not_to raise_error
      expect( Cfg.app.id ).to eq 'logleveltest'
      expect( Cfg.loglevel ).to eq Logger::WARN
    end

    it 'распознаёт из переменных окружения' do
      ENV['LOG_LEVEL'] = 'fatal'
      expect{ App::Config.init(
            approot: Pathname(__FILE__).dirname.expand_path,
            configdir: 'settings',
            filename: 'loglevel',
            env: 'test' ) }.not_to raise_error
      expect( Cfg.loglevel ).to eq Logger::FATAL
      ENV.delete 'LOG_LEVEL'
    end
  end

end
