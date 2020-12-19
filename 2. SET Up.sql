
--HELP TO NEW_CUSTOMERS
CREATE OR REPLACE PROCEDURE HELP
AS

BEGIN
        dbms_output.put_line('START USING THIS APPLICATION BY SIGNING UP !');
        dbms_output.put_line('EXECUTE THE BELOW PROCEDURE WITH THE SPECIFIED PARAMETERS IN AN ANONYMOUS PL/SQL BLOCK');
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
        dbms_output.put_line('6. DELETE AN ADDRESS FROM YOUR ADDRESS_BOOK USING REMOVE_ADDRESS(MY_ADDRESS_ID) ');
        dbms_output.put_line('');
        
        dbms_output.put_line('LISTING RELATED ACTIONS');
        dbms_output.put_line('1. VIEW OUR RENTAL BASIS THAT OUR SERVICE PROVIDES USING SELECT * FROM RENTAL_BASIS ');
        dbms_output.put_line('2. VIEW THE CATEGORIES IN WHICH WE OFFER RENTAL SERVICES USING SELECT * FROM LISTING_CATEGORY');
        dbms_output.put_line('3. ADD A NEW LISTING USING ADD_LISTING(TITLE,DESCRIPTION,CATEGORY,RENTAL_BASIS,CONTACT_DETAILS,PRICE,ADDRESS_ID');
        dbms_output.put_line('2. DELETE AN ADDRESS FROM YOUR ADDRESS_BOOK USING REMOVE_ADDRESS(USER_NAME,PASS_WORD) ');
        dbms_output.put_line('3. DELETE AN ADDRESS FROM YOUR ADDRESS_BOOK USING DELETE_ADDRESS(USER_NAME,PASS_WORD) ');

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
SELECT count(*) into nCount FROM all_users where username = user_name;
IF(nCount > 0)
THEN
  dbms_output.put_line('User already exists');
ELSE
  EXECUTE IMMEDIATE'alter session set "_ORACLE_SCRIPT"=true';  
  INSERT INTO PEOPLE(USERNAME, EMAIL,PASS_WORD, FIRST_NAME, LAST_NAME, PHONE_NUMBER) VALUES(UPPER(user_name),UPPER(email),pass_word,UPPER(first_name),UPPER(last_name),phone_number);
  EXECUTE IMMEDIATE'CREATE USER '||user_name||' IDENTIFIED BY '||pass_word;
  EXECUTE IMMEDIATE'GRANT DB_CUSTOMERS TO '||user_name;
  COMMIT;
  SELECT USER_ID INTO uid FROM PEOPLE WHERE USERNAME=user_name;
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
    sqlstmt := 'CREATE OR REPLACE VIEW DEALS_'||user_name||' AS
SELECT
    deals.deals_id,
    TRunc(CREATE_TIME) Date_Requested,
    p1.username,
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
  EXECUTE IMMEDIATE 'CREATE OR REPLACE PUBLIC SYNONYM DEALS_'||user_name||' FOR project_admin.DEALS_'||user_name;
   dbms_output.put_line('deals SYNONYM created');
  EXECUTE IMMEDIATE 'GRANT SELECT ON DEALS_'||user_name||' TO '||user_name;
  dbms_output.put_line('DEALS view granted');


--CREATE ORDER VIEW
  sqlstmt :='CREATE OR REPLACE VIEW ORDERS_'||user_name||' AS SELECT
    order_status.order_id Order_ID,
    Deal_View.Listing_title Listing_title,
    Deal_View.Listing_Owner Listing_Owner,
    Deal_View.username Deal_Owner,
    START_CONDITION,
    END_CONDITION,
    CURRENT_STATUS.status Order_Status,
    COMMENTS
FROM
    order_status
INNER JOIN CURRENT_STATUS
        USING(STATUS_ID)
INNER JOIN Deal_View ON deal_view.deals_id=order_status.deals_id AND deal_view.listing_owner='||uid||' OR deal_view.username='||uid;
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
END;

/

GRANT EXECUTE ON HELP TO NEW_CUSTOMER;
GRANT EXECUTE ON SIGNUP TO NEW_CUSTOMER;

--ADD NEW ADDRESS
CREATE OR REPLACE PROCEDURE ADD_NEW_ADDRESS(ADDRESSLINE_1 varchar,ADDRESSLINE_2 varchar,ZIPCODE number,CITY varchar)
AS
UID number;
CID number;
BEGIN
dbms_output.put_line(USER);
select user_id into UID from people where username=LOWER(USER);
dbms_output.put_line(UID);
select city_id into CID from ADDRESS_CITY where CITY_NAME=UPPER(CITY);
dbms_output.put_line(CID);
INSERT INTO USER_ADDRESS(USER_ID,ADDRESS_LINE_1,ADDRESS_LINE_2,ZIP_CODE,CITY_ID) VALUES(UID,ADDRESSLINE_1,ADDRESSLINE_2,ZIPCODE,CID);
COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
        dbms_output.put_line('Please provide the correct values according to the signature given in ALL_ACTIONS..Ensure the available locations from SELECT * FROM AVAILABLE_LOCATIONS');
        rollback;
        raise;
END;
/

GRANT EXECUTE ON ADD_NEW_ADDRESS TO DB_CUSTOMERS;
CREATE OR REPLACE PUBLIC SYNONYM ADD_NEW_ADDRESS FOR PROJECT_ADMIN.ADD_NEW_ADDRESS;


