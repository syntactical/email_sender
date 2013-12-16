require 'email_sender'
require 'pdf/reader'
require 'stringio'

def vacation_information 
 	{			csvFileName: './spec/vacation_test.csv',
 				htmlFileName: './html/raise_letter.html',
 				necessaryColumns:
								{name: 'name',
								first_name: 'first name',
								accrual_rate: 'accrual rate',
								start_date: 'start date',
								vacation_balance: 'vacation balance',
								email: 'email'}
	}
end

def emailLocals
	{ 	name: "Gregory Dutcher",
		first_name: "Gregory",
		email: "gdutcher@thoughtworks.com",
		start_date: "10.31.2013",
		vacation_balance: "10.3",
		accrual_rate: "10"
	}
end

def wrongColumnsCSVFileName
	'./spec/wrong_columns.csv'
end

def columnsFormattedImproperlyCSVFileName
	'./spec/badly_formatted_columns.csv'
end

def emptyRowWithNilsCSVFileName
	'./spec/vacation_empty_row.csv'
end

def emptyCellInRowCSVFileName
	'./spec/vacation_empty_cell.csv'
end

describe EmailSender do

	before(:each) do
		@emailSender = EmailSender.new(vacation_information)
	end

	describe 'The SMTP Email sending functionality'	do

		describe '#formatEmailContent' do
			it 'should put necessary fields into content of email message' do
				emailContent = @emailSender.renderEmailContent(emailLocals)
				emailLocals.each do |key, value|
					expect(emailContent).to include(value)
				end
			end
		end

		describe '#sendEmail' do
			it "should send an email with the right email content, sender and receiver information" do
				smtpSender = double("smtpSender")

				emailContent = @emailSender.renderEmailContent(emailLocals)

				sender = "asaavedr@thoughtworks.com"
				receivers = ["gdutcher@thoughtworks.com", "x@thoughtworks.com"]

				smtpSender.should_receive(:sendEmail).with(emailContent, sender, receivers)
		
				emailSender = EmailSender.new(vacation_information, smtpSender)
				emailSender.sendEmail(emailContent, sender, receivers)
			end	
		end

		describe '#start' do

			before(:each) do
				@output = double('output')
			end

			it 'should not display invalid column error message if given spreadsheet with valid column headers' do
				@output.should_not_receive(:display).with("Invalid column headers in CSV")
				@emailSender.start(@output)	
			end

			it 'should display email sent message' do
				@output.should_receive(:display).at_least(:once).with(any_args())
				EmailSender.new(vacation_information, STMPSenderFake.new).start(@output)
			end

			it 'should display error message if unable to process CSV because of empty rows or cells' do
				@output.should_receive(:display).with("Unable to process CSV file because of empty cells in file.")		

			 	invalidFileConfiguration = vacation_information.merge(csvFileName: emptyRowWithNilsCSVFileName)

				EmailSender.new(invalidFileConfiguration).start(@output)
			end
		end 
	end	
end	
