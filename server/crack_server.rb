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
		mx = 0
		@clients.each do |client_id,client|
			mx = [mx,client.__id__].max if client.hostname == hostname
		end

		client = CrackClient.new hostname,mx+1,pass_per_sec
		@clients[client.id] = client

		printf("Client [%s] added\n",client.id)
		printf("   [%d] clients left\n",@clients.size)

		add_intervals

		[client.id,client.__id__,@hash_file,@alphabet]
	end

	def remove_client client_id
		@clients.delete_if do |client_id_key,client|
			client_id_key == client_id
		end

		printf("Client [%s] removed\n",client_id)
		printf("   [%d] clients left\n",@clients.size)
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

	def send_statistics total_time,computing_time,sleep_time,pass_sec,client_id
		@statistics_queue << [total_time,computing_time,sleep_time,pass_sec,client_id]
	end

	def show_statistics
		until @statistics_queue.empty?
			total_time,computing_time,sleep_time,pass_sec,client_id = @statistics_queue.shift

			puts "########### Client[#{client_id}] Statistics #############"
			puts "Total Time   : %.6f" % [total_time]
			puts "Process Time : %.6f" % [computing_time]
			puts "Sleep Time   : %.6f" % [sleep_time]
			puts "Pass/Sec     : %d" % [pass_sec]		
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