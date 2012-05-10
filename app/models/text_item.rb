class TextItem < ActiveRecord::Base
  attr_accessible :body, :user_id
  
  validates_presence_of :body
  validates_length_of :body, :maximum => 512
  has_many :stream_items, :as => :streamable
  belongs_to :user
end
