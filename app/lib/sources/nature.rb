# frozen_string_literal: true

require_relative 'base_source'

module Sources
  class Nature < BaseSource
    BASE_URL = 'https://www.nature.com'
    SEARCH = '/search?q='

    def initialize(search_terms)
      query = build_query(search_terms)
      @doc = Nokogiri::HTML(open(query))
    end

    def fetch_papers
      data = []
      @doc.css("li[class='mb20 pb20 cleared']").each_with_index do |paper, index|
        heading = paper.css("h2[role='heading']")
        inner = {
          title: heading.text.strip,
          date: paper.css('p>time').text.strip,
          link: "#{BASE_URL}#{heading.css('a').attribute('href').value}",
          description: paper.css("ul[class='clean-list text13 serif mb0']").text.strip
        }
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
