=begin
  非确定性有限自动机（Non-deterministic Finite Automata）

  how to use:
    simply run command irb with '--simple-prompt' agrument
=end

require 'set'

class FARule < Struct.new(:state, :character, :next_state)
  def applies_to?(state,character)
    self.state == state && self.character == character
  end

  def follow
    next_state;
  end

  def inspect
    "#<FARule #{state.inspect} --#{character}--> #{next_state}>"
  end
end

class NFARuleSet < Struct.new(:rules)
  def next_states(states, character)
    states.flat_map { |state| follow_rules_for(state, character) }.to_set
  end

  def follow_rules_for(state, character)
    rules_for(state, character).map(&:follow)
  end

  def rules_for(state, character)
    rules.select { |rule| rule.applies_to?(state, character) } # select * where 
  end
end

=begin
#<struct NFARuleSet rules=[#<FARule 1 --a--> 1>, #<FARule 1 --b--> 1>, #<FARule 1 --b--> 2>, 
#<FARule 2 --a--> 3>, #<FARule 2 --b--> 3>, #<FARule 3 --a--> 4>, #<FARule 3 --b--> 4>]>
=end
ruleset = NFARuleSet.new([
  FARule.new(1, 'a', 1), FARule.new(1, 'b', 1), FARule.new(1, 'b', 2),
  FARule.new(2, 'a', 3), FARule.new(2, 'b', 3), FARule.new(3, 'a', 4),
  FARule.new(3, 'b', 4)
])

# => #<Set: {1, 2}>
ruleset.next_states(Set[1], 'b')
# => #<Set: {1, 3, 4}>
ruleset.next_states(Set[1,2,3], 'a')
# => #<Set: {1, 2, 4}>
ruleset.next_states(Set[1,3], 'b')

class NFA < Struct.new(:current_states, :final_states, :ruleset)
  def accepting?
    (current_states & final_states).any?       # set intersection operation is empty?
  end

  def read_char(character)
    self.current_states = ruleset.next_states(current_states,character)
  end

  def read_string(str)
    str.chars.each do |character| 
      read_char(character)
    end
  end
end

class NFAMaker < Struct.new(:start_state, :final_states, :ruleset)
  def make_nfa
    NFA.new(Set[start_state], final_states, ruleset)
  end
  
  def accepts?(str)
    make_nfa.tap { |nfa| nfa.read_string(str) }.accepting?
  end
end

nfa = NFAMaker.new(1, [4], ruleset)
# => true
nfa.accepts?('bab')
# => true
nfa.accepts?('bababab')
# => false
nfa.accepts?('babababa')
# => true
nfa.accepts?('bababababbbbbb')