require 'scraperwiki'
require './logging'

require_relative 'web_scraper'
require_relative 'csv_scraper'
require_relative 'pdf_scraper'

class ScraperMain < Logging

  def initialize
    super
    @logger = Logger.new($stdout)
    ScraperWiki.config = { db: 'data.sqlite', default_table_name: 'data' }
  end

  def match_on_secondary_data(csv, record)
    if record['type'] == 'mp'
      match = csv.find {|k, v| v['type'] == 'mp' && v['electorate'].casecmp(record['electorate']) == 0 }
    else
      match = csv.find {|k, v| v['type'] == 'senator' && v['surname'].casecmp(record['surname']) == 0 && v['electorate_state'].casecmp(record['state']) == 0 }
    end

    if match
      match[1].merge!(record)
    else
      binding.pry
      puts("Unable to find match for: #{record}")
      @logger.error("Unable to find match for: #{record}")
    end
  end

  def merge_into_csv(pdf, csv)
    pdf.each do |electorate_tel, record|
      csv_match = csv[electorate_tel]
      if csv_match
        csv_match.merge!(record)
      else
        match_on_secondary_data(csv, record)
      end
    end
    csv
  end

  def main
    @logger.info('Scraping CSV')
    csv_records = CsvScraper.new.scrape
    @logger.info("Scraping PDF")
    pdf_records = PdfScraper.new.scrape
    csv_records = merge_into_csv(pdf_records, csv_records)

    csv_records.each do |electorate, record|
      @logger.info("### Saving #{record['first_name']} #{record['surname']}")
      puts("### Saving #{record['first_name']} #{record['surname']}")
      ScraperWiki::save(['first_name', 'surname', 'state'], record)
    end
  end
end

