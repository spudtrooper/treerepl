module TreeRepl

  class Cmd
    attr_reader :repl,:name
    def initialize(repl,name)
      @repl = repl
      @name = name
    end
    def help
      raise 'Implement help()'
    end
    def exec(args)
      raise 'Implement exec(string[])'
    end
  end

  class Ls < Cmd
    def initialize(repl)
      super(repl,'ls')
    end
    def exec(args)
      def ls_print(n,prefix=nil)
        def pr(s,prefix)
          if prefix
            puts File.join prefix,s
          else
            puts s
          end
        end
        puts if prefix
        ['.','..'].each do |s|
          pr s,prefix
        end
        n.children.each do |node|
          pr node.name,prefix
        end
      end
      args = ['.'] if args.empty?
      args.uniq!
      args.each do |path|
        n = repl.eval_path repl.cur,path
        if n
          prefix = args.length > 1 ? path : nil
          ls_print n,prefix
        end
      end
    end
    def help
      'List directory'
    end
  end

  class Cd < Cmd
    def initialize(repl)
      super(repl,'cd')
    end
    def exec(args)
      args = ['/'] if args.empty?
      path = args.join ' '
      n = repl.eval_path repl.cur,path
      repl.cur = n if n
    end
    def help
      'Change directory'
    end
  end

  class Pwd < Cmd
    def initialize(repl)
      super(repl,'pwd')
    end
    def exec(args)
      puts cwd
    end
    def help
      'Print the current working directory'
    end
  end
  
  class Help < Cmd
    def initialize(repl)
      super(repl,'help')
    end
    def help
      'Print this message'
    end
    def exec(args)
      puts 'Commands:'
      repl.commands.sort {|a,b| a.name <=> b.name}.each do |cmd|
        printf " %-10s %s\n",cmd.name,cmd.help
      end
    end
  end

  class Quit < Cmd
    def initialize(repl)
      super(repl,'quit')
    end
    def help
      'Quit'
    end
    def exec(args)
      exit 0
    end
  end

  class Use < Cmd
    def initialize(repl)
      super(repl,'use')
    end
    def help
      'Start exploring a certain user'
    end
    def exec(args)
      if args.empty?
        STDERR.puts 'Missing required argument'
        return
      end
      username = args[0]
      user = nil
      begin
        user = repl.finder.call username
      rescue Exception => e
        STDERR.puts "Could not create user for name: #{username}"
        STDERR.puts e
      end
      if user
        repl.use repl.root_class.new user
      end
    end
  end

  class Cat < Cmd
    def initialize(repl)
      super(repl,'cat')
    end
    def help
      'Shows the contents of whatever it is you selected'
    end
    def exec(args)
      if args.empty?
        STDERR.put 'Required argument'
        return
      end
      args.each do |arg|
        n = repl.eval_path repl.cur,arg
        if n.kind_of? NamedNode
          p n.obj
        else
          STDERR.puts "Uh, not with this node #{n}"
        end
      end
    end
  end

end
