require 'pdf-reader'
require 'open-uri'
require 'pry'

class PdfScraper
  FED_MP_PDF_URL = "http://www.aph.gov.au/~/media/03%20Senators%20and%20Members/32%20Members/Lists/MemList.pdf"

  def get_electorate(line)
    if (line =~ /^[a-zA-Z\*]/) && !line.start_with?("Name") && @electorate.nil?
      tokens = line.split(/[ ]{2,}/)
      @electorate = tokens[1].gsub(',','') if tokens[1]
      if @electorate.nil? || @electorate.strip.empty?
        @electorate = @prev_line.strip.match(/^[a-zA-Z']*/)[0]
      end
    end
  end
  
  def get_email(line)
    if line.strip.start_with?("E-mail:")
      line.gsub("E-mail:", '').strip
    else
      nil
    end
  end

  def read_mps(lines)
    lines.each do |line|
      get_electorate(line)
      if email = get_email(line)
        @records[@electorate] = {email: email}
        @electorate = nil
      end
      @prev_line = line
    end
  end

  def scrape
    @records = {}
    reader = PDF::Reader.new(open(FED_MP_PDF_URL))
    reader.pages.each do |page|
      read_mps(page.text.split("\n"))
    end
    @records
  end

private
end

