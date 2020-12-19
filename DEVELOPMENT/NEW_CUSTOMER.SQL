SET SERVEROUTPUT ON;
--Ask help from Project admin
BEGIN
project_admin.help;
END;

--Ask Project admin to sign you up
BEGIN
PROJECT_ADMIN.signup('vikram01','vikram01','hello','vikram','m',6172598073);
END;
