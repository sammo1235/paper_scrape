# frozen_string_literal: true

require_relative 'base_source'

module Sources
  class Phys < BaseSource
    BASE_URL = 'phys.org'
    SEARCH_PATH = '/search/'

    def initialize(search_terms)
      hash = build_query(search_terms)
      uri = build_uri(self.class, hash)
      @doc = fetch_page(uri)
    end

    def fetch_papers
      data = []
      return data if @doc.nil?

      @doc.css("div[class='sorted-article-content w-100 d-flex flex-column']")&.map do |paper|
        header = paper.css("h4[class='mb-2']")
        next if header.nil?

        hash = {
          title: header.text.strip,
          link: header.css('a').attribute('href').value.strip,
          date: paper.css("span[class='text-low text-uppercase text-muted']").text,
          description: paper.css("p[class='mb-2']").text.strip
        }

        data << hash
      end
      data
    end

    private

    def build_query(search)
      {
        search: search.respond_to?(:join) ? search.join('+') : search,
        s: 0
      }
    end
  end
end
