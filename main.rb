require 'rubygems'
require 'nokogiri'
require 'anemone'
require 'mongo'

options = {
#  :storage => Anemone::Storage.MongoDB,
  :delay => 1.0,
  :skip_query_strings => true
}

dead_links = Hash.new {|h,k| h[k] = []}

Anemone.crawl("http://www.joshibi.ac.jp/", options) do |anemone|
  anemone.focus_crawl do |page|
    page.links.keep_if do |link|
      !link.to_s.match %r{.(jpe?g|gif|png|pdf|zip|xlsx?)$}i
    end
  end

  anemone.on_every_page do |page|
    if page.doc
      puts page.url.to_s
      puts page.doc.at('title').inner_html
      links = page.links.length
      puts "find #{links} links."
    end
  end
end

