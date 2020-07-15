# frozen_string_literal: true

require_relative 'base_source'

module Sources
  class Phys < BaseSource
    BASE_URL = 'phys.org'
    SEARCH_PATH = '/search/'

    def fetch_papers
      document.css("div[class='sorted-article-content w-100 d-flex flex-column']")&.each_with_object([]) do |paper, array|
        header = paper.css("h4[class='mb-2']")
        next if header.nil?

        hash = {
          title: header.text.strip,
          link: header.css('a').attribute('href').value.strip,
          date: paper.css("span[class='text-low text-uppercase text-muted']").text,
          description: paper.css("p[class='mb-2']").text.strip
        }

        array << hash
      end
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
