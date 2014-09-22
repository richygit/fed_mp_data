require 'csv'
require 'open-uri'

class CsvScraper
  FED_MP_URL = 'http://www.aph.gov.au/~/media/03%20Senators%20and%20Members/Address%20Labels%20and%20CSV%20files/SurnameRepsCSV.csv'

  def scrape
    records = {}
    csv = CSV.read(open(FED_MP_URL), :headers => :true)
    @headers = csv.headers
    csv.each do |line|
      electorate, record = parse_record(line)
      records[electorate] = record
    end
    records
  end

private

  def parse_record(row)
    record = {}
    electorate = row['"Electorate"']
    @headers.each_with_index do |header, index|
      record[header.gsub('"', '').gsub(' ','_').downcase.to_sym] = row[index]
    end

    [electorate, record]
  end
end
