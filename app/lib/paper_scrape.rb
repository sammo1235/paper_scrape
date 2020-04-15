# frozen_string_literal: true

require_relative 'sources/nature'
require_relative 'sources/google_scholar'
require_relative 'sources/phys'
require 'byebug'

class PaperScrape
  include Sources
  SOURCES = [
    Sources::Nature,
    Sources::GoogleScholar,
    Sources::Phys
  ].freeze

  def initialize(search)
    @search = to_array(search)
  end

  def to_array(search)
    if search.is_a? Array
      search
    else
      search.split(' ')
    end
  end

  def fetch_data
    data = []
    SOURCES.map do |sourced|
      data << sourced.new(@search).fetch_papers
    end
    data
  end
end
