# frozen_string_literal: true

require 'elasticsearch'
require 'json'
require 'sinatra/base'
require 'sinatra/reloader'
require 'lib/strain_search/indexer'

ES         = Elasticsearch::Client.new(url: ENV['ELASTICSEARCH_URL'])
INDEXER    = StrainSearch::Indexer.new(client: ES)
INDEX_NAME = INDEXER.index_name

# On app start up, re-initialize index
INDEXER.recreate_index!
puts "`#{INDEX_NAME}` index created! ✅"
INDEXER.populate!
puts "`#{INDEX_NAME}` populated with strains! ✅ 🌲"

module StrainSearch
  class Server < Sinatra::Base
    configure { register Sinatra::Reloader }
    before { content_type :json }
  end
end
