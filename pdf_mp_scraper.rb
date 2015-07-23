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

  #email
  #surname, state (key)
  def read_mp_details(lines)
    tel = nil
    surname = nil
    electorate = nil
    lines.reverse.each do |line|
      if matches = line.match(/Tel:\s*(\(\d{2}\)\s*\d{4}\s*\d{4})$/)
        tel = matches[1]
      end
      if surname_match = line.match(/^\**(\w[^,]*),/)
        surname = surname_match[1]
      end

      line = line[MP_ELECTORATE_START_COL..MP_EMAIL_START_COL]
      if line && line.index(',')
        electorate = line.split(',').first.strip.chomp(',')
      end
      return [tel, surname.gsub('*', ''), electorate] if electorate && surname && tel
    end
    @logger.warn("No MP logged for: #{lines}")
    nil
  end

  def read_data(lines)
    records = {}
    line_buffer = []
    lines.each_with_index do |line, index|
      if email = read_email('E-mail:', MP_EMAIL_START_COL, line)
        tel, surname, electorate = read_mp_details(line_buffer)
        records[tel] = {'email' => email, 'electorate_tel' => tel, 'electorate' => electorate, 'surname' => surname, 'type' => 'mp'} if tel
        line_buffer = []
      else
        line_buffer << line
      end
    end
    records
  end

end
