# frozen_string_literal: true

require_relative './app/lib/paper_scrape'
require_relative './app/lib/mailers/send'
require 'yaml'
require 'byebug'

desc 'Send out email(s) to users on their chosen topics'
task :send_emails_to_users do
  users = YAML.load_file('app/config/users.yml')
  users.map do |user|
    user = user[1]
    data = PaperScrape.new(user['search_terms']).fetch_data
    Mailers::Send.new(
      user['email'],
      user['search_terms'],
      data,
      user['name']
    ).send_mail
  end
end
