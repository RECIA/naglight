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