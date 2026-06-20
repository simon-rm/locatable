require_relative "locatable/version"
require_relative "locatable/migration_helpers"

require "activerecord-postgis-adapter"

require "locatable/railtie" if defined?(Rails::Railtie)

module Locatable
end