SET SERVEROUTPUT ON;

--HELP TO NEW_CUSTOMERS
CREATE OR REPLACE PROCEDURE HELP
AS

BEGIN
        dbms_output.put_line('START USING THIS APPLICATION BY SIGNING UP !');
        dbms_output.put_line('EXECUTE THE BELOW PROCEDURE WITH THE SPECIFIED PARAMETERS IN AN ANONYMOUS PL/SQL BLOCK');
        dbms_output.put_line('SIGNUP(user_name,email,pass_word,first_name,last_name,phone_number)');
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
        dbms_output.put_line(dbms_utility.format_error_backtrace);
        ROLLBACK;
END HELP;

GRANT EXECUTE ON HELP TO NEW_CUSTOMER;
GRANT EXECUTE ON SIGNUP TO NEW_CUSTOMER;

--ALL ACTIONS OF REGISTERED CUSTOMERS
CREATE OR REPLACE PROCEDURE ALL_ACTIONS
AS
BEGIN
        dbms_output.put_line('HELLO '||SYS_CONTEXT( 'USERENV', 'SESSION_USER' )||'WELCOME TO OUR RENTAL MARKET!');
        
        dbms_output.put_line('AVAILABLE ACTIONS:');
        dbms_output.put_line('--PERSONAL INFORMATION:');
        dbms_output.put_line('1. VIEW YOUR INFORMATION USING SELECT * FROM PEOPLE_<YOUR_USER_NAME>');
        dbms_output.put_line('');
        
        dbms_output.put_line('--ADDRESS RELATED ACTIONS:');
    
        dbms_output.put_line('1. REFER TO OUR SERVICE LOCATIONS USING SELECT * FROM AVAILABLE_LOCAITONS');
        dbms_output.put_line('2. REFER TO OUR SERVICE LOCATIONS BY STATE USING SELECT * FROM AVAILABLE_STATES(COUNTRY_NAME)');
        dbms_output.put_line('3. REFER TO OUR SERVICE LOCATIONS BY CITY USING SELECT * FROM AVAILABLE_CITIES(STATE_NAME)');
        dbms_output.put_line('4. VIEW YOUR ADDRESS BOOK USING SELECT * FROM ADDRESS_<YOUR_USER_NAME>');
        dbms_output.put_line('5. ADD A NEW ADDRESS TO YOUR ADDRESS_BOOK USING ADD_ADDRESS(ADDRESS_LINE 1, ADDRESS_LINE 2, CITY) ');
        dbms_output.put_line('6. DELETE AN ADDRESS FROM YOUR ADDRESS_BOOK USING DELETE_ADDRESS(ADDRESS_ID) ');
        dbms_output.put_line('');
        
        dbms_output.put_line('LISTING RELATED ACTIONS');
        dbms_output.put_line('1. VIEW OUR RENTAL BASIS THAT OUR SERVICE PROVIDES USING SELECT * FROM RENTAL_BASIS ');
        dbms_output.put_line('2. VIEW THE CATEGORIES IN WHICH WE OFFER RENTAL SERVICES USING SELECT * FROM LISTING_CATEGORY');
        dbms_output.put_line('3. ADD A NEW LISTING USING ADD_LISTING(TITLE,DESCRIPTION,CATEGORY,RENTAL_BASIS,CONTACT_DETAILS,PRICE,ADDRESS_ID');
        dbms_output.put_line('2. DELETE AN ADDRESS FROM YOUR ADDRESS_BOOK USING DELETE_ADDRESS(USER_NAME,PASS_WORD) ');
        dbms_output.put_line('3. DELETE AN ADDRESS FROM YOUR ADDRESS_BOOK USING DELETE_ADDRESS(USER_NAME,PASS_WORD) ');

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
        dbms_output.put_line(dbms_utility.format_error_backtrace);
        ROLLBACK;
END ALL_ACTIONS;

CREATE OR REPLACE PROCEDURE signup(user_name varchar,email varchar,pass_word varchar,first_name varchar,last_name varchar,phone_number number)
IS 
uid NUMBER;
BEGIN
  EXECUTE IMMEDIATE'alter session set "_ORACLE_SCRIPT"=true';  
  INSERT INTO PEOPLE(USERNAME, EMAIL,PASS_WORD, FIRST_NAME, LAST_NAME, PHONE_NUMBER) VALUES(user_name,email,pass_word,first_name,last_name,phone_number);
  EXECUTE IMMEDIATE'CREATE USER '||user_name||' IDENTIFIED BY '||pass_word;
  EXECUTE IMMEDIATE'GRANT DB_CUSTOMERS TO '||user_name;
  COMMIT;
  SELECT USER_ID INTO uid FROM PEOPLE WHERE USERNAME=user_name;
  dbms_output.put_line(uid);
  EXECUTE IMMEDIATE'CREATE OR REPLACE VIEW ADDRESS_'||user_name||' AS SELECT * FROM USER_ADDRESS WHERE USER_ID='||uid;
  EXECUTE IMMEDIATE'CREATE OR REPLACE VIEW PEOPLE_'||user_name||' AS SELECT * FROM PEOPLE WHERE USER_ID='||uid;
  EXECUTE IMMEDIATE'GRANT SELECT TO PEOPLE_'||user_name||' TO '||user_name;
  EXECUTE IMMEDIATE'GRANT SELECT TO ADDRESS_'||user_name||' TO '||user_name;
  EXECUTE IMMEDIATE'GRANT EXECUTE ON ALL_ACTIONS TO '||user_name;
  COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
        dbms_output.put_line(dbms_utility.format_error_backtrace);
        ROLLBACK;
END;

CREATE OR REPLACE TRIGGER Order_Creation_trg
    AFTER
    INSERT OR UPDATE
    ON DEALS
    FOR EACH ROW
BEGIN
   IF INSERTING THEN
   IF (:NEW.STATUS_ID = 2) THEN
   INSERT INTO ORDER_STATUS(STATUS_ID,DEALS_ID) VALUES(1,:NEW.DEALS_ID);
   END IF;
   END IF;
   IF UPDATING THEN
   IF (:OLD.STATUS_ID = 1 AND :NEW.STATUS_ID = 2) THEN
   INSERT INTO ORDER_STATUS(STATUS_ID,DEALS_ID) VALUES(1,:NEW.DEALS_ID);
   END IF;
   END IF;
END;










 







