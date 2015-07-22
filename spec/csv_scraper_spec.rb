require_relative '../csv_scraper'
require 'open-uri'

describe CsvScraper do
  it "can download the CSV files" do
    VCR.turned_off do
      WebMock.allow_net_connect!
      Net::HTTP.start(CsvScraper::CSV_HOST, 80) {|http| expect(http.head(CsvScraper::MP_CSV_PATH).code).to eq "200" }
      Net::HTTP.start(CsvScraper::CSV_HOST, 80) {|http| expect(http.head(CsvScraper::SENATOR_CSV_PATH).code).to eq "200" }
    end
  end

  describe "#senator_electorate_address" do
    it "should combine address entries" do
      expect(subject.send(:senator_electorate_address, ABETZ_RECORD)).to eq('Highbury House, 136 Davey Street')
      expect(subject.send(:senator_electorate_address, BERNARDI_RECORD)).to eq('36 Grenfell Street')
    end
  end

  describe "#scrape", :vcr do
    it "scrapes details correctly" do
      records = subject.scrape
      curtin = records["(02) 6277 7500"]
      expect(curtin.to_h).to eq CURTIN_RECORD
      xenophon = records["(08) 8232 1144"]
      expect(xenophon.to_h).to eq XENOPHON_RECORD
    end

    it "scrapes the right number of MPs and senators" do
      records = subject.scrape
      expect(records.select{ |_,v| v['type'] == 'mp'}.count).to eq 150
      expect(records.select{ |_,v| v['type'] == 'senator'}.count).to eq 77
    end
  end

  BERNARDI_RECORD = {"Title"=>"Senator",
 "Surname"=>"Bernardi",
 "First Name"=>"Cory",
 "Other Names"=>nil,
 "Prefered Name"=>"Cory",
 "Initials"=>"C.",
 "Honorifics"=>nil,
 "Salutation"=>"Senator",
 "Gender"=>"MALE",
 "Political Party"=>"LP",
 "State"=>"SA",
 "Electorate AddressLine1"=>"36 Grenfell Street",
 "Electorate AddressLine2"=>nil,
 "Electorate Suburb"=>"Kent Town",
 "Electorate State"=>"SA",
 "Electorate Postcode"=>"5067",
 "Label Address"=>"PO Box 2192",
 "Label Suburb"=>"Kent Town",
 "Label State"=>"SA",
 "Label Postcode"=>"5071",
 "Electorate Fax"=>"(08) 8362 8579",
 "Electorate Telephone"=>"(08) 8362 8600",
 "Electorate Toll Free"=>"1300 880 569",
 "Parliamentary Titles"=>nil}

  ABETZ_RECORD = {"Title"=>"Senator the Hon",
     "Surname"=>"Abetz",
     "First Name"=>"Eric",
     "Other Names"=>nil,
     "Prefered Name"=>"Eric",
     "Initials"=>"E.",
     "Honorifics"=>nil,
     "Salutation"=>"Senator",
     "Gender"=>"MALE",
     "Political Party"=>"LP",
     "State"=>"Tas",
     "Electorate AddressLine1"=>"Highbury House",
     "Electorate AddressLine2"=>"136 Davey Street",
     "Electorate Suburb"=>"Hobart",
     "Electorate State"=>"Tas",
     "Electorate Postcode"=>"7000",
     "Label Address"=>"GPO Box 1675",
     "Label Suburb"=>"Hobart",
     "Label State"=>"Tas",
     "Label Postcode"=>"7001",
     "Electorate Fax"=>"(03) 6224 3709",
     "Electorate Telephone"=>"(03) 6224 3707",
     "Electorate Toll Free"=>"1300 132 493",
     "Parliamentary Titles"=>"Minister for Employment, Minister Assisting the Prime Minister for the Public Service, Leader of the Government in the Senate"}

  CURTIN_RECORD = {"last_name"=>"Bishop", "first_name"=>"Julie", "parliament_phone"=>"(02) 6277 7500", "parliament_fax"=>"(02) 6273 4112", "party"=>"LP", "electorate"=>"Curtin", "office_address"=>"PO Box 2010,", "office_suburb"=>"Subiaco", "office_state"=>"WA", "office_postcode"=>"6904", "office_fax"=>"(08) 9388 0299", "office_phone"=>"(08) 9388 0288", "type"=>"mp"}

  XENOPHON_RECORD = {"last_name"=>"Xenophon", "first_name"=>"Nicholas", "party"=>"Ind.", "state"=>"SA", "office_address"=>"Level 2, 31 Ebenezer Place", "office_suburb"=>"Adelaide", "office_state"=>"SA", "office_postcode"=>"5000", "mailing_address"=>"Level 2, 31 Ebenezer Place", "mailing_suburb"=>"Adelaide", "mailing_state"=>"SA", "mailing_postcode"=>"5000", "office_fax"=>"(08) 8232 3744", "office_phone"=>"(08) 8232 1144", "type"=>"senator"} 
end
