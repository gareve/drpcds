set PATH=%PATH%;C:\Ruby193\bin

call del *.lock
call rake calc_power
call ruby win_utils\calculate_win_processors.rb


@set /p cores=<number_of_processors.txt

@echo %cores%


taskkill /FI "WINDOWTITLE eq crack_client*"

FOR %%A IN (%cores%) DO (
	@start "crack_client" C:\drpcds\win_utils\win_client.bat
	@ping -n 5 127.0.0.1 > nul
)