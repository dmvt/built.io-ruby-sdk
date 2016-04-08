module Built
  # This is used to specify a long/lat pair in built.io
  class Location
    attr_accessor :long
    alias_method :lng, :long
    alias_method :lng=, :long=
    alias_method :longitude, :long
    alias_method :longitude=, :long=
    attr_accessor :lat
    alias_method :latitude, :lat
    alias_method :latitude, :lat=

    # Create a new Location object
    # @param [Float] long Longitude of the location
    # @param [Float] lat Latitude of the location
    # @return [Location] location A new location
    def initialize(long, lat)
      Util.type_check("long", long, Float)
      Util.type_check("lat", lat, Float)

      self.long = long
      self.lat = lat
    end

    # Distance in meters from a certain location
    # @param [Location] location The location
    # @return [Integer] distance in meters
    def metersFrom(location)
      Util.type_check("location", location, Location)

      haversine(location.lat, location.long, lat, long, 1000)
    end

    # Distance in kilometers from a certain location
    # @param [Location] location The location
    # @return [Integer] distance in kilometers
    def kilometersFrom(location)
      Util.type_check("location", location, Location)

      haversine(location.lat, location.long, lat, long, 1)
    end

    # Convert this into an array of [long, lat]
    # @return [Array<Float, Float>]
    def to_arr
      [long, lat]
    end

    private

    def to_s
      "#<Built::Object long=#{long}, lat=#{lat}>"
    end

    def power(num, pow)
      num ** pow
    end

    def haversine(lat1, long1, lat2, long2, factor)
      dtor = Math::PI/180
      r = 6378.14*factor

      rlat1 = lat1 * dtor
      rlong1 = long1 * dtor
      rlat2 = lat2 * dtor
      rlong2 = long2 * dtor

      dlon = rlong1 - rlong2
      dlat = rlat1 - rlat2

      a = power(Math::sin(dlat/2), 2) + Math::cos(rlat1) * Math::cos(rlat2) * power(Math::sin(dlon/2), 2)
      c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
      d = r * c

      return d.ceil
    end
  end
end
