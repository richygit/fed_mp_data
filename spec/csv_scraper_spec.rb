require_relative '../csv_scraper'
require 'open-uri'

describe CsvScraper do
  it "can download the CSV file" do
    VCR.turned_off do
      Net::HTTP.start(CsvScraper::CSV_HOST, 80) {|http| expect(http.head(CsvScraper::CSV_PATH).code).to eq "200" }
    end
  end
end
