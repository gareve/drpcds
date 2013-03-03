class CrackServer
	include DRbUndumped
	attr_reader :hash_file,:password,:alphabet,:clients,:start_time,:end_time

	def initialize hash_file,alphabet
		@clients = {}
		@hash_file = hash_file
		@pass_index = 0
		@password = nil
		@alphabet = alphabet
		@length = 1

		@start_time = nil
		@end_time = nil
	end

	def add_client hostname
		mx = 0
		@clients.each do |client_id,client|
			mx = [mx,client.__id__].max if client.hostname == hostname
		end

		client = CrackClient.new hostname,mx+1
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

	def get_queue_size client_id
		ans = @clients[client_id].queue.size
		add_intervals if ans == 0

		ans
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
			while client.queue.size < 5
				@start_time = Time.now if @start_time.nil?

				chunk_size = client.pass_per_sec * 1 * 10
				interval,@pass_index,@length = build_interval(@pass_index,chunk_size,@length)

				client.add_interval interval
			end
		end
	end

	def setPassword password
		@password = password
		@end_time = Time.now
	end

	def hasPassword
		!@password.nil?
	end
end