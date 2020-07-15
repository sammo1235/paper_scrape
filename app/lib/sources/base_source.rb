# frozen_string_literal: true

require 'open-uri'
require 'nokogiri'
require 'byebug'
require 'openssl'

module Sources
  class BaseSource
    attr_reader :document

    def initialize(search_terms)
      hash = build_query(search_terms)
      uri = build_uri(self.class, hash)
      @document = fetch_page(uri)
    end

    def fetch_page(uri)
      count = 0
      begin
        Nokogiri::HTML(open(
                         uri,
                         ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE,
                         'User-Agent' => 'firefox'
                       ))
      rescue OpenURI::HTTPError => e
        response = e.io
        puts "Rescued: #{uri} from #{response.status}"
        nil
      rescue Errno::ECONNRESET => e
        count += 1
        retry unless count > 10
        puts "tried 10 times and couldn't get #{uri} : #{e}"
      end
    end

    def build_uri(source, hash)
      URI::HTTPS.build(
        host: source::BASE_URL,
        path: source::SEARCH_PATH,
        query: URI.encode_www_form(hash)
      )
    end
  end
end
