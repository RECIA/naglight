# Custom helpers

# Return human state from number
# See (and from) http://nagios.sourceforge.net/docs/3_0/statetypes.html
# TODO: include soft/hard : "OK HARD" etc..
# and use .split(" ")[x] in views.
def human_state(state)
  st = case state
  when 0 then "OK"         # HARD
  when 1 then "CRITICAL"   # SOFT
  when 2 then "WARNING"    # SOFT
  when 3 then "CRITICAL"   # HARD
  when 4 then "WARNING"    # HARD
  when 5 then "WARNING"    # HARD
  when 6 then "OK"         # HARD
  when 7 then "OK"         # HARD
  when 8 then "UNKNOWN"    # SOFT
  when 9 then "OK"         # SOFT
  when 10 then "OK"        # HARD
  end
  
  return st
end
