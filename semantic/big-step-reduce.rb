=begin
  大步规约实现 
  大步语义 big-step semantic

  how to use:
    simply run command irb with '--simple-prompt' agrument
=end

class Number < Struct.new(:value)
  def to_s
    value.to_s
  end

  def evaluate(var_eniroment)
    self
  end
      
  def inspect
    "<<#{self}>>"
  end
end

# => 23
Number.new(23).evaluate({})