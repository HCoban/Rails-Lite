require 'active_support'
require 'active_support/core_ext'
require 'erb'
require 'byebug'
require 'active_support/inflector'
require_relative './session'


class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, params = {})
    @req = req
    @res = res
    @params = req.params.merge(params)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    if already_built_response?
      raise Error "Already rendered"
    end
    @res["Location"] = url
    @res.status = 302
    session.store_session(@res)
    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    if already_built_response?
      raise Error "Already rendered"
    end
    @res["Content-Type"] = content_type
    @res.body = [content]
    @res.finish
    session.store_session(@res)
    @already_built_response = true
  end


  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = ActiveSupport::Inflector.underscore(self.class.to_s)
    content = File.read("../views/#{controller_name}/#{template_name}.html.erb")
    content = ERB.new(content).result(binding)
    render_content(content, "text/html")
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    send(name)
  end
end
