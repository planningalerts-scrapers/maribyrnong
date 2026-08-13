# Maribyrnong City Council

This is a scraper that runs on [Morph](https://morph.io). To get started [see the documentation](https://morph.io/documentation)

Add any issues to https://github.com/planningalerts-scrapers/issues/issues

## To run the scraper

    bundle exec ruby scraper.rb

### Expected output

    Storing TP315/2022(2) - 24 Queensville Street, Kingsville 3012
    Storing TP169/2026(1) - 60 Wilson Street, Yarraville 3013
    ...
    Storing TP204/2026(1) - 131 Rosamond Road, Maidstone 3012
    Finished - added 32 records

Execution time under a minute

## To run the tests

    bundle exec rspec

## To run style and coding checks

    bundle exec rubocop

## To check for security updates

    gem install bundler-audit
    bundle-audit
