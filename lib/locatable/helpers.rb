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
end
