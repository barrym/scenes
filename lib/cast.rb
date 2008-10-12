module CastMethods
  def with(&block)
    returning self do |obj|
      yield obj
      obj.save
    end
  end
end

class Cast

  @@members = {}
  @@loaded = {}

  def self.member(name, &block)
    if self.exists?(name)
      return self.load(name)
    else
      @@members[name] = block
    end
  end

  def self.[](name)
    self.load(name)
  end

  def self.load(name)
    if self.exists?(name)
      if self.loaded?(name)
        id = @@loaded[self.actual_name(name)].id
        member = @@loaded[self.actual_name(name)].class.find(id)
      else
        member = @@loaded[self.actual_name(name)] = @@members[self.actual_name(name)].call
      end
      member.extend(CastMethods)
    else
      raise "Missing cast member #{name}"
    end
  end

  def self.list
    @@members.keys.sort
  end

  def self.clear
    @@loaded = {}
  end

  def self.exists?(name)
    !!(self.actual_name(name))
  end

  def self.loaded?(name)
    !@@loaded[self.actual_name(name)].blank?
  end

  def self.actual_name(name)
    self.list.detect {|cast| cast =~ /^#{name}$/i}
  end

end
