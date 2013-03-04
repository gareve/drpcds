class CrackClient
	include DRbUndumped

	attr_reader :queue,:hostname,:__id__,:pass_per_sec,:pass

	def initialize hostname,client_id,pass_per_sec
		@queue = []
		@__id__ = client_id
		@hostname = hostname
		@pass_per_sec = pass_per_sec
		@pass = nil
	end

	def id
		@hostname+'-'+@__id__.to_s
	end

	def add_interval interval
		@queue << interval
	end

	def pop_interval
		raise "Queue Empty" if @queue.empty?
		@queue.shift
	end
end