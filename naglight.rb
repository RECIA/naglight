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


get '/' do
  @title = "Index"
  haml :index
end

get '/contact' do
  @title = "Contacts"
  @contacts = mk_array_to_hash(JSON.parse(get_contacts))
  haml :"other/contacts"
end

##################################
##########  API STUFF   ##########
##################################

get '/api/?' do
  haml :"api/index"
end

get '/api/get/contacts' do
  response.header['Content-type'] = 'application/x-javascript; charset=UTF-8'
  return get_contacts
end