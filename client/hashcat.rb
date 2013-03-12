now_dir = `lspci -vv`
USE_GPU = !now_dir.match(/NVidia/).nil?

class Hashcat
	def initialize start,chunk_size,length,alpha,hash_content,session_name
		@start = start
		@chunk_size = chunk_size
      @length = length

		@alphabet = alpha
		@hash_content = hash_content.strip
      @hash_file = session_name+'.hash'

      write_file
	end

   def write_file
      open(@hash_file,'w') do |f|
         f.puts @hash_content
      end
   end

   def run_cracking
	cpuHashcat = 'hashcat-cli64.bin'
	gpuHashcat = '/root/oclHashcat-lite-0.14/cudaHashcat-lite64.bin'

	
	cmd = nil

	if USE_GPU
   		cmd = gpuHashcat  +
  					" --pw-min=#{@length}"  +
  					" --pw-max=#{@length}"  +
   					' --hash-type=1000' + #NTLM
                  " --pw-skip=#{@start}" +
                  " --pw-limit=#{@start + @chunk_size}" +
   					' --quiet'+
                  " --custom-charset1=#{@alphabet}"+
   					" #{@hash_content}"+
   					' ' + '?1'*@length
	else
	   	cmd = cpuHashcat  +
                  ' --threads=1' +
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
	end

      	#puts cmd      
   	output = `#{cmd} 2>&1`
      
   	output.split("\n").each do |line| puts '#'+line end

      #File.delete(@hash_file)
      #File.delete('eula.accepted')
   	if output =~ /recovered/ or output =~ /#{@hash_content.downcase}:/
   		pass = output.match(/:([^ ]*)$/)[1].to_s.chop
#   		puts '################## FOUND #########################'
#   		puts pass+'<<'
#   		puts '################## FOUND #########################'
         return pass
   	else
   		return nil
   	end
   end
end
