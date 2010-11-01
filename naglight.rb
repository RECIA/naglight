require 'json'
require 'haml'
require 'sinatra'
require 'action_view'
require 'lib/helpers' # load our view helpers
require 'lib/utils'
require 'lib/ruby-mk-livestatus'
# You can override some defaults of ruby-mk-livestatus
# Respect the Array !
$mk_livestatus_socket_paths += ["/home/nagios/live"]
# true / false
$mk_livestatus_debug=true
require 'lib/mk-calls'  # put some MK Livestatus calls in external file
include ActionView::Helpers::TextHelper
include ActionView::Helpers::UrlHelper  # Need mail_to for auto_link


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

get '/hosts' do
  @title = "All Hosts"
  @allhosts = get_mk({:table => "hosts"})
  haml :"hosts/index"
end

get '/hosts/more/:host_name' do
  @title = "Host #{params[:host_name]}"
  extras_headers = "Filter: host_name = #{params[:host_name]}\n"
  @host = get_mk({:table => "hosts", :extras_headers => extras_headers}).first
  haml :"hosts/extended_infos"
end

get '/services' do
  @title = "All Services"
  group = "StatsGroupBy: host_name\n" # TODO: get it from params[:group_by]
  @allservices = get_mk({:table => "services", :extras_headers => group})
  haml :"services/index"
end

get '/services/hosts/:host_name' do
  @title = "Services of #{params[:host_name]}"
  filter = "Filter: host_name = #{params[:host_name]}\n"
  @services = get_mk({:table => "services", :extras_headers => filter})
  @allservices = @services
  haml :"services/one_host"
end

get '/services/more/:host_name/:service_name' do
  service_name = params[:service_name].gsub("+", " ")
  @title = "Service #{service_name}"
  filter =  "Filter: host_name = #{params[:host_name]}\n"
  filter << "Filter: display_name = #{service_name}\n"
  @service = get_mk({:table => "services", :extras_headers => filter}).first
  haml :"services/extended_infos"
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
  @title = "API Index"
  haml :"api/index"
end

get '/api/get/allhosts' do
  response.header['Content-type'] = 'application/x-javascript; charset=UTF-8'
  return mk_array_to_hash(JSON.parse(get_mk_livestatus({:table => "hosts"}))).to_json
end

get '/api/get/host/:host_name' do
  response.header['Content-type'] = 'application/x-javascript; charset=UTF-8'
  extras_headers = "Filter: host_name = #{params[:host_name]}\n"
  return mk_array_to_hash(JSON.parse(get_mk_livestatus({:table => "hosts", :extras_headers => extras_headers}))).first.to_json
end

get '/api/get/contacts' do
  response.header['Content-type'] = 'application/x-javascript; charset=UTF-8'
  return mk_array_to_hash(JSON.parse(get_mk_livestatus({:table => "contacts"}))).to_json
end

get '/api/get/services' do
  response.header['Content-type'] = 'application/x-javascript; charset=UTF-8'
  return mk_array_to_hash(JSON.parse(get_mk_livestatus({:table => "services"}))).to_json
end

get '/api/get/services/host/:host_name' do
  response.header['Content-type'] = 'application/x-javascript; charset=UTF-8'
  filter = "Filter: host_name = #{params[:host_name]}\n"
  return mk_array_to_hash(JSON.parse(get_mk_livestatus({:table => "services", :extras_headers => filter}))).to_json
end

get '/api/get/services/more/:host_name/:service_name' do
  response.header['Content-type'] = 'application/x-javascript; charset=UTF-8'
  service_name = params[:service_name].gsub("+", " ")
  filter =  "Filter: host_name = #{params[:host_name]}\n"
  filter << "Filter: display_name = #{service_name}\n"
  return mk_array_to_hash(JSON.parse(get_mk_livestatus({:table => "services", :extras_headers => filter}))).first.to_json
end