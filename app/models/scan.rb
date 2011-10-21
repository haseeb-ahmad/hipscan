class Scan < ActiveRecord::Base
  belongs_to :user
  belongs_to :qr

  geocoded_by :ip
#  reverse_geocoded_by :latitude, :longitude do |obj,results|
#    if geo = results.first
#      obj.address = geo.address
#      obj.city    = geo.city
#      obj.state   = geo.state
#      obj.zipcode = geo.postal_code
#      obj.country = geo.country_code
#    end
#  end

  def geocoded?
    super && (self.latitude != 0 && self.longitude != 0)
  end


  # Maxmind returns:
  #   ISO 3166 Two-letter Country Code, Region Code, City, Postal Code,
  #   Latitude, Longitude,
  #   Metropolitan Code, Area Code, ISP, Organization, Error code
  def geocode
    q = "http://geoip3.maxmind.com/f?l=#{APP_CONFIG[:maxmind_key]}&i=#{self.ip}"
    result = open(q).read

    self.country,self.state, self.city,self.zipcode, self.latitude, self.longitude, self.metro_code, self.area_code, self.isp, self.org, err = result.split(',')

  #        raise err
#    if err.blank?
#
#    end
  end

  def location
    begin
      unless geocoded?
        geocode
#        reverse_geocode
        save
      end
    rescue
    end
    city.blank? ? 'location unavailable' : "#{city}, #{state}"
  end

  def reverse_geocoded?; self.city; end

  def iphone?; self.http_user_agent =~ /iphone/i; end
  def android?; self.http_user_agent =~ /android/i; end

  def mobile_device
    if iphone?
      'iPhone'
    elsif android?
      'Android'
    else
      'Other'
    end
  end
end
