@echo OFF
SETLOCAL EnableDelayedExpansion

REM Set variable with all the websites and IP adresses you want here (website1 website2 website3...) 
REM !!PLEASE DO NOT MAKE MORE THAN ONE SPACE!!
SET websites_and_ips=(gelbooru.com, xnxx.com)

REM Loop thorugh all the websites
FOR %%w IN %websites_and_ips% DO (
	Echo %%w
	SET count=1
	SET temp_var=""
	
	REM Tried to do nslookup for the website to get its IP adresses for the firewall rule
	FOR /f "tokens=* USEBACKQ" %%f IN (`nslookup %%w`) DO (
		SET var!count!=%%f
		SET /A count=!count!+1
	)
	SET /A count=!count!-1
	
	REM Loop through the nslookup text from row 4 and save only IPv4 and IPv6 addresses
	FOR /L %%i IN (4,1,!count!-1) DO (
		IF !temp_var! == "" (
			SET temp_var=!var%%i:Addresses:  =!
			SET temp_var=!temp_var:Address:  =!
		) ELSE (
			SET temp_var=!temp_var!,!var%%i:Addresses:  =!
			SET temp_var=!temp_var!,!var%%i:Address:  =!
			SET temp_var=!temp_var:,Aliases:  %%w=!
		)
	)
	REM ECHO !temp_var!

	REM ECHO Trying to delete all old rules
	REM netsh advfirewall firewall delete rule name="Block PMO %%w" dir=out action=block enable=yes profile=any localip=any remoteip=!temp_var! interfacetype=any
	
	ECHO Trying to add new ones	
	netsh advfirewall firewall add rule name="Block PMO %%w" dir=out action=block enable=yes profile=any localip=any remoteip=!temp_var! protocol=any interfacetype=any
)
ENDLOCAL
PAUSE	