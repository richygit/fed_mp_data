require 'spec_helper'
require_relative '../scraper_main'

RSpec.describe ScraperMain do
  before(:each) do
    ScraperWiki.config = { db: 'data.test', default_table_name: 'data' }
    ScraperWiki::sqliteexecute("drop table if exists data")
  end

  describe "#match_on_secondary_data" do
    it "should match on surname and state" do
      pdf_record = {"electorate_tel"=>"(07) 3862 4044", "state"=>"QLD", "surname"=>"Brandis", "email"=>"senator.brandis@aph.gov.au", "type"=>"senator"}
      csv_records = {"(07) 3862 4244"=>
        {"title"=>"Senator the Hon",
         "surname"=>"Brandis",
         "first_name"=>"George",
         "other_names"=>"Henry",
         "prefered_name"=>"George",
         "initials"=>"G. H.",
         "honorifics"=>"QC",
         "salutation"=>"Senator",
         "gender"=>"MALE",
         "political_party"=>"LP",
         "state"=>"Qld",
         "electorate_addressline1"=>"349 Sandgate Road",
         "electorate_addressline2"=>nil,
         "electorate_suburb"=>"Albion",
         "electorate_state"=>"Qld",
         "electorate_postcode"=>"4010",
         "label_address"=>"PO Box 143",
         "label_suburb"=>"Albion DC",
         "label_state"=>"Qld",
         "label_postcode"=>"4010",
         "electorate_fax"=>"(07) 3862 4044",
         "electorate_telephone"=>"(07) 3862 4244",
         "electorate_toll_free"=>nil,
         "parliamentary_titles"=>"Attorney-General, Minister for Arts, Vice-President of the Executive Council, Deputy Leader of the Government in the Senate",
         "type"=>"senator"}}
      subject.match_on_secondary_data(csv_records, pdf_record)
      expect(csv_records["(07) 3862 4244"]).to eq({"title"=>"Senator the Hon",
         "surname"=>"Brandis",
         "first_name"=>"George",
         "other_names"=>"Henry",
         "prefered_name"=>"George",
         "initials"=>"G. H.",
         "honorifics"=>"QC",
         "salutation"=>"Senator",
         "gender"=>"MALE",
         "political_party"=>"LP",
         "state"=>"QLD",
         "electorate_addressline1"=>"349 Sandgate Road",
         "electorate_addressline2"=>nil,
         "electorate_suburb"=>"Albion",
         "electorate_state"=>"Qld",
         "electorate_postcode"=>"4010",
         "label_address"=>"PO Box 143",
         "label_suburb"=>"Albion DC",
         "label_state"=>"Qld",
         "label_postcode"=>"4010",
         "electorate_fax"=>"(07) 3862 4044",
         "electorate_telephone"=>"(07) 3862 4244",
         "electorate_toll_free"=>nil,
         "parliamentary_titles"=>"Attorney-General, Minister for Arts, Vice-President of the Executive Council, Deputy Leader of the Government in the Senate",
         "type"=>"senator",
         "electorate_tel"=>"(07) 3862 4044",
         "email"=>"senator.brandis@aph.gov.au"})
    end
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
