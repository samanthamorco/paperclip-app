class Upload < ApplicationRecord
  has_attached_file :document
  validates_attachment :document, content_type: { content_type: [
            "application/pdf",
            "application/vnd.ms-excel",     
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            "application/msword", 
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document", 
            "text/plain"] }
end
