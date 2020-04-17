# frozen_string_literal: true

require_relative 'base_source'

module Sources
  class GoogleScholar < BaseSource
    BASE_URL = 'scholar.google.com'
    SEARCH_PATH = '/scholar'

    def initialize(search_terms)
      hash = build_query(search_terms)
      uri = build_uri(self.class, hash)
      @doc = fetch_page(uri)
    end

    def fetch_papers
      data = []
      return data if @doc.nil?

      @doc.css("div[class='gs_ri']")&.map do |paper|
        next if paper.css("h3[class='gs_rt']>a").empty?

        hash = {
          title: paper.css('a').text,
          link: paper.css("h3[class='gs_rt']>a")
                     .attribute('href').value,
          description: paper.css("div[class='gs_rs']")
                            .text,
          date: Time.now.year.to_s
        }

        data << hash
      end
      data
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
