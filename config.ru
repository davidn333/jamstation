require_relative "./config/environment.rb"
require_all 'app'

run Router.new
