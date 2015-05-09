require 'scraperwiki'
require 'mechanize'

require_relative 'web_scraper'
require_relative 'csv_scraper'
require_relative 'pdf_scraper'

def merge_into_csv(source, csv)
  csv.each do |electorate, record|
    record.merge!(source[electorate]) if source[electorate]
  end
  csv
end

def main
  csv_records = CsvScraper.new.scrape
  web_mp_records = WebScraper.new.scrape_mps
  csv_records = merge_into_csv(web_mp_records, csv_records)
  pdf_records = PdfScraper.new.scrape
  csv_records = merge_into_csv(pdf_records, csv_records)

  csv_records.each do |electorate, record|
    puts "### Saving #{record[:full_name]}"
    puts record
    ScraperWiki::save_sqlite [:aph_id], record
  end
end

# TODO: test, senators, states
main
