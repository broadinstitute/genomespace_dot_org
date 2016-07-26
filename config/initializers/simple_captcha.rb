# SimpleCaptcha.setup do |captcha_config|
# 	captcha_config.image_style = "random"
# 	captcha_config.distortion = "random"
# 	captcha_config.tmp_path = Rails.root + 'tmp/simple_captcha'
# 	if Rails.env == "development"
# 		captcha_config.image_magick_path = "/usr/local/bin"
# 	else
# 		captcha_config.image_magick_path = "/broad/software/free/Linux/redhat_5_x86_64/pkgs/imagemagick_6.7.3-1/bin"
# 	end
# end