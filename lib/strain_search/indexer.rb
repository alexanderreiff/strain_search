# frozen_string_literal: true

require 'csv'

module StrainSearch
  class Indexer
    DOC_TYPE = :_doc

    MAPPING = {
      DOC_TYPE => {
        dynamic: :strict,
        properties: {
          id: { type: :long },
          name: { type: :text },
          class: { type: :keyword },
          city: { type: :keyword },
          origin: { type: :geo_point },
          created_at: { type: :date },
          updated_at: { type: :date }
        }
      }
    }.freeze

    attr_reader :index_name

    def initialize(client:, index_name: 'strains')
      @client     = client
      @index_name = index_name
    end

    def recreate_index!
      delete_index! if index_exists?
      @client.indices.create(index: @index_name,
                             body: { mappings: MAPPING })
    end

    def populate!
      file_path = File.realpath(File.join(File.dirname(__FILE__), '..', '..', 'data', 'strains.csv'))
      to_index = []
      CSV.foreach(file_path, headers: true, encoding: 'utf-8') do |row|
        to_index << { index: { _index: @index_name, _type: DOC_TYPE, _id: row['id'] } }
        to_index << row.to_hash
      end
      ES.bulk(body: to_index)
    end

    private

    def delete_index!
      @client.indices.delete(index: @index_name)
    end

    def index_exists?
      @client.indices.exists?(index: @index_name)
    end
  end
end
