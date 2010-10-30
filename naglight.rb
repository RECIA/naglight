require 'rubygems'
require 'sinatra'
require 'json'

require 'lib/utils'
require 'lib/ruby-mk-livestatus'
# You can override some defaults of ruby-mk-livestatus
# Respect the Array !
$mk_livestatus_socket_paths += ["/home/nagios/live"]
# true / false
$mk_livestatus_debug=true

def get_mk(query)
  mk_array_to_hash(JSON.parse(get_mk_livestatus(query)))
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
  return get_mk_livestatus({:table => "hosts"})
end

get '/api/get/contacts' do
  response.header['Content-type'] = 'application/x-javascript; charset=UTF-8'
  return get_mk_livestatus({:table => "contacts"})
end