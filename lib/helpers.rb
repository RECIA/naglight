# Custom helpers

def nagios_state_names(state)
  st = case state
  when 0 then "OK"
  when 1 then "WARNING"
  when 2 then "CRITICAL"
  when 3 then "UNKNOWN"
  when 4 then "DEPENDENT"
  end
  return st
end

def nagios_short_state_names(state)
  st = case state
  when 0 then "OK"
  when 1 then "WARN"
  when 2 then "CRIT"
  when 3 then "UNKN"
  when 4 then "DEP"
  end
  return st
end

def nagios_short_host_state_names(state)
  st = case state
  when 0 then "UP"
  when 1 then "DOWN"
  when 2 then "UNREACH"
  end
  return st
end

def number_to_human(num)
  if num == 1
    return "yes"
  end
  return "unknown"
end

# Just proxying get_services for views
def host_get_services(query)
  return get_services(query)
end




def cycle(first_value, *values)
  values.unshift(first_value)
  return Cycle.new(*values)
end

class Cycle
  def initialize(first_value, *values)
    @values = values.unshift(first_value)
    @index = 0
  end
  
  def to_s
    value = @values[@index].to_s
    @index = (@index + 1) % @values.size
    return value
  end
end
