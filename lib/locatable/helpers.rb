module Locatable::Helpers
  module_function

  def extract_lat_lng(origin)
    lat, lng = case origin
    when Array
      [origin[0], origin[1]]
    when Hash
      [origin[:lat] || origin["lat"], origin[:lng] || origin["lng"]]
    else
      [origin.try(:lat), origin.try(:lng)]
    end

    [parse_float(lat), parse_float(lng)]
  end

  def parse_float(value)
    Float(value)
  rescue ArgumentError, TypeError
    nil
  end

  def meters_per_unit(unit)
    Locatable::METERS_PER_UNIT.fetch(Locatable.normalize_unit(unit))
  end

  def convert_to_meters(distance, unit)
    distance = parse_float(distance)
    return nil if distance.nil?

    distance * meters_per_unit(unit)
  end
end
