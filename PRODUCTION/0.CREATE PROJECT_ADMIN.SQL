alter session set "_ORACLE_SCRIPT"=true;  
grant dba to project_admin with admin option;
grant all privileges to project_admin;
grant create any table to project_admin;
GRANT UNLIMITED TABLESPACE TO project_admin;

