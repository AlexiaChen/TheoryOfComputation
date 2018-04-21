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
  抽象机器支持赋值语句
  => x = x + 1, {:x=>5}
  => x = 5 + 1, {:x=>5}
  => x = 6, {:x=>5}
  => do-nothing, {:x=>6}
=end
AbstractMachine.new(
  Assign.new(:x, Add.new(Variable.new(:x),
                        Number.new(1))),
  {x: Number.new(5)}
).runs

#支持If语句
class If < Struct.new(:condition, :true_statement, :false_statement)
  def to_s
    "if (#{condition}) { #{true_statement} } else { #{false_statement} }"
  end

  def inspect
    "#{self}"
  end

  def reducible?
    true
  end

  def reduce(var_enviroment)
    if condition.reducible?
      [If.new(condition.reduce(var_enviroment), true_statement,false_statement),var_enviroment]
    else
      case condition
      when Boolean.new(true)
        [true_statement,var_enviroment]
      when Boolean.new(false)
        [false_statement,var_enviroment]
      end
    end
  end
end

=begin
  if(condition) {t = 7} else {t = 5}, {:condition => true}
  if(true) {t = 7} else {t = 5}, {:condition => true}
  t = 7, {:condition => true}
  do-nothing, {:condition => true, :t => 7}
=end
AbstractMachine.new(
  If.new(Variable.new(:condition),
        Assign.new(:t, Number.new(7)),
        Assign.new(:t, Number.new(5))),
  {condition: Boolean.new(true)}
).run

=begin
  if(x < y) {t = 7} else {x = 5}, {:condition => true, :x => 10, :y=>8}
  if(10 < y) {t = 7} else {x = 5}, {:condition => true, :x => 10, :y=>8}
  if(10 < 8) {t = 7} else {x = 5}, {:condition => true, :x => 10, :y=>8}
  if(false) {t = 7} else {x = 5}, {:condition => true, :x => 10, :y=>8}
  x = 5, {:condition => true, :x => 10, :y=>8}
  do-nothing, {:condition => true, :x => 5, :y=>8}
=end
AbstractMachine.new(
  If.new(LessThan.new(Variable.new(:x), Variable.new(:y)),
        Assign.new(:t, Number.new(7)),
        Assign.new(:x, Number.new(5))),
  {condition: Boolean.new(true), x: Number.new(10), y: Number.new(8)}
).run

#支持代码块
class CodeBlock < Struct.new(:first_statement, :second_statement)
  def to_s
    "{#{first_statement}; #{second_statement}}"
  end

  def inspect
    "#{self}"
  end

  def reducible?
    true
  end

  def reduce(var_enviroment)
    case first_statement
    when DoNothing.new
      [second_statement,var_enviroment]
    else
      reduced_first, reduced_enviroment = first_statement.reduce(var_enviroment)
      [CodeBlock.new(reduced_first,second_statement),reduced_enviroment]
    end
  end
end

=begin
  x = (2 + 5); y = (x + 3),{}
  x = 7; y = (x + 3),{}
  do-nothing; y = (x + 3),{:x => 7}
  y = (x + 3),{:x => 7}
  y = (7 + 3),{:x => 7}
  y = 10,{:x => 7}
  do-nothing,{:x =>7, :y=> 10}
=end
AbstractMachine.new(
  CodeBlock.new(
    Assign.new(:x, Add.new(Number.new(2), Number.new(5))),
    Assign.new(:y, Add.new(Variable.new(:x), Number.new(3)))
  ),
  {}
).run

=begin
  if (x < y) { {z = (2 + 5); z = (z + 10)} } else { w = 99 },{:x=>2, :y=>5}
  if (2 < y) { {z = (2 + 5); z = (z + 10)} } else { w = 99 },{:x=>2, :y=>5}
  if (2 < 5) { {z = (2 + 5); z = (z + 10)} } else { w = 99 },{:x=>2, :y=>5}
  if (true) { {z = (2 + 5); z = (z + 10)} } else { w = 99 },{:x=>2, :y=>5}
  {z = (2 + 5); z = (z + 10)},{:x=>2, :y=>5}
  {z = 7; z = (z + 10)},{:x=>2, :y=>5}
  {do-nothing; z = (z + 10)},{:x=>2, :y=>5, :z=>7}
  z = (z + 10),{:x=>2, :y=>5, :z=>7}
  z = (7 + 10),{:x=>2, :y=>5, :z=>7}
  z = 17,{:x=>2, :y=>5, :z=>7}
  do-nothing,{:x=>2, :y=>5, :z=>17}
