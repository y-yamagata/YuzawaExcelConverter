require 'forwardable'
require 'yeconv/helper'

module YEConv
  module Element
    module Type
      Number = 1
      String = 2
      Boolean = 3
      List = 4
      Object = 5
    end

    class BaseElement
      attr_reader :key, :parent

      def initialize(key=nil, parent=nil)
        @key = key
        @parent = parent
      end
    end

    class PrimitiveElement < BaseElement
      attr_reader :value

      def initialize(key, parent, formatter: nil)
        @value = nil
        @formatter = formatter
        super(key, parent)
      end

      def set(value)
        @value = @formatter ? @formatter.call(value) : value
      end

      def empty?
        !!@value
      end

      def build
        @value
      end
    end

    class NumberElement < PrimitiveElement
      def initialize(key, parent, formatter: nil)
        formatter = formatter || lambda { |v| v.is_a?(Float) || v.is_a?(Integer) ? v : v.to_f }
        super(key, parent, formatter: formatter)
      end

      def type
        Element::Type::Number
      end
    end

    class StringElement < PrimitiveElement
      def initialize(key, parent, formatter: nil)
        formatter = formatter || lambda { |v| v.is_a?(String) ? v : v.to_s }
        super(key, parent, formatter: formatter)
      end

      def type
        Element::Type::String
      end
    end

    class BooleanElement < PrimitiveElement
      def initialize(key, parent, formatter: nil)
        formatter = formatter || lambda { |v| YEConv::to_bool(v) }
        super(key, parent, formatter: formatter)
      end

      def type
        Element::Type::Boolean
      end
    end

    class ListElement < BaseElement
      extend Forwardable

      def_delegators :@list, :[], :[]=, :append, :each

      def initialize(key, parent=nil)
        @list = []
        super(key, parent)
      end

      def type
        Element::Type::List
      end

      def build
        @list.map { |v| v.build() }
      end
    end

    class ObjectElement < BaseElement
      extend Forwardable

      def_delegators :@map, :[], :[]=

      def initialize(key=nil, parent=nil)
        @map = {}
        super(key, parent)
      end

      def type
        Element::Type::Object
      end

      def build
        data = {}
        @map.each do |k, v|
          data[k] = v.build()
        end
        data
      end
    end

    NameToType = {
      'number' => Type::Number,
      'string' => Type::String,
      'boolean' => Type::Boolean,
      'list' => Type::List,
      'object' => Type::Object
    }

    TypeToClass = {
      Type::Number => NumberElement,
      Type::String => StringElement,
      Type::Boolean => BooleanElement
    }

    def self.get_type(name)
      NameToType[name]
    end

    def self.create(type, key, parent, formatter: nil)
      klass = TypeToClass[type]
      unless klass
        raise ConverterError.new("No support for the type, #{type}")
      end
      klass.new(key, parent, formatter: formatter)
    end

  end
end
