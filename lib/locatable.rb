# frozen_string_literal: true

require_relative "locatable/version"

require "active_support/concern"
require "active_record"

module Locatable
  # class Error < StandardError; end
  SRID = 4326
  
  extend ActiveSupport::Concern

  included do
    scope :within_bounding_box, ->(sw_lat:, sw_lng:, ne_lat:, ne_lng:) do
      next if [sw_lat, sw_lng, ne_lat, ne_lng].any?(&:blank?)

      sw_lat, sw_lng, ne_lat, ne_lng = [sw_lat, sw_lng, ne_lat, ne_lng].map(&:to_f)

      location_column = :location_geometry

      within_bbox_sql = sanitize_sql(
        if ne_lng > sw_lng
          [
            <<~SQL.squish,
              #{location_column} && ST_MakeEnvelope(?, ?, ?, ?, #{SRID})
            SQL
            sw_lng, sw_lat, ne_lng, ne_lat
          ]
        else
          # handle dateline crossing
          [
            <<~SQL.squish,
              (#{location_column} && ST_MakeEnvelope(?, ?, ?, ?, #{SRID})) OR
              (#{location_column} && ST_MakeEnvelope(?, ?, ?, ?, #{SRID}))
            SQL
            sw_lng, sw_lat, 180, ne_lat,
            -180, sw_lat, ne_lng, ne_lat
          ]
        end
      )

      where(within_bbox_sql)
    end
  end
end
