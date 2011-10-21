xml.instruct!
xml.us_states do
  xml.state :id => 'default_point' do
    xml.color '000099'
    xml.opacity 50
  end

  xml.state :id => 'label_color' do
    xml.color '88bbbb'
  end

  xml.state :id => 'outline_color' do
    xml.color '88bbbb'
  end

  xml.state :id => 'default_color' do
    xml.color 'eeffee'
  end

  xml.state :id => 'background_color' do
    xml.color 'eeeeff'
  end

  xml.state :id => 'hover' do
    xml.font_size 14
    xml.font_color '000000'
    xml.background_color 'ffffff'
  end

  xml.state :id => 'default_point' do
    xml.size '3'
    xml.color 'ff0000'
  end

  xml.state :id => 'range' do
    xml.data '0'
    xml.color 'e0e0ff'
  end

  for state in @states.map{|a| {:name => a, :count => @scans.count{|s| s.state == a } } }.sort{|a,b| b[:count] <=> a[:count]}
    unless state[:name].blank?
      xml.state :id => state[:name] do
        xml.name state[:name]
        xml.data '0'
        xml.hover "This state has #{state[:count]} scans."
      end
    end
  end

  for scan in @scans
    if scan.latitude && scan.latitude != 0
      xml.state :id => 'point' do
        xml.loc "#{scan.latitude},#{scan.longitude}"
        if scan.created_at > Time.now - 1.day
          sz = 6
        elsif scan.created_at > Time.now - 1.week
          sz = 4
        elsif scan.created_at > Time.now - 1.month
          sz = 2
        else
          sz = 1
        end
        xml.size sz
        xml.name "Scanned #{scan.created_at.strftime('%b %d %y at %I:%M %p')}"
        xml.hover "From #{scan.city} (#{scan.isp})"
      end
    end
  end

end

