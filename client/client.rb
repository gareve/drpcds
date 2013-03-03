def info message
   puts Time.now.strftime("%d/%m/%y %H:%M:%S : ") + message
end

def to_digit ch
   return ch.ord - '0'.ord if(ch <= '9')
   return ch.ord - 'a'.ord + 10
end

def num_to_base num,alphabet,length
   len = alphabet.size

   res = num.to_s(len)
   res.size.times do |i|
      d = to_digit(res[i])
      res[i] = alphabet[d]
   end

   res = (alphabet[0] * [0,length - res.size].max) + res

   res
end

def crack_interval start,finish,length,alphabet,ntlm_hash,session_name
   chunk_size = finish-start + 1
   cracker = Hashcat.new(start,chunk_size,length,alphabet,ntlm_hash,session_name.to_s)

   start_time = Time.now.to_i
      ans = cracker.run_cracking
   end_time = Time.now.to_i

   pass_per_sec = chunk_size / [end_time - start_time,1].max
   
   info(sprintf("%10d passes in %4d secs;  %10d pass/sec :: [%s,%s]\n",
            chunk_size,
            end_time - start_time,
            pass_per_sec,
         	num_to_base(start,alphabet,length),
         	num_to_base(finish,alphabet,length)
         )
      )
   return ans,pass_per_sec
end

def main
   DRb.start_service
   crack_server = DRbObject.new nil, 'druby://localhost:6666'

   host_name = `hostname`.strip
   client_info = crack_server.add_client host_name

   client_id  = client_info[0]
   client_num = client_info[1]
   ntlm_hash  = client_info[2]
   alphabet   = client_info[3]

   puts "Client id = " + client_id
   puts "Hash File request: " + ntlm_hash

   open(client_num.to_s + '.hash','w') do |f|
      f.puts ntlm_hash
   end

   while true
   	sz = crack_server.get_queue_size client_id
      if sz > 0
         interval = crack_server.get_interval client_id
         ans,pass_per_sec = crack_interval(
                              interval.start,
                              interval.finish,
                              interval.length,
                              alphabet,
                              ntlm_hash,
                              client_num)

         unless ans.nil?
            crack_server.setPassword ans
            break
         end
      else
   	  puts 'sleeping'
        sleep 5
      end
   end
rescue Interrupt
rescue => e
	puts e.message
	puts e.backtrace.to_a
ensure
   puts "Closing client: "  + client_id.to_s
   crack_server.remove_client client_id
end

main()