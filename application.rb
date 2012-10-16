require 'sinatra/base'
require 'sinatra/support/numeric'
require 'mongoid'
require 'dalli'
require 'rack-cache'

Dir[File.expand_path('../models/**/*.rb', __FILE__)].each {|f| require f}

class Application < Sinatra::Base
  register Sinatra::Numeric
  Mongoid.load!("configs/mongoid.yml")

  get '/' do
    last_snap = Snapshot.desc(:date).first.date
    last_modified last_snap
    expires last_snap + 24*60*60, :public, :must_revalidate, :max_age => 1800
    @category = params[:category] || 'languages'
    @categories = Keyword.categories
    @term_names, @snapshots_chart_data = Snapshot.to_chart(@category)
    @keywords = Keyword.trending(13)

    erb :index
  end

  run! if app_file == $0
end
