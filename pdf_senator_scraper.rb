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

  def read_senator_details(line)
    state, last_name = read_senator_state_and_last_name(line)
    {'state' => state, 'last_name' => last_name.gsub('*', '')}
  end

  def read_senator_state_and_last_name(line)
    state = line[SENATOR_STATE_START_COL..-1].split(' ')[0]
    state = line[SENATOR_STATE_START_COL..-1].split(' ')[1] if state.index(')')
    words = line[7..-1].split(' ')
    return nil if words.length < 3
    last_name = words[0].chomp(',')

    [state, last_name]
  end

  def senator_key(senator_details)
    "#{senator_details['last_name']}-#{senator_details['state']}"
  end

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
          records[senator_key(senator_details)] = senator_details.merge({'email' => email, 'type' => 'senator'})
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
