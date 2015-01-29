require "active_support"
require "active_support/core_ext"
require "active_support/dependencies/autoload"
require "tm_bundle/plutil"

class TMBundle
  extend ActiveSupport::Autoload
  
  eager_autoload do
    autoload :Menu, "tm_bundle/menu"
  end
  
  class Action
    attr_accessor :path, :data
    def initialize(path)
      @path = path
      @data = Plutil.load_json(path)
    end
    
    def inspect
      "#{self.class.name}:> #{data['name']} > `#{path.basename}`"
    end
    
    def expected_path
      @expected_path ||= data['name'].gsub(/[.:\/]+/, '.' => '_', ':' => '', '/' => '') + path.extname
    end
    
    def unmatching_path?
      expected_path != path.basename.to_s
    end
    
    def method_missing(meth, *args, &blk)
      meth_name = meth.to_s
      if @data.key?(meth_name) 
        @data[meth_name]
      else 
        super
      end
    end
  end
  class Command < Action; end
  class Snippet < Action; end
  class Macro < Action; end
  
  attr_accessor :path, :actions, :data, :menu
  
  def initialize(path = nil)
    self.path    = path ? Pathname.new(path) : Pathname.pwd
    self.data    = Plutil.load_json(@path/'info.plist')
    self.menu    = Menu.new(data['mainMenu'], @path)
    self.actions = []
    locate_actions
    fill_missing_menu_names!
    # menu.write_yaml_hierarchy!
  end
  
  def locate_actions
    Pathname.glob("#{path}/{Commands,Snippets,Macros}/*.{plist,tm{Command,Snippet}}")
      .group_by {|p| p.dirname.basename.to_s }
      .each do |group, files|
        # p group.downcase.to_sym, actions
        files.each do |pathname|
          actions << TMBundle.const_get(group.singularize.to_sym).new(pathname)
        end
      end
  end
  
  def fix_names!
    actions.select(&:unmatching_path?).each do |action|
      action.path.rename(action.path.dirname/action.expected_path)
    end
  end
  
  def fill_missing_menu_names!
    actions.each do |action|
      if item = menu.uuids[action.uuid]
        item.name ||= action.name
      else
        Menu.find_or_create_new_item(action.uuid, 0, name: action.name)
      end
    end
  end
  
  def menu_export!(prefix)
    fill_missing_menu_names!
    menu.write_yaml_hierarchy!(prefix && "-#{prefix}")
  end
  
  def save_plist!(type = :default)
    fill_missing_menu_names!
    
    file = case type
           when :last  then Pathname.glob((path/"menu-*.yml").to_s).last
           when String then path/"menu-#{type}.yml"
                       else path/"menu.yml" end
    
    hash = menu.read_yaml_hieararchy! file
    xml  = process_xml_output Plutil::JSON.dump(hash)
    puts Plutil.replace(@path/'info.plist', 'mainMenu', xml, &:read)
  end
  
  def process_xml_output(xml)
    xml.lines[3...-1]
      .join
      .gsub(/(?<=$\n|\t)\t/, "\n\t" => "\n", "\t" => "  ")
  end
end