module YEConv
  class WorkSpace
    def initialize(workbook)
      @workbook = workbook
      @store = Element::ObjectElement.new
    end

    def set(path, type, source, formatter: nil)
      node = @store
      while segment = path.car do
        parent = node
        node = node[segment.key]
        if !node
          if segment.is_a?(Segment::KeySegment)
            node = path.edge? ? Element::create(type, segment.key, parent, formatter: formatter) : Element::ObjectElement.new(segment.key, parent)
          elsif segment.is_a?(Segment::BracketSegment)
            node = Element::ListElement.new(segment.key, parent)
          end
          parent[segment.key] = node
        elsif path.edge? && type != node.type
          raise ConverterError.new('Unmatch type')
        end

        if node.type == Element::Type::List
          context = ArrayContext.new(@workbook, node)
          context.set(path.cdr, type, source, formatter: formatter)
          break
        elsif path.edge?
          values = source.values(@workbook)
          node.set(values[0])
        end
        path = path.cdr
      end
    end

    def build
      @store.build()
    end
  end

  class ArrayContext
    def initialize(workbook, store)
      @workbook = workbook
      @store = store
    end

    def set(path, type, source, formatter: nil)
      values = source.values(@workbook)
      index = 0
      for value in values do
        node = @store[index]
        if !node
          node = path.empty? ? Element::create(type, nil, @store, formatter: formatter) : Element::ObjectElement.new(nil, @store)
          @store[index] = node
        elsif path.empty? && type != node.type
          raise ConverterError.new('Unmatch type')
        end
        if path.empty?
          node.set(value)
          next
        end

        iter = path
        while segment = iter.car do
          if segment.is_a?(Segment::BracketSegment)
            raise ConverterError.new('No support for list including list now')
          end
          parent = node
          node = node[segment.key]
          if !node
            node = iter.edge? ? Element::create(type, segment.key, parent, formatter: formatter) : Element::ObjectElement.new(segment.key, parent)
            parent[segment.key] = node
          elsif iter.edge? && type != node.type
            raise ConverterError.new('Unmatch type')
          end

          if iter.edge?
            node.set(value)
          end
          iter = iter.cdr
        end
        index += 1
      end
    end
  end
end
