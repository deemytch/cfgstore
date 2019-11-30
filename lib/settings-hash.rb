require 'hashie'

module App
  class SettingsHash < Hashie::Mash
    include Hashie::Extensions::IndifferentAccess
    include Hashie::Extensions::DeepMerge
  end
end
