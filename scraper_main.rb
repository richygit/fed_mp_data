require 'scraperwiki'
require 'mechanize'
require './logging'

require_relative 'web_scraper'
require_relative 'csv_scraper'
require_relative 'pdf_scraper'

# TODO: senators, states
class ScraperMain < Logging

  def initialize
    super
    ScraperWiki.config = { db: 'data.sqlite', default_table_name: 'data' }
  end

  def merge_into_csv(source, csv, from_source)
    source.each do |key, record|
      if csv[key]
        csv[key].merge!(record)
      else
        logger.error("Unable to finding matching key for: #{key} from #{from_source}")
      end
    end
    csv
  end

  def main
    @logger.info('Scraping CSV')
    csv_records = CsvScraper.new.scrape
    @logger.info("Scraping web")
    web_records = WebScraper.new.scrape_mps
    csv_records = merge_into_csv(web_records, csv_records, 'web')
    @logger.info("Scraping PDF")
    pdf_records = PdfScraper.new.scrape
    csv_records = merge_into_csv(pdf_records, csv_records, 'pdf')

    csv_records.each do |electorate, record|
      @logger.info("### Saving #{record[:full_name]}")
      ScraperWiki::save_sqlite([:electorate], record)
    end
  end
end

