require 'csv'
require 'open-uri'
require './logging'
require_relative 'scraper_helper'

#get detailed info of MPs including titles and cabinet positions
class CsvScraper < Logging
  include ScraperHelper

  CSV_HOST = 'www.aph.gov.au'
  MP_CSV_PATH = '/~/media/03%20Senators%20and%20Members/Address%20Labels%20and%20CSV%20files/SurnameRepsCSV.csv'
  SENATOR_CSV_PATH = '/~/media/03%20Senators%20and%20Members/Address%20Labels%20and%20CSV%20files/allsenel.csv'
  MP_CSV_URL = "http://#{CSV_HOST}#{MP_CSV_PATH}"
  SENATOR_CSV_URL = "http://#{CSV_HOST}#{SENATOR_CSV_PATH}"

  def scrape
    scrape_csv(MP_CSV_URL, :representatives).merge(scrape_csv(SENATOR_CSV_URL, :senate))
  end

  def scrape_csv(url, house)
    records = {}
    csv = CSV.read(open(url), :headers => :true)
    csv.each do |line|
      if house == :representatives
        key, record = parse_mp_record(line)
      else
        key, record = parse_senator_record(line)
      end
      @logger.warn("Key clash! #{key}") if records[key]
      records[key] = record
    end
    records
  end

private

  def senator_electorate_address(row)
    address = row["Electorate AddressLine1"]
    if row["Electorate AddressLine2"] && row["Electorate AddressLine2"].strip.length > 0
      address = "#{address}, #{row["Electorate AddressLine2"]}"
    end
    address.squeeze(' ').strip
  end

  def parse_senator_record(row)
    record = {}
    record['last_name'] = row["Surname"]
    record['first_name'] = row["First Name"]
    record['party'] = row["Political Party"]
    record['state'] = row["State"]
    record['office_address'] = senator_electorate_address(row)
    record['office_suburb'] = row["Electorate Suburb"]
    record['office_state'] = row["Electorate State"]
    record['office_postcode'] = row["Electorate Postcode"]
    record['mailing_address'] = row["Label Address"]
    record['mailing_suburb'] = row["Label Suburb"]
    record['mailing_state'] = row["Label State"]
    record['mailing_postcode'] = row["Label Postcode"]
    record['office_fax'] = row["Electorate Fax"]
    record['office_phone'] = row["Electorate Telephone"]
  
    key = senator_key(record['last_name'], record['state'])
    record['type'] = 'senator'
    [key, record]
  end

  def parse_mp_record(row)
    record = {}
    record['last_name'] = row["\"Surname\""]
    record['first_name'] = row["\"First Name\""]
    record['parliament_phone'] = row["\"Parliament House Telephone\""]
    record['parliament_fax'] = row["\"Parliament House Fax\""]
    record['party'] = row["\"Political Party\""]
    record['electorate'] = row["\"Electorate\""]
    record['office_address'] = row["\"Electorate Office Postal Address\""]
    record['office_suburb'] = row["\"Electorate Office Postal Suburb\""]
    record['office_state'] = row["\"Electorate Office Postal State\""]
    record['office_postcode'] = row["\"Electorate Office Postal PostCode\""]
    record['office_fax'] = row["\"Electorate Office Fax\""]
    record['office_phone'] = row["\"Electorate Office Phone\""]

    key = mp_key(record['last_name'], record['electorate'])
    record['type'] = 'mp'
    [key, record]
  end

end
