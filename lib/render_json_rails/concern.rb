module RenderJsonRails
  module Concern
    extend ActiveSupport::Concern

    # http://marcin.xxx.test/api/organize/questions/2.json?formatted=yes&include=last_answers,last_answers.user&fields[question]=id&fields[user]=email,login,get_name
    # http://marcin.xxx.test/api/organize/questions/2.json?formatted=yes&include=last_answers,team,team.questions

    # http://marcin.yyy.test/xx/55200174.json?formatted=yes&mass_fiscal_print=yes
    # http://marcin.yyy.test/xx/55200174.json?formatted=yes&fields[invoice_position]=id,fiscal_short_name
    # http://marcin.yyy.test/yy/uu.json?formatted=yes&fields[payment]=id
    # http://marcin.yyy.test/yy/uu.json?formatted=yes&fields[payment]=id&include=invoices,payment_connections

    class_methods do
      # Metoda przygotowuje parametry `options` do generowania json-a
      # `methods` to dodatkowe metody które domyślnie będą wyświetlane w jsonie
      # `allowed_methods` definiuje metody, które możemy wymienić w `fields` i wtedy
      #  zostaną one wyświelone w json-ie
      # TODO:
      # [ ] spradzanie czy parametry "fields" i "include" sa ok i jesli nie to error
      def default_json_options(name:, default_fields: nil, fields: nil, except: nil, methods: nil, allowed_methods: nil)
        # name ||= self.name.underscore.gsub('/', '_')
        # raise self.name.underscore.gsub('/', '_')
        except ||= [:account_id, :agent, :ip]
        fields_present = fields && fields[name].present?
        options = {}

        if default_fields.present? || fields_present
          fields_for_render = default_fields || []
          fields_for_render += fields[name].split(",") if fields_present

          options[:only] = fields_for_render.find_all { |el| !except.include?(el.to_sym) }
          options[:methods] = methods&.find_all { |el| options[:only].include?(el.to_s) }
          if allowed_methods
            options[:methods] = (options[:methods] || []) | allowed_methods.find_all { |el| options[:only].include?(el.to_s) }
          end
        else
          options[:except] = except
          options[:methods] = methods
        end
        options
      end

      def render_json_config(config)
        @render_json_config = config
      end

      def render_json_options(includes: nil, fields: nil, additional_config: nil)
        raise "należy skonfigurowac render_json metodą: render_json_config" if !defined?(@render_json_config)

        options = default_json_options(
          name: @render_json_config[:name].to_s,
          default_fields: @render_json_config[:default_fields],
          fields: fields,
          except: @render_json_config[:except],
          methods: @render_json_config[:methods],
          allowed_methods: @render_json_config[:allowed_methods]
        )

        if includes
          include_options = []
          @render_json_config[:includes].each do |name, klass|
            if includes.include?(name.to_s)
              includes2 = RenderJsonRails::Concern.includes_for_model(includes: includes, model: name.to_s)
              include_options << { name => klass.render_json_options(includes: includes2, fields: fields) }
            end
          end if @render_json_config[:includes]

          options[:include] = include_options
        end

        options = RenderJsonRails::Concern.deep_meld(options, additional_config) if additional_config
        options
      end # render_json_options
    end # class_methods

    def self.includes_for_model(includes:, model:)
      includes = includes.map do |el|
        if el.start_with?(model + '.')
          el = el.gsub(/^#{model}\./, '')
        else
          el = nil
        end
      end
      includes.find_all { |el| el.present? }
    end

    private

    def self.deep_meld(h1, h2)
      h1.deep_merge(h2) do |key, this_val, other_val|
        if this_val != nil && other_val == nil
          this_val
        elsif this_val == nil && other_val != nil
          other_val
        elsif this_val.is_a?(Array) && other_val.is_a?(Array)
          this_val | other_val
        elsif this_val.is_a?(Hash) && other_val.is_a?(Hash)
          deep_meld(this_val, other_val)
        else
          [this_val, other_val]
        end
      end
    end
  end
end
