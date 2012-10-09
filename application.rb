require 'sinatra/base'
require 'mongoid'

Dir[File.expand_path('../models/**/*.rb', __FILE__)].each {|f| require f}

class Application < Sinatra::Base
  Mongoid.load!("configs/mongoid.yml")
  get '/' do
    @term_names = Snapshot.first.terms.map(&:name)
    @snapshots = Snapshot.all.asc(:date)
    @snapshots_chart_data = Snapshot.to_chart(@snapshots)
    @keywords = Keyword.trending
    erb :index
  end

  run! if app_file == $0
end
