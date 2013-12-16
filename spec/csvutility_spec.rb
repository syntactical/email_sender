require 'csvutility'
require 'csv'

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

def emptyRowWithNilsCSVFileName
	'./spec/vacation_empty_row.csv'
end

def emptyCellInRowCSVFileName
	'./spec/vacation_empty_cell.csv'
end

describe CSVUtility do

	describe '#hasAllNecessaryColumns' do
		it 'should check if all necessary columns are present in csv file' do
			csvUtility = CSVUtility.new(vacation_information[:csvFileName])
			expect(csvUtility.hasAllNecessaryColumns(vacation_information[:necessaryColumns])).to be_true
		end
	end

	describe '#hasEmptyRowsAndCells' do
		it 'should check if there are any empty cells in a row in csv file' do
			csvUtility = CSVUtility.new(emptyCellInRowCSVFileName)
			expect(csvUtility.hasEmptyRowsAndCells).to be_true
		end

		it 'should check if there are any empty rows in csv file' do
			csvUtility = CSVUtility.new(emptyRowWithNilsCSVFileName)
			expect(csvUtility.hasEmptyRowsAndCells).to be_true
		end
	end

	describe '#parse' do
		it 'should return hash of employee IDs mapped to employee information' do
			expectedParsedData = {}

			CSV.foreach(vacation_information[:csvFileName], :headers => true, :header_converters => :symbol, :converters => :all) do |row|
				expectedParsedData[row.fields[0]] = Hash[row.headers[0..-1].zip(row.fields[0..-1])]
			end

			csvUtility = CSVUtility.new(vacation_information[:csvFileName])
			actualParsedData = csvUtility.parse

			actualParsedData.each do |key, value|
				expect(actualParsedData[key]).to eq(value)
			end
		end
	end
end