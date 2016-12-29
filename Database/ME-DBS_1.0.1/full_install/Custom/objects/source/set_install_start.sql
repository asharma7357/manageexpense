-- set the version information in DB_VERSION table
insert into DB_VERSION (COMPONENT_NAME, VERSION, INSTALL_DT, STATUS, REMARKS)
values ('#PRODUCT_KEY(#NODE_ID)', '#NETMIND_VER', sysdate, 'STARTED', 'Installation started ['||to_char(sysdate,'yyyymmddhh24miss')||']');
commit;