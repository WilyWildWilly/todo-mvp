# TODO: Write documentation for `Crystal`
require "ecr"

print "I have started running!"

class Todo
  getter :name, :done, :id

  def initialize(name, id)
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
# $todos = TodoList.new

# Here's a simple top level router - could be a class if it implements 'call'

