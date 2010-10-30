# Various utils
def mk_array_to_hash(mk_array)
  header = mk_array[0]
  mk_array.shift
  datas  = mk_array

  final = []

  datas.each do |data|
    # each lines
    size_fin = data.size
    size_cur= 0
    hashline = {}

    data.each do |indata|
      # each columns
      hashline[header[size_cur].to_sym] = indata
      size_cur+=1
    end

    final << hashline

  end
  
  return final
end

def time_elapsed(first, last)
  time_now = last
  time_old = first

  difference = time_now - time_old

  seconds    =  difference % 60
  difference = (difference - seconds) / 60
  minutes    =  difference % 60
  difference = (difference - minutes) / 60
  hours      =  difference % 24
  difference = (difference - hours)   / 24
  days       =  difference % 7
  weeks      = (difference - days)    /  7

  return {:weeks   => weeks,
    :days    => days,
    :hours   => hours,
    :minutes => minutes,
    :seconds => seconds }
end