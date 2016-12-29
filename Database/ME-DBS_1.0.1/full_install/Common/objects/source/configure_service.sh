if [ "Y" == "#ENV_RAC_TYPE" ] || [ "y" == "#ENV_RAC_TYPE" ];
then
	srvctl remove service -d #DATABASE_NAME -s #JOB_SERVICE_NAME -f
	srvctl add service -d #DATABASE_NAME -s #JOB_SERVICE_NAME -r #INSTANCE_NAME1 -a #INSTANCE_NAME2
	srvctl start service -d #DATABASE_NAME -s #JOB_SERVICE_NAME
fi