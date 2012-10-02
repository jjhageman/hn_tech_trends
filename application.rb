require 'sinatra/base'
require 'mongoid'

class Application < Sinatra::Base
  Mongoid.load!("configs/mongoid.yml")
  get '/' do
    "Hello World!"
  end

  run! if app_file == $0
end
