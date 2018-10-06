require 'parslet'

class Parslet::Atoms::Base
  def surrounded_by(other, other2 = other)
    other >> self >> other2
  end
end

######################################################################
# Grammar :
#
# INSTRUCTION     -> ASSIGNMENT | LOW_PRECEDENCE
# ASSIGNMENT      -> variable '=' LOW_PRECEDENCE
# LOW_PRECEDENCE  -> HIGH_PRECEDENCE [+-] LOW_PRECEDENCE | HIGH_PRECEDENCE
# HIGH_PRECEDENCE -> ATOM [*/%] HIGH_PRECEDENCE | ATOM
# ATOM            -> PARENTHESIS | variable | value
# PARENTHESIS     -> '(' LOW_PRECEDENCE ')'
#
# The parser also eats the optional white spaces around tokens.
class REPLParser < Parslet::Parser
  root :instruction

  rule(:instruction) { assignment.as(:assignment) | low_precedence }

  rule(:assignment) { variable >> equal >> low_precedence.as(:expression) }

  def self.operator(name, list, sub_rule)
    rule name do
      send(sub_rule).as(:left) >>
      match(list).as(:operator).surrounded_by(wp?) >>
      send(name).as(:right) |
      send(sub_rule)
    end
  end

  operator :low_precedence, '[+-]', :high_precedence
  operator :high_precedence, '[*/%]', :atom

  rule(:atom) { parenthesis | variable | value }

  rule :parenthesis do
    low_precedence.surrounded_by(str('(') >> wp?, wp? >> str(')'))
  end

  rule :variable do
    (match('[a-zA-Z]') >> match('[a-zA-Z0-9]').repeat(0)).as(:variable)
  end

  rule :value do
    (match('[0-9]').repeat(1) >>
     (str('.') >> match('[0-9]').repeat(1)).maybe).as(:value)
  end

  rule(:equal) { str('=').surrounded_by(wp?) }
  rule(:wp?) { match('[ \t]').maybe }
end

class REPLTransform < Parslet::Transform
  rule(value: simple(:value)) { value.to_f }

  rule(left: simple(:left),
       operator: simple(:operator),
       right: simple(:right)) { left.send(operator, right) }

  rule(assignment: { variable: simple(:assignee),
                     expression: simple(:value)}) do |dictionary|
    @variables ||= {}
    @variables[dictionary[:assignee].str] = dictionary[:value]
  end

  rule(variable: simple(:variable)) do |dictionary|
    @variables&.fetch(dictionary[:variable].str)
  end
end

class REPL
  def initialize
    @parser = REPLParser.new
    @evaluator = REPLTransform.new
  end

  def run(line)
    @evaluator.apply(@parser.parse(line))
  end
end

if __FILE__ == $0
  repl = REPL.new
  loop do
    p repl.run(STDIN.readline.chomp)
  end
end
