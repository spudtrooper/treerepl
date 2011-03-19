module TreeRepl

  class TreeNode

    attr_accessor :name, :parent, :leaf
    
    @kids = nil

    def find_children
      raise 'Implement find_children'
    end

    def children(force=false)
      if force or not @kids
        @kids = find_children || []
        @kids.each do |node|
          node.parent = self
        end
      end
      @kids
    end

  end
  
  class CmdNode < TreeNode
    attr_reader :cmd
    
    class << self
      attr_accessor :classes2tree_nodes
    end
    self.classes2tree_nodes = {}
    
    def initialize(obj,cmd,name)
      @obj = obj
      @cmd = cmd
      @name = name || cmd.to_s
    end
    def find_children
      @obj.send(@cmd).map {|v| CmdNode.classes2tree_nodes[v.class].new v}
    end
  end

class NamedNode < TreeNode
  attr_reader :obj
  attr_reader :name
  def initialize(obj,name)
    @obj = obj
    @name = name
  end
  
  # Creates the children from the provided symbols defined by
  # implementing symbols()
  def find_children
    lst = symbols
    if lst.is_a? Hash
      lst.keys.sort.map {|n| CmdNode.new @obj,lst[n],n}
    else
      lst.sort {|a,b| a.to_s <=> b.to_s}.map {|n| CmdNode.new @obj,n,nil}
    end
  end

  # -> [symbol] | {string => symbol}
  #
  # The symbols (with possible) mapped names to use for children
  #
  def symbols
    raise 'Implement symbols()'
  end
end

end
