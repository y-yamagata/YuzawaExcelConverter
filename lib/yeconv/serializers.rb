require 'json'

module YEConv
  module Serializer
    class BaseSerializer
      def output(element, pathset, pretty: false)
        File.write(pathset.make(extention), serialize(element, pretty: pretty))
      end
    end

    class JsonSerializer < BaseSerializer
      def extention
        'json'
      end

      def serialize(data, pretty: false)
        pretty ? JSON.pretty_generate(data) : JSON.generate(data)
      end
    end

    NameToClass = {
      'json' => JsonSerializer
    }

    class Serializers
      @store = {}

      def self.get_serializer(type)
        serializer = @store[type]
        if serializer
          return serializer
        end

        klass = NameToClass[type]
        unless klass
          return nil
        end
        serializer = klass.new
        @store[type] = serializer
      end

      def self.output(type, element, pathset, pretty: false)
        serializer = get_serializer(type)
        unless serializer
          raise ConverterError.new("No support for the type, #{type}")
        end
        serializer.output(element, pathset, pretty: pretty)
      end
    end
  end
end
