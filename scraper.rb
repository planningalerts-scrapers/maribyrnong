#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
Bundler.require

require "date"

# Scrapes advertised planning applications from Maribyrnong City Council
# and saves them with ScraperWiki.
class Scraper
  INDEX_URL =
    "https://www.maribyrnong.vic.gov.au/Building-and-Planning/Advertised-Planning-Applications"

  # The council website sits behind Akamai, which returns 403 Access Denied
  # unless the request looks like it comes from a real browser.
  USER_AGENT =
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 " \
    "(KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"

  REQUEST_HEADERS = {
    "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
    "Accept-Language" => "en-AU,en;q=0.9",
    "Upgrade-Insecure-Requests" => "1",
    "Sec-Fetch-Dest" => "document",
    "Sec-Fetch-Mode" => "navigate",
    "Sec-Fetch-Site" => "none",
  }.freeze

  def scrape
    page = agent.get(INDEX_URL)
    page.search("//article").each do |article|
      yield record_for(article)
    end
  end

  def run
    count = 0
    scrape do |record|
      puts "Storing #{record['council_reference']} - #{record['address']}"
      ScraperWiki.save_sqlite(["council_reference"], record)
      count += 1
    end
    puts "Finished - added #{count} records"
  end

  private

  def agent
    @agent ||= Mechanize.new do |mechanize|
      mechanize.user_agent = USER_AGENT
      mechanize.request_headers = REQUEST_HEADERS.dup
    end
  end

  def record_for(article)
    {
      "council_reference" => article.xpath("a/p[@class='da-application-number small-text']").text,
      "address" => article.xpath("a/p[@class='list-item-address']").text,
      "description" => article.xpath("a/p[3]").text,
      "info_url" => article.xpath("a/@href").text,
      "date_scraped" => Date.today.to_s,
      # "date_received" => # Not available
    }
  end
end

Scraper.new.run if __FILE__ == $PROGRAM_NAME
