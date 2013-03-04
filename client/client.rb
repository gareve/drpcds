SLEEP_TIME = 2
PROCESS_POWER_FILE = 'client_power.stats'

def calculate_power
   start = 1
   finish = 10 ** 8
   
   alphabet = 'abcdefghijklmnopqrstuvwxyz'

   test_pass = 'aaaaabbbbb'

   ntlm_hash = pass_to_ntml_hash(test_pass)
   length = test_pass.size
   session_name = 'calculatin_power'

   ans,pass_per_sec,process_time = crack_interval start,finish,length,alphabet,ntlm_hash,session_name

   puts '########### POWER ##############'
   puts pass_per_sec
   puts '########### POWER ##############'

   open(PROCESS_POWER_FILE,'w') do |f|
      f.printf(pass_per_sec.to_s)
   end
end

def measure_time
   start_time = Time.now.to_f
   yield
   end_time = Time.now.to_f

   return @cracking_started ? end_time - start_time : 0
end

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

   start_time = Time.now.to_f
      ans = cracker.run_cracking
   end_time = Time.now.to_f

   process_time = end_time - start_time
   pass_per_sec = (chunk_size.to_f / [process_time,0.000001].max.to_f).to_i
   
   info(sprintf("%10d words in %7.4f secs;  %10d pass/sec :: [%s,%s]\n",
            chunk_size,
            process_time,
            pass_per_sec,
         	num_to_base(start,alphabet,length),
         	num_to_base(finish,alphabet,length)
         )
      )
   return ans,pass_per_sec,process_time
end

def read_process_power
   raise 'Power is not calculated for this client' unless File.exist?(PROCESS_POWER_FILE)
   open(PROCESS_POWER_FILE,'r').read.to_i
end

def start_client
   DRb.start_service
   crack_server = DRbObject.new nil, 'druby://localhost:6666'

   pass_per_sec_power = read_process_power()

   host_name = `hostname`.strip
   client_info = crack_server.add_client host_name,pass_per_sec_power

   client_id  = client_info[0]
   client_num = client_info[1]
   ntlm_hash  = client_info[2]
   alphabet   = client_info[3]

   puts "Client id = " + client_id
   puts "Hash File request: " + ntlm_hash

   open(client_num.to_s + '.hash','w') do |f|
      f.puts ntlm_hash
   end

   has_intervals = 0
   password_found = nil

   #Statistics
   @total_time = 0.0
   @computing_time = 0.0
   @sleep_time = 0.0
   @pass_sec = 0

   @cracking_started = false
   @password_found = false
   @password = nil

   until @password_found
      @total_time += measure_time do
   	  has_intervals,password_found = crack_server.get_status client_id
      end

      if password_found
         @password_found = true
         break
      end

      if has_intervals
         @cracking_started = true

         @total_time += measure_time() do
            interval = crack_server.get_interval client_id
            ans,pass_per_sec,process_time = crack_interval(
                                 interval.start,
                                 interval.finish,
                                 interval.length,
                                 alphabet,
                                 ntlm_hash,
                                 client_num)

            @computing_time += process_time            

            unless ans.nil?
               @password_found = true 
               @password = ans
            else
               #If the password was found, pass per sec has an invalid value
               #Because the chunk were not processed totally
               @pass_sec = [@pass_sec,pass_per_sec].max   
            end
         end
      else
         puts('sleeping %d secs'%SLEEP_TIME)
         sleep SLEEP_TIME
         @sleep_time += SLEEP_TIME
      end
   end

   info '########### Client Statistics #############'
   info "Total Time   : %.6f" % [@total_time]
   info "Process Time : %.6f" % [@computing_time]
   info "Sleep Time   : %.6f" % [@sleep_time]
   info "Pass/Sec     : %d" % [@pass_sec]
   info '########### Client Statistics #############'

   crack_server.send_statistics @total_time,@computing_time,@sleep_time,@pass_sec,client_id
   crack_server.setPassword @password
rescue Interrupt
rescue => e
	puts e.message
	puts e.backtrace.to_a
ensure
   puts "Closing client: "  + client_id.to_s
   crack_server.remove_client client_id
end