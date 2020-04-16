# frozen_string_literal: true

require_relative 'base_source'

module Sources
  class Nature < BaseSource
    BASE_URL = 'nature.com'
    SEARCH_PATH = '/search'

    def initialize(search_terms)
      hash = build_query(search_terms)
      uri = build_uri(self.class, hash)
      @doc = fetch_page(uri)
    end

    def fetch_papers
      data = []
      @doc.css("li[class='mb20 pb20 cleared']")&.each_with_index do |paper, index|
        heading = paper.css("h2[role='heading']")
        inner = {
          title: heading.text.strip,
          date: paper.css('p>time').text.strip,
          link: heading.css('a').attribute('href').value,
          description: paper.css("ul[class='clean-list text13 serif mb0']").text.strip
        }
        data << inner
        break if index == 5
      end
      data
    end

    private

    def build_query(search)
      {
        q: search.respond_to?(:join) ? search.join(' ') : search
      }
    end
  end
end
