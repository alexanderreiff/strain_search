# frozen_string_literal: true

module StrainSearch
  class Suggester
    def initialize(client:, index:)
      @client = client
      @index_name = index
    end

    def autocomplete(term, **context)
      suggester_response(term, context)
        .dig('suggest', 'strain_suggest', 0, 'options')
        &.map { |options| options.dig('text') } || []
    end

    private

    def suggester_response(term, context)
      @client.search(index: @index_name,
                     body: suggest_search_body(term, context))
    end

    def suggest_search_body(term, context)
      {
        suggest: {
          # Suggester results label
          strain_suggest: {
            # User input
            prefix: term,
            # Suggester type
            completion: {
              field: 'name.suggest',
              # Booster
              contexts: autocomplete_contexts(context)
            }
          }
        }
      }
    end

    def autocomplete_contexts(context)
      {}.tap do |suggest_contexts|
        suggest_contexts[:origin] = strain_origin_context(context[:origin]) if context[:origin]
        suggest_contexts[:class] = strain_class_context(context[:class]) if context[:class]
      end
    end

    def strain_class_context(strain_class)
      [
        { context: 'class-', prefix: true },
        { context: "class-#{strain_class}", boost: 10 }
      ]
    end

    def strain_origin_context(origin)
      lat, lon = origin.split(',')
      { lat: lat, lon: lon }
    end
  end
end
