class Employee

  attr_accessor :name, :title, :salary, :boss

  def initialize(name, title, salary, boss)
    @name, @title, @salary, @boss = name, title, salary.to_i, boss
  end

  def bonus(multiplier)
    salary * multiplier
  end

  protected
  def subs_salaries
    salary
  end
end

class Manager < Employee

  def initialize(name, title, salary, boss, employees = [])
    super(name, title, salary, boss)
    @employees = employees
  end

  def add_subordinate(employee)
    @employees << employee
  end

  def bonus(multiplier)
    multiplier * @employees.reduce(0) { |accumulator, employee| accumulator += employee.subs_salaries }
  end

  def subs_salaries
    salary + @employees.reduce(0) { |accumulator, employee| accumulator += employee.subs_salaries }
  end

end
