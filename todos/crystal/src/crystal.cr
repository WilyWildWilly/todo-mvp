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

def routes(request)
  case request.request_method
  when "GET"
    show_todos_handler
  when "POST"
    item = request[:item]
    name = item
    id = item.to_i32
    case request.path
    when "/done"
      TODOS.toggle id
    when "/not-done"
      TODOS.toggle id
    when "/delete"
      TODOS.delete id
    else
      TODOS.add name
    end
    redirect "/"
  else
    redirect "/"
  end
end

def show_todos_handler
  response = HTTP::Server.new do | context |
    context.response.status = 200
    context.response.headers.add("Content-Type": "text/html")
    context.response.write(TODOS.render)
    context.response
  end
end

# to readapt from ruby
def redirect(url)
  response = HTTP::Server.new do | context |
    context.response.redirect(url)
    context.response
  end
end

def new_server
  app = Proc.new do |env|
    request = Rack::Request.new(env)
    routes(request).finish
  end
  # to statically serve CSS
  Rack::Static.new(app, :urls => ["/static"])
end

Rack::Handler::WEBrick.run new_server, Port: 3000
