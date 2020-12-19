SET SERVEROUTPUT ON;

--HELP TO NEW_CUSTOMERS
CREATE OR REPLACE PROCEDURE HELP
AS
BEGIN
        dbms_output.put_line('START USING THIS APPLICATION BY SIGNING UP !');
        dbms_output.put_line('EXECUTE THE BELOW PROCEDURE WITH THE SPECIFIED PARAMETERS IN AN ANONYMOUS PL/SQL BLOCK AS FOLLOWS');
        dbms_output.put_line('SIGNUP(user_name,email,pass_word,first_name,last_name,phone_number)');
        dbms_output.put_line('AFTER LOGGING IN EXECUTE ALL_ACTIONS TO SEE THE LIST OF AVAILABLE ACTIONS');

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
        dbms_output.put_line(dbms_utility.format_error_backtrace);
        ROLLBACK;
END HELP;
/

--ALL ACTIONS OF REGISTERED CUSTOMERS
CREATE OR REPLACE PROCEDURE ALL_ACTIONS
AS
BEGIN
        dbms_output.put_line('HELLO '||SYS_CONTEXT( 'USERENV', 'SESSION_USER' )||' ! WELCOME TO OUR RENTAL MARKET!');
        
        dbms_output.put_line('AVAILABLE ACTIONS:');
        dbms_output.put_line('------------- PERSONAL INFORMATION -------------');
        dbms_output.put_line('1. VIEW YOUR INFORMATION USING SELECT * FROM PEOPLE_<YOUR_USER_NAME>');
        dbms_output.put_line('');
        
        dbms_output.put_line('------------- ADDRESS RELATED ACTIONS -----------');
    
        dbms_output.put_line('1. REFER TO OUR SERVICE LOCATIONS USING SELECT * FROM AVAILABLE_LOCAITONS');
        dbms_output.put_line('2. REFER TO OUR SERVICE LOCATIONS BY STATE USING SELECT * FROM ADDRESS_STATE');
        dbms_output.put_line('3. REFER TO OUR SERVICE LOCATIONS BY CITY USING SELECT * FROM ADDRESS_CITY');
        dbms_output.put_line('4. VIEW YOUR ADDRESS BOOK USING SELECT * FROM ADDRESS_<YOUR_USER_NAME>');
        dbms_output.put_line('5. ADD A NEW ADDRESS TO YOUR ADDRESS_BOOK USING ADD_ADDRESS(ADDRESSLINE 1 varchar, ADDRESSLINE 2 varchar,ZIPCODE number, CITY varchar) ');
        dbms_output.put_line('6. DELETE AN ADDRESS FROM YOUR ADDRESS_BOOK USING REMOVE_ADDRESS(MY_ADDRESS_ID number) ');
        dbms_output.put_line('');
        
        dbms_output.put_line('-------------LISTING RELATED ACTIONS-------------');
        dbms_output.put_line('1. VIEW THE RENTAL BASIS THAT OUR SERVICE SUPPORTS USING SELECT * FROM RENTAL_BASIS ');
        dbms_output.put_line('2. VIEW THE CATEGORIES IN WHICH WE OFFER RENTAL SERVICES USING SELECT * FROM LISTING_CATEGORY');
        dbms_output.put_line('3. ADD A NEW LISTING USING ADD_NEW_LISTING(LISTING_TITLE varchar,LISTING_DESCRIPTION varchar,LISTING_PRICE varchar,CONTACT_INFO varchar,RENT_BASIS varchar,ITEM_CATEGORY varchar,MY_ADDRESS_ID number,START_TIME timestamp,END_TIME timestamp)');
        dbms_output.put_line('4. REMOVE A LISTING USING REMOVE_LISTING(MY_LISTING_ID number) ');
        dbms_output.put_line('');
        
        dbms_output.put_line('-------------DEALS RELATED ACTIONS-------------');
        dbms_output.put_line('1. ');
        dbms_output.put_line('2. VIEW THE CATEGORIES IN WHICH WE OFFER RENTAL SERVICES USING SELECT * FROM LISTING_CATEGORY');
        dbms_output.put_line('3. ADD A NEW LISTING USING ADD_NEW_LISTING(LISTING_TITLE varchar,LISTING_DESCRIPTION varchar,LISTING_PRICE varchar,CONTACT_INFO varchar,RENT_BASIS varchar,ITEM_CATEGORY varchar,MY_ADDRESS_ID number,START_TIME timestamp,END_TIME timestamp)');
        dbms_output.put_line('4. REMOVE A LISTING USING REMOVE_LISTING(MY_LISTING_ID number) ');
        dbms_output.put_line('');
        
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
        dbms_output.put_line(dbms_utility.format_error_backtrace);
        ROLLBACK;
