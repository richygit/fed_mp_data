require_relative '../csv_scraper'
require 'open-uri'

describe CsvScraper do
  it "can download the CSV file" do
    VCR.turned_off do
      WebMock.allow_net_connect!
      Net::HTTP.start(CsvScraper::CSV_HOST, 80) {|http| expect(http.head(CsvScraper::CSV_PATH).code).to eq "200" }
    end
  end

  it "scrapes MPs details" do
    #spot check on various details from CSV file
  end

  it "scrapes the right number of MPs" do
  end
end
