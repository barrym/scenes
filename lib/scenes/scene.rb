module Scenes

  module SceneMethods
    def play( _options = {})
      options = {
        :clear => true
      }.merge(_options)

      Character.clear if options[:clear]
      self.call
      true
    end
  end

  class Scene

    @@scenes = {}

    def self.named(name, &block)
      if self.exists?(name)
        return self.load(name)
      else
        @@scenes[name] = block.extend(SceneMethods)
      end
    end

    def self.list
      @@scenes.keys.sort {|a,b| a.downcase <=> b.downcase }
    end

    def self.[](name)
      self.load(name)
    end

    def self.load(name)
      if self.exists?(name)
        @@scenes[self.actual_name(name)]
      else
        raise "Missing scene #{name}"
      end
    end

    def self.exists?(name)
      !!(self.actual_name(name))
    end

    def self.actual_name(name)
      self.list.detect {|scene| scene =~ /^#{name}$/i}
    end

  end
end
