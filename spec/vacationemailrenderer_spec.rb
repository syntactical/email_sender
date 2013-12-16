require 'vacationemailrenderer'

def emailLocals
	{ 	name: "Gregory Dutcher",
		first_name: "Gregory",
		email: "gdutcher@thoughtworks.com",
		start_date: "10.31.2013",
		vacation_balance: "10.3",
		accrual_rate: "10"
	}
end

describe VacationEmailRenderer do
	describe '#formatEmailContent' do
		it 'should put necessary fields into content of email message' do
			emailContent = VacationEmailRenderer.new.renderEmailContent(emailLocals)
			
			emailLocals.each do |key, value|
				expect(emailContent).to include(value)
			end
		end
	end
end