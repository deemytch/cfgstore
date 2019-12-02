require 'hashie'
require 'monkey-hash'

module App
  class SettingsHash < Hashie::Mash
    include Hashie::Extensions::IndifferentAccess
    include Hashie::Extensions::DeepMerge
  end
end
