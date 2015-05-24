require 'spec_helper'
require_relative '../web_scraper'

RSpec.describe WebScraper do
  it "can download the search page" do
    VCR.turned_off do
      WebMock.allow_net_connect!
      Net::HTTP.start(WebScraper::SEARCH_HOST, 80) {|http| expect(http.head(WebScraper::SEARCH_PATH).code).to eq "200" }
    end
  end

  describe "#scrape_mps", :vcr do
    it "finds the right MP data" do
      records = subject.scrape_mps

      expect(records.count).to eq 150
      expect(records["Hasluck"]).to eq HASLUCK_RECORD
      expect(records["Grayndler"]).to eq GRAYNDLER_RECORD
    end
  end

  describe "#scrape_senators", :vcr do
    it "finds the right senator data" do
      records = subject.scrape_senators

      expect(records.count).to eq 75
      expect(records["sa.cory bernardi"]).to eq CORY_BERNARDI_RECORD
      expect(records["sa.penny wright"]).to eq PENNY_WRIGHT_RECORD
    end
  end

  CORY_BERNARDI_RECORD = {
   :house=>"senate",
   :aph_id=>"G0D",
   :full_name=>"Senator Cory Bernardi",
   :electorate=>"South Australia",
   :party=>"Liberal Party of Australia",
   :profile_page=>"http://www.aph.gov.au/Senators_and_Members/Parliamentarian?MPID=G0D",
   :contact_page=>"http://www.aph.gov.au/Senators_and_Members/Contact_Senator_or_Member?MPID=G0D",
   :photo_url=>"http://parlinfo.aph.gov.au/parlInfo/download/handbook/allmps/G0D/upload_ref_binary/G0D.JPG",
   :email=>nil,
   :facebook=>nil,
   :twitter=>nil,
   :website=>"http://www.senatorbernardi.com/",
   "parliament_telephone"=>"(02) 6277 3278",
   "parliament_fax"=>"(02) 6277 5783"}

  PENNY_WRIGHT_RECORD = {
   :house=>"senate",
   :aph_id=>"200287",
   :full_name=>"Senator Penny Wright",
   :electorate=>"South Australia",
   :party=>"Australian Greens",
   :profile_page=>"http://www.aph.gov.au/Senators_and_Members/Parliamentarian?MPID=200287",
   :contact_page=>"http://www.aph.gov.au/Senators_and_Members/Contact_Senator_or_Member?MPID=200287",
   :photo_url=>"http://parlinfo.aph.gov.au/parlInfo/download/handbook/allmps/200287/upload_ref_binary/200287.jpg",
   :email=>"senator.wright@aph.gov.au",
   :facebook=>"http://www.facebook.com/SenatorPennyWright",
   :twitter=>"http://www.twitter.com/pennywrites",
   :website=>nil,
   "parliament_telephone"=>"(02) 6277 3626",
   "parliament_fax"=>"(02) 6277 5992"}

  GRAYNDLER_RECORD = {
                        :house => "representatives",
                       :aph_id => "R36",
                    :full_name => "Hon Anthony Albanese MP",
                   :electorate => "Grayndler, New South Wales",
                        :party => "Australian Labor Party",
                 :profile_page => "http://www.aph.gov.au/Senators_and_Members/Parliamentarian?MPID=R36",
                 :contact_page => "http://www.aph.gov.au/Senators_and_Members/Contact_Senator_or_Member?MPID=R36",
                    :photo_url => "http://parlinfo.aph.gov.au/parlInfo/download/handbook/allmps/R36/upload_ref_binary/R36.jpg",
                        :email => "A.Albanese.MP@aph.gov.au",
                     :facebook => nil,
                      :twitter => "http://twitter.com/AlboMP",
                      :website => "http://www.anthonyalbanese.com.au",
        "parliament_telephone" => "(02) 6277 4664",
              "parliament_fax" => "(02) 6277 8532"
    }

  HASLUCK_RECORD = {
                        :house => "representatives",
                       :aph_id => "M3A",
                    :full_name => "Mr Ken Wyatt AM, MP",
                   :electorate => "Hasluck, Western Australia",
                        :party => "Liberal Party of Australia",
                 :profile_page => "http://www.aph.gov.au/Senators_and_Members/Parliamentarian?MPID=M3A",
                 :contact_page => "http://www.aph.gov.au/Senators_and_Members/Contact_Senator_or_Member?MPID=M3A",
                    :photo_url => "http://parlinfo.aph.gov.au/parlInfo/download/handbook/allmps/M3A/upload_ref_binary/m3a.jpg",
                        :email => nil,
                     :facebook => nil,
                      :twitter => "http://twitter.com/KenWyattMP",
                      :website => "http://www.kenwyatt.com.au/",
        "parliament_telephone" => "(02) 6277 4707",
              "parliament_fax" => "(02) 6277 8552"
  }
end
