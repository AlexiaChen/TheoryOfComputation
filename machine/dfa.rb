=begin
  确定性有限自动机（Deterministic Finite Automata）

  how to use:
    simply run command irb with '--simple-prompt' agrument
=end

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

class DFARuleSet < Struct.new(:rules)
  def next_state(state,character)
    rule_for(state,character).follow
  end

  def rule_for(state,character)
    rules.detect { |rule| rule.applies_to?(state,character) } # find first if
  end
end

=begin
#<struct DFARuleSet rules=[#<FARule 1 --a--> 2>, #<FARule 1 --b--> 1>, #<FARule 2 --a--> 2>, 
#<FARule 2 --b--> 3>, #<FARule 3 --a--> 3>, #<FARule 3 --b--> 3>]>
=end
rules = DFARuleSet.new([
  FARule.new(1,'a',2), FARule.new(1,'b',1),
  FARule.new(2,'a',2), FARule.new(2,'b',3),
  FARule.new(3,'a',3), FARule.new(3,'b',3)
])

# => 2
rules.next_state(1,'a')
# => 1
rules.next_state(1,'b')
# => 3
rules.next_state(2,'b')

class DFA < Struct.new(:current_state,:final_states,:ruleset)
  def accepting?
    final_states.include?(current_state)
  end

  def read_char(character)
    self.current_state = ruleset.next_state(current_state,character)
  end

  def read_string(str)
    str.chars.each do |character|
      read_char(character)
    end
  end  
end

# => true
DFA.new(1,[1,3],rules).accepting?

# => false
DFA.new(1,[3],rules).accepting?

class DFAMaker < Struct.new(:start_state, :final_states, :ruleset)
  def make_dfa
    DFA.new(start_state,final_states,ruleset)
  end
  
  def accepts?(str)
    make_dfa.tap { |dfa| dfa.read_string(str) }.accepting?
  end
end

# => false
DFAMaker.new(1,[3],rules).accepts?('a')

# => false
DFAMaker.new(1,[3],rules).accepts?('baa')

# => true
DFAMaker.new(1,[3],rules).accepts?('babab')

# => true
DFAMaker.new(1,[2],rules).accepts?('aaaa')

# => false
DFAMaker.new(1,[1],rules).accepts?('a')

# => true
DFAMaker.new(1,[1],rules).accepts?('b')