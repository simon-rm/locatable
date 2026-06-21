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
    def default_unit
      @default_unit ||= :km
    end

    def default_unit=(unit)
      @default_unit = normalize_unit(unit)
    end

    def normalize_unit(unit)
      unit = unit.to_sym
      return unit if VALID_UNITS.include?(unit)

      raise ArgumentError, "unit must be one of: #{VALID_UNITS.join(", ")}"
    rescue NoMethodError
      raise ArgumentError, "unit must be one of: #{VALID_UNITS.join(", ")}"
    end
  end
end
