require_relative '../csv_scraper'
require 'open-uri'

describe CsvScraper, :vcr => true do
  describe "scraping MPs" do
    let(:data) {"\"\"Surname\"\",\"\"First Name\"\",\"\"Other Names\"\",\"\"Preferred Name\"\",\"\"Initials\"\",\"\"Courtesy Title\"\",\"\"Salutation\"\",\"\"Honorific\"\",\"\"Gender\"\",\"\"Parliament House Telephone\"\",\"\"Parliament House Fax\"\",\"\"Political Party\"\",\"State\",\"\"Electorate\"\",\"\"Electorate Office Postal Address\"\",\"\"Electorate Office Postal Suburb\"\",\"\"Electorate Office Postal State\"\",\"\"Electorate Office Postal PostCode\"\",\"\"Electorate Office Fax\"\",\"\"Electorate Office Phone\"\",\"\"Electorate Office Toll Free\"\",\"\"Parliamentary Titles\"\"\r\n\"Abbott\",\"Anthony\",\"John\",\"Tony\",\"A. J.\",\"The Hon\",\"Mr\",\"MP\",\"MALE\",\"(02) 6277 7700\",\"(02) 6273 4100\",\"LP\",\"NSW\",\"Warringah\",\"PO Box 450\",\"Manly\",\"NSW\",\"2095\",\"(02) 9977 8715\",\"(02) 9977 6411\",\"\",\"Prime Minister\"\r\n"}
    let(:results) { {'Warringah' => {surname: 'Abbott'} } }

    it "should parse data in the expected format" do
      File.stub(:open) { StringIO.new(data) }
      CsvScraper.new.scrape.should == results
    end
  end
end
