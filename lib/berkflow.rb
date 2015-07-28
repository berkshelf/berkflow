require 'celluloid/autostart'
require 'berkflow/version'
require 'ridley'
require 'ridley-connectors'
require 'berkshelf'

module Berkflow
  # Your code goes here...
end

# Disable Celluloid logging to silence erronous warnings and errors. This
# will be re-enabled in the future once the cause of false crash reports
# on shutdown is identified and fixed.
Celluloid.logger = nil
