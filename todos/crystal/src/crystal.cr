require "http/server"
require "ecr"
# TODO: Write documentation for `Crystal`

class Todo
  getter :name, :done, :id

  def initialize(name : String, id : Int32)
    print "I'm initializing a Todo!"
    @name = name
    @done = false
    @id = id
  end

  def toggle
    @done = !@done
    self
  end
end
# remove these tests in prod
b = TodoList.new
b.add ("first_todo")
c = b.toggle 0
pp! b
b.delete 0
pp! b

class TodoList
  getter :todos

  ECR.def_to_s "./template.html.ecr"

  def initialize
    @todos = [] of Todo
    @next_id = 0
    print "I have initialized a TodoList!"
  end

  def add(name)
    @todos.push(Todo.new(name, @next_id))
    @next_id += 1
  end

  def delete(id)
    @todos.delete_if { | todo | todo.id == id }
  end

  def toggle(id)
    @todos = todos.map { | todo | todo.id == id ? todo.toggle : todo }
  end

  def render
    @@template.result(binding)
  end
end

# The todo 'API' - global (for now)
TODOS = TodoList.new

# Here's a simple top level router - could be a class if it implements 'call'

