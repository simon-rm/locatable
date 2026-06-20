module Locatable::MigrationHelpers
  def make_locatable(table, longitude_column, latitude_column)
    reversible do |dir|
      dir.up do
        execute <<~SQL
          ALTER TABLE #{table}
          ADD COLUMN location_geography geography(Point, 4326)
          GENERATED ALWAYS AS (
            ST_Point(#{longitude_column}, #{latitude_column}, 4326)::geography
          ) STORED,
          ADD COLUMN location_geometry geometry(Point, 4326)
          GENERATED ALWAYS AS (
            ST_Point(#{longitude_column}, #{latitude_column}, 4326)
          ) STORED;
        SQL
      end

      dir.down do
        remove_column table, :location_geometry
        remove_column table, :location_geography
      end
    end

    add_index table, :location_geography, using: :gist
    add_index table, :location_geometry, using: :gist
  end
end 