require 'scraperwiki'
require 'mechanize'

require_relative 'web_scraper'
require_relative 'csv_scraper'
require_relative 'pdf_scraper'

# TODO: senators, states
class ScraperMain
  LOG_DIR = 'log/development.log'

  def initialize
    ScraperWiki.config = { db: 'data.sqlite', default_table_name: 'data' }
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
    web_records = WebScraper.new.scrape_mps
    csv_records = merge_into_csv(web_records, csv_records)
    @logger.info("Scraping PDF")
    pdf_records = PdfScraper.new.scrape
    csv_records.each do |electorate, record|
      record.merge!(pdf_records[electorate]) if pdf_records[electorate]
    end

    csv_records.each do |electorate, record|
      puts "### Saving #{record[:full_name]}"
      ScraperWiki::save_sqlite([:electorate], record)
    end
  end
end

