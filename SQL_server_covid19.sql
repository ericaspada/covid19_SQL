CREATE DATABASE COVID19;
use COVID19;

-- used import wizard to load csv file into a new database called COVID19_1
-- needed to change the date format in the csv to YYYY-MM-DD
select * from COVID19_1;

-- Calculate daily data and add a week attribute
SELECT
    m1.Id,
    m1.Province_State,
    m1.Country_Region,
    m1.Date,
    datepart(week, Date) as Week,
    m1.ConfirmedCases,
    m1.Fatalities,
        COALESCE(m1.ConfirmedCases - (SELECT m2.ConfirmedCases 
                     FROM COVID19_1 m2
                     WHERE m2.Id = m1.Id - 1), 0) AS confirmed_daily,
        COALESCE(m1.Fatalities - (SELECT m2.Fatalities
                     FROM COVID19_1 m2
                     WHERE m2.Id = m1.Id - 1), 0) AS fatalities_daily
into covid19daily
FROM COVID19_1 m1;

select * from covid19daily;

-- Aggregate "ConfirmedDaily" and "FatalitiesDaily"  by "Country_Region and WeekOfYear(Date)" and copy the aggregated data into a new table
select
	Country_Region,
    Week as week_of_year,
	sum(confirmed_daily) as confirmed_cases,
    sum(fatalities_daily) as fatalities
into COVID_19_aggr
from covid19daily
group by Country_Region, Week
order by Country_Region, Week;

-- Experiment with group by and grouping sets operators
select
	Country_Region,
    week_of_year,
    sum(confirmed_cases) as Cases,
    sum(fatalities) as Fatalities
from COVID_19_aggr
group by cube (Country_Region, week_of_year);

select
	Country_Region,
    week_of_year,
    sum(confirmed_cases) as Cases,
    sum(fatalities) as Fatalities
from COVID_19_aggr
group by rollup (Country_Region, week_of_year);

select
	Country_Region,
    week_of_year,
    sum(confirmed_cases) as Cases,
    sum(fatalities) as Fatalities
from COVID_19_aggr
group by grouping sets ((Country_Region), (week_of_year))
order by week_of_year desc;

-- Rank countries by confirmed cases
select
	Country_Region,
	sum(confirmed_cases) as total_cases,
    rank() over (order by sum(confirmed_cases) desc) as rank_cases,
    dense_rank() over (order by sum(confirmed_cases) desc) as dense_rank_cases,
    round(percent_rank() over (order by sum(confirmed_cases) desc),3) as perc_rank_cases,
    round(cume_dist() over (order by sum(confirmed_cases) desc),3) as cum_rank_cases
from COVID_19_aggr
group by Country_Region;

-- select * from COVID_19_aggr;

select top 10
	country_region,
    sum(confirmed_cases) as total_cases,
    sum(fatalities) as total_fatlities
into top10_cases
from COVID_19_aggr
group by country_region
order by total_cases desc;

select * from top10_cases;

select * from COVID_19_aggr
inner join top10_cases on top10_cases.country_region = COVID_19_aggr.Country_Region;

select top 10
	country_region,
    sum(confirmed_cases) as total_cases,
    sum(fatalities) as total_fatalities
into top10_fatalities
from COVID_19_aggr
group by country_region
order by total_fatalities desc;

-- Create a pivot table for total confirmed cases that has dimensions week & country_region (only the top 10 countries)
SELECT  
    country_region, [4] as Week4, [5] as Week5, [6] as Week6, [7] as Week7, [8] as Week8,
    [9] as Week9, [10] as Week10, [11] as Week11, [12] as Week12, [13] as Week13, [14] as Week14
FROM  
    (select top10_cases.country_region, week_of_year, confirmed_cases from COVID_19_aggr
    inner join top10_cases on top10_cases.country_region = COVID_19_aggr.Country_Region) as joined
PIVOT
(  
   sum(confirmed_cases)
FOR   
week_of_year 
    IN ([4],[5], [6], [7], [8], [9], [10], [11], [12], [13], [14])
)
AS pivot1;

-- Create a pivot table for total fatalities that has dimensions week & country_region (only the top 10 countries)
SELECT  
    country_region, [4] as Week4, [5] as Week5, [6] as Week6, [7] as Week7, [8] as Week8,
    [9] as Week9, [10] as Week10, [11] as Week11, [12] as Week12, [13] as Week13, [14] as Week14
FROM  
    (select top10_fatalities.country_region, week_of_year, total_fatalities from COVID_19_aggr
    inner join top10_fatalities on top10_fatalities.country_region = COVID_19_aggr.Country_Region) as joined2
PIVOT
(  
   sum(total_fatalities)
FOR   
week_of_year 
    IN ([4],[5], [6], [7], [8], [9], [10], [11], [12], [13], [14])
)
AS pivot2;