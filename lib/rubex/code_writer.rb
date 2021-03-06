module Rubex
  class CodeWriter
    attr_reader :code

    def initialize target_name
      @code = "/* C extension for #{target_name}.\n"\
                 "This file in generated by Rubex. Do not change!\n"\
               "*/\n"
      @indent = 0
    end

    def write_func_declaration return_type, c_name, args=""
      write_func_prototype return_type, c_name, args
      @code << ";"
      new_line
    end

    def write_func_definition_header return_type, c_name, args=""
      write_func_prototype return_type, c_name, args
    end

    def declare_variable var
      @code << " "*@indent + "#{var.type.to_s} #{var.c_name};"
      new_line
    end

    def declare_carray arr, local_scope
      stmt = "#{arr.type.type.to_s} #{arr.c_name}["
      stmt << arr.type.dimension.c_code(local_scope)
      stmt << "]"
      unless arr.value.nil?
        stmt << " = {" + arr.value.map { |a| a.c_code(local_scope) }.join(',') + "}"
      end
      stmt << ";"
      self << stmt
      nl
    end

    def init_variable var, local_scope=nil
      rhs = var.value.c_code(local_scope)
      if var.value.type.object?
        rhs = "#{var.type.from_ruby_function(rhs)}"
      end
      rhs = "(#{var.type.to_s})(#{rhs})"
      stat = " "*@indent + "#{var.c_name} = #{rhs};"
      @code << stat
      new_line
    end

    def << s
      @code << " "*@indent
      @code << s
    end

    def new_line
      @code << "\n"
    end
    alias :nl :new_line

    def indent
      @indent += 2
    end

    def dedent
      raise "Cannot dedent, already 0." if @indent == 0
      @indent -= 2
    end

    def define_instance_method_under scope, name, c_name
      @code << " "*@indent + "rb_define_method(" + scope.c_name + " ,\"" +
        name + "\", " + c_name + ", -1);"
      new_line
    end

    def to_s
      @code
    end

    def lbrace
      @code << (" "*@indent + "{")
    end

    def rbrace
      @code << (" "*@indent + "}")
    end

    def block str="", &block
      new_line
      lbrace
      indent
      new_line
      block.call
      dedent
      rbrace
      @code << str
      new_line
    end

  private

    def write_func_prototype return_type, c_name, args
      @code << "#{return_type} #{c_name} "
      @code << "("
      if args.empty?
        @code << "int argc, VALUE* argv, VALUE #{Rubex::ARG_PREFIX}self"
      else
        @code << args
      end
      @code << ")"
    end
  end
end
