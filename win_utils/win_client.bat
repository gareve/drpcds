set PATH=%PATH%;C:\Ruby193\bin

:loop
call C:\Ruby193\bin\rake -f C:\drpcds\Rakefile client
@ping -n 5 127.0.0.1 > nul
goto loop