# frozen_string_literal: true

require_relative 'base_source'

module Sources
  class GoogleScholar < BaseSource
    BASE_URL = 'www.scholar.google.com'
    SEARCH_PATH = '/scholar'

    def fetch_papers
      document.css("div[class='gs_ri']")&.each_with_object([]) do |paper, array|
        next if paper.css("h3[class='gs_rt']>a").empty?

        hash = {
          title: paper.css('a').text,
          link: paper.css("h3[class='gs_rt']>a")
                     .attribute('href').value,
          description: paper.css("div[class='gs_rs']")
                            .text,
          date: Time.now.year.to_s
        }

        array << hash
      end
    end

    private

    def build_query(search_terms)
      if search_terms.size == 1
        {
          "as_ylo": Time.now.year,
          "q": search_terms.to_s,
          hl: 'en',
          as_sdt: '0,5'
        }
      else
        {
          hl: 'en',
          as_sdt: '0%2C5',
          as_ylo: Time.now.year,
          q: search_terms.join('+').to_s,
          btnG: ''
        }
      end
    end
  end
end
