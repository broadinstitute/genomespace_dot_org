class Ckeditor::AttachmentFile < Ckeditor::Asset
  has_attached_file :data,
                    :url => "/attachments/:filename",
                    :path => ":rails_root/public/attachments/:filename"

  validates_attachment_size :data, :less_than => 2.gigabytes
  validates_attachment_presence :data
  do_not_validate_attachment_file_type :data

	def url_thumb
		@url_thumb ||= Ckeditor::Utils.filethumb(filename)
	end
end
