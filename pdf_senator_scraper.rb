require './logging.rb'
require_relative 'pdf_scraper'

class PdfSenatorScraper < PdfScraper
  SENATOR_EMAIL_START_COL = 73
  SENATOR_STATE_START_COL = 52
  SENATOR_PATH = '/~/media/03%20Senators%20and%20Members/31%20Senators/contacts/los.pdf'
  SENATOR_URL = "http://#{PDF_HOST}#{SENATOR_PATH}"

  def scrape
    scrape_pdf(SENATOR_URL)
  end

  def new_senator_line?(line)
    return false if line == nil || line.length < SENATOR_STATE_START_COL
    line =~ /^\**\d+\s{3,}/ && line[5..6] == '  '
  end

  def read_electorate_tel(line)
    matches = line.match /(\(\d{2}\)\s*\d{4}\s*\d{4})$/
    matches ? matches[0] : nil
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

  #`email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  # last_name, state (key)
  # TODO key should be last_name-state
  def read_data(lines)
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
end
