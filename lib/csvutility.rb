require 'csv'

class CSVUtility

	def initialize(csvFileName)
		@csvFileName = csvFileName
	end

	def getHeaders(csvFileName = @csvFileName)
		CSV.read(csvFileName, :encoding => 'windows-1251:utf-8').shift.map{|x| x.downcase}
	end

	def hasAllNecessaryColumns(necessaryColumns, csvFileName = @csvFileName)
		necessaryColumns.all? { |key, value| getHeaders.include?(value) }
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

		CSV.foreach(csvFileName, :headers => true, :header_converters => :symbol,
							:converters => :all, :encoding => 'windows-1251:utf-8') do |row|
			employees[row.fields[0]] = Hash[row.headers[0..-1].zip(row.fields[0..-1])]
		end

		employees
	end
end