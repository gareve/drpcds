DIVS = 1
LENGTH = 2
#Instantiation of the hashcat files
(('a'*LENGTH)..('z'*LENGTH)).each do |word|
#['asd'].each do |word|
    describe Hashcat do
        it "Cracking [#{word}]" do
            start = 0
            alphabet = 'abcdefghijklmnopqrstuvwxyz'
            chunk_size = alphabet.size ** word.size
            length = word.size

            hash_content = pass_to_ntml_hash(word)
            session_name = 'test_session'

            found = false
            
            (DIVS+1).times do
                chunk = chunk_size / DIVS
                
                hashcat = Hashcat.new(start,chunk,length,alphabet,hash_content,session_name)
                pass,pass_per_second = hashcat.run_cracking

                unless pass.nil?
                    raise 'Wrong pass' unless pass == word
                    found = true
                    break
                end

                start += chunk
            end

            raise 'password not found' unless found
        end
    end
end