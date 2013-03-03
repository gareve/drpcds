####################
### Installation ###
####################

    gem install bundler

    add bin directory
        ~/.bashrc
            PATH=$PATH:$HOME/hashcat-0.42
        $ source .bashrc

#############
### Usage ###
#############
    Validate with http://www.md5decrypter.co.uk/ntlm-decrypt.aspx
    If the hashcat does not return anything, is asking for ACCEPTANCE of the licence

    #Run tests
        rspec tests.rb --format NyanCatWideFormatter