require 'spec_helper'
require_relative '../scraper_main'

RSpec.describe ScraperMain do
  before(:each) do
    ScraperWiki.config = { db: 'data.test', default_table_name: 'data' }
    ScraperWiki::sqliteexecute("drop table if exists data")
  end

  describe "#main" do
    before(:each) do
      allow_any_instance_of(CsvScraper).to receive(:scrape).and_return({durack: DURACK_RECORD})
      allow_any_instance_of(PdfScraper).to receive(:scrape).and_return({durack: {email: 'Melissa.Price.MP@aph.gov.au'} })
    end

    it "should merge data from each scraper" do
      subject.main
      grayndler = ScraperWiki::select('* FROM data WHERE electorate = "Durack"')
      expect(grayndler.first).to eq({"surname"=>"Price", "first_name"=>"Melissa", "other_names"=>"Lee", "preferred_name"=>"", "initials"=>"M. L.", "courtesy_title"=>"Ms", "salutation"=>"Ms", "honorific"=>"MP", "gender"=>"FEMALE", "parliament_house_telephone"=>"(02) 6277 4242", "parliament_house_fax"=>"(02) 6277 8554", "political_party"=>"LP", "state"=>"WA", "electorate"=>"Durack", "electorate_office_postal_address"=>"2B/209 Foreshore Drive", "electorate_office_postal_suburb"=>"Geraldton", "electorate_office_postal_state"=>"WA", "electorate_office_postal_postcode"=>"6530", "electorate_office_fax"=>"(08) 9921 7990", "electorate_office_phone"=>"(08) 9964 2195", "electorate_office_toll_free"=>"", "parliamentary_titles"=>"", "type"=>"mp", "email"=>"Melissa.Price.MP@aph.gov.au"})
    end
  end

  describe "full test", :vcr do
    it "should merge all data" do
      subject.main
      records = ScraperWiki::select('* FROM data')
      expect(records.count).to eq (150+77)
    end
  end
  

  DURACK_RECORD = {"surname"=>"Price", "first_name"=>"Melissa", "other_names"=>"Lee", "preferred_name"=>"", "initials"=>"M. L.", "courtesy_title"=>"Ms", "salutation"=>"Ms", "honorific"=>"MP", "gender"=>"FEMALE", "parliament_house_telephone"=>"(02) 6277 4242", "parliament_house_fax"=>"(02) 6277 8554", "political_party"=>"LP", "state"=>"WA", "electorate"=>"Durack", "electorate_office_postal_address"=>"2B/209 Foreshore Drive", "electorate_office_postal_suburb"=>"Geraldton", "electorate_office_postal_state"=>"WA", "electorate_office_postal_postcode"=>"6530", "electorate_office_fax"=>"(08) 9921 7990", "electorate_office_phone"=>"(08) 9964 2195", "electorate_office_toll_free"=>"", "parliamentary_titles"=>"", 'type'=>'mp'}
end
