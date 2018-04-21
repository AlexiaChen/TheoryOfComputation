=begin
  指称语义实现
  指称语义 denotational semantic

  how to use:
    simply run command irb with '--simple-prompt' agrument
=end

# -> e { } 是参数为e的lambda表达式 
class Number < Struct.new(:value)
    def to_ruby
        "-> e { #{value.inspect} }"
    end
   
    def inspect
      "<<#{self}>>"
    end
end

class Boolean < Struct.new(:value)
    def to_ruby
        "-> e { #{value.inspect} }"
    end
   
    def inspect
      "<<#{self}>>"
    end
end

# => "-> e { 5 }"
Number.new(2).to_ruby
# => "-> e { true }"
Boolean.new(true).to_ruby

# => 2
proc = eval(Number.new(2).to_ruby)
proc.call({})
# => true
proc = eval(Boolean.new(true).to_ruby)
proc.call({})


class Variable < Struct.new(:name)
    def to_ruby
        "-> e { e[#{name.inspect}] }"
    end
   
    def inspect
      "<<#{self}>>"
    end
end

# => "-> e { e[:test] }"
expression = Variable.new(:test)
expression.to_ruby
# => 6
proc = eval(expression.to_ruby)
proc.call({ test: 6})

class Add < Struct.new(:left,:right)
    def to_ruby
        "-> e { (#{left.to_ruby}).call(e) + (#{right.to_ruby}).call(e) }"
    end
    def inspect
      "<<#{self}>>"
    end
  end
  
  class Minus < Struct.new(:left,:right)
    def to_ruby
        "-> e { (#{left.to_ruby}).call(e) - (#{right.to_ruby}).call(e) }"
    end
    def inspect
      "<<#{self}>>"
    end
  end
  
  class Multiply < Struct.new(:left,:right)
    def to_ruby
        "-> e { (#{left.to_ruby}).call(e) * (#{right.to_ruby}).call(e) }"  
    end
    def inspect
      "<<#{self}>>"
    end
  end
  
  class Divide < Struct.new(:left,:right)
    def to_ruby
        "-> e { (#{left.to_ruby}).call(e) / (#{right.to_ruby}).call(e) }"   
    end
    def inspect
      "<<#{self}>>"
    end
  end

  class LessThan < Struct.new(:left, :right)
    def to_ruby
        "-> e { (#{left.to_ruby}).call(e) < (#{right.to_ruby}).call(e) }" 
    end
    def inspect
      "#{self}"
    end
  end
  
  class GreaterThan < Struct.new(:left, :right)
    def to_ruby
        "-> e { (#{left.to_ruby}).call(e) > (#{right.to_ruby}).call(e) }" 
    end
    def inspect
      "#{self}"
    end
  end
  
  class Equal < Struct.new(:left, :right)
    def to_ruby
        "-> e { (#{left.to_ruby}).call(e) == (#{right.to_ruby}).call(e) }"
    end
    def inspect
      "#{self}"
    end
  end
  
  class LessEqualThan < Struct.new(:left, :right)
    def to_ruby
        "-> e { (#{left.to_ruby}).call(e) <= (#{right.to_ruby}).call(e) }" 
    end
    def inspect
      "#{self}"
    end
  end
  
  class GreaterEqualThan < Struct.new(:left, :right)
    def to_ruby
        "-> e { (#{left.to_ruby}).call(e) >= (#{right.to_ruby}).call(e) }" 
    end
    def inspect
      "#{self}"
    end
  end

  # "-> e { (-> e { e[:a] }).call(e) + (-> e { 4 }).call(e) }"
  Add.new(Variable.new(:a),Number.new(4)).to_ruby

  # "-> e { (-> e { (-> e { e[:a] }).call(e) - (-> e { 2 }).call(e) }).call(e) > (-> e { 5 }).call(e) }"
  GreaterThan.new(Minus.new(Variable.new(:a),Number.new(2)),Number.new(5)).to_ruby

  # => 10
  var_environment = { x: 6 }
  proc = eval(Add.new(Variable.new(:x),Number.new(4)).to_ruby)
  proc.call(var_environment) 

  # => false
  proc = eval(GreaterThan.new(Minus.new(Variable.new(:x),Number.new(2)),Number.new(5)).to_ruby)
  proc.call(var_environment) 

  class Assign < Struct.new(:name,:expression)
    def to_ruby
        "-> e { e.merge({ #{name.inspect} => (#{expression.to_ruby}).call(e) }) }" 
    end
    def inspect
      "#{self}"
    end
  end

  # "-> e { e.merge({ :foo => (-> e { (-> e { e[:bar] }).call(e) + (-> e { 2 }).call(e) }).call(e) }) }"
  statement = Assign.new(:foo, Add.new(Variable.new(:bar),Number.new(2)))
  statement.to_ruby

  # => {:bar=>6, :foo=>8}
  proc = eval(statement.to_ruby)
  proc.call({ bar: 6})

  class DoNothing
    def to_ruby
        "-> e { e }"
    end
  end

  class If < Struct.new(:condition, :true_statement, :false_statement)
    def to_ruby
      "-> e {" +
          "if (#{condition.to_ruby}).call(e)" + 
          "then (#{true_statement.to_ruby}).call(e)" +
          "else (#{false_statement.to_ruby}).call(e)" + 
          "end" + 
      "}"
    end
  end

=begin
=> "-> e {          if (-> e { true }).call(e)          
then (-> e { e.merge({ :foo => (-> e { 3 }).call(e) }) }).call(e)          
else (-> e { e.merge({ :foo => (-> e { 6 }).call(e) }) }).call(e) end     }"
=end
  If.new(Boolean.new(true),Assign.new(:foo,Number.new(3)),Assign.new(:foo,Number.new(6))).to_ruby
  
  # => {:foo=>3}
  proc = eval(
      If.new(
            Boolean.new(true),
            Assign.new(:foo,Number.new(3)),
            Assign.new(:foo,Number.new(6))
      ).to_ruby
  )
  proc.call({})

  class CodeBlock < Struct.new(:first_statement, :second_statement)
    def to_ruby
      "-> e { (#{second_statement.to_ruby}).call((#{first_statement.to_ruby}).call(e)) }"
    end
  end

  class While < Struct.new(:condition, :body)
    def to_ruby
        "-> e {" +
        "while (#{condition.to_ruby}).call(e);" +
        "e = (#{body.to_ruby}).call(e);end;" +
        "e" +  
        "}"
    end
  end

=begin
=> "-> e {while (-> e { (-> e { e[:x] }).call(e) < (-> e { 3 }).call(e) }).call(e);
    e = (-> e { e.merge({ :x => (-> e { (-> e { e[:x] }).call(e) + (-> e { 1 }).call(e) }).call(e) }) }).call(e);
    end;e}"
=end  
  
  Assign.new(:x,Number.new(0))
  statement = While.new(
      LessThan.new(Variable.new(:x),Number.new(3)),
      Assign.new(:x, Add.new(Variable.new(:x),Number.new(1)))
  )
  statement.to_ruby

  # => {:x=>3}
  proc = eval(statement.to_ruby)
  proc.call({x: 1})