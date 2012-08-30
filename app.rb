require 'sinatra'
require 'rack-flash'
require 'haml'
require 'mongo_mapper'

require_relative 'models/device.rb'
require_relative 'models/notification.rb'
require_relative 'helpers/helper.rb'

set :protection, except: :ip_spoofing
set :appname, 'Conductor'

set :mongo_hostname, '127.0.0.1'
set :mongo_port, '27017'
set :mongo_database, 'conductor'
set :mongo_username, 'conductor'
set :mongo_password, 'conductor'

if ENV['VCAP_SERVICES']
  services = JSON.parse(ENV['VCAP_SERVICES'])
  set :mongo_hostname, services['mongodb-1.8'].first['credentials']['hostname']
  set :mongo_port, services['mongodb-1.8'].first['credentials']['port']
  set :mongo_database, services['mongodb-1.8'].first['credentials']['db']
  set :mongo_username, services['mongodb-1.8'].first['credentials']['username']
  set :mongo_password, services['mongodb-1.8'].first['credentials']['password']
end

MongoMapper.connection = Mongo::Connection.new(settings.mongo_hostname, settings.mongo_port, :pool_size => 5, :timeout => 5)
MongoMapper.database = settings.mongo_database
MongoMapper.database.authenticate(settings.mongo_username, settings.mongo_password)

# enable :methodoverride
# use Rack::MethodOverride
enable :sessions
use Rack::Flash#, :sweep => true

get '/' do
  @devices = Device.all
  @device = Device.new
  haml :index
end

post '/' do
  @devices = Device.all
  @device = Device.find(params[:device_id])||Device.new

  unless @device.new_record?
    @notification = Notification.new(params[:notification])
    @notification.device = @device
    @notification.save
    if @notification.errors.empty?
      # @device.push(@notification.category, @notification.message)
      @notification.push
      @alert = "Sending \"#{@notification.message}\" to #{@device.name}"
    end
  else
    @alert = "Selected device not found."
  end
  haml :index
end

get '/add' do
  @device = Device.new
  haml :add
end

post '/add' do
  device = Device.new(params)
  if device.save
    @alert = "Created device #{device.name}"
    redirect '/'
  else
    @device = device
  end
  haml :add
end

get '/devices' do
  @devices = Device.all
  haml :devices
end

delete '/devices/:id' do |id|
  # @devices = Device.all
  @device = Device.find(id)
  @device.destroy

  flash[:notice] = 'Successfully deleted device.'
  redirect '/devices'
end
