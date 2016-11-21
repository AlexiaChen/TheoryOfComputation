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
    "#{left} + #{right}"
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

class Multiply < Struct.new(:left,:right)
  def to_s
    "#{left} * #{right}"
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
  1*2 + 3*4
  2 + 3*4
  2 + 12
  14
=end
AbstractMachine.new(
   Add.new(                                          
    Multiply.new(Number.new(1), Number.new(2)),   
    Multiply.new(Number.new(3),Number.new(4))
   )
).run