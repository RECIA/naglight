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

def get_contacts(only_columns=[], extras_headers=nil, format=:json)
  query = "GET contacts\n"
  if (only_columns.size > 0) and (only_columns.is_a? Array)
    query << "Columns: #{only_columns.join(' ')}\n"
  end
  if format == :json
    query << "OutputFormat: json\n"
    query << "ColumnHeaders: on\n"
  end
  query << extras_headers if extras_headers

  return make_query(query)
end