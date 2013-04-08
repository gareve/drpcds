def infos message, print_stdout = true,print_file = true
	str = Time.now.strftime("%d/%m/%y %H:%M:%S : ") + message.to_s
	puts str if print_stdout

	begin
		if print_file
			open('master.log','a') do |f|
				f.puts str
			end
		end
	rescue => e
	end
end

class CrackServer
	include DRbUndumped
	attr_reader :hash_file,:password,:alphabet,:clients,:start_time,:end_time,:statistics_queue

	def initialize hash_file,alphabet
		@clients = {}
		@hash_file = hash_file
		@pass_index = 0
		@password = nil
		@alphabet = alphabet
		@length = 1

		@start_time = nil
		@end_time = nil

		@statistics_queue = []
	end

	def add_client hostname,pass_per_sec
		return nil unless @password.nil?

		mx = 0
		@clients.each do |client_id,client|
			mx = [mx,client.__id__].max if client.hostname == hostname
		end

		client = CrackClient.new hostname,mx+1,pass_per_sec
		@clients[client.id] = client

		printf("Client [%s] added. Total = %d\n",client.id,@clients.size)

		add_intervals

		[client.id,client.__id__,@hash_file,@alphabet]
	end

	def remove_client client_id
		@clients.delete_if do |client_id_key,client|
			client_id_key == client_id
		end

		printf("Client [%s] removed. Total = %d\n",client_id,@clients.size)
	end

	def get_interval client_id
		@clients[client_id].queue.shift
	end

	def build_interval start,chunk_size,len
		last = (@alphabet.size ** len) - 1
		finish = start + chunk_size - 1

		next_value = nil

		interval = CrackInterval.new(start,[last,finish].min,len)

		if finish >= last
			len += 1
			next_value = 0
		else
			next_value = interval.finish + 1
		end

		return [interval,next_value,len]
	end

	def add_intervals
		return if @clients.empty?

		@clients.each do |client_id,client|
			while client.queue.size < 10
				@start_time = Time.now if @start_time.nil?

				chunk_size = client.pass_per_sec * 1 * 10
				interval,@pass_index,@length = build_interval(@pass_index,chunk_size,@length)

				client.add_interval interval
			end
		end
	end

   def actual_capacity
      sum = 0
      @clients.each do |key,client|
         sum += client.pass_per_sec
      end
      return sum
   end

	def send_statistics total_time,computing_time,sleep_time,pass_sec,client_id
		#puts client_id + ' <> ' + pass_sec.to_s
		return if pass_sec <= 10 ** 6

		@statistics_queue << [total_time,computing_time,sleep_time,pass_sec,client_id]
      
      @clients[client_id].pass_per_sec = pass_sec

		infos sprintf('[stats]%s;%.6f;%.6f;%.6f;%d',client_id,total_time,computing_time,sleep_time,pass_sec)
      infos sprintf('[actual_capacity] = %d',self.actual_capacity)
	end

	def send_final_statistics total_time,computing_time,sleep_time,pass_sec,client_id
		infos sprintf('[final_stats]%s;%.6f;%.6f;%.6f;%d',client_id,total_time,computing_time,sleep_time,pass_sec)
	end

	def show_statistics
		return if @statistics_queue.empty?

		until @statistics_queue.empty?
			total_time,computing_time,sleep_time,pass_sec,client_id = @statistics_queue.shift

			infos "########### Client[#{client_id}] Statistics #############"
			infos "Total Time   : %.6f" % [total_time]
			infos "Process Time : %.6f" % [computing_time]
			infos "Sleep Time   : %.6f" % [sleep_time]
			infos "Pass/Sec     : %d" % [pass_sec]		
		end
	end

	def get_status client_id
		queue_size = @clients[client_id].queue.size
		add_intervals if queue_size == 0

		[queue_size > 0, hasPassword()]
	end

	def setPassword password
		@password = password
		@end_time = Time.now
	end

	def hasPassword
		!@password.nil?
	end
end