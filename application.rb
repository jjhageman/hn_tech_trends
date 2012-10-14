require 'sinatra/base'
require 'sinatra/support/numeric'
require 'mongoid'

Dir[File.expand_path('../models/**/*.rb', __FILE__)].each {|f| require f}

class Application < Sinatra::Base
  register Sinatra::Numeric

  Mongoid.load!("configs/mongoid.yml")
  get '/' do
    @category = params[:category] || 'languages'
    @categories = Keyword.categories
    @term_names, @snapshots_chart_data = Snapshot.to_chart(@category)
    @keywords = Keyword.trending(13)
    erb :index
  end

  run! if app_file == $0
end
