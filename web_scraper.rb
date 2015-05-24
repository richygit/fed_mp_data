require 'mechanize'
require 'fileutils'
require './logging'

#get social media contact details of MPs
class WebScraper < Logging

  SEARCH_HOST = 'www.aph.gov.au'
  SEARCH_PATH = '/Senators_and_Members/Parliamentarian_Search_Results'
  SEARCH_URL = "http://#{SEARCH_HOST}#{SEARCH_PATH}"

  def scrape
    scrape_mps.merge(scrape_senators)
  end

  def scrape_mps
    records = {}
    @agent = Mechanize.new

    page = @agent.get "#{SEARCH_URL}?mem=1&q="

    while page.link_with(:text => 'Next')
      @logger.debug "Saving results from Representatives page"
      records.merge!(save_results_from_page(page, :representatives))
      page = @agent.get SEARCH_URL + page.link_with(:text => 'Next').href
    end

    records.merge!(save_results_from_page(page, :representatives)) # Save the final page

  end

  def scrape_senators
    records = {}
    @agent = Mechanize.new
    page = @agent.get "#{SEARCH_URL}?sen=1&q="

    while page.link_with(:text => 'Next')
      @logger.debug "Saving results from Senate page"
      records.merge!(save_results_from_page(page, :senate))
      page = @agent.get SEARCH_URL + page.link_with(:text => 'Next').href
    end

    records.merge!(save_results_from_page(page, :senate)) # Save the final page
  end

private

  def detail?(type, dl)
    dl.at(:dt).inner_text == ":#{type}"
  end

  def detail_key(type, detail)
    "#{type}_#{detail}".gsub(":",'').downcase
  end

  def get_details(type, office)
    details = {}

    getting_detail = nil
    office.at(:dl).children.each do |child|
      if child.name == 'dt'
        getting_detail = child.inner_text
      end

      if child.name == 'dd'
        detail = child.inner_text

        details[detail_key(type, getting_detail)] = detail
        getting_detail = nil
        detail = nil
      end
    end

    details
  end

  def save_details_from_mp_page(url)
    agent = Mechanize.new
    page = agent.get url
    @logger.debug "Scraping #### #{url}"

    details = {}
    page.search('.col-third').each do |col_outer|
      parl_office = col_outer.search('h3').select {|col| col.inner_text == 'Parliament Office' }
      details.merge!(get_details('parliament', col_outer)) if parl_office.size > 0
      electorate_office = col_outer.search('h3').select {|col| col.inner_text == 'Electorate Office' }
      details.merge!(get_details('electorate', col_outer)) if electorate_office.size > 0
    end
    details

  end

  def representative_key(record, house)
    house == :representatives ? electorate_key(record[:electorate]) : senator_key(record)
  end

  def clean_senator_name(name)
    name.downcase.gsub('senator', '').gsub('the hon', '').strip
  end

  STATES = {'South Australia' => 'sa',
  'Queensland' => 'qld',
  'Tasmania' => 'tas',
  'New South Wales' => 'nsw',
  'Western Australia' => 'wa',
  'Australian Capital Territory' => 'act',
  'Northern Territory' => 'nt',
  'Victoria' => 'vic'}

  def state_abbr(state)
    STATES[state]
  end

  def senator_key(record)
    "#{state_abbr(record[:electorate])}.#{clean_senator_name(record[:full_name])}".downcase
  end

  def electorate_key(electorate)
    electorate.match(/[^,]*/)[0]
  end

  def save_results_from_page(page, house)
    records = {}
    page.at('.search-filter-results').search(:li).each do |i|
      electorate, party, contact_page, email, facebook, twitter = nil, nil, nil, nil, nil, nil

      aph_id = i.at('.title').at(:a).attr(:href).match(/MPID\=(.*)/)[1]

      i.at(:dl).search(:dt).each do |dt|
        case dt.inner_text
        when 'Member for', 'Senator for'
          electorate = dt.next_element.inner_text
        when 'Party'
          party = dt.next_element.inner_text
        end
      end


      email = i.search('.social.mail').at(:a).attr(:href).gsub('mailto:', '') unless i.search('.social.mail').empty? 
      facebook = i.search('.social.facebook').at(:a).attr(:href) unless i.search('.social.facebook').empty? 
      twitter = i.search('.social.twitter').at(:a).attr(:href) unless i.search('.social.twitter').empty? 

      profile_page_url = "http://www.aph.gov.au#{i.at('.title').at(:a).attr(:href)}"
      profile_page = @agent.get profile_page_url
      website = profile_page.link_with(text: 'Personal website').href if profile_page.link_with(text: 'Personal website')

      record = {
        house: house.to_s,
        aph_id: aph_id,
        full_name: i.at('.title').inner_text,
        electorate: electorate,
        party: party,
        profile_page: profile_page_url,
        # Some members don't list this page on their profile (WTF?!) but generating this URL works fine
        contact_page: "http://www.aph.gov.au/Senators_and_Members/Contact_Senator_or_Member?MPID=#{aph_id}",
        photo_url: i.at('.thumbnail').at(:img).attr(:src),
        email: email,
        facebook: facebook,
        twitter: twitter,
        website: website
      }
      details = save_details_from_mp_page(profile_page_url)
      record.merge!(details)
      
      records[representative_key(record, house)] = record
    end
    records
  end
end
