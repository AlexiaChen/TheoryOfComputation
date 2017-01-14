=begin
  小步规约实现 
  小步语义 small-step semantic
=end
class Number < Struct.new(:value)
 def to_s
   value.to_s
 end

 def reducible?
   false
 end

 def inspect
   "<<#{self}>>"
 end
end

class Add < Struct.new(:left,:right)
  def to_s
    "(#{left} + #{right})"
  end

  def reducible?
   true
  end

  def reduce
    if left.reducible?
      Add.new(left.reduce,right)
    elsif right.reducible?
      Add.new(left,right.reduce)
    else
      Number.new(left.value + right.value)
    end
  end

  def inspect
    "<<#{self}>>"
  end
end

class Minus < Struct.new(:left,:right)
  def to_s
    "(#{left} - #{right})"
  end

  def reducible?
   true
  end

  def reduce
    if left.reducible?
      Minus.new(left.reduce,right)
    elsif right.reducible?
      Minus.new(left,right.reduce)
    else
      Number.new(left.value - right.value)
    end
  end

  def inspect
    "<<#{self}>>"
  end
end

class Multiply < Struct.new(:left,:right)
  def to_s
    "(#{left} * #{right})"
  end

  def reducible?
   true
  end

  def reduce
    if left.reducible?
      Multiply.new(left.reduce,right)
    elsif right.reducible?
      Multiply.new(left,right.reduce)
    else
      Number.new(left.value * right.value)
    end
  end

  def inspect
    "<<#{self}>>"
  end
end

class Divide < Struct.new(:left,:right)
  def to_s
    "(#{left} / #{right})"
  end

  def reducible?
   true
  end

  def reduce
    if left.reducible?
      Divide.new(left.reduce,right)
    elsif right.reducible?
      Divide.new(left,right.reduce)
    else
      Number.new(left.value / right.value)
    end
  end

  def inspect
    "<<#{self}>>"
  end
end

class Boolean < Struct.new(:value)
  def to_s
    value.to_s
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    false
  end
end

class LessThan < Struct.new(:left, :right)
  def to_s
    "#{left} < #{right}"
  end

  def inspect
    "#{self}"
  end

  def reducible?
    true
  end

  def reduce
    if left.reducible?
      LessThan.new(left.reduce,right)
    elsif right.reducible?
      LessThan.new(left,right.reduce)
    else
      Boolean.new(left.value < right.value)
    end
  end
end

class GreaterThan < Struct.new(:left, :right)
  def to_s
    "#{left} > #{right}"
  end

  def inspect
    "#{self}"
  end

  def reducible?
    true
  end

  def reduce
    if left.reducible?
      GreaterThan.new(left.reduce,right)
    elsif right.reducible?
      GreaterThan.new(left,right.reduce)
    else
      Boolean.new(left.value > right.value)
    end
  end
end

class Equal < Struct.new(:left, :right)
  def to_s
    "#{left} == #{right}"
  end

  def inspect
    "#{self}"
  end

  def reducible?
    true
  end

  def reduce
    if left.reducible?
      Equal.new(left.reduce,right)
    elsif right.reducible?
      Equal.new(left,right.reduce)
    else
      Boolean.new(left.value == right.value)
    end
  end
end

# 构造表达式树
# => 1*2 + 3*4
Add.new(                                          
    Multiply.new(Number.new(1), Number.new(2)),   
    Multiply.new(Number.new(3),Number.new(4))
)

# => false
Number.new(4).reducible?
# => true
Add.new(Number.new(3),Number.new(7)).reducible?

# => 1*2 + 3*4
expression = Add.new(                                          
    Multiply.new(Number.new(1), Number.new(2)),   
    Multiply.new(Number.new(3),Number.new(4))
)

#直到规约终止，表达式的值也计算完成
# => true
expression.reducible?

# => 2 + 3*4
expression = expression.reduce

# => true
expression.reducible?

# => 2 + 12
expression = expression.reduce

# => true
expression.reducible?

# => 14
expression = expression.reduce

# => false
expression.reducible?

#建立一个抽象机器来执行规约，直到得到一个值为止
#抽象机器也可以简单认为是虚拟机

class AbstractMachine < Struct.new(:expression)
  def step_next
    self.expression = expression.reduce
  end

  def run
    while expression.reducible?
      puts expression
      step_next
    end
    puts expression  # final state
  end
end

#实例化一个虚拟机执行表达式
=begin
  3*2 +  (10 - 8/4)
  6   +  (10 - 8/4)
  6   +  (10 - 2)
  6   +  8
  14
=end
AbstractMachine.new(
   Add.new(                                          
    Multiply.new(Number.new(3), Number.new(2)),   
    Minus.new(
        Number.new(10),
        Divide.new(Number.new(8),Number.new(4))
    )
   )
).run

=begin
  6 < (2 + 12)
  6 < 14
  true
=end
AbstractMachine.new(
   LessThan.new(
     Number.new(6),
     Add.new(
       Number.new(2),
       Number.new(12)))
).run

=begin
  6 > (2 + 12)
  6 > 14
  false
=end
AbstractMachine.new(
   GreaterThan.new(
     Number.new(6),
     Add.new(
       Number.new(2),
       Number.new(12)))
).run

=begin
  6 == (2 + 4)
  6 == 6
  true
=end
AbstractMachine.new(
   Equal.new(
     Number.new(6),
     Add.new(
       Number.new(2),
       Number.new(4)))
).run

