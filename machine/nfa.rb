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