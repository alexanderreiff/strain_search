# frozen_string_literal: true

module StrainSearch
  class Suggester
    def initialize(client:, index:)
      @client = client
      @index_name = index
    end

    def autocomplete(term)
      suggester_response(term)
        .dig('suggest', 'strain_suggest', 0, 'options')
        &.map { |options| options.dig('text') } || []
    end

    private

    def suggester_response(term)
      @client.search(index: @index_name,
                     body: suggest_search_body(term))
    end

    def suggest_search_body(term)
      {
        suggest: {
          # Suggester results label
          strain_suggest: {
            # User input
            prefix: term,
            # Suggester type
            completion: { field: 'name.suggest' }
          }
        }
      }
    end
  end
end
