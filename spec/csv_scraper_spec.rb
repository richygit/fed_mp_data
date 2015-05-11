require_relative '../csv_scraper'
require 'open-uri'

describe CsvScraper do
  it "can download the CSV file" do
    VCR.turned_off do
      WebMock.allow_net_connect!
      Net::HTTP.start(CsvScraper::CSV_HOST, 80) {|http| expect(http.head(CsvScraper::CSV_PATH).code).to eq "200" }
    end
  end

  describe "#scrape", :vcr do
    it "scrapes MPs details correctly" do
      records = subject.scrape
      curtin = records["Curtin"]
      expect(curtin.to_h).to eq CURTIN_RECORD
      durack = records["Durack"]
      expect(durack.to_h).to eq DURACK_RECORD
    end

    it "scrapes the right number of MPs" do
      records = subject.scrape
      expect(records.size).to eq 150
    end
  end

  DURACK_RECORD = {
   :surname=>"Price",
   :first_name=>"Melissa",
   :other_names=>"Lee",
   :preferred_name=>"",
   :initials=>"M. L.",
   :courtesy_title=>"Ms",
   :salutation=>"Ms",
   :honorific=>"MP",
   :gender=>"FEMALE",
   :parliament_house_telephone=>"(02) 6277 4242",
   :parliament_house_fax=>"(02) 6277 8554",
   :political_party=>"LP",
   :state=>"WA",
   :electorate=>"Durack",
   :electorate_office_postal_address=>"2B/209 Foreshore Drive",
   :electorate_office_postal_suburb=>"Geraldton",
   :electorate_office_postal_state=>"WA",
   :electorate_office_postal_postcode=>"6530",
   :electorate_office_fax=>"(08) 9921 7990",
   :electorate_office_phone=>"(08) 9964 2195",
   :electorate_office_toll_free=>"",
   :parliamentary_titles=>""
  }

  CURTIN_RECORD = {
   :surname=>"Bishop",
   :first_name=>"Julie",
   :other_names=>"Isabel",
   :preferred_name=>"",
   :initials=>"J. I.",
   :courtesy_title=>"The Hon",
   :salutation=>"Ms",
   :honorific=>"MP",
   :gender=>"FEMALE",
   :parliament_house_telephone=>"(02) 6277 7500",
   :parliament_house_fax=>"(02) 6273 4112",
   :political_party=>"LP",
   :state=>"WA",
   :electorate=>"Curtin",
   :electorate_office_postal_address=>"PO Box 2010,",
   :electorate_office_postal_suburb=>"Subiaco",
   :electorate_office_postal_state=>"WA",
   :electorate_office_postal_postcode=>"6904",
   :electorate_office_fax=>"(08) 9388 0299",
   :electorate_office_phone=>"(08) 9388 0288",
   :electorate_office_toll_free=>"",
   :parliamentary_titles=>"Minister for Foreign Affairs"
  }
end
