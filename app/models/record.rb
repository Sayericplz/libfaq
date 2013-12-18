class Record < ActiveRecord::Base
  belongs_to :faq
  attr_accessible :count, :thedate
end
