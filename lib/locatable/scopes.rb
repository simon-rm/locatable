require "active_support/concern"
require "active_record"
require "locatable/scopes/helpers"
module Locatable::Scopes
  extend ActiveSupport::Concern

  SRID = 4326

  included do
    scope :within_bounding_box, ->(sw_lat:, sw_lng:, ne_lat:, ne_lng:) do
      sw_lat, sw_lng, ne_lat, ne_lng =
        [sw_lat, sw_lng, ne_lat, ne_lng].map { |value| Helpers.parse_float(value) }

      next none if [sw_lat, sw_lng, ne_lat, ne_lng].any?(&:nil?)

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

    scope :order_by_closest_to, ->(origin) do
      lat, lng = Helpers.extract_lat_lng(origin)

      next all if lat.nil? || lng.nil?

      order(Arel.sql("location_geography <-> ST_Point(#{lng}, #{lat}, #{SRID})::geography"))
    end
  end
end
