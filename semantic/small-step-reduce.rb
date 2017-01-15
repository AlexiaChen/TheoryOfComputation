=begin
  小步规约实现 
  小步语义 small-step semantic

  how to use:
    simply run command irb with '--simple-prompt' agrument
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

  def reduce(var_enviroment)
    if left.reducible?
      Add.new(left.reduce(var_enviroment),right)
    elsif right.reducible?
      Add.new(left,right.reduce(var_enviroment))
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

  def reduce(var_enviroment)
    if left.reducible?
      Minus.new(left.reduce(var_enviroment),right)
    elsif right.reducible?
      Minus.new(left,right.reduce(var_enviroment))
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

  def reduce(var_enviroment)
    if left.reducible?
      Multiply.new(left.reduce(var_enviroment),right)
    elsif right.reducible?
      Multiply.new(left,right.reduce(var_enviroment))
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

  def reduce(var_enviroment)
    if left.reducible?
      Divide.new(left.reduce(var_enviroment),right)
    elsif right.reducible?
      Divide.new(left,right.reduce(var_enviroment))
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

  def reduce(var_enviroment)
    if left.reducible?
      LessThan.new(left.reduce(var_enviroment),right)
    elsif right.reducible?
      LessThan.new(left,right.reduce(var_enviroment))
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

  def reduce(var_enviroment)
    if left.reducible?
      GreaterThan.new(left.reduce(var_enviroment),right)
    elsif right.reducible?
      GreaterThan.new(left,right.reduce(var_enviroment))
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

  def reduce(var_enviroment)
    if left.reducible?
      Equal.new(left.reduce(var_enviroment),right)
    elsif right.reducible?
      Equal.new(left,right.reduce(var_enviroment))
    else
      Boolean.new(left.value == right.value)
    end
  end
end

class LessEqualThan < Struct.new(:left, :right)
  def to_s
    "#{left} <= #{right}"
  end

  def inspect
    "#{self}"
  end

  def reducible?
    true
  end

  def reduce(var_enviroment)
    if left.reducible?
      LessEqualThan.new(left.reduce(var_enviroment),right)
    elsif right.reducible?
      LessEqualThan.new(left,right.reduce(var_enviroment))
    else
      Boolean.new(left.value <= right.value)
    end
  end
end

class GreaterEqualThan < Struct.new(:left, :right)
  def to_s
    "#{left} >= #{right}"
  end

  def inspect
    "#{self}"
  end

  def reducible?
    true
  end

  def reduce(var_enviroment)
    if left.reducible?
      GreaterEqualThan.new(left.reduce(var_enviroment),right)
    elsif right.reducible?
      GreaterEqualThan.new(left,right.reduce(var_enviroment))
    else
      Boolean.new(left.value >= right.value)
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

class AbstractMachine < Struct.new(:statement,:var_enviroment)
  def step_next
    self.statement, self.var_enviroment = statement.reduce(var_enviroment)
  end

  def run
    while statement.reducible?
      puts "#{statement},#{var_enviroment}"
      step_next
    end
    puts "#{statement},#{var_enviroment}"  # final state
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
        Divide.new(Number.new(8),Number.new(4)))
   ),
   {}
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
       Number.new(12))),
   {}
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
       Number.new(12))),
   {} 
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
       Number.new(4))),
   {}
).run

=begin
  6 >= (2 + 4)
  6 >= 6
  true
=end
AbstractMachine.new(
   GreaterEqualThan.new(
     Number.new(6),
     Add.new(
       Number.new(2),
       Number.new(4))),
   {}
).run

=begin
  200 >= (2 + 4)
  200 >= 6
  true
=end
AbstractMachine.new(
   GreaterEqualThan.new(
     Number.new(200),
     Add.new(
       Number.new(2),
       Number.new(4))),
   {}
).run

=begin
  6 <= (2 + 4)
  6 <= 6
  true
=end
AbstractMachine.new(
   LessEqualThan.new(
     Number.new(6),
     Add.new(
       Number.new(2),
       Number.new(4))),
   {}
).run

=begin
  4 <= (2 + 4)
  4 <= 6
  true
=end
AbstractMachine.new(
   LessEqualThan.new(
     Number.new(4),
     Add.new(
       Number.new(2),
       Number.new(4))),
   {}
).run

# 有定义变量的功能
#变量可以规约，需要规约到一个值上，就是变量名（相当于一个符号）映射到变量的值
#变量名到变量值的一个映射，var_enviroment可以简单设计为Hash Table
class Variable < Struct.new(:name)
  def to_s
    name.to_s
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true            
  end

  def reduce(var_enviroment)
    var_enviroment[name]     
  end
end

=begin
  x <= y + z
  4 <= y + z
  4 <= 2 + z
  4 <= 2 + 8
  4 <= 10
  true

  相当于:
  x = 4;
  y = 2;
  z = 8;

  puts x <= y + z;
  => true
=end
AbstractMachine.new(
   LessEqualThan.new(
     Variable.new(:x),
     Add.new(
       Variable.new(:y),
       Variable.new(:z))),
   {x: Number.new(4), y: Number.new(2), z: Number.new(8)}  
).run

#为语言的语句(statement)定一个不能规约的状态，不可规约语句, 没任何属性
#注意: 语句(statement)和表达式(expression)不是一个概念 
class DoNothing
  def to_s
    "do-nothing"
  end

  def inspect
    "#{self}"
  end

  def ==(other_statement)
    other_statement.instance_of?(DoNothing)
  end

  def reducible?
    false
  end
end

class Assign < Struct.new(:name,:expression)
  def to_s
    "#{name} = #{expression}"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(var_enviroment)
    if expression.reducible?
      [Assign.new(name,expression.reduce(var_enviroment)), var_enviroment]
    else
      [DoNothing.new, var_enviroment.merge({name => expression})]
    end
  end
end

#对一个赋值表达式进行反复规约，直到不能规约为止，表达式的值就会更新到环境上
# => x = x + 1
statement = Assign.new(:x, Add.new(
                            Variable.new(:x),
                            Number.new(1)))
# => {:x => 5}
var_enviroment = {x: Number.new(5)}

# => true
statement.reducible?

# => [x = 5 + 1, {:x=>5}]
statement, var_enviroment = statement.reduce(var_enviroment)

# => true
statement.reducible?

# => [x = 6, {:x=>5}]
statement, var_enviroment = statement.reduce(var_enviroment)

# => true
statement.reducible?

# => [do-nothing, {:x=>6}]
statement, var_enviroment = statement.reduce(var_enviroment)

# => false
statement.reducible?

=begin
  => x = x + 1, {:x=>5}
  => x = 5 + 1, {:x=>5}
  => x = 6, {:x=>5}
  => do-nothing, {:x=>6}
=end
AbstractMachine.new(
  Assign.new(:x, Add.new(Variable.new(:x),
                        Number.new(1))),
  {x: Number.new(5)}
).run