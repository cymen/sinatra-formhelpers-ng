require 'rubygems'
require 'bacon'
require 'rack/test'

$LOAD_PATH.unshift(File.expand_path File.dirname(__FILE__))
$LOAD_PATH.unshift(File.expand_path File.join(File.dirname(__FILE__), '..', 'lib'))
require 'sinatra/base'
require 'sinatra/form_helpers'

class TestFormHelpers
  include Sinatra::FormHelpers
  attr_accessor :params
  def initialize
    @params = {}
  end
end
def fh
  @fh ||= TestFormHelpers.new
end

class Application < Sinatra::Base
  helpers Sinatra::FormHelpers
  set :raise_errors, false
  set :show_exceptions, false
end

Bacon.summary_on_exit
class Bacon::Context
  include Rack::Test::Methods
  def app
    Application
  end
end

# Lifted from sinatra/test_helpers (sinatra-contrib)
# def app
#   @app ||= Class.new Sinatra::Base
#   Rack::Lint.new @app
# end
#
# def app=(base)
#   @app = base
# end
#
# def mock_app(base = Sinatra::Base, &block)
#   inner = nil
#   @app  = Sinatra.new(base) do
#     inner = self
#     set :raise_errors, false
#     set :show_exceptions, false
#     class_eval(&block)
#   end
#   @settings = inner
#   app
# end
