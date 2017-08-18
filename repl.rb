require 'parslet'

######################################################################
class REPLParser < Parslet::Parser
  root :instruction

  rule :instruction do
    assignment.as(:assignment) | low_precedence
  end

  rule :assignment do
    variable >> wp? >> str('=') >> wp? >> low_precedence.as(:expression)
  end

  rule :wp? { match('[ \t]').maybe }

  rule :low_precedence do
    (high_precedence.as(:left) >>
     wp? >> match('[+-]').as(:operator) >> wp? >>
     low_precedence.as(:right)) |
    high_precedence
  end

  rule :high_precedence do
    (atom.as(:left) >>
      wp? >> match('[*/%]').as(:operator) >> wp? >>
      high_precedence.as(:right)) |
      atom
  end

  rule :atom { parenthesis | variable | value }

  rule :parenthesis do
    str('(') >> wp? >> low_precedence >> wp? >> str(')')
  end

  rule :variable do
    (match('[a-zA-Z]') >> match('[a-zA-Z0-9]').repeat(0)).as(:variable)
  end

  rule :value do
    (match('[0-9]').repeat(1) >>
     (str('.') >> match('[0-9]').repeat(1)).maybe).as(:value)
  end
end

######################################################################
class REPL
  class UnbalancedParens < RuntimeError; end

  def initialize
    @variables = {}
  end

  def run(str)
    parser = REPLParser.new
    begin
      tree = parser.parse(str)
    rescue
      raise UnbalancedParens
    end

    assignment = tree[:assignment]
    if assignment
      @variables[assignment[:variable].str] = evaluate(assignment[:expression])
    else
      evaluate(tree)
    end
  end

  private

  def evaluate(tree)
    case
    when tree[:operator] then evaluate(tree[:left]).send(tree[:operator], evaluate(tree[:right]))
    when tree[:variable] then @variables[tree[:variable].str]
    when tree[:value] then tree[:value].to_f
    else raise tree.inspect
    end
  end
end

if __FILE__ == $0
  r = REPL.new
  loop do
    puts r.run(STDIN.readline)
  end
end
