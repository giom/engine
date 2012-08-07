module Locomotive
  module Liquid
    module Tags

      # Filter a collection
      #
      # Usage:
      #
      # {% with_scope main_developer: 'John Doe', active: true %}
      #   {% for project in contents.projects %}
      #     {{ project.name }}
      #   {% endfor %}
      # {% endwith_scope %}
      #

      class WithScope < ::Liquid::Block

        TagAttributes = /(\w+|\w+\.\w+)\s*\:\s*(#{::Liquid::QuotedFragment})/

        def initialize(tag_name, markup, tokens, context)
          @attributes = HashWithIndifferentAccess.new
          markup.scan(TagAttributes) do |key, value|
            @attributes[key] = value
          end
          super
        end

        def render(context)
          context.stack do
            context['with_scope'] = decode(@attributes, context)
            render_all(@nodelist, context)
          end
        end

        private

        def decode(attributes, context)
          processed_attributes = {}
          attributes.each_pair do |key, value|
            key_parts = key.to_s.split('.')
            key = key_parts[0].to_sym
            key_parts[1..key_parts.count].each do |part|
              key = key.send part
            end
            processed_attributes[key] = context[value]
          end
          processed_attributes
        end
      end

      ::Liquid::Template.register_tag('with_scope', WithScope)
    end
  end
end
