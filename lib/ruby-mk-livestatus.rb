# ruby-mk-livestatus wrapper
require 'socket'

# Globals
$mk_livestatus_socket_paths=["/var/lib/nagios/rw/live", "/var/lib/nagios3/rw/live"]
$mk_livestatus_debug=false
$fixed16_header_responses = {
  :err200 => "OK. Reponse contains the queried data.",
  :err400 => "The request contains an invalid header.",
  :err403 => "The user is not authorized.",
  :err404 => "The target of the GET has not been found (e.g. the table).",
  :err450 => "A non-existing column was being referred to.",
  :err451 => "The request is incomplete.",
  :err452 => "The request is completely invalid."
}

class SocketNotFoundException < Exception
end
class MkStatusLiveException < Exception
end

def check_answer_error(answer)
  error_code = answer.split(" ")[0].to_i
  if error_code > 200
    raise MkStatusLiveException, $fixed16_header_responses["err#{error_code}".to_sym]
  end
end

def get_socket_path
  if !($mk_livestatus_socket_paths.is_a? Array)
    raise RuntimeError, "$mk_livestatus_socket_paths is not an Array"
  end
  found_sock = nil
  $mk_livestatus_socket_paths.each do |sock|
    if File.exist? sock
      found_sock = sock
      puts "Socket found: #{sock}" if $mk_livestatus_debug
      # TODO: break if found
    end
  end
  if found_sock == nil
    raise SocketNotFoundException, "Can't find a valid socket in $mk_livestatus_socket_paths: #{$mk_livestatus_socket_paths.join(':')}"
  else
    return found_sock
  end
end



def make_query(query)
  # Add ResponseHeader: fixed16
  query << "ResponseHeader: fixed16\n"
  socket = get_socket_path

  if $mk_livestatus_debug
    puts "Preparing to send packet:"
    puts query
    puts "---"
  end

  s=UNIXSocket.open socket
  s.puts query
  s.shutdown(Socket::SHUT_WR)

  # We use the ResponseHeader: fixed16 so the first thing is the status code
  # and the second the datas queryied, no need to check if == 200 because
  # check_answer_error will raise an Exception if > 200
  answer = s.recv(100000000)
  check_answer_error answer
  datas = s.recv(100000000)
  return datas
end

# Eat a Hash:
# => :table               String, Required
# => :columns             Array,  Optional
# => :extras_headers      String, Optional
# => :format              Symbol, Optional, Default to :json, Available: :json :csv
# See http://mathias-kettner.de/checkmk_livestatus.html for "extras headers" or only columns
# or format
# By default "ResponseHeader: fixed16\n" is added to do a Return Code check
# PLEASE PLEASE PLEASE don't override this or it will totally break the parsing stuff...
# Also by default, ColumnHeaders: on is added if :format => :json is choosed
# And PLEASE PLEASE PLEASE dont override ColumnHeaders if you want json or ...
def get_mk_livestatus(opts)
  # Checks
  puts opts.class
  if !opts.include? :table
    raise ArgumentError, "A table name is required!"
  end
  opts[:format] = :json if !opts.include? :format

  query = "GET #{opts[:format]}\n"
  
  if opts.include? :columns
    if (opts[:columns].size > 0) and (opts[:columns].is_a? Array)
      query << "Columns: #{opts[:columns].join(' ')}\n"
    end
  end
  
  if opts[:format] == :json
    query << "OutputFormat: json\n"
    query << "ColumnHeaders: on\n"
  end
  query << opts[:extras_headers] if opts.include? :extras_headers

  return make_query(query)
end