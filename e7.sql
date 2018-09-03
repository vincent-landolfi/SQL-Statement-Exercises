create table _country like world.country;
insert into _country select * from world.country;
insert into _country(Name, Code, Population, Continent) values ("Nowhereland","NHD",3,"Antarctica");
update _country
set name = "Nowhere land"
where code = "NHD";
create view e7View as
select Code, Name, Continent, Population, SurfaceArea, IndepYear, GovernmentForm
from _country;
delete from e7View where Code = "NHD";
select * from e7View where GovernmentForm = "Republic";
select count(GovernmentForm) from e7View where GovernmentForm = "Republic";
select count(GovernmentForm), GovernmentForm from e7View group by GovernmentForm;
select count(Code), GovernmentForm from e7View group by GovernmentForm order by count(Code) desc;
select count(GovernmentForm), GovernmentForm from e7View group by GovernmentForm having count(Code) > 2 order by count(Code) desc;
select count(GovernmentForm), Continent, GovernmentForm from e7View group by GovernmentForm, Continent;
select * from e7View where SurfaceArea = (select max(SurfaceArea) from e7View);
select avg(Population) from e7View where GovernmentForm = "Monarchy";
select avg(Population), Continent from e7View where GovernmentForm = "Monarchy" group by Continent;
select * from e7View where GovernmentForm like "%Republic" order by GovernmentForm, Name;
select * from e7View where GovernmentForm not like "%Republic" and IndepYear > 1800;