require 'scraperwiki'
require './logging'

require_relative 'csv_scraper'
require_relative 'pdf_mp_scraper'
require_relative 'pdf_senator_scraper'
require_relative 'scraper_helper'

class ScraperMain < Logging
  def initialize
    super
    @logger = Logger.new($stdout)
    ScraperWiki.config = { db: 'data.sqlite', default_table_name: 'data' }
  end

  def merge(src, dest)
    src.each do |key, record|
      if dest[key]
        dest[key].merge!(record)
      else
        @logger.warn("No matching record for: #{key}")
      end
    end
    dest
  end

  def main
    @logger.info('Scraping CSV')
    csv_records = CsvScraper.new.scrape
    @logger.info("Scraping PDF MPs")
    pdf_mps = PdfMpScraper.new.scrape
    @logger.info("Scraping PDF Senators")
    pdf_senators = PdfSenatorScraper.new.scrape
    pdf_records = pdf_mps.merge(pdf_senators)
    @logger.warn("PDF records lost in merge! Expected: #{pdf_mps.size + pdf_senators.size}. Was: #{pdf_records.size}") if pdf_mps.size + pdf_senators.size != pdf_records.size
    merge(pdf_records, csv_records)

    csv_records.each do |key, record|
      @logger.info("### Saving #{record['first_name']} #{record['last_name']}")
      puts("### Saving #{record['first_name']} #{record['last_name']}")
      ScraperWiki::save(['first_name', 'last_name', 'office_state'], record)
    end
  end
end

