require 'pdf-reader'
require 'open-uri'
require './logging.rb'

#get MP emails
class PdfScraper < Logging
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

  SENATOR_EMAIL_START_COL = 73
  SENATOR_STATE_START_COL = 52

  def new_senator_line?(line)
    return false if line == nil || line.length < SENATOR_STATE_START_COL
    line =~ /^\**\d+\s{3,}/ && line[5..6] == '  '
  end

  def read_senator_key(line)
    state = line[SENATOR_STATE_START_COL..-1].split(' ')[0].downcase
    state = line[SENATOR_STATE_START_COL..-1].split(' ')[1].downcase if state.index(')')
    words = line[7..-1].split(' ').map {|w| w.downcase }
    return nil if words.length < 3
    last_name = words[0].chomp(',')
    first_name = nil
    if words.length > 3 && words[2] == 'the' && words[3] == 'hon'
      first_name = words[4]
    else
      first_name = words[2]
    end

    "#{state}.#{first_name} #{last_name}"
  end

  def read_senator_data(lines)
    records = {}
    senator_key = nil
    lines.each_with_index do |line, index|
      if new_senator_line?(line)
        @logger.warn("Detected new senator but previous senator's email not recoreded: #{senator_key}") if senator_key
        senator_key = read_senator_key(line) 
        @logger.debug("New senator key: #{senator_key}")
      end

      if read_email('Email:', SENATOR_EMAIL_START_COL, line)
        email = read_email('Email:', SENATOR_EMAIL_START_COL, line)
        if senator_key
          records[senator_key] = {email: email, house: :senate}
          @logger.debug("Added senator: #{senator_key} => #{email}")
        else
          @logger.warn("Detected email but senator is not known: #{email}")
        end
        senator_key = nil
      end
    end
    records
  end

  def read_mp_data(lines)
    records = {}
    line_buffer = []
    lines.each_with_index do |line, index|
      if email = read_email('E-mail:', MP_EMAIL_START_COL, line)
        electorate = find_electorate(line_buffer)
        records[electorate] = {email: email, house: :representatives} if electorate
        line_buffer = []
      else
        line_buffer << line
      end
    end
    records
  end

  def read_email(email_token, start_col, line)
    return nil unless line
    line = line[start_col..-1]
    if line && line.strip.start_with?(email_token)
      email = line.gsub(email_token, '').strip
      email = email[0,email.index(' ')] if email.index(' ')
      email
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
