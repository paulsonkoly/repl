require 'strscan'
require 'forwardable'

######################################################################
# Tokens
class Equal; end
class LeftParen; end
class RightParen; end

class Operator
  def initialize(sym)
    @sym = sym.to_sym
  end

  def precedence
    case @sym
    when :* , :/ , :% then 1
    when :+ , :-      then 0
    end
  end

  include Comparable

  def <=>(other)
      precedence <=> other.precedence
  end

  def eval(*operands)
    operands[0].send(@sym, *operands[1..-1])
  end
end

class Operand; end

class Number < Operand
  attr_accessor :value
  def initialize(value)
    @value = value.to_f
  end
end

class Identifier < Operand
  attr_accessor :name
  def initialize(name)
    @name = name.to_sym
  end
end

######################################################################
class Lexer
  class LexerError < RuntimeError; end

  def initialize(str)
    @scanner = StringScanner.new(str)
  end

  extend Forwardable
  def_delegator :@scanner, :reset, :reset
  def_delegator :@scanner, :eos?, :eos?

  def next
    until eos?
      if @scanner.scan(/=/) then return(Equal.new)
      elsif @scanner.scan(/\(/) then return(LeftParen.new)
      elsif @scanner.scan(/\)/) then return(RightParen.new)
      elsif @scanner.scan(/[+\-*\/%]/)
        return(Operator.new(@scanner.matched))
      elsif @scanner.scan(/\d+(\.\d+)?/)
        return(Number.new(@scanner.matched))
      elsif @scanner.scan(/\w+/)
        return(Identifier.new(@scanner.matched))
      elsif @scanner.scan(/\s+/)
      else raise LexerError
      end
    end
  end
end


######################################################################
class REPL
  class UnbalancedParens < RuntimeError; end

  def initialize
    @variables = {}
  end

  def run(str)
    lexer = Lexer.new(str)

    id = lexer.next
    eq = lexer.next
    if id.class == Identifier && eq.class == Equal
      @variables[id.name] = evaluate(lexer)
    else
      lexer.reset
      evaluate(lexer)
    end
  end

  private

  def evaluate(lexer)
    tokens = shunting_yard(lexer)
    reverse_polish(tokens)
  end

  def shunting_yard(lexer)
    result, stack = [], []

    until lexer.eos?
      token = lexer.next
      case token

      when Operand then result << token

      when Operator
        while Operator === stack.last && stack.last >= token
          result << stack.pop
        end
        stack << token

      when LeftParen then stack << token
      when RightParen
        result << stack.pop until LeftParen === stack.last || stack.empty?
        raise UnbalancedParens if stack.empty?
        stack.pop
      end
    end

    until stack.empty?
      raise UnbalancedParens if LeftParen === stack.last
      result << stack.pop
    end
    result
  end

  def reverse_polish(tokens)
    stack = []
    until tokens.empty?
      token = tokens.shift
      case token
      when Number then stack << token.value
      when Identifier then stack << @variables[token.name]
      when Operator
        b, a = stack.pop, stack.pop
        stack << token.eval(a, b)
      end
    end
    stack.pop
  end
end

if __FILE__ == $0
  r = REPL.new
  loop do
    puts r.run(STDIN.readline)
  end
end
