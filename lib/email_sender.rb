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
		@marker = "AUNIQUEMARKER"
	end

	def renderEmailContent(locals)
body = <<-EOF
Hi #{locals[:first_name]},

The JCs have created a vacation balance calculator called RnR (add link here)

The following is the information you will need to use the site:

Start date: #{locals[:start_date]}
Rollover days as of January 1, 2014:  #{locals[:vacation_balance]}
Initial accrual rate: #{locals[:accrual_rate]}

All employees begin the year with 7 personal days.  If your start date is after September 1
of a given year, you are allotted 3 personal days for that year.  Similary, if your start date
is between May 1 and August 31, you are allotted 4 personal days for that year.  Employees
that start between January 1 and April 31 have 7 personal days.

Note: This calculator is meant to be a tool and does not give an official vacation balance.
Please inquire at TKTKTKTKTKTKTKTKKTKTKTKTKTKTK for official vacation balances.

Thank you,

Barbara Walberg

EOF

emailInformation = <<-EOF
From: Barbara Walberg <bwalberg@thoughtworks.com>
To: #{locals[:name]} <#{locals[:email]}>
Subject: Your Vacation Balance
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary=#{@marker}
--#{@marker}
EOF

content = <<-EOF
Content-Type: text/plain
Content-Transfer-Encoding:8bit

#{body}
--#{@marker}
EOF

		emailInformation + content
	end

	def sendEmail(emailContent, sender, receiver)
		@smtpSender.sendEmail(emailContent, sender, receiver)
	end

	def start(output = Output.new)

		if !hasAllNecessaryColumns
			output.display "Invalid columns in CSV. The following columns must be present in the CSV:"
			@necessaryColumns.each { |key, value| puts value}
			return
		end

		if hasEmptyRowsAndCells
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


