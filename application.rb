require 'sinatra/base'
require 'mongoid'
require 'debugger'

Dir[File.expand_path('../models/**/*.rb', __FILE__)].each {|f| require f}

class Application < Sinatra::Base
  Mongoid.load!("configs/mongoid.yml")
  get '/' do
    @keywords = Keyword.all.desc(:counts)
    erb :index
  end

  run! if app_file == $0
end
