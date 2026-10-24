module SteamApiClient
  # Builds the immutable Data classes the endpoints return, from Steam's JSON:
  #
  #   PlayerLevel = Model.define(
  #     steam_id: [:integer, from: :steamid],
  #     level: [:integer, from: %i[stats level], optional: true],
  #     tags: [[:string], default: []]
  #   )
  #   PlayerLevel.from_json({steamid: "76561197960435530", stats: {level: 9}})
  #
  # Each field is `name: type` or `name: [type, options]`. The type is :integer, :float,
  # :string, :boolean, :number (an Integer or a Float, as Steam sends it), another model,
  # or [type] for a list. Options:
  # - from: Steam's key (Steam's names have no separators, e.g. steamid), or a path of keys
  # - optional: true when Steam may leave the key out. The field is then nil.
  # - default: the value used when Steam leaves the key out or sends null (implies optional)
  #
  # Values are converted (Steam often sends numbers as strings), nil passes through (Steam
  # sends null for values it doesn't have), and anything else raises Model::Error.
  module Model
    # Raised when Steam's JSON doesn't match a model. The message names the field
    # but never the value, which could be personal data.
    class Error < StandardError; end

    # @param [Hash{Symbol => Object}] fields name => type, or name => [type, options]
    # @yield the class body, like Data.define's block
    # @return [Class] a Data class that also responds to .from_json
    def self.define(**fields, &block)
      fields = fields.to_h do |name, spec|
        type, options = spec_parts(spec)
        [name, Field.new(name, type, **options)]
      end

      Data.define(*fields.keys, &block).tap do |klass|
        klass.instance_variable_set(:@fields, fields.freeze)
        klass.extend(ClassMethods)
        klass.include(InstanceMethods)
      end
    end

    # `[type, {options}]`, or the bare type
    def self.spec_parts(spec)
      type, options = spec
      (spec.is_a?(Array) && options.is_a?(Hash)) ? [type, options] : [spec, {}]
    end
    private_class_method :spec_parts

    # Converts one JSON value to the given type
    # @raise [Model::Error] if the value doesn't convert
    def self.cast(type, value)
      return if value.nil?

      case type
      when Array then cast_list(type.first, value)
      when Class then cast_model(type, value)
      else Scalars.public_send(Scalars.method_for(type), value)
      end
    end

    def self.cast_list(type, value)
      raise Error, "expected a list, got #{value.class}" unless value.is_a?(Array)

      value.map { |item| cast(type, item) }
    end
    private_class_method :cast_list

    # Steam sends an empty array instead of an object when there's nothing
    # (e.g. an app's mac_requirements)
    def self.cast_model(model, value)
      (value == []) ? nil : model.from_json(value)
    end
    private_class_method :cast_model

    # Turns models (and lists of them) into plain hashes
    def self.to_plain(value)
      case value
      when Data then value.to_h
      when Array then value.map { |item| to_plain(item) }
      else value
      end
    end

    # Added to every model class
    module ClassMethods
      # Builds the model from Steam's JSON (a Hash with symbol keys)
      # @raise [Model::Error] if the JSON doesn't match the model
      def from_json(json)
        raise Error, "expected an object, got #{json.class}" unless json.is_a?(Hash)

        new(**@fields.transform_values { |field| field.read(json) })
      end
    end

    # Added to every model
    module InstanceMethods
      # @return [Hash] the fields, with nested models as hashes too
      def to_h
        super.transform_values { |value| Model.to_plain(value) }
      end
    end
  end
end