END ALL_ACTIONS;

/

CREATE OR REPLACE PROCEDURE signup(user_name varchar,email varchar,pass_word varchar,first_name varchar,last_name varchar,phone_number number)
IS 
uid NUMBER;
sqlstmt varchar(1000 char);
nCount NUMBER;
BEGIN
SELECT count(*) into nCount FROM all_users where username = UPPER(user_name);
IF(nCount > 0)
THEN
  dbms_output.put_line('User already exists');
ELSE
  EXECUTE IMMEDIATE'alter session set "_ORACLE_SCRIPT"=true';  
  INSERT INTO PEOPLE(USERNAME, EMAIL,PASS_WORD, FIRST_NAME, LAST_NAME, PHONE_NUMBER) VALUES(UPPER(user_name),UPPER(email),pass_word,UPPER(first_name),UPPER(last_name),phone_number);
  EXECUTE IMMEDIATE'CREATE USER '||user_name||' IDENTIFIED BY '||pass_word;
  EXECUTE IMMEDIATE'GRANT DB_CUSTOMERS TO '||user_name;
  COMMIT;
  SELECT USER_ID INTO uid FROM PEOPLE WHERE USERNAME=UPPER(user_name);
  dbms_output.put_line(uid);
  
  --CREATE ADDRESS_VIEW
  sqlstmt :='CREATE OR REPLACE VIEW ADDRESS_'||user_name||' AS SELECT
    user_address.address_id,
    people.username,
    user_address.address_line_1,
    user_address.address_line_2,
    zip_code,
    address_city.city_name,
    address_state.state_name,
    address_country.country_name
FROM
    user_address
INNER JOIN address_city
        USING(city_id)
INNER JOIN address_state
        USING(state_id)
INNER JOIN address_country
        USING(country_id)
INNER JOIN people
        USING(user_id) where user_id='||uid;
        
  EXECUTE IMMEDIATE sqlstmt;
  dbms_output.put_line('address view created');
  EXECUTE IMMEDIATE 'CREATE OR REPLACE PUBLIC SYNONYM ADDRESS_'||user_name||' FOR project_admin.ADDRESS_'||user_name;
  dbms_output.put_line('SYNONYM CREATED FOR ADDRESS');
  EXECUTE IMMEDIATE 'GRANT SELECT ON ADDRESS_'||user_name||' TO '||user_name;
  dbms_output.put_line('address view granted');
  

--CREATE DEALS VIEW
    sqlstmt := 'CREATE OR REPLACE VIEW DEALS_REQUEST_BY_'||user_name||' AS SELECT
    deals.deals_id,
    TRunc(CREATE_TIME) Date_Requested,
    p1.username deal_owner,
    listings.title Listing_title,
    l_description Listing_Description,
    p2.username Listing_Owner,
    DEALS.PRICE Counter_Offer_Price,
    to_char(DEALS.START_DATE,'' DD/MON - HH24:MI'') Counter_Offer_Start_Date,
    to_char(DEALS.END_DATE,'' DD/MON - HH24:MI'') Counter_Offer_End_Date,
    deal_status.status_name Deal_Status
FROM
    DEALS
INNER JOIN people p1 ON p1.user_id=deals.user_id and deals.user_id='||uid||'
 INNER JOIN DEAL_STATUS
        USING(STATUS_ID)
INNER JOIN LISTINGS
        USING(LISTING_ID)
INNER JOIN people p2 ON p2.user_id=LISTINGS.user_id';
  EXECUTE IMMEDIATE sqlstmt;
   dbms_output.put_line('deals view created');
  EXECUTE IMMEDIATE 'CREATE OR REPLACE PUBLIC SYNONYM DEALS_REQUEST_BY_'||user_name||' FOR project_admin.DEALS_REQUEST_BY_'||user_name;
   dbms_output.put_line('deals SYNONYM created');
  EXECUTE IMMEDIATE 'GRANT SELECT ON DEALS_REQUEST_BY_'||user_name||' TO '||user_name;
  dbms_output.put_line('DEALS view granted');
  

