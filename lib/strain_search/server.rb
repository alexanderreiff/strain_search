# frozen_string_literal: true

require 'elasticsearch'
require 'json'
require 'sinatra/base'
require 'sinatra/reloader'
require 'lib/strain_search/indexer'
require 'lib/strain_search/suggester'

ES         = Elasticsearch::Client.new(url: ENV['ELASTICSEARCH_URL'])
INDEXER    = StrainSearch::Indexer.new(client: ES)
INDEX_NAME = INDEXER.index_name
SUGGESTER  = StrainSearch::Suggester.new(client: ES, index: INDEX_NAME)

# On app start up, re-initialize index
INDEXER.recreate_index!
puts "`#{INDEX_NAME}` index created! ✅"
INDEXER.populate!
puts "`#{INDEX_NAME}` populated with strains! ✅ 🌲"

module StrainSearch
  class Server < Sinatra::Base
    configure { register Sinatra::Reloader }
    before { content_type :json }

    # ?q=<search_term>&lat_lon=<lat_lon>&prefer=(indica|sativa|hybrid)
    get '/autocomplete' do
      results = SUGGESTER.autocomplete(params['q'], origin: params['lat_lon'], class: params['prefer'])
      JSON[data: { terms: results }]
    end

    # ?q=<search_term>&lat_lon=<lat_lon>&prefer=(indica|sativa|hybrid)
    get '/search' do
      results = SUGGESTER.search(params['q'], origin: params['lat_lon'], class: params['prefer'])
      JSON[data: { results: results }]
    end
  end
end
