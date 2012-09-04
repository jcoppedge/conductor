require 'sinatra'
require 'rack-flash'
require 'haml'
require 'mongo_mapper'

require_relative 'models/device.rb'
require_relative 'models/notification.rb'
require_relative 'models/certificate.rb'
require_relative 'helpers/helper.rb'

configure do
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

  MongoMapper.connection = Mongo::Connection.new(settings.mongo_hostname, settings.mongo_port, :pool_size => 5, :pool_timeout => 5)
  MongoMapper.database = settings.mongo_database
  MongoMapper.database.authenticate(settings.mongo_username, settings.mongo_password)

  # use Rack::Auth::Basic do |username, password|
  #   username == 'admin' && password == 'securecom'
  # end

  ## No longer necessary to do this manually - documented just in case.  Only one of these next 2 lines is necessary.
  # enable :method_override
  # use Rack::MethodOverride

  enable :sessions
  use Rack::Flash, :sweep => true
end

before do
  # Does not seem the best place for this, but the Time.zone settings seems to be ignored if added in a configure block.
  # For now just set it for each request.
  Time.zone = "Central Time (US & Canada)"
  @params = params
  if request.path_info =~ /^\/$/
    @devices = Device.all(:order => :name.asc)
    @device = Device.find(params[:device_id])||Device.new
    @certificates = Certificate.all
    @certificate = params[:certificate] && Certificate.find_by_file_name(params[:certificate][:file_name])||Certificate.new
  end
end

get '/' do
  haml :index
end

post '/' do
  unless @device.new_record? || @certificate.new_record?
    @notification = Notification.new(params[:notification])
    @notification.certificate = @certificate
    @notification.device = @device
    @notification.save and @notification.push
    if @notification.errors.empty?
      flash[:success] = "Sending \"#{@notification.message}\" to #{@device.name}"
    end
  else
    flash[:info] = "Selected device or certificate not found."
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
    flash[:notice] = "Created device #{device.name}"
    redirect '/'
  else
    @device = device
  end
  haml :add
end

get '/devices' do
  @devices = Device.all(:order => :name.asc)
  haml :devices
end

delete '/devices/:id' do |id|
  @device = Device.find(id)
  if @device.destroy
    flash[:success] = 'Successfully deleted device.'
  else
    flash[:error] = 'Unable to delete device.'
  end
  redirect '/devices'
end

get '/notifications' do
  @notifications = Notification.all(:order => :created_at.desc)
  haml :notifications
end
