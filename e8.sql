-- 1 --
use world;
select distinct Name, Language
from country, countrylanguage
where country.code = countrylanguage.CountryCode;

-- 2 --
select Name
from country, countrylanguage
where Language = 'English' and IsOfficial = 'T'
union
select Name
from country, countrylanguage
where Language = 'French' and IsOfficial = 'T';

-- 3 --
select count(distinct c.Name) as CountryCount
from country c
inner join countrylanguage cl on c.Code = cl.CountryCode
where cl.Language = 'English' and cl.IsOfficial = 'T';

-- 4a --
select Language
from countrylanguage
where CountryCode in
	(select Code from Country where Code = 'USA');

-- 4b --
select Language
from countrylanguage
where exists
	(select * from country where countrylanguage.CountryCode = 'USA');

-- 5 --
select name,
	case
    when Population > (select avg(Population) from country) then 'more'
    when Population < (select avg(Population) from country) then 'less'
    end
from country;

-- 6 --
select name
from country
where exists
	(select distinct CountryCode 
    from city where city.CountryCode = country.Code 
    having count(city.CountryCode) > 50);

-- 7 --
create view southAmericaCountries as
select * from country where Continent = 'South America';

create view federalRepublicCountries as
select * from country where GovernmentForm = 'Federal Republic';

drop view southAmericaCountries;
drop view federalRepublicCountries;

select *
from southAmericaCountries
left outer join federalRepublicCountries 
on southAmericaCountries.GovernmentForm = federalRepublicCountries.GovernmentForm;

-- 8 --
select *
from southAmericaCountries
left outer join federalRepublicCountries 
on southAmericaCountries.Name = federalRepublicCountries.Name;

-- 9 --
select Language, count(Language) as LanguageOccurrence
from countrylanguage
group by Language
order by LanguageOccurrence desc
limit 1;