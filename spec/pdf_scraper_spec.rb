require_relative '../pdf_scraper'
require 'open-uri'

describe PdfScraper, focus: true do
  it "can download the PDF file" do
    VCR.turned_off do
      WebMock.allow_net_connect!
      Net::HTTP.start(PdfScraper::PDF_HOST, 80) {|http| expect(http.head(PdfScraper::MP_URL).code).to eq "200" }
      Net::HTTP.start(PdfScraper::PDF_HOST, 80) {|http| expect(http.head(PdfScraper::SENATOR_URL).code).to eq "200" }
    end
  end

  describe "#scrape_pdf", :vcr do
    it "scrapes MP details correctly" do
      records = subject.scrape_pdf(PdfScraper::MP_URL, :representatives)
      expect(records["Curtin"][:email]).to eq('Julie.Bishop.MP@aph.gov.au')
      expect(records["Durack"][:email]).to eq('Melissa.Price.MP@aph.gov.au')

      expect(records.count{|_,v| v[:house] == :representatives}).to eq 148
    end

    it "scrapes senator details corectly" do
      records = subject.scrape_pdf(PdfScraper::SENATOR_URL, :senate)
      expect(records.count{|_,v| v[:house] == :senate}).to eq 75
    end
  end

  describe "#new_senator_line?" do
    specify { expect(subject.send(:new_senator_line?, "4      Bilyk, Senator CatrynaLouise                  TAS        ALP      Suite 3, Kingston Plaza, 20 Channel Highway,      (03) 6229 4444 ")).to be_truthy }
    specify { expect(subject.send(:new_senator_line?, "**34   Lindgren, Senator JoannaMaria                 QLD         LP       2166 Logan Road, Upper Mount Gravatt QLD 4122    (07) 3422 1990 ")).to be_truthy }
    specify { expect(subject.send(:new_senator_line?, " 44 Parliament                                                                                                             as at 21 May 2015 ")).to be_falsey }
    specify { expect(subject.send(:new_senator_line?, " 3    Chosen by the Australian Capital Territory Legislative Assemblya casual vacancy(vice K. Lundy), pursuant to section 15 of the Constitution.  ")).to be_falsey }
  end

  describe "#read_senator_key" do
    it "should create senator keys" do
      line = '2      Back, Senator Christopher John (Chris)        WA          LP      Unit E5, 817 Beeliar Drive,                       (08) 9414 7288'
      expect(subject.send(:read_senator_key, line)).to eq 'wa.back christopher'
    end

    it "should read senators with title 'the hon'" do
      line = '1      Abetz, Senator the Hon Eric                   TAS         LP      Highbury House, 136 Davey Street,                 (03) 6224 3707'
      expect(subject.send(:read_senator_key, line)).to eq 'tas.abetz eric'
    end

  end
  
end
