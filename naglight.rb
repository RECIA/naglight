require 'rubygems'
require 'sinatra'
require 'json'

require 'lib/helpers' # load our view helpers
require 'lib/utils'
require 'lib/ruby-mk-livestatus'
# You can override some defaults of ruby-mk-livestatus
# Respect the Array !
$mk_livestatus_socket_paths += ["/home/nagios/live"]
# true / false
$mk_livestatus_debug=true
require 'lib/mk-calls'  # put some MK Livestatus calls in external file

# Need to improve this...
before do
  # number  /  short  /  end of "num_services_foo" key
  @simple_states_list = [ [0, "OK", "OK"],
                          [1, "WARN", "WARN"],
                          [2, "CRIT", "CRIT"],
                          [3, "UNKN", "UNKNOWN"],
                          [4, "DEP", "PENDING"] ]
end

get '/' do
  @title = "Index"
  haml :index
end

get '/allhosts' do
  @title = "All Hosts"
  @allhosts = get_mk({:table => "hosts"})
  haml :"hosts/allhosts"
end

get '/allservices' do
  @title = "All Services"
  group = "StatsGroupBy: host_name\n" # TODO: get it from params[:group_by]
  @allservices = get_mk({:table => "services", :extras_headers => group})
  haml :"services/allservices"
end

get '/contacts' do
  @title = "Contacts"
  @contacts = get_mk({:table => "contacts"})
  haml :"other/contacts"
end

##################################
##########  API STUFF   ##########
##################################

get '/api/?' do
  haml :"api/index"
end

get '/api/get/allhosts' do
  response.header['Content-type'] = 'application/x-javascript; charset=UTF-8'
  return mk_array_to_hash(JSON.parse(get_mk_livestatus({:table => "hosts"}))).to_json
end

get '/api/get/allhosts/raw' do
  response.header['Content-type'] = 'application/x-javascript; charset=UTF-8'
  return get_mk_livestatus({:table => "hosts"})
end

get '/api/get/contacts' do
  response.header['Content-type'] = 'application/x-javascript; charset=UTF-8'
  return mk_array_to_hash(JSON.parse(get_mk_livestatus({:table => "contacts"}))).to_json
end

get '/api/get/contacts/raw' do
  response.header['Content-type'] = 'application/x-javascript; charset=UTF-8'
  return get_mk_livestatus({:table => "contacts"})
end

get '/api/get/services' do
  response.header['Content-type'] = 'application/x-javascript; charset=UTF-8'
  return mk_array_to_hash(JSON.parse(get_mk_livestatus({:table => "services"}))).to_json
end

get '/api/get/services/raw' do
  response.header['Content-type'] = 'application/x-javascript; charset=UTF-8'
  return get_mk_livestatus({:table => "services"})
end
