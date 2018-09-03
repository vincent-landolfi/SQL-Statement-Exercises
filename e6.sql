create table Professors(
	ProfessorIdentificationCode varchar(16) not null,
    Name varchar(20) check (length(Name) >= 7 and length(Name) <= 20),
    Address varchar(25) check (length(Address) >= 10 and length(Address) <= 25),
    Phone varchar(12) check (length(Phone) = 12),
    constraint Professor_pk primary key (ProfessorIdentificationCode)
);
create table Books(
	ISBN varchar(13) not null check (length(ISBN) = 13),
    PublicationDate date not null,
    BookType varchar(25) check (BookType in ("scientific", "fiction", "novel")),
    constraint book_pk primary key (ISBN, PublicationDate)
);
create table Publishing(
	ProfessorIdentificationCode varchar(16) not null check (length(ProfessorIdentificationCode) = 16),
    ISBN varchar(13) not null check (length(ISBN) = 13),
    Price Decimal(20,2),
    constraint publish_pk primary key (ProfessorIdentificationCode, ISBN),
    constraint pin_fk foreign key (ProfessorIdentificationCode) references Professors(ProfessorIdentificationCode),
    constraint isbn_fk foreign key (ISBN) references Books(ISBN)
);
alter table Professors rename to Professor;
alter table Books rename to Book;
alter table Professor add unique(Phone);
alter table Book
	drop primary key,
    add primary key (ISBN);
alter table Professor modify Phone bigint(13);
alter table Publishing
	drop primary key,
    add primary key (ProfessorIdentificationCode, ISBN);
alter table Publishing
	drop foreign key isbn_fk,
    add constraint isbn_restrict_fk
    foreign key (ISBN)
    references Book(ISBN) on delete restrict;
alter table Publishing
	drop foreign key pin_fk,
    add constraint pin_restrict_fk
    foreign key (ProfessorIdentificationCode)
    references Professor(ProfessorIdentificationCode) on delete restrict;
alter table Professor add index(Name);
alter table Book drop BookType;
alter table Publishing
	drop foreign key isbn_restrict_fk,
    drop foreign key pin_restrict_fk,
    drop primary key,
    add primary key (ProfessorIdentificationCode, ISBN);
insert into Professor (ProfessorIdentificationCode,Name,Address,Phone) values (1234567890987654,"Vincent L","123 UTSC Drive",1234567876543);
insert into Professor (ProfessorIdentificationCode,Name,Address,Phone) values (2987654321234567,"Jeffrey J","432 UTM Avenue",4163333333333);
insert into Book (ISBN,PublicationDate) values (1234567890987,"2012-03-03");
insert into Book (ISBN,PublicationDate) values (2987654321234,"2017-09-12");
insert into Publishing (ProfessorIdentificationCode,ISBN,Price) values (2987654321234567,2987654321234,3.33);
insert into Publishing (ProfessorIdentificationCode,ISBN,Price) values (1234567890987654,1234567890987,6.99);
drop table Professor