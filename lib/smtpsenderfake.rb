class STMPSender
	def sendEmail(emailContent, sender, receiver)
		Net::SMTP.start('192.168.1.102', 25, 'thoughtworks.com') do |smtp|
		  smtp.send_message(emailContent, sender, receiver )
		end			
	end
end