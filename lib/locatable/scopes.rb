require "active_support/concern"
require "active_record"
require "locatable/helpers"

module Locatable::Scopes
  extend ActiveSupport::Concern

  SRID = 4326

  included do
    scope :within_bounding_box, ->(sw_ne_corners) do
      next none if sw_ne_corners.nil?

      sw_corner = sw_ne_corners.flatten[0..1]
      ne_corner = sw_ne_corners.flatten[2..3]

      sw_lat, sw_lng = Locatable::Helpers.extract_lat_lng(sw_corner)
      ne_lat, ne_lng = Locatable::Helpers.extract_lat_lng(ne_corner)

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

    scope :select_distance_to, ->(origin, unit: nil) do
      unit ||= Locatable.default_unit
      lat, lng = Locatable::Helpers.extract_lat_lng(origin)
      meters_per_unit = Locatable::Helpers.meters_per_unit(unit)

      distance_sql = if lat.nil? || lng.nil?
        "NULL"
      else
        "ST_Distance(location_geography, ST_Point(#{lng}, #{lat}, #{SRID})::geography) / #{meters_per_unit}"
      end

      select("#{distance_sql} AS distance")
    end

    scope :within_radius, ->(origin, radius, unit: nil) do
      unit ||= Locatable.default_unit
      lat, lng = Locatable::Helpers.extract_lat_lng(origin)
      radius = Locatable::Helpers.convert_to_meters(radius, unit)

      next none if lat.nil? || lng.nil?
      next all if radius.nil?

      where(Arel.sql("ST_DWithin(location_geography, ST_Point(#{lng}, #{lat}, #{SRID})::geography, #{radius})"))
    end

    scope :near, ->(origin, radius = 20, unit: nil, order_by_closest: true, select_distance: false) do
      unit ||= Locatable.default_unit
      scope = all
      scope = scope.within_radius(origin, radius, unit: unit) if radius.present?
      scope = scope.order_by_closest_to(origin) if order_by_closest
      scope = scope.select_distance_to(origin, unit: unit) if select_distance
      scope
    end
  end
end
