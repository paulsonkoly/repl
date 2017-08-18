require 'simplecov'

SimpleCov.start do
  add_filter 'spec'
end

require 'rspec'
require_relative '../repl'

RSpec::describe REPL do
  before :each { @repl = REPL.new }

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
    before :each { @repl.run('a=1') }

    it 'can retrieve the variable' do
      expect(@repl.run('a')).to eq(1.0)
    end
  end

  context 'when evaluating unbalanced parenthesis' do
    it 'raises error' do
      expect { @repl.run(')') }.to raise_error Parslet::ParseFailed
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
