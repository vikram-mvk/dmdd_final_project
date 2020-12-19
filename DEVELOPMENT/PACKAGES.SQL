SET SERVEROUTPUT ON;

CREATE OR REPLACE PACKAGE ADDRESS_BOOK
AS
PROCEDURE ADD_NEW(ADDRESSLINE_1 varchar,ADDRESSLINE_2 varchar,ZIPCODE number,CITY varchar);
PROCEDURE DELETE_EXISTING(MY_ADDRESS_ID NUMBER);
END ADDRESS_BOOK;
/
CREATE OR REPLACE PACKAGE BODY ADDRESS_BOOK
AS
PROCEDURE ADD_NEW(ADDRESSLINE_1 varchar,ADDRESSLINE_2 varchar,ZIPCODE number,CITY varchar)
AS
UID number;
CID number;
BEGIN
dbms_output.put_line(USER);
select user_id into UID from people where username=USER;
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
END ADD_NEW;

PROCEDURE DELETE_EXISTING(MY_ADDRESS_ID NUMBER)
AS
UID number;
AID number;
BEGIN
dbms_output.put_line(USER);
select user_id into UID from people where username=USER;
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
END DELETE_EXISTING;

END ADDRESS_BOOK;
/

GRANT EXECUTE ON ADDRESS_BOOK TO DB_CUSTOMERS;
CREATE OR REPLACE PUBLIC SYNONYM ADDRESS_BOOK FOR PROJECT_ADMIN.ADDRESS_BOOK;

/


CREATE OR REPLACE PACKAGE LISTING
AS
PROCEDURE ADD_NEW(LISTING_TITLE varchar,LISTING_DESCRIPTION varchar,LISTING_PRICE varchar,CONTACT_INFO varchar,RENT_BASIS varchar,ITEM_CATEGORY varchar,MY_ADDRESS_ID number,START_TIME timestamp,END_TIME timestamp);
PROCEDURE DELETE_MINE(MY_LISTING_ID NUMBER);
END LISTING;
/
CREATE OR REPLACE PACKAGE BODY LISTING
AS
PROCEDURE ADD_NEW(LISTING_TITLE varchar,LISTING_DESCRIPTION varchar,LISTING_PRICE varchar,CONTACT_INFO varchar,RENT_BASIS varchar,ITEM_CATEGORY varchar,MY_ADDRESS_ID number,START_TIME timestamp,END_TIME timestamp)
AS
UID number;
AID number;
RID number;
CID number;
BEGIN
dbms_output.put_line(USER);
select user_id into UID from people where username=USER;
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
END ADD_NEW;
PROCEDURE DELETE_MINE(MY_LISTING_ID NUMBER)
AS
UID number;
LID number;
BEGIN
dbms_output.put_line(USER);
select user_id into UID from people where username=USER;
dbms_output.put_line(UID);
select LISTING_ID into LID from LISTINGS where USER_ID=UID AND LISTING_ID=MY_LISTING_ID;
DELETE FROM LISTINGS WHERE LISTING_ID=LID AND USER_ID=UID;
COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
        dbms_output.put_line('Please provide the correct values according to the signature given in ALL_ACTIONS..Ensure that the listing ID blongs to you');
        rollback;
        raise;
END DELETE_MINE;
END LISTING;
/

GRANT EXECUTE ON LISTING TO DB_CUSTOMERS;
CREATE OR REPLACE PUBLIC SYNONYM LISTING FOR PROJECT_ADMIN.LISTING;



CREATE OR REPLACE PACKAGE DEAL
AS
PROCEDURE REQUEST(INPUT_LISTING_ID NUMBER,DEAL_PRICE number,START_TIME timestamp,END_TIME timestamp);
PROCEDURE ACCEPT_DEAL(INPUT_DEAL_ID NUMBER);
END DEAL;
/
CREATE OR REPLACE PACKAGE BODY DEAL
AS
PROCEDURE REQUEST(INPUT_LISTING_ID NUMBER,DEAL_PRICE number,START_TIME timestamp,END_TIME timestamp)
AS
UID number;
LID number;
BEGIN
dbms_output.put_line(USER);
select user_id into UID from people where username=USER;
dbms_output.put_line(UID);
INSERT INTO DEALS(USER_ID,LISTING_ID,PRICE,STATUS_ID,START_DATE,END_DATE) VALUES(UID,INPUT_LISTING_ID,DEAL_PRICE,1,START_TIME,END_TIME);
COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
        dbms_output.put_line('Please provide the correct values according to the signature given in ALL_ACTIONS..Ensure that the listing ID is valid');
        rollback;
        raise;
END REQUEST;
PROCEDURE ACCEPT_DEAL(INPUT_DEAL_ID NUMBER)
AS
UID number;
DID number;
BEGIN
dbms_output.put_line(USER);
select user_id into UID from people where username=USER;
dbms_output.put_line(UID);
UPDATE DEALS SET STATUS_ID=2 WHERE DEALS_ID=INPUT_DEAL_ID AND LISTING_ID IN (SELECT LISTING_ID FROM LISTINGS WHERE USER_ID = UID);
COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(SQLERRM);
        dbms_output.put_line('Please provide the correct values according to the signature given in ALL_ACTIONS..Ensure that the address ID blongs to you');
        rollback;
        raise;
END ACCEPT_DEAL;
END DEAL;
/

GRANT EXECUTE ON DEAL TO DB_CUSTOMERS;
CREATE OR REPLACE PUBLIC SYNONYM DEAL FOR PROJECT_ADMIN.DEAL;

