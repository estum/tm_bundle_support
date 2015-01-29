class TMBundle
  class Menu
    extend ActiveSupport::Autoload
    
    eager_autoload do
      autoload :Item,      "tm_bundle/item"
      autoload :Separator, "tm_bundle/item"
    end
    
    cattr_accessor(:uuids){ Hash[] }
    cattr_accessor(:items){ Set.new }
    
    def self.find_or_create_new_item(uuid, order, attributes = {})
      item = if uuid.squeeze == '-'
        Separator.new(uuid, order, attributes) 
      elsif exists?(uuid)
        uuids[uuid].checkout(attributes.to_h)
      else 
        Item.new(uuid, order, attributes.to_h)
      end
      
      items.add item if item.is_a?(Item) && item.root?
      unless item.is_a? Separator
        uuids[uuid] ||= item
      end
      item
    end
    
    def self.exists?(uuid)
      uuids.key? uuid
    end
    
    def initialize(tree, path)
      @path = path
      submenus, items, @excludedItems = *tree.values_at("submenus", "items", "excludedItems")
      process_subtree(submenus)
    end
    
    def process_subtree(submenus)
      submenus.each do |uuid, hash|
        self.class.find_or_create_new_item(uuid, submenus.keys.index(uuid), hash.symbolize_keys)
      end
    end
    
    def write_yaml_hierarchy!(prefix = nil)
      p prefix
      tree = make_hash_tree! uuids.values.select(&:root?)
      yaml = tree.to_yaml.gsub(/^(.*)\s*$\n\s*:uuid:(.*)$/){|s,n| "%-60s # %s" % [$1, $2] }
      (Pathname.new(@path)/"menu#{prefix}.yml").write(yaml)
    end
    
    def read_yaml_hieararchy!(file)
      yaml = file.read
      yaml.gsub!(/^(\s*)(.*)\s*#\s*(.*)$/){|s,n| "#{$1}%s \n#{$1}  :uuid: %s" % [$2, $3] }
      prepare_items_to_plist YAML.load(yaml)
    end
    
    def make_hash_tree!(items)
      items.reduce(Hash[]) do |m, item| 
        hash = { uuid: item.uuid }
        hash[:items] = make_hash_tree!(item.items) if item.items.any?
        
        m.merge! item.name => hash
      end
    end
    
    def prepare_items_to_plist(hash)
      @menu = { submenus: {}, items: [], excludedItems: Array.wrap(@excludedItems) }
      @menu[:items] = Array.wrap(iterate_to_plist(hash))
      @menu
    end
    
    def iterate_to_plist(hash, parent = nil)
      ary = []
      hash.each do |name, tree|
        uuid = tree[:uuid]
        if tree[:items]
          ary << uuid
          @menu[:submenus][uuid] = {
            :items => iterate_to_plist(tree[:items]),
            :name  => name
          }
        else
          ary << uuid
        end
      end
      ary
    end
  end
end