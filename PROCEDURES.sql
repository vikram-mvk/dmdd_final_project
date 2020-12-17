CREATE OR REPLACE PROCEDURE signup(username varchar,email varchar,pass_word varchar,first_name varchar,last_name varchar,phone_number number)
IS     
BEGIN
  EXECUTE IMMEDIATE 
  'INSERT INTO PEOPLE(USERNAME, EMAIL,PASS_WORD, FIRST_NAME, LAST_NAME, PHONE_NUMBER) VALUES('||username||','||email||','||pass_word||','||first_name||',
  '||last_name||','||phone_number||')';
  EXECUTE IMMEDIATE 'CREATE USER '||username||' IDENTIFIED BY '||pass_word;
  EXECUTE IMMEDIATE 'GRANT CREATE SESSION, CONNECT TO'||username;
  EXECUTE IMMEDIATE 'GRANT INSERT, SELECT,UPDATE, DELETE ON PEOPLE,USER_ADDRESS,LISTINGS,DEALS TO '||username;
  EXECUTE IMMEDIATE 'GRANT SELECT ON ADDRESS_COUNTRY,ADDRESS_STATE,ADDRESS_CITY,LISTING_CATEGORY,LISTING_TYPE,RENTAL_BASIS,DEAL_STATUS,ORDERS,CURRENT_STATUS TO '||username;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(dbms_utility.format_error_backtrace);
        ROLLBACK;
END;
 
    signup('testuser','testemail','testpassword,testfname,testlname,1234567890);
END;