set serveroutput on;
begin
project_admin.all_actions;
end;


select * from people_vikram00;
select * from address_vikram00;
select * from ORDER_vikram00;

begin
add_new_address('my THIRD home','my THIRD house',12345,'BOSTON');
end;

begin
REMOVE_address(4);
end;

SELECT * FROM PROJECT_ADMIN.LISTING_CATEGORY;