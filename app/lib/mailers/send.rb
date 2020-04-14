# frozen_string_literal: true

require 'sendgrid-ruby'
require 'erb'
require 'byebug'

module Mailers
  class Send
    include SendGrid
    def initialize(email, search, data, name)
      @email = email
      @search = search
      @data = data
      @name = name
    end

    def send_mail
      sg = api_key
      response = sg.client.mail._('send').post(request_body: compose_email)
      puts response.status_code
    end

    private

    def compose_email
      JSON.generate({
                      personalizations: [
                        {
                          to: [
                            {
                              email: @email.to_s
                            }
                          ],
                          subject: "#{@name}, Here Are Your Papers for Search: #{@search.join(' ')}"
                        }
                      ],
                      from: {
                        email: 'samrhysperry@gmail.com'
                      },
                      content: [
                        {
                          type: 'text/html',
                          value: write_content
                        }
                      ]
                    })
    end

    def api_key
      SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    end

    def write_content
      renderer = ERB.new("<!DOCTYPE html>
      <html>
        <head>
          <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
        </head>
        <body>
          <h1><%=@name%>, we have some new papers for you!</h1>
          <h2>For the search terms \"<%=@search.join(', ')%>\", we found:</h2>
          <% @data.map do |paper| %>
          <h2> <%= paper['title'] %></h2>
          <h3> <%= paper['date'] %></h3>
          <h3><a href=<%=paper['link']%>><%=paper['link']%></a></h3>
          <p> <%= paper['description'] %></p>
          <p> ------------------------------ </p>
          <% end %>
        </body>
      </html>")
      renderer.result(binding)
    end
  end
end
