# frozen_string_literal: true

require "test_helper"
require "active_record"
require "locatable/model"

ActiveRecord::Migration.include Locatable::MigrationHelpers

ActiveRecord::Base.establish_connection(ENV.fetch("LOCATABLE_DATABASE_URL"))
ActiveRecord::Base.connection.enable_extension("postgis")
ActiveRecord::Base.connection.drop_table(:locations, if_exists: true)

Class.new(ActiveRecord::Migration[8.1]) do
  def change
    create_table :locations do |table|
      table.float :latitude
      table.float :longitude
    end

    make_locatable :locations, :longitude, :latitude
  end
end.migrate(:up)

class Location < ActiveRecord::Base
  include Locatable::Model

  locatable
end

LOCATION_ATTRIBUTES = [
  {latitude: 40.7128, longitude: -74.0060},
  {latitude: 40.7138, longitude: -74.0050},
  {latitude: 40.7228, longitude: -74.0160},
  {latitude: 34.0522, longitude: -118.2437},
  {latitude: 51.5074, longitude: -0.1278}
].freeze

describe Locatable::Scopes do
  before do
    Location.delete_all
    Location.insert_all!(LOCATION_ATTRIBUTES)
  end

  describe ".within_bounding_box" do
    describe "nil case" do
      it "returns no locations" do
        _(Location.within_bounding_box(nil).count).must_equal 0
      end
    end

    describe "simple happy path case" do
      it "returns locations inside the box" do
        _(Location.within_bounding_box([[40.70, -74.02], [40.73, -73.99]]).count).must_equal 3
      end
    end
  end

  describe ".order_by_closest_to" do
    describe "nil case" do
      it "keeps all locations" do
        _(Location.order_by_closest_to(nil).count).must_equal 5
      end
    end

    describe "simple happy path case" do
      it "returns the closest location first" do
        _(Location.order_by_closest_to([40.7128, -74.0060]).first.latitude).must_equal 40.7128
      end
    end
  end

  describe ".select_distance_to" do
    describe "nil case" do
      it "selects a nil distance" do
        _(Location.select_distance_to(nil).first.distance).must_be_nil
      end
    end

    describe "simple happy path case" do
      it "selects a zero distance" do
        _(Location.select_distance_to([40.7128, -74.0060]).first.distance.to_f).must_equal 0.0
      end
    end
  end

  describe ".within_radius" do
    describe "nil case" do
      it "returns no locations" do
        _(Location.within_radius(nil, 1).count).must_equal 0
      end
    end

    describe "simple happy path case" do
      it "returns locations inside the radius" do
        _(Location.within_radius([40.7128, -74.0060], 1).count).must_equal 2
      end
    end
  end

  describe ".near" do
    describe "nil case" do
      it "returns no locations" do
        _(Location.near(nil).count).must_equal 0
      end
    end

    describe "simple happy path case" do
      it "returns nearby locations" do
        _(Location.near([40.7128, -74.0060], 1).count).must_equal 2
      end
    end
  end
end
