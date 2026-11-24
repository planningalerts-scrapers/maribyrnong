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
    @agent ||= Mechanize.new
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
