require_relative '../csv_scraper'
require 'open-uri'

describe CsvScraper, focus: true do
  it "can download the CSV files" do
    VCR.turned_off do
      WebMock.allow_net_connect!
      Net::HTTP.start(CsvScraper::CSV_HOST, 80) {|http| expect(http.head(CsvScraper::MP_CSV_PATH).code).to eq "200" }
      Net::HTTP.start(CsvScraper::CSV_HOST, 80) {|http| expect(http.head(CsvScraper::SENATOR_CSV_PATH).code).to eq "200" }
    end
  end

  describe "#scrape", :vcr do
    it "scrapes details correctly" do
      records = subject.scrape
      curtin = records["Curtin"]
      expect(curtin.to_h).to eq CURTIN_RECORD
      durack = records["Durack"]
      expect(durack.to_h).to eq DURACK_RECORD
      xenophon = records["SA.Nicholas Xenophon"]
      expect(xenophon.to_h).to eq XENOPHON_RECORD
      parry = records["Tas.Stephen Parry"]
      expect(parry.to_h).to eq PARRY_RECORD
    end

    it "scrapes the right number of MPs and senators" do
      records = subject.scrape
      expect(records.select{ |_,v| v[:type] == 'mp'}.count).to eq 150
      expect(records.select{ |_,v| v[:type] == 'senator'}.count).to eq 75
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
   :parliamentary_titles=>"",
   :type=>"mp"
  }

  CURTIN_RECORD = {
   :surname=>"Bishop",
   :first_name=>"Julie",
   :other_names=>"Isabel",
   :preferred_name=>"",
   :initials=>"J. I.",
   :courtesy_title=>"Hon",
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
   :parliamentary_titles=>"Minister for Foreign Affairs",
   :type=>"mp"
  }

  XENOPHON_RECORD = 
  {:type=>"senator",
   :title=>"Senator",
   :surname=>"Xenophon",
   :first_name=>"Nicholas",
   :other_names=>nil,
   :prefered_name=>"Nick",
   :initials=>"N.",
   :honorifics=>nil,
   :salutation=>"Senator",
   :gender=>"MALE",
   :political_party=>"Ind.",
   :state=>"SA",
   :electorate_addressline1=>"Level 2",
   :electorate_addressline2=>"31 Ebenezer Place",
   :electorate_suburb=>"Adelaide",
   :electorate_state=>"SA",
   :electorate_postcode=>"5000",
   :label_address=>"Level 2, 31 Ebenezer Place",
   :label_suburb=>"Adelaide",
   :label_state=>"SA",
   :label_postcode=>"5000",
   :electorate_fax=>"(08) 8232 3744",
   :electorate_telephone=>"(08) 8232 1144",
   :electorate_toll_free=>"1300 556 115",
   :parliamentary_titles=>nil}
   
   PARRY_RECORD =
  {:type=>"senator",
   :title=>"Senator the Hon",
   :surname=>"Parry",
   :first_name=>"Stephen",
   :other_names=>nil,
   :prefered_name=>"Stephen",
   :initials=>"S.",
   :honorifics=>nil,
   :salutation=>"Senator",
   :gender=>"MALE",
   :political_party=>"LP",
   :state=>"Tas",
   :electorate_addressline1=>"33 George Street",
   :electorate_addressline2=>nil,
   :electorate_suburb=>"Launceston",
   :electorate_state=>"Tas",
   :electorate_postcode=>"7250",
   :label_address=>"33 George Street",
   :label_suburb=>"Launceston",
   :label_state=>"Tas",
   :label_postcode=>"7250",
   :electorate_fax=>"(03) 6334 1624",
   :electorate_telephone=>"(03) 6334 1755",
   :electorate_toll_free=>"1300 760 788",
   :parliamentary_titles=>"President of the Senate"}
end
