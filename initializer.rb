require 'rubygems'
Gem.use_paths(nil, Gem.path << 'gems/')

require './lib/email_sender.rb'

csvFileName = ARGF.argv.join(' ')

vacation_information = {csvFileName: csvFileName,
							necessaryColumns: {name: 'name',
								first_name: 'first name',
								accrual_rate: 'accrual rate',
								start_date: 'start date',
								vacation_balance: 'vacation balance',
								email: 'email',
							}
						}

puts "Now sending Vacation Emails"
EmailSender.new(vacation_information, STMPSender.new).start