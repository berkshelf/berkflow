require 'celluloid/autostart'
require 'berkflow/version'
require 'ridley'
require 'ridley-connectors'
require 'berkshelf'

module Berkflow
  class << self
    def debug?
      !ENV['DEBUG'].nil?
    end

    def setup
      if debug?
        Ridley.logger.level    = Logger::DEBUG
        Berkshelf.logger.level = Logger::DEBUG
      else
        # Disable Celluloid logging to silence erronous warnings and errors. This
        # will be re-enabled in the future once the cause of false crash reports
        # on shutdown is identified and fixed.
        Celluloid.logger = nil

        Ridley.logger.level    = Logger::ERROR
        Berkshelf.logger.level = Logger::ERROR
      end
    end
  end
end

Berkflow.setup