--CREATE DEALS_INBOX_ VIEW
    sqlstmt := 'CREATE OR REPLACE VIEW DEALS_INBOX_'||user_name||' AS SELECT
    deals.deals_id,
    TRunc(CREATE_TIME) Date_Requested,
    p1.username,
    listings.title Listing_title,
    l_description Listing_Description,
    DEALS.PRICE Counter_Offer_Price,
    to_char(DEALS.START_DATE,'' DD/MON - HH24:MI'') Counter_Offer_Start_Date,
    to_char(DEALS.END_DATE,'' DD/MON - HH24:MI'') Counter_Offer_End_Date,
    deal_status.status_name Deal_Status
FROM
    DEALS
INNER JOIN people p1 ON p1.user_id=deals.user_id
 INNER JOIN DEAL_STATUS
        USING(STATUS_ID)
INNER JOIN LISTINGS
        USING(LISTING_ID) WHERE LISTINGS.user_id='||uid;
  EXECUTE IMMEDIATE sqlstmt;
   dbms_output.put_line('DEALS_INBOX_ view created');
  EXECUTE IMMEDIATE 'CREATE OR REPLACE PUBLIC SYNONYM DEALS_INBOX_'||user_name||' FOR project_admin.DEALS_INBOX_'||user_name;
   dbms_output.put_line('DEALS_INBOX_ SYNONYM created');
  EXECUTE IMMEDIATE 'GRANT SELECT ON DEALS_INBOX_'||user_name||' TO '||user_name;
  dbms_output.put_line('DEALS_INBOX_ view granted');


--CREATE ORDER VIEW
  sqlstmt :='CREATE OR REPLACE VIEW ORDERS_'||user_name||' AS SELECT
    order_status.order_id Order_ID,
    DEALS_REQUEST_BY_'||user_name||'.Listing_title Listing_title,
    DEALS_REQUEST_BY_'||user_name||'.Listing_Owner Listing_Owner,
    DEALS_REQUEST_BY_'||user_name||'.deal_owner Deal_owner,
    START_CONDITION,
    END_CONDITION,
    CURRENT_STATUS.status Order_Status,
    COMMENTS
FROM
    order_status
INNER JOIN CURRENT_STATUS
        USING(STATUS_ID)
INNER JOIN DEALS_REQUEST_BY_'||user_name||' ON DEALS_REQUEST_BY_'||user_name||'.deals_id=order_status.deals_id
WHERE Listing_Owner=''||user_name||'' OR Deal_owner=''||user_name||''';
  EXECUTE IMMEDIATE sqlstmt;
  dbms_output.put_line('order view created');
  EXECUTE IMMEDIATE 'CREATE OR REPLACE PUBLIC SYNONYM ORDERS_'||user_name||' FOR project_admin.ORDERS_'||user_name;
  dbms_output.put_line('SYNONYM CREATED FOR ORDERS');
  EXECUTE IMMEDIATE 'GRANT SELECT ON ORDERS_'||user_name||' TO '||user_name;
  dbms_output.put_line('order view granted');


--CREATE PEOPLE VIEW
  EXECUTE IMMEDIATE'CREATE OR REPLACE VIEW PEOPLE_'||user_name||' AS SELECT * FROM PEOPLE WHERE USER_ID='||uid;
   dbms_output.put_line('people view created');
  EXECUTE IMMEDIATE 'CREATE OR REPLACE PUBLIC SYNONYM PEOPLE_'||user_name||' FOR project_admin.PEOPLE_'||user_name;
   dbms_output.put_line('PEOPLE SYNONYM created');
  EXECUTE IMMEDIATE 'GRANT SELECT ON PEOPLE_'||user_name||' TO '||user_name;
   dbms_output.put_line('people view granted');
     
--GIVE ACCESS TO ALL ACTIONS
  EXECUTE IMMEDIATE 'GRANT EXECUTE ON ALL_ACTIONS TO '||user_name;
  dbms_output.put_line('all actions granted');


  COMMIT;
END IF;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
        dbms_output.put_line(dbms_utility.format_error_backtrace);
        ROLLBACK;
END SIGNUP;

/

GRANT EXECUTE ON HELP TO NEW_CUSTOMER;
GRANT EXECUTE ON SIGNUP TO NEW_CUSTOMER;

