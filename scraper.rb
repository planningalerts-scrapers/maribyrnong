require 'scraperwiki'
require 'mechanize'

agent = Mechanize.new
index = Nokogiri::HTML(agent.get("https://www.maribyrnong.vic.gov.au/Building-and-Planning/Advertised-Planning-Applications").body)
items = []
index.xpath("//article").each do |article|
  record = {
      'council_reference' => article.xpath('a/p[@class="da-application-number small-text"]').text,
      'address' => article.xpath('a/p[@class="list-item-address"]').text,
      'description' => article.xpath("a/p[3]").text,
      'info_url' => article.xpath("a/@href").text,
      'date_scraped' => Date.today.to_s,
      # 'date_received' => # Not available
    }

  puts "Storing #{record['council_reference']} - #{record['address']}"
  ScraperWiki.save_sqlite(['council_reference'], record)
end