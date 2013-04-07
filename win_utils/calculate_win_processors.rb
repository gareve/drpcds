hardware_specs = `WMIC CPU Get /Format:List`

num_processors = hardware_specs.strip.scan(/NumberOfCores=(\d+)/).first.first.to_i

printf("Processors : %d\n",num_processors)

open('number_of_processors.txt','w') do |f|
	num_processors.times do |i|
		f.printf(' ') unless i == 0
		f.printf('%d',i+1)
	end
end