=end
AbstractMachine.new(
  If.new(LessThan.new(Variable.new(:x), Variable.new(:y)),
         CodeBlock.new(
                       Assign.new(:z,Add.new(Number.new(2),Number.new(5))),
                       Assign.new(:z,Add.new(Variable.new(:z),Number.new(10)))
                       ),
        Assign.new(:w,Number.new(99))
        ),
  {x: Number.new(2), y: Number.new(5)}
).run

#支持While循环语句
class While < Struct.new(:condition, :body)
  def to_s
    "while (#{condition}) { #{body} }"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(var_enviroment)
    [If.new(condition,CodeBlock.new(body,self),DoNothing.new),var_enviroment]
  end
end

=begin
  i = 1;
  result = 0;
  while(i <= 3)
  {
    result = result + 1;
    i++;
  }
  puts result; // result is 3

  while (i <= 3) { {x = (x + 1); i = (i + 1)} },{:i=><<1>>, :x=><<0>>}
if (i <= 3) { {{x = (x + 1); i = (i + 1)}; while (i <= 3) { {x = (x + 1); i = (i + 1)} }} } else { do-nothing },{:i=><<1>>, :x=><<0>>}
if (1 <= 3) { {{x = (x + 1); i = (i + 1)}; while (i <= 3) { {x = (x + 1); i = (i + 1)} }} } else { do-nothing },{:i=><<1>>, :x=><<0>>}
if (true) { {{x = (x + 1); i = (i + 1)}; while (i <= 3) { {x = (x + 1); i = (i + 1)} }} } else { do-nothing },{:i=><<1>>, :x=><<0>>}
{{x = (x + 1); i = (i + 1)}; while (i <= 3) { {x = (x + 1); i = (i + 1)} }},{:i=><<1>>, :x=><<0>>}
{{x = (0 + 1); i = (i + 1)}; while (i <= 3) { {x = (x + 1); i = (i + 1)} }},{:i=><<1>>, :x=><<0>>}
{{x = 1; i = (i + 1)}; while (i <= 3) { {x = (x + 1); i = (i + 1)} }},{:i=><<1>>, :x=><<0>>}
{{do-nothing; i = (i + 1)}; while (i <= 3) { {x = (x + 1); i = (i + 1)} }},{:i=><<1>>, :x=><<1>>}
{i = (i + 1); while (i <= 3) { {x = (x + 1); i = (i + 1)} }},{:i=><<1>>, :x=><<1>>}
{i = (1 + 1); while (i <= 3) { {x = (x + 1); i = (i + 1)} }},{:i=><<1>>, :x=><<1>>}
{i = 2; while (i <= 3) { {x = (x + 1); i = (i + 1)} }},{:i=><<1>>, :x=><<1>>}
{do-nothing; while (i <= 3) { {x = (x + 1); i = (i + 1)} }},{:i=><<2>>, :x=><<1>>}
while (i <= 3) { {x = (x + 1); i = (i + 1)} },{:i=><<2>>, :x=><<1>>}
if (i <= 3) { {{x = (x + 1); i = (i + 1)}; while (i <= 3) { {x = (x + 1); i = (i + 1)} }} } else { do-nothing },{:i=><<2>>, :x=><<1>>}
if (2 <= 3) { {{x = (x + 1); i = (i + 1)}; while (i <= 3) { {x = (x + 1); i = (i + 1)} }} } else { do-nothing },{:i=><<2>>, :x=><<1>>}
if (true) { {{x = (x + 1); i = (i + 1)}; while (i <= 3) { {x = (x + 1); i = (i + 1)} }} } else { do-nothing },{:i=><<2>>, :x=><<1>>}
{{x = (x + 1); i = (i + 1)}; while (i <= 3) { {x = (x + 1); i = (i + 1)} }},{:i=><<2>>, :x=><<1>>}
{{x = (1 + 1); i = (i + 1)}; while (i <= 3) { {x = (x + 1); i = (i + 1)} }},{:i=><<2>>, :x=><<1>>}
{{x = 2; i = (i + 1)}; while (i <= 3) { {x = (x + 1); i = (i + 1)} }},{:i=><<2>>, :x=><<1>>}
{{do-nothing; i = (i + 1)}; while (i <= 3) { {x = (x + 1); i = (i + 1)} }},{:i=><<2>>, :x=><<2>>}
{i = (i + 1); while (i <= 3) { {x = (x + 1); i = (i + 1)} }},{:i=><<2>>, :x=><<2>>}
{i = (2 + 1); while (i <= 3) { {x = (x + 1); i = (i + 1)} }},{:i=><<2>>, :x=><<2>>}
{i = 3; while (i <= 3) { {x = (x + 1); i = (i + 1)} }},{:i=><<2>>, :x=><<2>>}
{do-nothing; while (i <= 3) { {x = (x + 1); i = (i + 1)} }},{:i=><<3>>, :x=><<2>>}
while (i <= 3) { {x = (x + 1); i = (i + 1)} },{:i=><<3>>, :x=><<2>>}
if (i <= 3) { {{x = (x + 1); i = (i + 1)}; while (i <= 3) { {x = (x + 1); i = (i + 1)} }} } else { do-nothing },{:i=><<3>>, :x=><<2>>}
if (3 <= 3) { {{x = (x + 1); i = (i + 1)}; while (i <= 3) { {x = (x + 1); i = (i + 1)} }} } else { do-nothing },{:i=><<3>>, :x=><<2>>}
if (true) { {{x = (x + 1); i = (i + 1)}; while (i <= 3) { {x = (x + 1); i = (i + 1)} }} } else { do-nothing },{:i=><<3>>, :x=><<2>>}
{{x = (x + 1); i = (i + 1)}; while (i <= 3) { {x = (x + 1); i = (i + 1)} }},{:i=><<3>>, :x=><<2>>}
{{x = (2 + 1); i = (i + 1)}; while (i <= 3) { {x = (x + 1); i = (i + 1)} }},{:i=><<3>>, :x=><<2>>}
{{x = 3; i = (i + 1)}; while (i <= 3) { {x = (x + 1); i = (i + 1)} }},{:i=><<3>>, :x=><<2>>}
{{do-nothing; i = (i + 1)}; while (i <= 3) { {x = (x + 1); i = (i + 1)} }},{:i=><<3>>, :x=><<3>>}
{i = (i + 1); while (i <= 3) { {x = (x + 1); i = (i + 1)} }},{:i=><<3>>, :x=><<3>>}
{i = (3 + 1); while (i <= 3) { {x = (x + 1); i = (i + 1)} }},{:i=><<3>>, :x=><<3>>}
{i = 4; while (i <= 3) { {x = (x + 1); i = (i + 1)} }},{:i=><<3>>, :x=><<3>>}
{do-nothing; while (i <= 3) { {x = (x + 1); i = (i + 1)} }},{:i=><<4>>, :x=><<3>>}
while (i <= 3) { {x = (x + 1); i = (i + 1)} },{:i=><<4>>, :x=><<3>>}
if (i <= 3) { {{x = (x + 1); i = (i + 1)}; while (i <= 3) { {x = (x + 1); i = (i + 1)} }} } else { do-nothing },{:i=><<4>>, :x=><<3>>}
if (4 <= 3) { {{x = (x + 1); i = (i + 1)}; while (i <= 3) { {x = (x + 1); i = (i + 1)} }} } else { do-nothing },{:i=><<4>>, :x=><<3>>}
if (false) { {{x = (x + 1); i = (i + 1)}; while (i <= 3) { {x = (x + 1); i = (i + 1)} }} } else { do-nothing },{:i=><<4>>, :x=><<3>>}
do-nothing,{:i=><<4>>, :x=><<3>>}
 
=end
AbstractMachine.new(
  While.new(
    LessEqualThan.new(Variable.new(:i),Number.new(3)),
    CodeBlock.new(
     Assign.new(:x,Add.new(Variable.new(:x),Number.new(1))),
     Assign.new(:i,Add.new(Variable.new(:i),Number.new(1))))
    ),
  {i: Number.new(1), x: Number.new(0)}
).run