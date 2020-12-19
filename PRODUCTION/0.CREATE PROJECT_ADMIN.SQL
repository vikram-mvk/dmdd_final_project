alter session set "_ORACLE_SCRIPT"=true;  
create user project_admin identified by info6150;
grant dba to project_admin;
grant all privileges to project_admin;
grant create any table to project_admin;
GRANT UNLIMITED TABLESPACE TO project_admin;


