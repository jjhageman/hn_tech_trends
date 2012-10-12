require 'sinatra/base'
require 'sinatra/support/numeric'
require 'mongoid'

Dir[File.expand_path('../models/**/*.rb', __FILE__)].each {|f| require f}

class Application < Sinatra::Base
  register Sinatra::Numeric

  Mongoid.load!("configs/mongoid.yml")
  get '/' do
    @term_names, @categories = Snapshot.names_and_categories
    @category = params[:category] || 'languages'
    @snapshots = Snapshot.all.asc(:date)
    @snapshots_chart_data = Snapshot.to_chart(@snapshots, @category)
    @keywords = Keyword.trending(13)
    erb :index
  end

  run! if app_file == $0
end
