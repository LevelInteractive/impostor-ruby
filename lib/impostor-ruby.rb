require "impostor-ruby/version"

module Impostor
  require 'faker'
  require 'mysql2'
  require 'active_support/all'
  require 'twilio-ruby'

  require 'impostor-ruby/address'
  require 'impostor-ruby/internet'
  require 'impostor-ruby/personal'
  require 'impostor-ruby/phone'
  require 'impostor-ruby/persona'
  require 'impostor-ruby/klass'

  ##
  # initialize a new instance of Klass and return it.
  class << self
    def new(options={})
      Klass.new options
    end
  end
end
