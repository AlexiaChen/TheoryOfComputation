=begin
  大步语义实现 
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

class Boolean < Struct.new(:value)
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

class Variable < Struct.new(:name)
  def to_s
    name.to_s
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(var_eniroment)
    var_eniroment[name]
  end
end

class Add < Struct.new(:left,:right)
  def to_s
    "(#{left} + #{right})"
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(var_eniroment)
    Number.new(left.evaluate(var_eniroment).value + right.evaluate(var_eniroment).value)
  end
end

class Minus < Struct.new(:left,:right)
  def to_s
    "(#{left} - #{right})"
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(var_eniroment)
    Number.new(left.evaluate(var_eniroment).value - right.evaluate(var_eniroment).value)
  end
end

class Multiply < Struct.new(:left,:right)
  def to_s
    "(#{left} * #{right})"
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(var_eniroment)
    Number.new(left.evaluate(var_eniroment).value * right.evaluate(var_eniroment).value)
  end
end

class Divide < Struct.new(:left,:right)
  def to_s
    "(#{left} / #{right})"
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(var_eniroment)
    Number.new(left.evaluate(var_eniroment).value / right.evaluate(var_eniroment).value)
  end
end

class LessThan < Struct.new(:left, :right)
  def to_s
    "#{left} < #{right}"
  end

  def inspect
    "#{self}"
  end

  def evaluate(var_eniroment)
    Boolean.new(left.evaluate(var_eniroment).value < right.evaluate(var_eniroment).value)
  end
end

class GreaterThan < Struct.new(:left, :right)
  def to_s
    "#{left} > #{right}"
  end

  def inspect
    "#{self}"
  end

  def evaluate(var_eniroment)
    Boolean.new(left.evaluate(var_eniroment).value > right.evaluate(var_eniroment).value)
  end
end

class Equal < Struct.new(:left, :right)
  def to_s
    "#{left} == #{right}"
  end

  def inspect
    "#{self}"
  end

  def evaluate(var_eniroment)
    Boolean.new(left.evaluate(var_eniroment).value == right.evaluate(var_eniroment).value)
  end
end

class LessEqualThan < Struct.new(:left, :right)
  def to_s
    "#{left} <= #{right}"
  end

  def inspect
    "#{self}"
  end

  def evaluate(var_eniroment)
    Boolean.new(left.evaluate(var_eniroment).value <= right.evaluate(var_eniroment).value)
  end
end

class GreaterEqualThan < Struct.new(:left, :right)
  def to_s
    "#{left} >= #{right}"
  end

  def inspect
    "#{self}"
  end

  def evaluate(var_eniroment)
    Boolean.new(left.evaluate(var_eniroment).value >= right.evaluate(var_eniroment).value)
  end
end

class Assign < Struct.new(:name,:expression)
  def to_s
    "#{name} = #{expression}"
  end

  def inspect
    "<<#{self}>>"
  end

  def evaluate(var_eniroment)
    var_eniroment.merge({ name => expression.evaluate(var_eniroment)})
  end
end

# => 23
Number.new(23).evaluate({})

=begin
 x = 45
 print x 
=end
Variable.new(:x).evaluate({ x: Number.new(45) })


# => true
LessThan.new(
  Add.new(Variable.new(:x), Number.new(2)),
  Variable.new(:y)
).evaluate({ x: Number.new(2), y: Number.new(5)})

# => false
GreaterEqualThan.new(
  Multiply.new(Variable.new(:x), Number.new(12)),
  Variable.new(:y)
).evaluate({ x: Number.new(2), y: Number.new(25)})

# age => 24
Assign.new(:age,
Add.new(Number.new(21), Variable.new(:step))
).evaluate({ step: Number.new(23)})
