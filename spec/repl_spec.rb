require 'simplecov'

SimpleCov.start do
  add_filter 'spec'
end

require 'rspec'
require_relative '../repl'

RSpec::describe Lexer do
  it "parses equal sign" do
    expect(Lexer.new('=').next).to be_an Equal
  end

  it 'parses an open parenthesis' do
    expect(Lexer.new('(').next).to be_a LeftParen
  end

  it 'parses a close parenthesis' do
    expect(Lexer.new(')').next).to be_a RightParen
  end

  it 'parses an operator sign' do
    %w(+ - * \ %).each do |op|
      expect(Lexer.new(op).next).to be_an Operator
    end
  end

  it 'parses numbers' do
    expect(Lexer.new('123').next).to be_a Number
  end

  it 'parses identifiers' do
    expect(Lexer.new('abc').next).to be_an Identifier
  end

  it 'raises LexerError if cannot parse' do
    expect { Lexer.new('&a').next }.to raise_error Lexer::LexerError
  end
end


RSpec::describe Operator do
  describe 'precedence' do
    it 'gives higher precedence for * than +' do
      mul = Operator.new(:*)
      add = Operator.new(:+)

      expect(mul > add).to be
    end
  end

  describe '#eval' do
    it 'adds numbers' do
      add = Operator.new(:+)
      expect(add.eval(1,2)).to eq 3
    end
  end
end

RSpec::describe REPL do
  before { @repl = REPL.new }

  context 'when evaluating a single token expression' do
    it 'returns the single token' do
      expect(@repl.run('1')).to eq(1.0)
    end
  end

  context 'when evaluating a single expression' do
    it 'returns the result' do
      expect(@repl.run('1+2')).to eq(3.0)
    end
  end

  context 'after assignign a variable' do
    before { @repl.run('a=1') }

    it 'can retrieve the variable' do
      expect(@repl.run('a')).to eq(1.0)
    end
  end

  context 'when evaluating unbalanced parenthesis' do
    it 'raises UnbalancedParens error' do
      expect { @repl.run(')') }.to raise_error REPL::UnbalancedParens
    end
  end

  context 'when evaluating an expression with parentheses' do
    it 'returns the correct result' do
      expect(@repl.run('2*(1+1)')).to eq 4.0
    end
  end

  context 'when evaluating an expression with a sequence of equal precedence operators' do
    it 'returns the correct result' do
      expect(@repl.run('1+1+1')).to eq 3.0
    end
  end
end
