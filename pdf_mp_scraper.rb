require './logging.rb'
require_relative 'pdf_scraper'

class PdfMpScraper < PdfScraper
  MP_EMAIL_START_COL = 67
  MP_ELECTORATE_START_COL = 37
  MP_PATH = '/~/media/03%20Senators%20and%20Members/32%20Members/Lists/MemList.pdf'
  MP_URL = "http://#{PDF_HOST}#{MP_PATH}"

  def scrape
    scrape_pdf(MP_URL)
  end

  def read_mp_details(lines)
    last_name = nil
    electorate = nil
    lines.reverse.each do |line|
      if last_name_match = line.match(/^\**(\w[^,]*),/)
        last_name = last_name_match[1]
      end

      line = line[MP_ELECTORATE_START_COL..MP_EMAIL_START_COL]
      if line && line.index(',')
        electorate = line.split(',').first.strip.chomp(',')
      end
      return [last_name.gsub('*', ''), electorate] if electorate && last_name
    end
    @logger.warn("No MP logged for: #{lines}")
    nil
  end

  def mp_key(last_name, electorate)
    "#{last_name}-#{electorate}"
  end

  def read_data(lines)
    records = {}
    line_buffer = []
    lines.each_with_index do |line, index|
      if email = read_email('E-mail:', MP_EMAIL_START_COL, line)
        last_name, electorate = read_mp_details(line_buffer)
        records[mp_key(last_name, electorate)] = {'email' => email, 'electorate' => electorate, 'last_name' => last_name, 'type' => 'mp'}
        line_buffer = []
      else
        line_buffer << line
      end
    end
    records
  end
end
