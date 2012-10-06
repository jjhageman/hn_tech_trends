require 'sinatra/base'
require 'mongoid'

Dir[File.expand_path('../models/**/*.rb', __FILE__)].each {|f| require f}

class Application < Sinatra::Base
  Mongoid.load!("configs/mongoid.yml")
  get '/' do
    @keywords = Keyword.all.desc(:counts)
    @keyword_names = @keywords.map(&:name)
    @keywords_chart_data = Keyword.to_chart(@keywords)
    erb :index
  end

  run! if app_file == $0
end
