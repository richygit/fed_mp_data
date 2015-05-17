require 'spec_helper'
require_relative '../scraper_main'
require 'pry'

RSpec.describe ScraperMain, focus: true do
  describe "#main" do
    before(:each) do
      allow_any_instance_of(CsvScraper).to receive(:scrape).and_return({grayndler: {'first_name' => 'Anthony', 'last_name' => 'Albanese'} })
      allow_any_instance_of(WebScraper).to receive(:scrape_mps).and_return({grayndler: {'twitter' => 'http://twitter.com/AlboMP', electorate: 'Grayndler'} })
      allow_any_instance_of(PdfScraper).to receive(:scrape).and_return({grayndler: {email: 'A.Albanese.MP@aph.gov.au'} })
    end

    it "should merge data from each scraper" do
      subject.main
      grayndler = ScraperWiki::select('* FROM data WHERE electorate = "Grayndler"')
      expect(grayndler.first).to eq({"first_name"=>"Anthony", "last_name"=>"Albanese", "twitter"=>"http://twitter.com/AlboMP", "electorate"=>"Grayndler", "email"=>"A.Albanese.MP@aph.gov.au"})
    end
  end

end
