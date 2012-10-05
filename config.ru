require './application'
Dir[File.expand_path('../models/**/*.rb', __FILE__)].each {|f| require f}
run Application
