require 'rubygems'
require 'nokogiri'
require 'anemone'
require 'mongo'

require 'parallel'
require './lib/LinkMap'

url = "http://www.example.com/"

options = {
#  :storage => Anemone::Storage.MongoDB,
  :delay => 1.0,
  :skip_query_strings => true
}

linkmap = LinkMap.new url

Anemone.crawl(url, options) do |anemone|
  anemone.focus_crawl do |page|
    page.links.keep_if do |link|
      !link.to_s.match %r{.(jpe?g|gif|png|pdf|zip|xlsx?)$}i
    end
  end

  anemone.on_every_page do |page|
    if page.doc
      puts page.url.to_s
      title = page.doc.at 'title'
      puts title.inner_html if title
      puts "ficnd #{page.links.length} links."

      Parallel.each(page.links, in_threads: 5) do |link|
        linkmap.store :from => page.url.to_s, :to => link.to_s
      end
    end
  end
end

p linkmap
