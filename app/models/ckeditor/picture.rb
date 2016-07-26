class Ckeditor::Picture < Ckeditor::Asset
  has_attached_file :data,
                    :url  => "/uploaded/:style_:basename.:extension",
                    :path => ":rails_root/public/uploaded/:style_:basename.:extension",
	                  :styles => { :content => '800>', :thumb => '118x100#' }

	validates_attachment_content_type :data, :content_type => /\Aimage/
  validates_attachment_size :data, :less_than => 2.gigabytes
  validates_attachment_presence :data
  do_not_validate_attachment_file_type :data

	def url_content
	  url(:content)
	end
end
