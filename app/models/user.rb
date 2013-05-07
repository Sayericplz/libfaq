class User < ActiveRecord::Base
  attr_accessible :password, :username
  validates :password, :presence => true
  validates :username, :presence => true,
                       :uniqueness => true
end
