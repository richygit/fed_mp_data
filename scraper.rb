require 'scraperwiki'
require 'mechanize'

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
  puts "Scraping #### #{url}"

  details = {}
  page.search('.col-third').each do |col|
    parl_office = col.search('h3').select {|col| col.inner_text == 'Parliament Office' }
    details.merge!(get_details('parliament', col)) if parl_office.size > 0
    electorate_office = col.search('h3').select {|col| col.inner_text == 'Electorate Office' }
    details.merge!(get_details('electorate', col)) if electorate_office.size > 0
  end
  details

end

def save_results_from_page(page, house)
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

    puts record
    puts "Saving #{record[:full_name]}"
    ScraperWiki::save_sqlite [:aph_id], record
  end
end

@agent = Mechanize.new
search_url = 'http://www.aph.gov.au/Senators_and_Members/Parliamentarian_Search_Results'

page = @agent.get "#{search_url}?mem=1&q="

while page.link_with(:text => 'Next')
  puts "Saving results from Representatives page"
  save_results_from_page(page, :representatives)
  page = @agent.get search_url + page.link_with(:text => 'Next').href
end

save_results_from_page(page, :representatives) # Save the final page

page = @agent.get "#{search_url}?sen=1&q="

while page.link_with(:text => 'Next')
  puts "Saving results from Senate page"
  save_results_from_page(page, :senate)
  page = @agent.get search_url + page.link_with(:text => 'Next').href
end

save_results_from_page(page, :senate) # Save the final page
