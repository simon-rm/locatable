# Locatable

Location scopes for Active Record models backed by PostGIS.

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

Place.within_radius(origin, 5)
Place.near(origin, 5)
Place.order_by_closest_to(origin)
Place.select_distance_to(origin)
Place.within_bounding_box([[40.70, -74.02], [40.73, -73.99]])
```

Distances use kilometers by default. Supported units are `:km`, `:mi`, and `:nm`.

```ruby
Place.near(origin, 10, unit: :mi)
Locatable.default_unit = :mi
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
