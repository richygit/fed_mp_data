require 'csv'
require 'open-uri'

#get detailed info of MPs including titles and cabinet positions
class CsvScraper
  CSV_HOST = 'www.aph.gov.au'
  CSV_PATH = '/~/media/03%20Senators%20and%20Members/Address%20Labels%20and%20CSV%20files/SurnameRepsCSV.csv'
  CSV_URL = "http://#{CSV_HOST}#{CSV_PATH}"

  def scrape
    records = {}
    csv = CSV.read(open(CSV_URL), :headers => :true)
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
