require 'scraperwiki'
require 'mechanize'

require_relative 'web_scraper'
require_relative 'csv_scraper'
require_relative 'pdf_scraper'

class Scraper
  LOG_DIR = 'log/development.log'

  def initialize
    FileUtils.mkpath LOG_DIR
    @logger = Logger.new File.new("#{LOG_DIR}/development.log", 'a+')
  end

  def merge_into_csv(source, csv)
    csv.each do |electorate, record|
      record.merge!(source[electorate]) if source[electorate]
    end
    csv
  end

  def main
    @logger.info('Scraping CSV')
    csv_records = CsvScraper.new.scrape
    @logger.info("Scraping web")
    web_records = WebScraper.new.scrape
    csv_records = merge_into_csv(web_records, csv_records)
    @logger.info("Scraping PDF")
    pdf_records = PdfScraper.new.scrape
    csv_records.each do |electorate, record|
      record.merge!(email: pdf_records[electorate]) if pdf_records[electorate]
    end

    csv_records.each do |electorate, record|
      puts "### Saving #{record[:full_name]}"
      ScraperWiki::save_sqlite([:electorate], record)
    end
  end
end

# TODO: senators, states
Scraper.new.main
