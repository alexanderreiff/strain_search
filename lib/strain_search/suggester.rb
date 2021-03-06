# frozen_string_literal: true

module StrainSearch
  class Suggester
    def initialize(client:, index:)
      @client = client
      @index_name = index
    end

    def autocomplete(term, **context)
      suggester_response(term, context, source: false)
        .dig('suggest', 'strain_suggest', 0, 'options')
        &.map { |options| options.dig('text') } || []
    end

    def search(term, **context)
      suggester_response(term, context)
        .dig('suggest', 'strain_suggest', 0, 'options')
        &.map { |options| options.dig('_source') } || []
    end

    private

    def suggester_response(term, context, source: true)
      @client.search(index: @index_name,
                     body: suggest_search_body(term, context)).merge(source_fields(source))
    end

    def source_fields(source)
      return {} if source
      { _source: source }
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
              # Fuzziness
              fuzzy: true,
              # Booster
              contexts: autocomplete_contexts(context),
              # Result count
              size: 20
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
