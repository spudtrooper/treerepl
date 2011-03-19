$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed

# stdlib
require 'logger'

# internal requires
require 'treerepl/tree'
require 'treerepl/cmds'
require 'treerepl/repl'

module TreeRepl
  VERSION = '0.0.1'


  class << self
    attr_accessor :debug
    attr_accessor :logger
    def log(str)
      logger.debug { str }
    end
  end
  self.debug = false

  @logger ||= ::Logger.new(STDERR)

  def self.version
    VERSION
  end

end
