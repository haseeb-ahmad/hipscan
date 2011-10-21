

namespace :hipscan do

  desc "Regenerate QR codes"
  task :regen_qr => :environment do
    puts 'Regenerating QR pngs'
    for u in User.all
      u.generate_qr
      u.save(false)
    end
  end

  desc "Geocode Scans and clicks"
  task :geocode => :environment do
    for scan in Scan.all
      if scan.isp.blank?
        scan.geocode
        scan.save
      end
#      unless scan.geocoded?
#        scan.geocode
#        if scan.geocoded?
#          scan.save
#          puts "Geocoding #{scan.id} (#{scan.latitude} #{scan.longitude})"
#        end
#      end
#      if scan.geocoded? && !scan.reverse_geocoded?
#        scan.reverse_geocode
#        if scan.reverse_geocoded?
#          scan.save
#          puts "Reverse Geocoding #{scan.id} (#{scan.city} #{scan.state})"
#        end
#      end
    end

#    for click in Click.all
#      unless scan.geocoded?
#        click.geocode
#        click.save
#      end
#    end

  end
end
