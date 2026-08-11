# frozen_string_literal: true

RSpec.describe Scraper do
  describe "#scrape", :vcr do
    subject(:records) do
      [].tap do |collected|
        described_class.new.scrape { |record| collected << record }
      end
    end

    it "finds at least one advertised planning application" do
      expect(records.size).to be_positive
    end

    it "returns records with all the expected fields" do
      expect(records).to all(
        match(
          "council_reference" => match(/\A[A-Z]+.*\d+/),
          "address" => match(/\d{4}\z/),
          "description" => be_a(String),
          "info_url" => start_with("https://www.maribyrnong.vic.gov.au/"),
          "date_scraped" => Date.today.to_s
        )
      )
    end

    it "does not return duplicate council references" do
      references = records.map { |record| record["council_reference"] }
      expect(references.uniq).to eq(references)
    end

    it "returns non-empty descriptions" do
      expect(records.map { |record| record["description"] }).to all(match(/\S/))
    end
  end

  describe "#run", :vcr do
    it "saves each scraped record with ScraperWiki" do
      saved = []
      allow(ScraperWiki).to receive(:save_sqlite) { |keys, record| saved << [keys, record] }

      expect { described_class.new.run }.to output(/Storing /).to_stdout

      expect(saved.size).to be_positive
      expect(saved).to all(match([["council_reference"], be_a(Hash)]))
    end
  end
end
