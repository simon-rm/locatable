# Locatable

Simple, fast, Geocoder-compatible PostGIS-backed location scopes for Active Record models.

## Requirements

- Ruby 3.2+
- Active Record
- PostgreSQL with PostGIS

## Installation

Add the gem to your Gemfile:

```ruby
gem "locatable"
```

Then run:

```sh
bundle install
```

## Setup

Add latitude and longitude columns, then call `make_locatable` in the migration.

```ruby
class CreatePlaces < ActiveRecord::Migration[8.1]
  def change
    create_table :places do |t|
      t.float :latitude
      t.float :longitude
      t.timestamps
    end

    make_locatable :places, latitude: :latitude, longitude: :longitude
  end
end
```

`make_locatable` adds generated PostGIS geography and geometry columns, plus GiST indexes.

In the model, call `locatable`:

```ruby
class Place < ApplicationRecord
  locatable
end
```

## Usage

Coordinates are passed as `[latitude, longitude]`.

```ruby
origin = [40.7128, -74.0060]

Place.within_bounding_box([[40.70, -74.02], [40.73, -73.99]]) # Geocoder-compatible
Place.near(origin, 5) # Geocoder-compatible
Place.within_radius(origin, 5)
Place.order_by_closest_to(origin)
Place.select_distance_to(origin)
```

These 2 calls are equivalent:

```ruby
Place.near(origin, 2)
Place.within_radius(origin, 2).order_by_closest_to(origin)
```

Distances use miles by default. Supported units are `:km`, `:mi`, and `:nm`.

Set the units directly on a scope call:

```ruby
Place.near(origin, 10, units: :km)
Place.within_radius(origin, 5, units: :nm)
```

Or set the default once in an initializer:

```ruby
# config/initializers/locatable.rb
Locatable.default_units = :km
```

## Development

Install dependencies:

```sh
bin/setup
```

Run tests with a PostGIS database URL:

```sh
LOCATABLE_DATABASE_URL=postgis://user:password@localhost/locatable_test bundle exec rake test
```

Run formatting:

```sh
bundle exec rake standard
```
