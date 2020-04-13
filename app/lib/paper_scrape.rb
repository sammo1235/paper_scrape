require_relative './sources/nature'
require 'byebug'

class PaperScrape
  include Sources
  SOURCES = [
    Sources::Nature
  ].freeze

  def initialize(search)
    @search = to_array(search)
  end

  def to_array(search)
    unless search.is_a? Array
      search.split(' ')
    else
      search
    end
  end

  def get_data
    data = []
    SOURCES.map do |sourced|
      data << sourced.new(@search).get_papers
    end
    data
  end
end