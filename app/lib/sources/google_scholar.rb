# frozen_string_literal: true

require_relative 'base_source'

module Sources
  class GoogleScholar < BaseSource
    BASE_URL = 'scholar.google.com'
    SEARCH = '/scholar'

    def initialize(search_terms)
      hash = build_query(search_terms)
      uri = URI::HTTP.build(
        host: BASE_URL,
        path: SEARCH,
        query: URI.encode_www_form(hash)
      )
      @doc = Nokogiri::HTML(open("#{uri}", ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE, 'User-Agent' => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:75.0) Gecko/20100101 Firefox/75.0'))
    end

    def fetch_papers
      data = []
      @doc.css("div[class='gs_ri']").map do |paper|
        if !paper.css("h3[class='gs_rt']>a").empty?
          hash = {
            'title' => paper.css('a').text,
            'link' => paper.css("h3[class='gs_rt']>a")
                              .attribute('href').value,
            'description' => paper.css("div[class='gs_rs']")
                                   .text,
            'date' => Time.now.year.to_s
          }
        else
          next
        end
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
