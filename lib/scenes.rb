require 'scenes/character'
require 'scenes/scene'

module Scenes
  
  def self.load(*patterns)
    patterns = "scenes/**/*.rb" if patterns.empty? || patterns == [nil]
    Dir.glob(patterns).each do |file|
      require file
    end
  end

end
