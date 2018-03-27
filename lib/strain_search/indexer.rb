# frozen_string_literal: true

require 'csv'

module StrainSearch
  class Indexer
    ANALYSIS = {
      char_filter: {
        remove_space: {
          type: :pattern_replace,
          pattern: '\s+',
          replacement: '-'
        },
        remove_non_word: {
          type: :pattern_replace,
          pattern: '[^\w\u00C0-\u017F\-]',
          replacement: ''
        }
      },
      normalizer: {
        slugifier: {
          type: :custom,
          char_filter: %i[remove_space remove_non_word],
          filter: %i[lowercase asciifolding]
        }
      },
      analyzer: {
        slugifier: {
          type: :custom,
          char_filter: %i[remove_space remove_non_word],
          filter: %i[lowercase asciifolding],
          tokenizer: :keyword
        }
      }
    }.freeze

    INDEX_SETTINGS = { analysis: ANALYSIS }.freeze

    DOC_TYPE = :_doc

    MAPPING = {
      DOC_TYPE => {
        dynamic: :strict,
        properties: {
          id: { type: :long },
          name: {
            type: :text,
            fields: {
              suggest: {
                type: :completion,
                analyzer: :pattern,
                contexts: [
                  {
                    name: :class,
                    type: :category,
                    path: :class
                  },
                  {
                    name: :origin,
                    type: :geo,
                    path: :origin,
                    precision: '25mi'
                  }
                ]
              },
              slug: {
                type: :keyword,
                normalizer: :slugifier
              }
            }
          },
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
                             body: {
                               mappings: MAPPING,
                               settings: INDEX_SETTINGS
                             })
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
