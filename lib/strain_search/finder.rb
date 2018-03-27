# frozen_string_literal: true

module StrainSearch
  class Finder
    def initialize(client:, index:)
      @client = client
      @index_name = index
    end

    def find_by_slug(slug)
      response = @client.search(index: @index_name,
                                body: find_query(slug))

      response.dig('hits', 'hits', 0, '_source')
    end

    private

    def find_query(slug)
      {
        query: {
          term: {
            'name.slug': slug
          }
        }
      }
    end
  end
end
