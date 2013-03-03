class Hashcat
	def initialize start,chunk_size,length,alpha,hash_content,session_name
		@start = start
		@chunk_size = chunk_size
      @length = length

		@alphabet = alpha
		@hash_content = hash_content
      @hash_file = session_name+'.hash'      
	end

   def run_cracking
   	cmd = 'hashcat-cli64.bin'  +
                  ' --threads=2' +
   					" --pw-min=#{@length}"  +
   					" --pw-max=#{@length}"  +
   					' --hash-mode=1000' + #NTLM
   					' --attack-mode=3' +
                  " --words-skip=#{@start}" +
                  " --words-limit=#{@chunk_size}" +
   					' --quiet'+
                  ' --disable-potfile'+
                  " --custom-charset1=#{@alphabet}"+
   					" #{@hash_file}"+
   					' ' + '?1'*@length

      #puts cmd      
   	output = `#{cmd} 2>&1`
      
   	#output.split("\n").each do |line| puts '#'+line end

      #File.delete(@hash_file)
      #File.delete('eula.accepted')
   	if output =~ /recovered/
   		pass = output.match(/:([^ ]*)$/)[1].to_s
   		puts '################## FOUND #########################'
   		puts pass
   		#puts '################## FOUND #########################'
         return pass
   	else
   		return nil
   	end


   end
end