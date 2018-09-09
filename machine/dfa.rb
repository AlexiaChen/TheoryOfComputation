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

class DFARuleBook < Struct.new(:rules)

end