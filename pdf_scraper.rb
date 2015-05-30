require 'pdf-reader'
require 'open-uri'
require './logging.rb'

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

  def read_senator_details(line)
    electorate_tel = read_electorate_tel(line)
    state, surname = read_senator_state_and_surname(line)
    {'electorate_tel' => electorate_tel, 'state' => state, 'surname' => surname.gsub('*', '')}
  end

  def read_senator_state_and_surname(line)
    state = line[SENATOR_STATE_START_COL..-1].split(' ')[0]
    state = line[SENATOR_STATE_START_COL..-1].split(' ')[1] if state.index(')')
    words = line[7..-1].split(' ')
    return nil if words.length < 3
    surname = words[0].chomp(',')

    [state, surname]
  end

  def read_electorate_tel(line)
    matches = line.match /(\(\d{2}\)\s*\d{4}\s*\d{4})$/
    matches ? matches[0] : nil
  end

  def read_mp_details(lines)
    tel = nil
    surname = nil
    electorate = nil
    lines.reverse.each do |line|
      if matches = line.match(/Tel:\s*(\(\d{2}\)\s*\d{4}\s*\d{4})$/)
        tel = matches[1]
      end
      if surname_match = line.match(/^\**([^, ]*),/)
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

  def read_senator_data(lines)
    records = {}
    senator_details = nil
    lines.each_with_index do |line, index|
      if new_senator_line?(line)
        @logger.warn("Detected new senator but previous senator's email not recorded: #{senator_details}") if senator_details
        senator_details = read_senator_details(line) 
        @logger.debug("New senator key: #{senator_details}")
      end

      if read_email('Email:', SENATOR_EMAIL_START_COL, line)
        email = read_email('Email:', SENATOR_EMAIL_START_COL, line)
        if senator_details
          records[senator_details['electorate_tel']] = senator_details.merge({'email' => email, 'type' => 'senator'})
          @logger.debug("Added senator: #{senator_details} => #{email}")
        else
          @logger.warn("Detected email but senator is not known: #{email}")
        end
        senator_details = nil
      end
    end
    records
  end

  def read_mp_data(lines)
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
end
