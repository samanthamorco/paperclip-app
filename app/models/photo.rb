class Photo < ApplicationRecord
  before_create :capital_title
  has_attached_file :image
  validates_attachment :image, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"] }

  def capital_title
    self.title = title.capitalize
  end

end
