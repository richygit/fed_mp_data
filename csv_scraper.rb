require 'csv'
require 'open-uri'

#get detailed info of MPs including titles and cabinet positions
class CsvScraper
  CSV_HOST = 'www.aph.gov.au'
  MP_CSV_PATH = '/~/media/03%20Senators%20and%20Members/Address%20Labels%20and%20CSV%20files/SurnameRepsCSV.csv'
  SENATOR_CSV_PATH = '/~/media/03%20Senators%20and%20Members/Address%20Labels%20and%20CSV%20files/allsenel.csv'
  MP_CSV_URL = "http://#{CSV_HOST}#{MP_CSV_PATH}"
  SENATOR_CSV_URL = "http://#{CSV_HOST}#{SENATOR_CSV_PATH}"

  def scrape
    scrape_csv(MP_CSV_URL, false).merge(scrape_csv(SENATOR_CSV_URL, true))
  end

  def scrape_csv(url, senators)
    records = {}
    csv = CSV.read(open(url), :headers => :true)
    headers = csv.headers
    csv.each do |line|
      key, record = parse_record(line, headers, senators)
      records[key] = record
    end
    records
  end

private

  def parse_record(row, headers, senator)
    record = {}
    if senator 
      key = "#{row['State']}.#{row['Surname']}.#{row['First Name']}" 
      record[:type] = 'senator'
    else
      key = row['"Electorate"']
      record[:type] = 'mp'
    end
    headers.each_with_index do |header, index|
      record[header.gsub('"', '').gsub(' ','_').downcase.to_sym] = row[index]
    end

    [key, record]
  end
end
