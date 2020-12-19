SET SERVEROUTPUT ON;

select * from PEOPLE ; --need view
select * from LISTING_CATEGORY ; --PUBLIC
select * from RENTAL_BASIS ;--PUBLIC
select * from ADDRESS_STATE ;--PUBLIC
select * from ADDRESS_COUNTRY ;--PUBLIC
select * from ADDRESS_CITY ;--PUBLIC
select * from USER_ADDRESS ; --need view
select * from LISTINGS; --PUBLIC
select * from EMPLOYEE_ADDRESS;--NO ACCESS
select * from DEAL_STATUS;--PUBLIC
select * from DEALS; --NEED VIEW
select * from DESIGNATION;--NO ACCESS
select * from CURRENT_STATUS;--NEED VIEW
select * from ORDER_STATUS;--NEED VIEW
select * from EMPLOYEE;--NO ACCESS


