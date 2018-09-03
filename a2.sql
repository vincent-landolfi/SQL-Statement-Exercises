create table Facility(
	FacilityID char(2) not null,
    Type varchar(45),
    constraint facility_pk primary key (FacilityID)
);

create table MailingList(
	Name varchar(15) not null,
    email mediumblob not null,
    constraint name_pk primary key (Name)
);

create table ReminderText(
	ReminderTextID char(4) not null,
    text tinyblob not null,
    constraint reminder_pk primary key (ReminderTextID)
);

create table Certificate(
	CertificateID char(10) not null,
    Title varchar(45) not null,
    text tinyblob not null,
    constraint cert_pk primary key (CertificateID)
);

create table Event(
	EventID char(5) not null,
    Description varchar(45) not null,
    Date date not null,
    Time time(5),
    Reminder tinyint,
    Type char(1),
    constraint event2_pk primary key (EventID)
);

create table PublicEvent(
	EventID char(5) not null,
    FinishDate date not null,
    FinishTime time(5) not null,
    CertificateID char(10) not null,
    price varchar(100),
    constraint eventpub_fk foreign key (EventID) references Event(EventID),
    constraint cert_fk foreign key (CertificateID) references Certificate(CertificateID),
    constraint event_pk primary key (EventID)
);

create table EventFacility(
	Facility_ID char(2) not null,
    EventID char(5) not null,
    constraint fac_fk foreign key (Facility_ID) references Facility(FacilityID),
    constraint event_fk foreign key (EventID) references PublicEvent(EventID),
    constraint event_fac_pk primary key (Facility_ID, EventID)
);

create table Reminder(
	ReminderID char(8) not null,
    date date not null,
    time time(5) not null,
    text varchar(45),
    Event_EventID char(3) not null,
    ReminderTextID char(5),
    constraint reminder2_pk primary key (ReminderID),
    constraint event2_fk foreign key (Event_EventID) references Event(EventID),
    constraint reminder_text_fk foreign key (ReminderTextID) references ReminderText(ReminderTextID)
);

create table MailingListReminder(
	ReminderID char(8) not null,
    MailingList_Name varchar(15) not null,
    constraint reminder_fk foreign key (ReminderID) references Reminder(ReminderID),
    constraint mail_list_fk foreign key (MailingList_Name) references MailingList(Name),
    constraint mail_list_pk primary key (ReminderID, MailingList_Name)
);

create table User(
	Username varchar(10) not null,
    name varchar(30) not null,
    Surname varchar(30) not null,
    Email varchar(30) not null,
    Cell int(10),
    constraint username_pk primary key (Username)
);

create table UserCertificate(
	CertificateID char(10) not null,
    Username varchar(10) not null,
    DateAwarded date,
    constraint cert_id_fk foreign key (CertificateID) references Certificate(CertificateID),
    constraint cert_un_fk foreign key (Username) references User(Username),
    constraint user_cert primary key (CertificateID, Username)
);

create table User_Reminder(
	ReminderID char(8) not null,
    Username varchar(10) not null,
    DateTime datetime not null,
    constraint rem_id_fk foreign key (ReminderID) references Reminder(ReminderID),
    constraint un_fk foreign key (Username) references User(Username),
    constraint user_rem_pk primary key (ReminderID, Username, DateTime)
);

create table UserEvent(
	User_Username varchar(10) not null,
    EventID char(5) not null,
    constraint user_un_fk foreign key (User_Username) references User(Username),
    constraint event4_id_fk foreign key (EventID) references Event(EventID),
    constraint user_event_pk primary key (User_Username, EventID)
);

create table CardText(
	ID char(3) not null,
    Text tinyblob not null,
    constraint c_text_pk primary key (ID)
);

create table Picture(
	ID char(6) not null,
    URL varchar(100) not null,
    constraint c_picture_pk primary key (ID)
);

create table CardTemplate(
	ID char(3) not null,
    URL varchar(100) not null,
    constraint c_template_pk primary key (ID)
);

create table Card(
	ID char(3) not null,
    Picture_ID char(6) not null,
    CardTemplate_ID char(3) not null,
    CardText_ID char(3) not null,
    User_Username varchar(10) not null,
    constraint pic_fk foreign key (Picture_ID) references Picture(ID),
    constraint template_fk foreign key (CardTemplate_ID) references CardTemplate(ID),
    constraint cardText_fk foreign key (CardText_ID) references CardText(ID),
    constraint card_un_fk foreign key (User_Username) references User(Username)
);

