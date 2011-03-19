module TreeRepl

  class Repl

    attr_reader :root
    attr_accessor :commands
    attr_accessor :cur
    attr_accessor :root_class

    # String -> TreeNode
    attr_accessor :finder
    
    def initialize(root_class)
      @root_class = root_class
      @finder = nil
      @commands = [Ls,Cd,Pwd,Use,Help,Quit,Cat].map {|cls| cls.new self}
    end

    def add_command(command_class)
      @commands << command_class.new(self)
    end

    # ----------------------------------------------------------------------
    # Main
    # ----------------------------------------------------------------------

    # TreeNode -> Void
    def main(root)
      use root
      strings2cmds = {}
      commands.each do |cmd|
        strings2cmds[cmd.name] = cmd
      end
      def loop(strings2cmds)
        print cwd + '> '
        orig_line = STDIN.readline.strip
        line = orig_line.split(/ /)
        return false if line.empty?
        str = line.shift.downcase
        return true if str == 'quit'
        if not cur
          if str != 'use' and str != 'help'
            STDERR.puts 'You must set a user with \'use\' before anything else.'
            return
          end
        end
        args = line
        cmd = strings2cmds[str]
        if cmd
          begin
            cmd.exec args
          rescue Exception => e
            STDERR.puts 'Trouble executing: ' + orig_line
            raise e
          end
        else
          STDERR.puts 'Unknown command: ' + str
        end
        return false
      end
      while true
        break if loop strings2cmds
      end
    end

    # ----------------------------------------------------------------------
    # 'Private'
    # ----------------------------------------------------------------------

    def use(user)
      if user
        @cur = user
        @root = user
      end
    end

    # TreeNode string -> TreeNode
    def eval_path(node,path)
      path = '.' if not path or path == ''
      if path =~ /^\//
        args = ['/'] + path.gsub(/^\/+/,'').split(/\//)
      else
        args = path.split /\//
      end
      trav = node
      args.each do |arg|
        case arg
        when '.'
          trav = trav
        when '..'
          trav = trav.parent
        when '/'
          trav = root
        else
          found = false
          trav.children.each do |n|
            if n.name == arg
              trav = n
              found = true
              break
            end
          end
          if not found
            STDERR.puts 'Invalid path: ' + path
            return nil
          end
        end
      end
      return trav
    end

    # void -> string
    def cwd
      path(root,cur).map {|n| n.name}.join('/')
    end

    # TreeNode string -> TreeNode
    def node_relative_to(node,name)
      if name == '.'
        return node
      elsif name == '..'
        return node.parent
      elsif name == '/'
        return root
      else
        node.children.each do |n|
          if name == n.name
            return n
          end
        end
      end
      return nil
    end

    # TreeNode TreeNode -> TreeNode[]
    def path(from,dest)
      res = []
      trav = dest
      while trav
        res.push trav
        break if trav == from
        trav = trav.parent
      end
      return res.reverse
    end
    
  end

end
