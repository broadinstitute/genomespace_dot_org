#! /usr/bin/env ruby

RAILS_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
Dir.chdir(RAILS_ROOT)

require "open3"
require "net/smtp"

# set up env vars
@ps = []
@to_email = "bistline@broadinstitute.org"
@env = "production"
@port = 3000
@current_date = Time.now.strftime("%B %d, %Y %H:%M:%S")
@i = false

# parse args
ARGV.each do |arg|
	arg =~ /\-e\=/ ? @env = arg.gsub(/\-e\=/, "") : nil
	arg =~ /\-p\=/ ? @port = arg.gsub(/\-p\=/, "") : nil
	arg =~ /\-i/ ? @i = true : nil
end

# find all running processes for user
Open3.popen3("ps x | awk '{print substr($0, index($0,$5))}'") do |stdin, stdout, stderr|
	stdout.each_line {|line| @ps << line.chomp}
end

# if rails server is running on specified port and env, script will exit silently
@ps.each do |p|
	if p.include?("ruby script/rails s -e #{@env} -d -p #{@port}")
		if @i == true
			puts "The server is running"
		end
		exit 0
	end
end

# no running server was found, so server is rebooted
system "#{RAILS_ROOT}/script/soft_reboot -e #{@env} -p #{@port}"

# email with message notifying of dead server
Net::SMTP.start('smtp.broadinstitute.org', 25) do |smtp|
	smtp.open_message_stream("no-reply@gparc.org", @to_email) do |contents|
		contents.puts "From: no-reply@genomespace.org"
		contents.puts "To: #{@to_email}"
		contents.puts "Content-Type: text/html; charset=utf-8"
		contents.puts "Subject: GenomeSpace server died at #{@current_date}"
		contents.puts ""
		contents.puts "The server died and had to be restarted at #{@current_date}."
	end
end