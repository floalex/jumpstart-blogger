class Page < ActiveRecord::Base
  
  def self.find(slug)
    find_by(slug: slug)
  end
 
  def to_param
    slug
  end
end
