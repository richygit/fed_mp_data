require_relative '../pdf_mp_scraper'
require 'open-uri'

describe PdfMpScraper do
  it "can download the PDF file" do
    VCR.turned_off do
      WebMock.allow_net_connect!
      Net::HTTP.start(PdfMpScraper::PDF_HOST, 80) {|http| expect(http.head(PdfMpScraper::MP_URL).code).to eq "200" }
    end
  end

  describe "#scrape_pdf", :vcr do
    it "scrapes MP details correctly" do
      records = subject.scrape_pdf(PdfMpScraper::MP_URL)
      expect(records["(02) 6277 7500"]).to eq({"email"=>"Julie.Bishop.MP@aph.gov.au", "electorate_tel"=>"(02) 6277 7500", "electorate"=>"Curtin", "surname"=>"Bishop", "type"=>"mp"})
      expect(records["(02) 6277 4242"]).to eq({"email"=>"Melissa.Price.MP@aph.gov.au", "electorate_tel"=>"(02) 6277 4242", "electorate"=>"Durack", "surname"=>"Price", "type"=>"mp"})

      expect(records.count).to eq 148
    end
  end

  describe "#read_mp_details" do
    it "should read the MP's details" do
      lines = ['Abbott, The Hon Anthony John         Warringah,         LP         Level 2, 17 Sydney Road (PO Box 450), Manly                 Tel: (02) 6277 7700']
      expect(subject.send(:read_mp_details, lines)).to eq ['(02) 6277 7700', 'Abbott', 'Warringah']
    end

    it "should read the MP's details even when the order is backwards" do
      lines = ['                                       McMillan,           LP        46C Albert Street, Warragul Vic 3820                           Tel: (02) 6277 4233',
                'Broadbent, Mr Russell Evan']
      expect(subject.send(:read_mp_details, lines)).to eq ['(02) 6277 4233', 'Broadbent', 'McMillan']
    end

    it "should read MP's details when their first name starts a new line" do
      lines = [ 'van Manen, Mr Albertus                 Forde,              LP        Tenancy 4/96 George Street (PO Box 884), Beenleigh             Tel: (02) 6277 4719',
              '                                       Qld                           Qld 4207                                                       Fax: (02) 6277 8553',
              'Johannes (Bert)',
              '                                                                     Tel : (07) 3807 6340, Fax : (07) 3807 1990',
              '                                                                     E-mail: bert.vanmanen.mp@aph.gov.au']
      expect(subject.send(:read_mp_details, lines)).to eq ['(02) 6277 4719', 'van Manen', 'Forde']
    end
  end

  describe "#read_email" do
    it "should read emails" do
      line = '                                                                   E-mail: A.Albanese.MP@aph.gov.au'
      expect(subject.send(:read_email, 'E-mail:', PdfMpScraper::MP_EMAIL_START_COL, line)).to eq 'A.Albanese.MP@aph.gov.au'
    end
  end
end
