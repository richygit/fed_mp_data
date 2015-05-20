require 'pdf-reader'
require 'open-uri'

#get MP contact details
class PdfScraper
  PDF_HOST = 'www.aph.gov.au'
  MP_PATH = '/~/media/03%20Senators%20and%20Members/32%20Members/Lists/MemList.pdf'
  MP_URL = "http://#{PDF_HOST}#{MP_PATH}"
  SENATOR_PATH = '/~/media/03%20Senators%20and%20Members/31%20Senators/contacts/los.pdf'
  SENATOR_URL = "http://#{PDF_HOST}#{SENATOR_PATH}"

  def scrape
    scrape_pdf(MP_URL, :representatives).merge(scrape_pdf(SENATOR_URL, :senate))
  end

  def scrape_pdf(url, house)
    reader = PDF::Reader.new(open(url))
    lines = []
    reader.pages.each do |page|
      lines << page.text.split("\n")
    end
    house == :senate ? read_senator_data(lines.flatten) : read_mp_data(lines.flatten)
  end

private

  MP_EMAIL_START_COL = 67
  MP_ELECTORATE_START_COL = 37

  def read_senator_data(lines)
    records = {}
    line_buffer = []
    lines.each_with_index do |line, index|
      if email = get_email(line)
        electorate = find_electorate(line_buffer)
        records[electorate] = {email: email} if electorate
        line_buffer = []
      else
        line_buffer << line
      end
    end
    records
  end

  def read_mp_data(lines)
    records = {}
    line_buffer = []
    lines.each_with_index do |line, index|
      if email = get_email(line)
        electorate = find_electorate(line_buffer)
        records[electorate] = {email: email} if electorate
        line_buffer = []
      else
        line_buffer << line
      end
    end
    records
  end

  def get_email(line)
    false unless line
    line = line[MP_EMAIL_START_COL..-1]
    if line && line.strip.start_with?('E-mail:')
      line.strip.gsub('E-mail:', '').strip
    else
      nil
    end
  end

  def find_electorate(lines)
    lines.reverse!.each do |line|
      line = line[MP_ELECTORATE_START_COL..MP_EMAIL_START_COL]
      if line && line.index(',')
        return line.split(',').first.strip.chomp(',')
      end
    end
    nil
  end
end
