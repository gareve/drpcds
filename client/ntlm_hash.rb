def pass_to_ntml_hash(password)
  hash = String.new
  NTLM::Util.nt_v1_hash(password).each_byte { |b| hash += sprintf("%02X",b) }
  raise "Hash size != 32" unless hash.size == 32
  hash
end

=begin
puts pass_to_ntml_hash('abc')
puts pass_to_ntml_hash('patita')
puts pass_to_ntml_hash('patitas')
puts pass_to_ntml_hash('patitata')
=end