class Profile < ActiveRecord::Base
  belongs_to :person
  belongs_to :location
  accepts_nested_attributes_for :location
  before_validation :strip_and_downcase_name
  validates_presence_of :name
  validates_length_of :name, :maximum => 20

  def strip_and_downcase_name
    if name.present?
      name.strip!
      name.downcase!
    end
  end

  def image_url(size = :thumb_large)
    result = if size == :thumb_medium && self[:image_url_medium]
               self[:image_url_medium]
             elsif size == :thumb_small && self[:image_url_small]
               self[:image_url_small]
             else
               self[:image_url]
             end
    result || '/images/user/default_small.png'
  end
end
