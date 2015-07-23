require_relative '../pdf_senator_scraper'
require 'open-uri'

describe PdfSenatorScraper do
  it "can download the PDF file" do
    VCR.turned_off do
      WebMock.allow_net_connect!
      Net::HTTP.start(PdfSenatorScraper::PDF_HOST, 80) {|http| expect(http.head(PdfSenatorScraper::SENATOR_URL).code).to eq "200" }
    end
  end

  describe "#scrape", :vcr do
    it "scrapes senator details corectly" do
      records = subject.scrape_pdf(PdfSenatorScraper::SENATOR_URL)
      expect(records["Abetz-TAS"]).to eq({"state"=>"TAS", "last_name"=>"Abetz", "email"=>"senator.abetz@aph.gov.au", "type"=>"senator"})
      expect(records.count).to eq 75
    end
  end

  describe "#new_senator_line?" do
    specify { expect(subject.send(:new_senator_line?, "4      Bilyk, Senator CatrynaLouise                  TAS        ALP      Suite 3, Kingston Plaza, 20 Channel Highway,      (03) 6229 4444 ")).to be_truthy }
    specify { expect(subject.send(:new_senator_line?, "**34   Lindgren, Senator JoannaMaria                 QLD         LP       2166 Logan Road, Upper Mount Gravatt QLD 4122    (07) 3422 1990 ")).to be_truthy }
    specify { expect(subject.send(:new_senator_line?, " 44 Parliament                                                                                                             as at 21 May 2015 ")).to be_falsey }
    specify { expect(subject.send(:new_senator_line?, "3    Chosen by the Australian Capital Territory Legislative Assemblya casual vacancy(vice K. Lundy), pursuant to section 15 of the Constitution.  ")).to be_falsey }
  end

  describe "#read_senator_state_and_last_name" do
    it "should senator read state and surname" do
      line = '2      Back, Senator Christopher John (Chris)        WA          LP      Unit E5, 817 Beeliar Drive,                       (08) 9414 7288'
      expect(subject.send(:read_senator_state_and_last_name, line)).to eq ['WA', 'Back']
    end

    it "should read senators with title 'the hon'" do
      line = '1      Abetz, Senator the Hon Eric                   TAS         LP      Highbury House, 136 Davey Street,                 (03) 6224 3707'
      expect(subject.send(:read_senator_state_and_last_name, line)).to eq ['TAS', 'Abetz']
    end

    it "should handle extra long name columns" do
      line = '24     Fifield, Senator the Hon Mitchell Peter (Mitch) VIC         LP      42 Florence Street, Mentone VIC 3194               (03) 9584 2455'
      expect(subject.send(:read_senator_state_and_last_name, line)).to eq ['VIC', 'Fifield']
    end

    it "should handle state starting in a different column" do
      line = '73     Williams, Senator John Reginald              NSW        NATS      144 Byron Street, Inverell NSW 2360              (02) 6721 4500'
      expect(subject.send(:read_senator_state_and_last_name, line)).to eq ['NSW', 'Williams']
    end
  end

  describe "#read_email" do
    it "should read emails" do
      line = '         Minister Assisting the Prime Ministerfor the                    Email: senator.abetz@aph.gov.au'
      expect(subject.send(:read_email, 'Email:', PdfSenatorScraper::SENATOR_EMAIL_START_COL, line)).to eq 'senator.abetz@aph.gov.au'
    end

    it "should not include any trailing crap" do
      line = '                                                                         Email: senator.bushby@aph.gov.au                  (03) 6244 8521 (fax)'
      expect(subject.send(:read_email, 'Email:', PdfSenatorScraper::SENATOR_EMAIL_START_COL, line)).to eq 'senator.bushby@aph.gov.au'
    end
  end
end
