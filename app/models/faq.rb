class Faq < ActiveRecord::Base
  attr_accessible :answer, :answerdate, :checkdate, :checkperson, :enable, :hit, :keywords, :question, :questiondate
  validates :question,	:presence => true
  validates :hit, :presence => true,
  								:numericality => { :only_integer => true }
end
