set PATH=%PATH%;C:\Ruby193\bin

call rake calc_power
call ruby calculate_win_processors.rb


@set /p cores=<number_of_processors.txt

@echo %cores%


taskkill /FI "WINDOWTITLE eq crack_client*"

FOR %%A IN (%cores%) DO (
	REM @start "crack_client" C:\Ruby193\bin\rake.bat -f C:\drpcds\Rakefile client
	@start "crack_client" C:\drpcds\win_client.bat
	@ping -n 5 127.0.0.1 > nul
)