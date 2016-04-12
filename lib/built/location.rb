module Built
  # This is used to specify a lng/lat pair in built.io
  class Location
    attr_accessor :lng
    alias_method :longitude, :lng
    alias_method :longitude=, :lng=
    attr_accessor :lat
    alias_method :latitude, :lat
    alias_method :latitude, :lat=

    # Legacy support
    alias_method :long, :lng
    alias_method :long=, :lng=

    # Create a new Location object
    # @param [Float] lng Longitude of the location
    # @param [Float] lat Latitude of the location
    # @return [Location] location A new location
    def initialize(lng, lat)
      Util.type_check("lng", lng, Numeric)
      Util.type_check("lat", lat, Numeric)

      self.lng = lng.to_f
      self.lat = lat.to_f
    end

    # Distance in meters from a certain location
    # @param [Location] location The location
    # @return [Integer] distance in meters
    def meters_from(location)
      Util.type_check("location", location, Location)

      distance(location.lat, location.lng)
    end

    # Distance in kilometers from a certain location
    # @param [Location] location The location
    # @return [Integer] distance in kilometers
    def kilometers_from(location)
      Util.type_check("location", location, Location)

      distance(location.lat, location.lng) / 1000
    end

    # Convert this into an array of [lng, lat]
    # to match the API :(
    # @return [Array<Float, Float>]
    def to_arr
      [lng, lat]
    end

    # Convert this into an array of [lat, lng]
    # @return [Array<Float, Float>]
    def to_a
      [lat, lng]
    end

    private

    def to_s
      "#<Built::Object lat=#{lat}, lng=#{lng}>"
    end

    def power(num, pow)
      num ** pow
    end

    # credit: http://stackoverflow.com/questions/12966638/how-to-calculate-the-distance-between-two-gps-coordinates-without-using-google-m
    def distance(remote_lat, remote_lng)
      rad_per_deg = Math::PI/180  # PI / 180
      rkm = 6371                  # Earth radius in kilometers
      rm = rkm * 1000             # Radius in meters

      dlat_rad = (remote_lat-lat) * rad_per_deg  # Delta, converted to rad
      dlng_rad = (remote_lng-lng) * rad_per_deg

      lat1_rad = lat * rad_per_deg
      lat2_rad = remote_lat * rad_per_deg

      a = Math.sin(dlat_rad/2)**2 +
          Math.cos(lat1_rad) *
          Math.cos(lat2_rad) *
          Math.sin(dlng_rad/2)**2

      c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))

      rm * c # Delta in meters
    end
  end
end
