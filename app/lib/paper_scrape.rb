# frozen_string_literal: true

require_relative 'sources/nature'
require_relative 'sources/google_scholar'
require_relative 'sources/phys'
require 'byebug'

class PaperScrape
  include Sources

  attr_reader :search

  SOURCES = [
    Sources::Nature,
    Sources::GoogleScholar,
    Sources::Phys
  ].freeze

  def initialize(search)
    @search = search
  end

  def fetch_data
    SOURCES.each_with_object([]) do |source, array|
      array << source.new(search).fetch_papers
    end.flatten
  end
end
