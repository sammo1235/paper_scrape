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
      puts "#{uri}"
      @doc = Nokogiri::HTML(open("#{uri}"))
    end

    def fetch_papers
      data = []
      @doc.css("div[class='gs_ri']").map do |paper|
        hash = {}
        hash['title'] = paper.css('a').text
        if !paper.css("h3[class='gs_rt']>a").empty?
          hash['link'] = paper.css("h3[class='gs_rt']>a").attribute('href').value
        else
          hash['link'] = "citation"
        end
        hash['description'] = paper.css("div[class='gs_rs']")
                                   .text
        hash['date'] = Time.now.year.to_s
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

puts Sources::GoogleScholar.new(['wolves', 'canada']).fetch_papers