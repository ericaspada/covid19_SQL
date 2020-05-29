create schema COVID19;
use COVID19;

create table covid19(
id int not null,
province_state varchar(200),
country_region varchar(200) not null,
date date not null,
confirmed_cases int not null,
fatalities int not null,
primary key(id)
);

use COVID19;
load data local infile '/home/ec2-user/COVID19/COVID-19.csv'
into table covid19
columns terminated by ',';
-- this does not work (loading local data is disabled error), need to load through CL for now

CREATE TABLE covid19daily as
SELECT 
  m1.id,
  m1.province_state,
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

-- delete from covid19 where id=0;
select * from covid19daily;