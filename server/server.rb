HASH_FILE = "file.hash"

hash_file = open(HASH_FILE).read
alphabet = 'abcdefghijklmnopqrstuvwxyz'

crack_server = CrackServer.new(hash_file,alphabet)
DRb.start_service 'druby://:6666', crack_server
puts "Server running at #{DRb.uri}"

begin
   until crack_server.hasPassword
      crack_server.add_intervals
      crack_server.show_statistics
      sleep 5
   end

   start_wait = Time.now.to_i
   while Time.now.to_i - start_wait < 60 and crack_server.clients.empty? == false
      sleep 1
   end

   total = crack_server.end_time.to_i - crack_server.start_time.to_i

   h = total / (60 ** 2)
   m = (total % (60 ** 2)) / 60
   s = total % 60

   infos sprintf("####### Found in %dh:%02d:%02ds #############\n",h,m,s)
   infos crack_server.password
   infos sprintf("####### Found in %dh:%02d:%02ds #############\n",h,m,s)

   #DRb.thread.join
rescue Interrupt
   puts "Ctrl + C"
rescue => e
   puts e.message
   puts e.backtrace.to_a
ensure
   crack_server.show_statistics
   DRb.stop_service
end