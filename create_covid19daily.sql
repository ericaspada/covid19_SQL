use COVID19;
select * from covid19
limit 25;

-- Create the daily data table
CREATE TABLE covid19daily as
SELECT 
  m1.id,
  m1.Province_State,
  m1.country_region,
  m1.date,
  weekofyear(date) as week,
  m1.confirmed_cases,
  m1.fatalities,
  COALESCE(m1.confirmed_cases - (SELECT m2.confirmed_cases 
                     FROM covid19 m2
                     WHERE m2.id = m1.id - 1), 0) AS confirmed_daily,
  COALESCE(m1.fatalities - (SELECT m2.fatalities
                     FROM covid19 m2
                     WHERE m2.id = m1.id - 1), 0) AS fatalities_daily
FROM covid19 m1;

select * from covid19daily
limit 50;
-- there are some negative values, we will leave them in for now



