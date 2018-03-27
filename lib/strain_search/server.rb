# frozen_string_literal: true

require 'elasticsearch'
require 'json'
require 'sinatra/base'
require 'sinatra/reloader'

ES = Elasticsearch::Client.new(url: ENV['ELASTICSEARCH_URL'])

module StrainSearch
  class Server < Sinatra::Base
    configure { register Sinatra::Reloader }
    before { content_type :json }
  end
end
