require_relative "locatable/version"
require_relative "locatable/migration_helpers"
require_relative "locatable/scopes"

require "activerecord-postgis-adapter"

require "locatable/railtie" if defined?(Rails::Railtie)

module Locatable
  VALID_UNITS = %i[km mi nm].freeze
  METERS_PER_UNIT = {
    km: 1_000.0,
    mi: 1_609.344,
    nm: 1_852.0
  }.freeze

  class << self
    def default_units
      @default_units ||= :mi
    end

    def default_units=(units)
      @default_units = normalize_units(units)
    end

    def normalize_units(units)
      units = units.to_sym
      return units if VALID_UNITS.include?(units)

      raise ArgumentError, "units must be one of: #{VALID_UNITS.join(", ")}"
    rescue NoMethodError
      raise ArgumentError, "units must be one of: #{VALID_UNITS.join(", ")}"
    end
  end
end
