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



--DELETE USERS
--DELETE VIEWS
--DELETE SYNONYMS
--DELETE PROCEDURES

