# frozen_string_literal: true

require_relative 'base_source'

module Sources
  class Nature < BaseSource
    BASE_URL = 'www.nature.com'
    SEARCH_PATH = '/search'

    def fetch_papers
      document.css("li[class='mb20 pb20 cleared']")&.each_with_object([]).with_index do |(paper, array), index|

        heading = paper.css("h2[role='heading']")
        inner = {
          title: heading.text.strip,
          date: paper.css('p>time').text.strip,
          link: "https://www.#{BASE_URL}#{heading.css('a').attribute('href').value}",
          description: paper.css("ul[class='clean-list text13 serif mb0']").text.strip
        }
        array[index] = inner
      end
    end

    private

    def build_query(search)
      {
        q: search.respond_to?(:join) ? search.join(' ') : search
      }
    end
  end
end
