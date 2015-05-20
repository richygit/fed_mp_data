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

      binding.pry
      expect(records.count).to eq 75
      expect(records["Hasluck"]).to eq HASLUCK_RECORD
      expect(records["Grayndler"]).to eq GRAYNDLER_RECORD
    end
  end

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
