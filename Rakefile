$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

require 'bundler/setup'
Bundler.require

desc 'Generate a new hash file as a unix passwd file'
task :gen do
   test_word = 'abcdefg'
	puts "Generating a new passwd Hash File of size #{test_word.length}"

    open('file.hash','w') do |f|
    	f.puts(pass_to_ntml_hash(test_word))
    end
end

desc 'Initate a new Crack Server'
task :server do
	puts 'Initating server'
	require 'server/server.rb'
end

desc 'Initate a new Crack Client'
task :client do
	#puts 'Initating Client ' + RUBY_PLATFORM
	
   start_client()
end

desc 'Calculates the processing power of the client machine'
task :calc_power do
    puts 'Calculating processing power'
    calculate_power
end

desc 'Rspec Tests'
task :test do
	#system 'rspec client/tests.rb --format NyanCatWideFormatter'
   system 'rspec client/tests.rb'
end
