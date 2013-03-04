class Template < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :template_type
end
