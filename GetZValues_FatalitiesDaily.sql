CREATE PROCEDURE `GetZValues_FatalitiesDaily`()
BEGIN
create temporary table zvalues as
select
	c.*,
    round(((c.fatalities_daily - c.mean)/c.sd),4) as z
from
(select
	Province_State,
    country_region,
    date,
    confirmed_cases,
    fatalities_daily,
    avg(fatalities_daily) over(partition by country_region) as mean,
    round(std(fatalities_daily) over(partition by country_region),4) as sd
from covid19daily) as c
where confirmed_cases>0 and sd>0.0000;
END
-- this only works in version 8.0