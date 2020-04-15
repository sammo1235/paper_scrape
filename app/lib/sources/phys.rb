# frozen_string_literal: true

require_relative 'base_source'

module Sources
  class Phys < BaseSource
    BASE_URL = 'phys.org'
    SEARCH_PATH = '/search/'

    def initialize(search_terms)
      hash = build_query(search_terms)
      uri = URI::HTTP.build(
        host: BASE_URL,
        path: SEARCH_PATH,
        query: URI.encode_www_form(hash)
      )
      @doc = Nokogiri::HTML(open(
                              uri,
                              ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE,
                              'User-Agent' => 'safari'
                            ))
    end

    def fetch_papers
      data = []
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
