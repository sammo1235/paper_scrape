require 'open-uri'
require 'nokogiri'
require 'byebug'

module Sources
  class Nature
    BASE_URL = 'https://www.nature.com'
    SEARCH = '/search?q='
    def initialize(search_terms)
      query = build_query(search_terms)
      @doc = Nokogiri::HTML(open(query))
    end

    def get_papers
      data = []
      @doc.css("div[class='cleared']").each_with_index do |paper, index|
        next if index == 0
        index -= 1
        heading = paper.css("h2[role='heading']")
        inner = Hash.new
        inner['title'] = heading.text.strip
        inner['date'] = @doc.css("p[class='mt6 mb0 inline-block text13 equalize-line-height text-gray-light']")[index]
                            .css("time[itemprop='datePublished']")[0]['datetime']
        inner['link'] =  "#{BASE_URL}#{heading.children[1].attributes['href'].value}"
        inner['description'] =  paper.css("ul[class='clean-list text13 serif mb0']").text.strip
        data << inner
        break if index == 5
      end
      data
    end

    private
      def build_query(search_terms)
        search_uri = "#{BASE_URL}#{SEARCH}"
        "#{search_uri}#{search_terms.size < 2 ? search_terms[0] : search_terms.join(' ')}"
      end
  end
end
