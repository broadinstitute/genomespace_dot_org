atom_feed :language => 'en-US' do |feed| 
  feed.title "GenomeSpace System Status"
  feed.updated @system_messages.order('id desc').first.created_at 
  @system_messages.each do |system_message| 
    feed.entry(system_message, :url => sys_message_url(system_message)) do |entry| 
			entry.title "GenomeSpace System Status as of #{system_message.display_date}, Priority: #{system_message.priority.capitalize}"
			entry.author "The GenomeSpace Team"
      entry.content system_message.content, :type => "html"
    end 
  end 
end 
