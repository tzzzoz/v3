require "mysql2"

client = Mysql2::Client.new(:host => "localhost", :username => "root")

client.query("use pixpalace_production")

client.query("SELECT id, ms_picture_id FROM images").each do |row|
  if row["ms_picture_id"].size > 20
    decrypted = marek_decrypt(row["ms_picture_id"])
    myIddd = row["id"]
    client.query("UPDATE images SET ms_picture_id = #{decrypted} WHERE id = #{myIddd}")
  end
end

def marek_decrypt(mastr)
  tostr = ''
  offset = 0
  scan = true
  while scan
    skipChars = mastr[offset..offset].to_i
    offset += skipChars + 1
    if mastr[offset..offset] == '0'
      if mastr[offset+1..offset+1].to_i < 5
        tostr << '/'
      else
        tostr << '@'
      end
    elsif mastr[offset..offset] == '1'
      if mastr[offset+1..offset+1].to_i < 5
        tostr << ' '
      else
        tostr << '.'
      end
    else
      tostr << mastr[offset+1..offset+1]
    end
    offset += 2
    scan = false if mastr[offset].nil?
  end
  tostr.tr("A-Za-z", "N-ZA-Mn-za-m")
end
