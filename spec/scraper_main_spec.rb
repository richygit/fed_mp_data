require 'spec_helper'
require_relative '../scraper_main'

RSpec.describe ScraperMain do
  before(:each) do
    ScraperWiki.config = { db: 'data.test', default_table_name: 'data' }
    ScraperWiki::sqliteexecute("drop table if exists data")
  end

  describe "#merge" do
    before(:each) do
      allow_any_instance_of(CsvScraper).to receive(:scrape).and_return()
      allow_any_instance_of(PdfMpScraper).to receive(:scrape).and_return()
      allow_any_instance_of(PdfSenatorScraper).to receive(:scrape).and_return()
    end

    it "should merge all data" do
      src = {'Price-Durack' => DURACK_RECORD, 'Abetz-TAS' => ABETZ_RECORD}
      dest = {'Price-Durack' => {"email"=>"Melissa.Price.MP@aph.gov.au", "electorate"=>"Durack", "last_name"=>"Price", "type"=>"mp"}, "Abetz-TAS" => {"state"=>"TAS", "last_name"=>"Abetz", "email"=>"senator.abetz@aph.gov.au", "type"=>"senator"}}
      subject.merge(src, dest)
      expect(dest['Price-Durack']).to eq(DURACK_RESULT)
      expect(dest['Abetz-TAS']).to eq(ABETZ_RESULT)
    end
  end

  describe "full test", :vcr do
    it "should merge all data" do
      subject.main
      records = ScraperWiki::select('* FROM data')
      expect(records.count).to eq (150+76)
      durack = ScraperWiki::select('* FROM data where electorate = "Durack"')
      expect(durack.first.to_h).to eq(DURACK_RESULT)
      abetz = ScraperWiki::select('* FROM data where last_name = "Abetz"')
      expect(abetz.first.to_h).to eq(ABETZ_RESULT)
    end
  end
  

  ABETZ_RESULT = {"last_name"=>"Abetz", "first_name"=>"Eric", "parliament_phone"=>nil, "parliament_fax"=>nil, "party"=>"LP", "electorate"=>nil, "office_address"=>"Highbury House, 136 Davey Street", "office_suburb"=>"Hobart", "office_state"=>"Tas", "office_postcode"=>"7000", "office_fax"=>"(03) 6224 3709", "office_phone"=>"(03) 6224 3707", "type"=>"senator", "email"=>"senator.abetz@aph.gov.au", "state"=>"TAS", "mailing_address"=>"GPO Box 1675", "mailing_suburb"=>"Hobart", "mailing_state"=>"Tas", "mailing_postcode"=>"7001"}

  DURACK_RESULT = {"last_name"=>"Price", "first_name"=>"Melissa", "parliament_phone"=>"(02) 6277 4242", "parliament_fax"=>"(02) 6277 8554", "party"=>"LP", "electorate"=>"Durack", "office_address"=>"2B/209 Foreshore Drive", "office_suburb"=>"Geraldton", "office_state"=>"WA", "office_postcode"=>"6530", "office_fax"=>"(08) 9921 7990", "office_phone"=>"(08) 9964 2195", "type"=>"mp", "email"=>"Melissa.Price.MP@aph.gov.au", "state"=>nil, "mailing_address"=>nil, "mailing_suburb"=>nil, "mailing_state"=>nil, "mailing_postcode"=>nil}

  DURACK_RECORD = {"last_name"=>"Price",
   "first_name"=>"Melissa",
   "parliament_phone"=>"(02) 6277 4242",
   "parliament_fax"=>"(02) 6277 8554",
   "party"=>"LP",
   "electorate"=>"Durack",
   "office_address"=>"2B/209 Foreshore Drive",
   "office_suburb"=>"Geraldton",
   "office_state"=>"WA",
   "office_postcode"=>"6530",
   "office_fax"=>"(08) 9921 7990",
   "office_phone"=>"(08) 9964 2195",
   "type"=>"mp"}

  ABETZ_RECORD = {"last_name"=>"Abetz",
   "first_name"=>"Eric",
   "party"=>"LP",
   "state"=>"Tas",
   "office_address"=>"Highbury House, 136 Davey Street",
   "office_suburb"=>"Hobart",
   "office_state"=>"Tas",
   "office_postcode"=>"7000",
   "mailing_address"=>"GPO Box 1675",
   "mailing_suburb"=>"Hobart",
   "mailing_state"=>"Tas",
   "mailing_postcode"=>"7001",
   "office_fax"=>"(03) 6224 3709",
   "office_phone"=>"(03) 6224 3707",
   "type"=>"senator"}
  
end