--REMOVE ADDRESS
CREATE OR REPLACE PROCEDURE REMOVE_ADDRESS(MY_ADDRESS_ID NUMBER)
AS
UID number;
AID number;
BEGIN
dbms_output.put_line(USER);
select user_id into UID from people where username=LOWER(USER);
dbms_output.put_line(UID);
select ADDRESS_ID into AID from USER_ADDRESS where ADDRESS_ID=MY_ADDRESS_ID AND USER_ID=UID;
dbms_output.put_line(AID);
DELETE FROM USER_ADDRESS WHERE ADDRESS_ID=AID;
COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
        dbms_output.put_line('Please provide the correct values according to the signature given in ALL_ACTIONS..Ensure that the address ID blongs to you');
        rollback;
        raise;
END;
/

GRANT EXECUTE ON REMOVE_ADDRESS TO DB_CUSTOMERS;
CREATE OR REPLACE PUBLIC SYNONYM REMOVE_ADDRESS FOR PROJECT_ADMIN.REMOVE_ADDRESS;

--ADD NEW LISTING
CREATE OR REPLACE PROCEDURE ADD_NEW_LISTING(LISTING_TITLE varchar,LISTING_DESCRIPTION varchar,LISTING_PRICE varchar,CONTACT_INFO varchar,RENT_BASIS varchar,ITEM_CATEGORY varchar,MY_ADDRESS_ID number,START_TIME timestamp,END_TIME timestamp)
AS
UID number;
AID number;
RID number;
CID number;
BEGIN
dbms_output.put_line(USER);
select user_id into UID from people where username=LOWER(USER);
dbms_output.put_line(UID);
select ADDRESS_ID into AID from USER_ADDRESS where ADDRESS_ID=MY_ADDRESS_ID AND USER_ID=UID;
dbms_output.put_line(AID);
select BASIS_ID into RID from RENTAL_BASIS where BASIS_NAME=UPPER(RENT_BASIS);
dbms_output.put_line(RID);
select CATEGORY_ID into CID from LISTING_CATEGORY where CATEGORY_NAME=UPPER(ITEM_CATEGORY);
dbms_output.put_line(CID);

INSERT INTO LISTINGS(TITLE,L_DESCRIPTION,CONTACT_DETAILS,PRICE,RENTAL_BASIS_ID,CATEGORY_ID,USER_ID,ADDRESS_ID,START_DATE,END_DATE)
VALUES(LISTING_TITLE,LISTING_DESCRIPTION,CONTACT_INFO,LISTING_PRICE,RID,CID,UID,AID,START_TIME,END_TIME);
COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
        dbms_output.put_line('Please provide the correct values according to the signature given in ALL_ACTIONS..Ensure that the address ID blongs to you');
        rollback;
        raise;
END;
/

GRANT EXECUTE ON ADD_NEW_LISTING TO DB_CUSTOMERS;
CREATE OR REPLACE PUBLIC SYNONYM ADD_NEW_LISTING FOR PROJECT_ADMIN.ADD_NEW_LISTING;


--REMOVE LISTING
CREATE OR REPLACE PROCEDURE REMOVE_LISTING(MY_LISTING_ID NUMBER)
AS
UID number;
LID number;
BEGIN
dbms_output.put_line(USER);
select user_id into UID from people where username=LOWER(USER);
dbms_output.put_line(UID);
select LISTING_ID into LID from LISTINGS where USER_ID=UID AND LISTING_ID=LID;
dbms_output.put_line(LID);
DELETE FROM LISTINGS WHERE LISTING_ID=LID;
COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
        dbms_output.put_line('Please provide the correct values according to the signature given in ALL_ACTIONS..Ensure that the listing ID blongs to you');
        rollback;
        raise;
END;
/

GRANT EXECUTE ON REMOVE_LISTING TO DB_CUSTOMERS;
CREATE OR REPLACE PUBLIC SYNONYM REMOVE_LISTING FOR PROJECT_ADMIN.REMOVE_LISTING;


--REQUEST A DEAL
    CREATE OR REPLACE PROCEDURE REQUEST_A_DEAL(INPUT_LISTING_ID NUMBER)
AS
UID number;
AID number;
BEGIN
dbms_output.put_line(USER);
select user_id into UID from people where username=LOWER(USER);
dbms_output.put_line(UID);
select ADDRESS_ID into AID from USER_ADDRESS where ADDRESS_ID=MY_ADDRESS_ID AND USER_ID=UID;
dbms_output.put_line(AID);
DELETE FROM USER_ADDRESS WHERE ADDRESS_ID=AID;
COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
        dbms_output.put_line('Please provide the correct values according to the signature given in ALL_ACTIONS..Ensure that the address ID blongs to you');
        rollback;
        raise;
END;
/

GRANT EXECUTE ON REMOVE_ADDRESS TO DB_CUSTOMERS;
CREATE OR REPLACE PUBLIC SYNONYM REMOVE_ADDRESS FOR PROJECT_ADMIN.REMOVE_ADDRESS;


--ACCEPT A DEAL
CREATE OR REPLACE PROCEDURE ACCEPT_DEAL(INPUT_DEAL_ID NUMBER)
AS
UID number;
DID number;
BEGIN
dbms_output.put_line(USER);
select user_id into UID from people where username=LOWER(USER);
dbms_output.put_line(UID);
UPDATE DEALS SET STATUS_ID=2 WHERE DEAL_ID=INPUT_DEAL_ID AND LISTING_ID IN (SELECT LISTING_ID FROM LISTINGS WHERE USER_ID = UID);
COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
        dbms_output.put_line('Please provide the correct values according to the signature given in ALL_ACTIONS..Ensure that the address ID blongs to you');
        rollback;
        raise;
END;
/


GRANT EXECUTE ON REMOVE_ADDRESS TO DB_CUSTOMERS;
CREATE OR REPLACE PUBLIC SYNONYM REMOVE_ADDRESS FOR PROJECT_ADMIN.REMOVE_ADDRESS;


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
/