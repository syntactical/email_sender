Gem.use_paths(nil, Gem.path << 'gems/')

require 'csv'
require 'ostruct'
require 'erb'
require 'net/smtp'
require 'output'
require 'smtpSender'
require 'smtpSenderFake'

class EmailSender

	def initialize(letterConfiguration, smtpSender = STMPSenderFake.new)
		@csvUtility = letterConfiguration[:csvUtility]
		@necessaryColumns = letterConfiguration[:necessaryColumns]
		@smtpSender = smtpSender
	end

	def sendEmail(emailContent, sender, receiver)
		@smtpSender.sendEmail(emailContent, sender, receiver)
	end

	def start(output = Output.new)

		if !@csvUtility.hasAllNecessaryColumns(@necessaryColumns)
			output.display "Invalid columns in CSV. The following columns must be present in the CSV:"
			@necessaryColumns.each { |key, value| puts value}
			return
		end

		if @csvUtility.hasEmptyRowsAndCells
			output.display "Unable to process CSV file because of empty cells in file."
			return
		end

		employees = parse
		employees.each do |id, employee|

			emailContent = renderEmailContent(employee)
			sender = "bwalberg@thoughtworks.com"
			receiver = employee[:email]

			begin
				sendEmail(emailContent, sender, receiver)
				output.display("Sent email to " + employee[:name])

				rescue Timeout::Error			
		  			abort("Unable to send emails. Check that you are connected to twdata.")		
				rescue Exception => e 
		 			abort("Unable to send emails. " + e.to_s)	 
		  	end
		end

		output.display("Emails sent!")
	end
end


