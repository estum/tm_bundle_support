class TMBundle
  class Menu
    class Item
      attr_accessor :uuid, :name, :items, :exclude, :parent, :order
      def initialize(uuid, order, name: nil, items: [], parent: nil)
        @exclude = false
        self.uuid   = uuid
        self.name   = name
        self.items  = items
        self.parent = parent
        self.order  = order
      end
    
      def checkout(options = {})
        self.name ||= options[:name]
        self.parent ||= options[:parent]
        self.order ||= options[:order]
        self.items = Array.wrap(options[:items])
        self
      end  
    
      def items=(uuids)
        @items = process_items(uuids)
      end
    
      def process_items(uuids)
        uuids.map.with_index{|id, index| Menu.find_or_create_new_item(id, index, parent: uuid) }
      end
  
      def eql?(other)
        uuid == other.uuid
      end
      
      def inspect
        "#{order||:nil}> * #{name || uuid}"
      end
      
      def name?
        name.present?
      end
    
      def items; @items ||= []; end
      def to_s; name; end
      def root?; !@parent; end
      def separator?; false; end
    end
  
    class Separator < Item
      def inspect
        "#{order}> — #{name}"
      end
      
      def initialize(uuid, order, options = {})
        @exclude = false
        self.uuid = uuid
        self.name = uuid
        self.order = order
        self.parent = options[:parent]
      end
    
      def eql?
        order == order && parent == parent
      end
      
      def separator?; true end
    end    
  end
end