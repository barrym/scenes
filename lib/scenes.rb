require  File.join(File.dirname(__FILE__), 'scenes/character')
require  File.join(File.dirname(__FILE__), 'scenes/scene')

module Scenes
  
  def self.load(*patterns)
    patterns = "scenes/**/*.rb" if patterns.empty? || patterns == [nil]
    Dir.glob(patterns).each do |file|
      require file
    end
  end

end

# shorcuts methods
def set_scene(name, &block); Scenes::Scene.named(name,&block); end
def get_scene(name); Scenes::Scene[name]; end 
def set_character(name, &block); Scenes::Character.named(name,&block); end
def get_character(name); Scenes::Character[name]; end 
