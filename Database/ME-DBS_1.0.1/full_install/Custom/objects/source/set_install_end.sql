

-- update the installation status
update DB_VERSION 
	set STATUS = 'COMPLETE',
	REMARKS = REMARKS||',Installation completed ['||to_char(sysdate,'yyyymmddhh24miss')||']'
where INSTALL_DT = (select max(INSTALL_DT) from DB_VERSION);
commit;