-- REPORT 1 --
select u.name as FirstName, u.Surname, u.Email, convert(rt.text using utf8) as Text from User u
inner join User_Reminder ur on u.Username = ur.Username
inner join Reminder r on ur.ReminderID = r.ReminderID
inner join ReminderText rt on r.ReminderTextID = rt.ReminderTextID
inner join Event e on r.Event_EventID = e.EventID
inner join UserEvent ue on e.EventID = ue.EventID
where ur.DateTime = CURDATE()
order by u.name;

-- REPORT 2 --
create view awarenessUsers as
select u.Surname, u.name from User u
inner join User_Reminder ur on u.Username = ur.Username
inner join Reminder r on ur.ReminderID = r.ReminderID
inner join Event e on r.Event_EventID = e.EventID
inner join PublicEvent pe on e.EventID = pe.EventID
where e.Description = "health awareness"
order by u.Surname, u.name;

select * from awarenessUsers;

-- REPORT 3 --

create view PictureIDsAndURLs as
select u.name, u.Surname, p.ID as pid, p.URL as purl from User u
left join Card c on u.Username = c.User_Username
left join Picture p on c.Picture_ID = p.ID
group by pid, purl, u.name, u.Surname
order by pid;

select distinct count(pid) as NumUsed, purl as URL
	from (
	select * from PictureIDsAndURLs
	) as T
group by pid
order by URL;

-- REPORT 4 --
select u.name, u.Surname, count(u.Username) as NumCertificates from User u
inner join UserCertificate uc on u.Username = uc.Username
group by u.Username having count(u.Username) > 3
order by count(u.Username), u.Username;

-- REPORT 5 --
select count(*)*100 as PotentialEarnings from awarenessUsers;

-- REPORT 6 --
create view JohnSmithsTexts as
select c.CardText_ID from User u
inner join Card c on u.Username = c.User_Username
where u.name = "John" and u.Surname = "Smith";

select u.name, u.Surname from User u
inner join Card c on u.Username = c.User_Username
where c.CardText_ID in
(select * from JohnSmithsTexts)
and not (u.name = "John" and u.Surname = "Smith");

-- REPORT 7 --
create view facilities as
select e.Description as Description, f.FacilityID as FacilityID, 
e.EventID as event1, pe.EventID as PubID, f.Type as type from Event e
inner join PublicEvent pe on e.EventID = pe.EventID
inner join EventFacility ef on pe.EventID = ef.EventID
inner join Facility f on ef.Facility_ID = f.FacilityID;

create view facilities2 as
select f2.FacilityID as FacilityID2, e2.EventID as event2 from Event e2
inner join PublicEvent pe2 on e2.EventID = pe2.EventID
inner join EventFacility ef2 on pe2.EventID = ef2.EventID
inner join Facility f2 on ef2.Facility_ID = f2.FacilityID;

select Description, FacilityID, type from facilities
	where event1 in(
		select event1 from(
		select event1, event2, count(*) as sameFacilitiesCount from
			(select FacilityID as fac, event1 from facilities) t1
			inner join
			(select FacilityID2 as fac, event2 from facilities2) t2
			on t1.fac = t2.fac
			where event2 <> event1
			group by event1,event2
			having sameFacilitiesCount = (select count(*) from facilities where event1 = event2)
			and sameFacilitiesCount = (select count(*) from facilities2 where event2 = event1)
		) as T
	group by Description
	order by type, Description
);

-- REPORT 8 --
select p.URL, u.name, u.Surname from User u
inner join Card c on u.Username = c.User_Username
inner join Picture p on c.Picture_ID = p.ID
group by p.ID, p.URL, u.name, u.Surname
order by p.ID, p.URL, u.name, u.Surname;

-- REPORT 9 --
select c.CardTemplate_ID, ct.URL as TemplateURL, c.Picture_ID, p.URL as PicURL, c.CardText_ID, convert(ctx.Text using utf8) as CardText, count(*) as CombinationOccurrences from Card c
left join CardTemplate ct on c.CardTemplate_ID = ct.ID
left join Picture p on c.Picture_ID = p.ID
left join CardText ctx on c.CardText_ID = ctx.ID
group by CardTemplate_ID, Picture_ID, CardText_ID
order by CombinationOccurrences desc, CardText_ID, Picture_ID, CardTemplate_ID;

-- REPORT 10 --
create view RemindersSentEachYear as
select count(ReminderID) as RemCount, year(date) as Yr from Reminder
group by year(date)
order by year(date) desc;

select RemCount/365 as Avg, Yr from RemindersSentEachYear
order by Yr desc;

/*
Old code, annual average in each year,
Rakin said to do daily average on piazza

select year(date) as Year,
	(select avg(RemCount) from
		(
        select * from RemindersSentEachYear
		) as T
	where Yr <= Year
	) as AverageRemindersSentPerYear
from Reminder
group by Year
order by Year desc;
*/