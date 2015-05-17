require 'pdf-reader'
require 'open-uri'

#get MP contact details
class PdfScraper
  PDF_HOST = 'www.aph.gov.au'
  PDF_PATH = '/~/media/03%20Senators%20and%20Members/32%20Members/Lists/MemList.pdf'
  PDF_URL = "http://#{PDF_HOST}#{PDF_PATH}"

  def scrape
    reader = PDF::Reader.new(open(PDF_URL))
    lines = []
    reader.pages.each do |page|
      lines << page.text.split("\n")
    end
    read_mp_data(lines.flatten)
  end

private

  EMAIL_START_COL = 67
  ELECTORATE_START_COL = 37

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
    line = line[EMAIL_START_COL..-1]
    if line && line.strip.start_with?('E-mail:')
      line.strip.gsub('E-mail:', '').strip
    else
      nil
    end
  end

  def find_electorate(lines)
    lines.reverse!.each do |line|
      line = line[ELECTORATE_START_COL..EMAIL_START_COL]
      if line && line.index(',')
        return line.split(',').first.strip.chomp(',')
      end
    end
    nil
  end
end
