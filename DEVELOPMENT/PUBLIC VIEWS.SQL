


Create Materialized view ALL_LISTINGS
      refresh complete start with (sysdate) next  (sysdate+1/1440) with rowid
   AS
SELECT
    listings.listing_id,
    TITLE,
    L_DESCRIPTION Description,
    TRunc(DATE_POSTED) Date_Posted,
    CONTACT_DETAILS,
    PRICE,
    to_char(START_DATE,' DD/MON - HH24:MI') Start_Date,
    to_char(END_DATE,' DD/MON - HH24:MI') End_Date,
    people.username,
    category_name,
    user_address.address_line_1 ,
    user_address.address_line_2,
    user_address.zip_code,
    address_city.city_name,
    address_state.state_name,
    address_country.country_name
FROM
    LISTINGS
INNER JOIN LISTING_CATEGORY
        USING(CATEGORY_ID)
INNER JOIN people
        USING(user_id)
INNER JOIN user_address
        USING(ADDRESS_ID)
INNER JOIN address_city
        USING(city_id)
INNER JOIN address_state
        USING(state_id)
INNER JOIN address_country
        USING(country_id);
/             
GRANT SELECT ON ALL_LISTINGS TO DB_CUSTOMERS;
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_LISTINGS FOR PROECT_ADMIN.ALL_LISTINGS;

