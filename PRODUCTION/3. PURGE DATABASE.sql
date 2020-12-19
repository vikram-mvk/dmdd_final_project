SET SERVEROUTPUT ON;

drop table "PEOPLE" cascade constraints PURGE;
drop table "LISTING_CATEGORY" cascade constraints PURGE;
drop table "RENTAL_BASIS" cascade constraints PURGE;
drop table "ADDRESS_STATE" cascade constraints PURGE;
drop table "ADDRESS_COUNTRY" cascade constraints PURGE;
drop table "ADDRESS_CITY" cascade constraints PURGE;
drop table "USER_ADDRESS" cascade constraints PURGE;
drop table "LISTINGS" cascade constraints PURGE;
drop table "EMPLOYEE_ADDRESS" cascade constraints PURGE;
drop table "DEAL_STATUS" cascade constraints PURGE;
drop table "DEALS" cascade constraints PURGE;
drop table "DESIGNATION" cascade constraints PURGE;
drop table "CURRENT_STATUS" cascade constraints PURGE;
drop table "ORDER_STATUS" cascade constraints PURGE;
drop table "EMPLOYEE" cascade constraints PURGE;
drop role DB_CUSTOMERS;
DROP TRIGGER Order_Creation_trg;
DROP PUBLIC SYNONYM ADDRESS_COUNTRY;
DROP PUBLIC SYNONYM ADDRESS_CITY;
DROP PUBLIC SYNONYM ADDRESS_STATE;
DROP PUBLIC SYNONYM LISTINGS;
DROP PUBLIC SYNONYM LISTING_CATEGORY;
DROP PUBLIC SYNONYM RENTAL_BASIS;
DROP PUBLIC SYNONYM CURRENT_STATUS;

/
DECLARE
uname varchar(50);
sqlstmt varchar(1000);
CURSOR c_uname IS
   SELECT username from all_users WHERE TO_CHAR(CREATED)=TO_CHAR(SYSDATE);
BEGIN
   OPEN c_uname;
   LOOP
   FETCH c_uname into uname;
      EXIT WHEN c_uname%notfound;
      dbms_output.put_line(uname);
      sqlstmt := 'DROP USER '||uname||' cascade';
      EXECUTE IMMEDIATE sqlstmt;
   END LOOP;
   CLOSE c_uname;
END;
/


DECLARE
uname varchar(50);
sqlstmt varchar(1000);
CURSOR c_uname IS
    select synonym_name into uname from all_synonyms WHERE TABLE_OWNER='PROJECT_ADMIN';
BEGIN
   OPEN c_uname;
   LOOP
   FETCH c_uname into uname;
      EXIT WHEN c_uname%notfound;
      dbms_output.put_line(uname);
      EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM '||uname;
   END LOOP;
   CLOSE c_uname;
END;
/



