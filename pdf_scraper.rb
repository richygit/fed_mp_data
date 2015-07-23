require 'pdf-reader'
require 'open-uri'
require './logging.rb'

class PdfScraper < Logging
  PDF_HOST = 'www.aph.gov.au'

  def scrape_pdf(url)
    reader = PDF::Reader.new(open(url))
    lines = []
    reader.pages.each do |page|
      lines << page.text.split("\n")
    end
    read_data(lines.flatten)
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
