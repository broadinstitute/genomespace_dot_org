module SystemMessagesHelper

	def sys_message_url(system_message)
	
		return "/system-status/" + system_message.url
	end
end
