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
--DROP TRIGGER Order_Creation_trg;
DROP PUBLIC SYNONYM ADDRESS_COUNTRY;
DROP PUBLIC SYNONYM ADDRESS_CITY;
DROP PUBLIC SYNONYM ADDRESS_STATE;
DROP PUBLIC SYNONYM LISTINGS;
DROP PUBLIC SYNONYM LISTING_CATEGORY;
DROP PUBLIC SYNONYM RENTAL_BASIS;
--DROP PUBLIC SYNONYM CURRENT_STATUS;
DROP VIEW AVAILABLE_LOCATIONS;
DROP MATERIALIZED VIEW ALL_LISTINGS;
DECLARE
uname varchar(50);
sqlstmt varchar(1000);
CURSOR c_uname IS
   SELECT username from all_users WHERE TO_CHAR(trunc(CREATED))=TO_CHAR(trunc(SYSDATE)) and username not in ('PROJECT_ADMIN') ;
BEGIN
   OPEN c_uname;
   LOOP
   FETCH c_uname into uname;
      EXIT WHEN c_uname%notfound;
        DECLARE
        vname varchar(50);
        CURSOR c_vname IS
            select view_name into vname from all_views WHERE REGEXP_LIKE(view_name,''||uname||'$');
        BEGIN
            OPEN c_vname;
            LOOP
            FETCH c_vname into vname;
                EXIT WHEN c_vname%notfound;
                dbms_output.put_line('view-');
                dbms_output.put_line(vname);
                EXECUTE IMMEDIATE 'DROP VIEW '||vname;
            END LOOP;
        CLOSE c_vname;
        END;
        DECLARE
        sname varchar(50);
        CURSOR c_sname IS
            select synonym_name into sname from all_synonyms WHERE REGEXP_LIKE(synonym_name,''||uname||'$');
        BEGIN
            OPEN c_sname;
            LOOP
            FETCH c_sname into sname;
                EXIT WHEN c_sname%notfound;
                dbms_output.put_line('synonym-');
                dbms_output.put_line(sname);
                EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM "'||sname||'"';
            END LOOP;
        CLOSE c_sname;
        END;
      dbms_output.put_line('user-');
      dbms_output.put_line(uname);
      sqlstmt := 'DROP USER '||uname||' cascade';
      EXECUTE IMMEDIATE sqlstmt;
   END LOOP;
   CLOSE c_uname;
END;
/

