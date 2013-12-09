Gem.use_paths(nil, Gem.path << 'gems/')

require 'csv'
require 'ostruct'
require 'erb'
require 'net/smtp'

class Output
  def display(message)
    puts message
  end
end

class STMPSenderFake
	def sendEmail(emailContent, sender, receiver)
	end
end

class STMPSender
	def sendEmail(emailContent, sender, receiver)
		Net::SMTP.start('192.168.1.102', 25, 'thoughtworks.com') do |smtp|
		  smtp.send_message(emailContent, sender, receiver )
		end			
	end
end

class EmailSender

	def initialize(letterConfiguration, smtpSender = STMPSenderFake.new )
		@csvFileName = letterConfiguration[:csvFileName]
		@necessaryColumns = letterConfiguration[:necessaryColumns]
		@smtpSender = smtpSender
		@marker = "AUNIQUEMARKER"
	end

	def getHeaders(csvFileName = @csvFileName)
		CSV.read(csvFileName, :encoding => 'windows-1251:utf-8').shift.map{|x| x.downcase}
	end

	def hasAllNecessaryColumns(csvFileName = @csvFileName)
		@necessaryColumns.all? { |key, value| getHeaders.include?(value) }
	end

	def hasEmptyRowsAndCells(csvFileName = @csvFileName)
		parse(csvFileName).each_value do |employeeInfo|
			employeeInfo.each_value do |cell|
				return true if cell.nil?
			end
		end
		false
	end

	def parse(csvFileName = @csvFileName)
		employees = {}

		CSV.foreach(csvFileName, :headers => true, :header_converters => :symbol, :converters => :all, :encoding => 'windows-1251:utf-8') do |row|
			employees[row.fields[3]] = Hash[row.headers[0..-1].zip(row.fields[0..-1])]
		end

		employees
	end

	def renderEmailContent(locals)
body = <<-EOF
Hi #{locals[:first_name]},

The following is the information you will need to use the RnR app:

Start date: #{locals[:start_date]}
Rollover days as of January 1, 2014:  #{locals[:vacation_balance]}
Initial accrual rate: #{locals[:accrual_rate]}

Thank you,

Barbara Walberg

EOF

emailInformation = <<-EOF
From: Barbara Walberg <bwalberg@thoughtworks.com>
To: #{locals[:name]} <#{locals[:email]}>
Subject: RnR Information
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


