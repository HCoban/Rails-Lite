require 'rack'

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  res['Content-Type'] = 'text/html'

  host = env["HTTP_HOST"]
  path = env["PATH_INFO"]
  red = "http://#{host}#{path}"

  res.write("This is ")
  res.write(env["PATH_INFO"])

  res.redirect(env["PATH_INFO"], 302) unless red == env["REQUEST_URI"]
  res.finish
end



Rack::Server.start(
  app: app,
  Port: 3000
)
