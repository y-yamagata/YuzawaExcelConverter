module YEConv
  class Path
    def initialize(path)
      @segments = path.is_a?(String) ? parse(path) : path
    end

    def car
      @segments.slice(0)
    end

    def cdr
      Path.new(@segments.slice(1, @segments.size))
    end

    def edge?
      @segments.length == 1
    end

    def empty?
      @segments.empty?
    end

    def to_s
      @segments.map { |seg| seg.to_s }.join('.')
    end

    private

    def parse(path)
      keys = path.split(/\./)
      keys.map { |key|
        if key.end_with?('[]')
          next Segment::BracketSegment.new(key.chomp('[]'))
        end
        Segment::KeySegment.new(key)
      }
    end
  end

  module Segment
    class BaseSegment
      attr_reader :key

      def initialize(key)
        @key = key
      end
    end

    class KeySegment < BaseSegment
      def to_s
        @key
      end
    end

    class BracketSegment < BaseSegment
      def to_s
        @key + '[]'
      end
    end
  end
end
