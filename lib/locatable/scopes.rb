require "active_support/concern"
require "active_record"
require "locatable/helpers"
module Locatable::Scopes
  extend ActiveSupport::Concern

  SRID = 4326

  included do
    scope :within_bounding_box, ->(sw_lat:, sw_lng:, ne_lat:, ne_lng:) do
      sw_lat, sw_lng, ne_lat, ne_lng =
        [sw_lat, sw_lng, ne_lat, ne_lng].map { |value| Locatable::Helpers.parse_float(value) }

      next none if [sw_lat, sw_lng, ne_lat, ne_lng].any?(&:nil?)

      location_column = :location_geometry

      within_bbox_sql = if ne_lng > sw_lng
        <<~SQL.squish
          #{location_column} && ST_MakeEnvelope(#{sw_lng}, #{sw_lat}, #{ne_lng}, #{ne_lat}, #{SRID})
        SQL
      else
        <<~SQL.squish
          #{location_column} && ST_MakeEnvelope(#{sw_lng}, #{sw_lat}, 180, #{ne_lat}, #{SRID}) OR
          #{location_column} && ST_MakeEnvelope(-180, #{sw_lat}, #{ne_lng}, #{ne_lat}, #{SRID})
        SQL
      end

      where(Arel.sql(within_bbox_sql))
    end

    scope :order_by_closest_to, ->(origin) do
      lat, lng = Locatable::Helpers.extract_lat_lng(origin)

      next all if lat.nil? || lng.nil?

      order(Arel.sql("location_geography <-> ST_Point(#{lng}, #{lat}, #{SRID})::geography"))
    end

    scope :with_distance_to, ->(origin) do
      lat, lng = Locatable::Helpers.extract_lat_lng(origin)

      select("ST_Distance(location_geography, ST_Point(#{lng}, #{lat}, #{SRID})::geography) AS distance")
    end
  end
end
