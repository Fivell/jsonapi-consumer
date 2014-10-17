module JSONAPI::Consumer
  module Resource
    extend ActiveSupport::Concern

    included do
      extend ActiveModel::Naming

      class << self
        attr_writer :host
      end
    end

    include AttributesConcern
    include AssociationConcern
    include FindersConcern
    include SerializerConcern
    include ConnectionConcern

    module ClassMethods
      def json_key
        self.name.demodulize.pluralize.underscore
      end

      def host
        @host || raise(NotImplementedError, 'host was not set')
      end

      def path
        json_key
      end

      def ssl
        {}
      end
    end

    # FIXME
    # extend ActiveModel::Callbacks
    # define_model_callbacks :save, :create, :destroy

    def initialize(params={})
      params.slice(*association_names).each do |key, value|
        set_association(key, value)
      end

      self.attributes = params.except(*association_names) if params
      super()
    end

  private

    def method_missing(method, *args, &block)
      if respond_to_without_attributes?(method, true)
        super
      else
        if method.to_s =~ /^(.*)=$/
          set_attribute($1, args.first)
        elsif has_attribute?(method)
          read_attribute(method)
        elsif has_association?(method)
          read_assocation(method)
        end
      end
    end
  end
end