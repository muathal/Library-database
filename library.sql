//// Table Creation /////
create table lib_dept(
    dept_id number (1),
    dept_name varchar2(20),
    mgr_id number(6),
constraint pk_lib_dept_id primary key(dept_id)
);
create table rank_salary(
    rank_level  number(1),
    rank_salary number(5),
    constraint pk_rank_level primary key(rank_level)
);
create table employee (
    emp_id number(6),
    fname varchar2(10),
    lname   varchar(10),
    sex     varchar2(1),
    phone_number    number(11),
    rank_emp    number(1),
    email   varchar2(25),
    birth_date varchar(11),
    superviosr number(6),
    dept_no number(1),
    constraint pk_employ_id primary key(emp_id),
    constraint fk_rank  foreign key(rank_emp) references rank_salary(rank_level)
);
create table member_(
    mem_id number(6),
    fname   varchar2(10),
    lname   varchar2(10),
    birth_date  varchar2(11),
    status  varchar2(1),
    phone_number    number(15),
    constraint pk_mem_id primary key(mem_id)
);
create table author(
    Auth_id number(6),
    fanem   varchar2(10),
    lname   varchar2(10),
    date_of_bith    varchar2(11),
    date_of_death   varchar2(11),
    brith_location varchar(10),
    constraint pk_auth_id primary key(Auth_id)
);
create table book(
    book_id number(6),
    bname   varchar2(25),
    language varchar2(2),
    auth_id number(6),
    constraint pk_book_id primary key(book_id)
);
create table publisher (
    Pub_id  number(6),
    pname   varchar2(20),
    Country_of_origin   varchar2(10),
    constraint pk_Pub_id primary key(Pub_id)
);
create table shelve(
    shelve_id  number(6),
    Name    varchar2(4),
    location    varchar(20),
    constraint pk_shelve_id primary key(shelve_id)
);
create table version_book(
    ISBN        number(13),
    type_ver    varchar2(9),
    book_id     number(6),
    pub_id      number(6),
    shelve_id   number(6),
    constraint pk_ISBN  primary key(ISBN)
);
create table borrow(
    invoice_no  number(5),
    Mem_id  number(6) not null,
    ISBN    number(13) not null,
    emp_id  number(6) not null,
    date_of_borrow  varchar2(11),
    deadline    varchar2(11),
    Status      varchar2(8),
    constraint pk_Invoice_no_borrowing primary key(invoice_no)
);
create table return_borrow(
    invoice_no  number(10),
    date_of_returning   varchar2(11),
    condition_of_the_book   varchar2(4),
    constraint pk_invocie_no_returning primary key(invoice_no),
    constraint fk_invoce_no_returning foreign key(invoice_no) references borrow(invoice_no)
);
//////////////////////////
//// functions ///////////
CREATE or replace FUNCTION getAGEalive
           (birthday varchar2) 
          RETURN number DETERMINISTIC
          IS
              age_of_person number(3);
          BEGIN
          select (EXTRACT(Year from (sysdate())) - EXTRACT(Year from to_date(birthday,'DD-Mon-YYYY HH24:MI:SS')))  
          into age_of_person from dual;
              return age_of_person;
          END getAGEalive;
CREATE or replace FUNCTION getAGEDead
           (birthday varchar2,year_of_death VARCHAR2) 
          RETURN number DETERMINISTIC
          IS
              age_of_person number(3);
          BEGIN
          if year_of_death = 'alive'
          then
          age_of_person := getagealive(birthday);
          else
          select EXTRACT(Year from to_date(year_of_death,'DD-Mon-YYYY HH24:MI:SS')) - EXTRACT(Year from to_date(birthday,'DD-Mon-YYYY HH24:MI:SS'))  
          into age_of_person from dual;
          end if;
              return age_of_person;
          END getAGEDead;
create or replace FUNCTION getFee
            (date_of_returning varchar2,condition varchar2,invo number)
            return number DETERMINISTIC
            is
            fee number(3);
            begin
            select (sysdate + (intervaldiff) - sysdate)*10 into fee from (
            select ((to_date(date_of_returning))-(to_date(deadline))) as intervaldiff from borrow where invo = borrow.invoice_no) ;
            if fee < 0 then 
             fee := 0;
             end if;
             if condition = 'bad' then
             fee := fee + 150;
             end if;
             return fee;
             end getFee;
create or replace FUNCTION getTotalfee
            (mem_fid number)
            RETURN number DETERMINISTIC
            is totalfee number(4);
            begin
            select sum(r.fee) into totalfee from borrow b, return_borrow r where b.mem_id = mem_fid and r.invoice_no = b.invoice_no;
            return totalfee;
            end getTotalfee;
create or replace function getLateReturn
            (mem_fid number)
            return number deterministic 
            is countlateReturn number(2);
            begin
            select count(b.invoice_no) into countlateReturn from return_borrow r, borrow b where b.invoice_no = r.invoice_no 
            and mem_fid = b.mem_id 
            and r.fee > 0;
            return countlateReturn;
            end getLateReturn;
create or replace FUNCTION getcountofbook
            (auth_fid number)
            return number deterministic
            is countofbook number(4);
            begin
            select count(book_id) into countofbook from book where auth_id = auth_fid;
            return countofbook;
            end getcountofbook;
create or replace FUNCTION getcountofversion
            (pub_fid number)
            return number deterministic
            is countofversion number(4);
            begin
            select count(ISBN) into countofversion from version_book where pub_id = pub_fid;
            return countofversion;
            end getcountofversion;

//////////////////////////
//// Altering Tables /////
alter table lib_dept add constraint fk_Manger_id foreign key(mgr_id) references employee(emp_id);
alter table employee add constraint fk_supervisor foreign key(superviosr) references employee(emp_id);
alter table employee add constraint fk_deptid foreign key(dept_no) references lib_dept(dept_id);
alter table borrow add constraint fk_mem_id_borrow foreign key(mem_id) references member_(mem_id);
alter table borrow add constraint fk_ISBN_borrow foreign key(ISBN) references version_book(ISBN);
alter table borrow add constraint fk_emp_id foreign key(emp_id) references employee(emp_id);
alter table version_book add constraint fk_book_id_version foreign key(book_id) references book(book_id);
alter table version_book add constraint fk_shelve_id_version foreign key(shelve_id) references shelve(shelve_id);
alter table version_book add constraint fk_publisher_id_version foreign key(pub_id) references publisher(pub_id);
alter table book add constraint fk_authors_id foreign key(auth_id) references author(auth_id);
alter table member_ add age number(3) generated always as (getagealive(birth_date)) VIRTUAL;
alter table member_ add COUNT_OF_LATE_RETURN number(2) generated always as (getlatereturn(mem_id)) VIRTUAL;
alter table member_ add TOTAL_FEE number(4) generated always as (gettotalfee(mem_id)) VIRTUAL;
alter table return_borrow add fee number(3) generated always as (getfee(DATE_OF_RETURNING,CONDITION_OF_THE_BOOK,INVOICE_NO)) virtual;
alter table author add  NUM_OF_BOOKS number(4) generated always as (getcountofbook(auth_id)) virtual;
alter table author add age number(3) generated always as (getagedead(DATE_OF_BITH,DATE_OF_DEATH)) virtual;
alter table publisher add NUM_OF_BOOKS number(4) generated always as (getcountofversion(pub_id)) virtual;
//////////////////////////
//// system rules ////////
alter table employee add constraint employee_rule check (floor(emp_id/100000) = dept_no);
alter table version_book add constraint version_rule check ((REMAINDER(ISBN,10) =1 and type_ver = 'original')
or (REMAINDER(ISBN,10) =2 and type_ver = 'hardcover')
or(REMAINDER(ISBN,10) =3 and type_ver = 'softcover'));
alter table borrow add constraint borrowing_rules check (floor(emp_id/100000) = 1 and (REMAINDER(ISBN,10) = 1)
or floor(emp_id/100000) in (1,2) and (REMAINDER(ISBN,10) in(2,3)));
//////////////////////////
////insertion ////////////
insert into lib_dept(dept_id,dept_name,mgr_id) values (1,'administrator',null);
insert into lib_dept(dept_id,dept_name,mgr_id) values (2,'customer service', null);
insert into lib_dept(dept_id,dept_name,mgr_id) values (3,'cleaning service',null);
insert into lib_dept(dept_id,dept_name,mgr_id) values (4,'RD',null);
insert into lib_dept(dept_id,dept_name,mgr_id) values (5,'IT',null);
insert into rank_salary(rank_level,rank_salary) values(1,3000);
insert into rank_salary(rank_level,rank_salary) values(2,6000);
insert into rank_salary(rank_level,rank_salary) values(3,9000);
insert into rank_salary(rank_level,rank_salary) values(4,12000);
insert into rank_salary(rank_level,rank_salary) values(5,15000); 
insert into rank_salary(rank_level,rank_salary) values(6,18000);
insert into rank_salary(rank_level,rank_salary) values(7,21000);
insert into rank_salary(rank_level,rank_salary) values(8,24000);
insert into employee(emp_id,fname,lname,phone_number,email,sex,dept_no,rank_emp,superviosr)
values (123876,'muath','alhurtumi',0536644243,'muathalhurtumi@gmail.com','m',1,8,null);
insert into employee(emp_id,fname,lname,phone_number,email,sex,dept_no,rank_emp,superviosr)
values (227680,'hatan','alzahrani',0547866243,'hatanlazahrani@gmail.com','m',2,6,123876);
insert into employee(emp_id,fname,lname,phone_number,email,sex,dept_no,rank_emp,superviosr)
values (328972,'mohand','aljabri',0537658923,'mohandaljabri@gmail.com','m',3,2,123876);
insert into employee(emp_id,fname,lname,phone_number,email,sex,dept_no,rank_emp,superviosr)
values (428972,'farah','khaild',05357889560,'farahkhaild@gmail.com','f',4,7,123876);
insert into employee(emp_id,fname,lname,phone_number,email,sex,dept_no,rank_emp,superviosr)
values (528972,'bader','aljabri',05678923456,'mohandaljabri@gmail.com','m',5,7,123876);
update lib_dept set mgr_id = 123876 where dept_id = 1;
update lib_dept set mgr_id = 227680 where dept_id = 2;
update lib_dept set mgr_id = 328972 where dept_id = 3;
update lib_dept set mgr_id = 428972 where dept_id = 4;
update lib_dept set mgr_id = 528972 where dept_id = 5;
insert into author (auth_id,fanem,lname,date_of_bith,date_of_death,BRITH_LOCATION) values (000001,'ahmed','alshaybani','01-Jan-1923','01-Jan-1996','sryia');
insert into author (auth_id,fanem,lname,date_of_bith,date_of_death,BRITH_LOCATION) values (000002,'sultan','almousa','01-Jan-1987','alive','suadi');
insert into author (auth_id,fanem,lname,date_of_bith,date_of_death,BRITH_LOCATION) values (000003,'William','Shakes','23-Apr-1564','26-Apr-1616','england');
insert into author (auth_id,fanem,lname,date_of_bith,date_of_death,BRITH_LOCATION) values (000004,'Charles','Dickens','07-Feb-1812','09-Jun-1870','england');
insert into author (auth_id,fanem,lname,date_of_bith,date_of_death,BRITH_LOCATION) values (000005,'Jane','Austen','16-Dec-1775','18-Jul-1817','england');
insert into book (book_id,bname,language,auth_id) values (000001,'history and culture','ar',000001);
insert into book (book_id,bname,language,auth_id) values (000002,'the complete women','ar',000002);
insert into book (book_id,bname,language,auth_id) values (000003,'The Pickwick Papers','en',000004);
insert into book (book_id,bname,language,auth_id) values (000004,'David Copperfield','en',000004);
insert into book (book_id,bname,language,auth_id) values (000005,' A Christmas Carol','en',000004);
insert into book (book_id,bname,language,auth_id) values (000006,'Sense and Sensibility','en',000005);
insert into book (book_id,bname,language,auth_id) values (000007,'Mansfield Park','en',000005);
insert into book (book_id,bname,language,auth_id) values (000008,'Emma','en',000005);
insert into book (book_id,bname,language,auth_id) values (000009,'Northanger Abbey','en',000005);
insert into book (book_id,bname,language,auth_id) values (000010,'A Midsummer Nights Dream','en',000003);
insert into publisher (pub_id,pname,COUNTRY_OF_ORIGIN) values (000001,'alobiekan','saudi');
insert into publisher (pub_id,pname,COUNTRY_OF_ORIGIN) values (000002,'Simon and Schuster','USA');
insert into publisher (pub_id,pname,COUNTRY_OF_ORIGIN) values (000003,'HarperCollins','USA');
insert into publisher (pub_id,pname,COUNTRY_OF_ORIGIN) values (000004,'Random Houser','USA');
insert into publisher (pub_id,pname,COUNTRY_OF_ORIGIN) values (000005,'Penguin Books','UK');
insert into shelve (shelve_id,name,location) values(000001,'A-1','F-1 east wing');
insert into shelve (shelve_id,name,location) values(000002,'A-2','F-1 east wing');
insert into shelve (shelve_id,name,location) values(000003,'E-1','F-2 west wing');
insert into shelve (shelve_id,name,location) values(000004,'E-2','F-2 west wing');
insert into shelve (shelve_id,name,location) values(000005,'E-3','F-2 west wing');
insert into version_book (ISBN,type_ver,book_id,pub_id,shelve_id) values(9872001001011,'original',000001,000001,000001);
insert into version_book (ISBN,type_ver,book_id,pub_id,shelve_id) values(9872001001012,'hardcover',000001,000001,000001);
insert into version_book (ISBN,type_ver,book_id,pub_id,shelve_id) values(9872001001013,'softcover',000001,000001,000001);
insert into version_book (ISBN,type_ver,book_id,pub_id,shelve_id) values(9872001002011,'original',000002,000001,000002);
insert into version_book (ISBN,type_ver,book_id,pub_id,shelve_id) values(9872001002012,'hardcover',000002,000001,000002);
insert into version_book (ISBN,type_ver,book_id,pub_id,shelve_id) values(9872001002013,'softcover',000002,000001,000002);
insert into version_book (ISBN,type_ver,book_id,pub_id,shelve_id) values(9872002003022,'hardcover',000003,000002,000003);
insert into version_book (ISBN,type_ver,book_id,pub_id,shelve_id) values(9872002003023,'softcover',000003,000002,000003);
insert into version_book (ISBN,type_ver,book_id,pub_id,shelve_id) values(9872004005021,'original',000005,000004,000004);
insert into version_book (ISBN,type_ver,book_id,pub_id,shelve_id) values(9872004005022,'hardcover',000005,000004,000004);
insert into version_book (ISBN,type_ver,book_id,pub_id,shelve_id) values(9872003004023,'softcover',000004,000003,000005);
insert into version_book (ISBN,type_ver,book_id,pub_id,shelve_id) values(9872005007023,'softcover',000007,000005,000005);
insert into version_book (ISBN,type_ver,book_id,pub_id,shelve_id) values(9872005006023,'softcover',000006,000005,000005);
insert into member_(mem_id,fname,lname,birth_date,status,phone_number) values(100000,'ahmed','alhurumi','01-Feb-1999','A',0537869901);
insert into member_(mem_id,fname,lname,birth_date,status,phone_number) values(110000,'fahad','alhurumi','26-Dec-1999','A',0536677892);
insert into member_(mem_id,fname,lname,birth_date,status,phone_number) values(120000,'lama','alhurumi','13-Jun-2009','A',0537382845);
insert into member_(mem_id,fname,lname,birth_date,status,phone_number) values(130000,'zyad','alhurumi','27-May-2004','A',0532384923);
insert into member_(mem_id,fname,lname,birth_date,status,phone_number) values(140000,'leonard','william','23-Feb-1959','A',053374829);
insert into borrow (invoice_no,isbn,emp_id,mem_id,date_of_borrow,deadline,status) values (10000,9872001001012,227680,100000,'01-Feb-2023','20-Feb-2023','returned');
insert into borrow (invoice_no,isbn,emp_id,mem_id,date_of_borrow,deadline,status) values (10001,9872001001013,227680,100000,'01-Feb-2023','25-Feb-2023','returned');
insert into borrow (invoice_no,isbn,emp_id,mem_id,date_of_borrow,deadline,status) values (10002,9872002003023,227680,110000,'01-Feb-2023','25-Feb-2023','returned');
insert into borrow (invoice_no,isbn,emp_id,mem_id,date_of_borrow,deadline,status) values (10003,9872005006023,227680,110000,'01-Feb-2023','25-Feb-2023','returned');
insert into borrow (invoice_no,isbn,emp_id,mem_id,date_of_borrow,deadline,status) values (10004,9872004005022,227680,120000,'01-Feb-2023','25-Feb-2023','returned');
insert into borrow (invoice_no,isbn,emp_id,mem_id,date_of_borrow,deadline,status) values (10005,9872004005022,227680,130000,'01-Feb-2023','25-Feb-2023','returned');
insert into borrow (invoice_no,isbn,emp_id,mem_id,date_of_borrow,deadline,status) values (10006,9872001002011,123876,140000,'01-Feb-2023','25-Feb-2023','returned');
insert into borrow (invoice_no,isbn,emp_id,mem_id,date_of_borrow,deadline,status) values (10007,9872004005021,123876,140000,'01-Feb-2023','25-Feb-2023','borrowed');
insert into return_borrow(INVOICE_NO,DATE_OF_RETURNING,CONDITION_OF_THE_BOOK) values(10000,'23-Feb-2023','good');
insert into return_borrow(INVOICE_NO,DATE_OF_RETURNING,CONDITION_OF_THE_BOOK) values(10001,'23-Feb-2023','good');
insert into return_borrow(INVOICE_NO,DATE_OF_RETURNING,CONDITION_OF_THE_BOOK) values(10002,'15-Mar-2023','bad');
insert into return_borrow(INVOICE_NO,DATE_OF_RETURNING,CONDITION_OF_THE_BOOK) values(10003,'1-Mar-2023','good');
insert into return_borrow(INVOICE_NO,DATE_OF_RETURNING,CONDITION_OF_THE_BOOK) values(10004,'4-Feb-2023','bad');
insert into return_borrow(INVOICE_NO,DATE_OF_RETURNING,CONDITION_OF_THE_BOOK) values(10005,'15-Feb-2023','good');
insert into return_borrow(INVOICE_NO,DATE_OF_RETURNING,CONDITION_OF_THE_BOOK) values(10006,'27-Feb-2023','good');
//////////////////////////
//// quries //////////////
spool library.txt;
desc lib_dept;
desc employee;
desc rank_salary;
desc author;
desc book;
desc publisher;
desc version_book;
desc member_;
desc borrow;
desc return_borrow;
select * from lib_dept;
select * from employee;
select * from rank_salary;
select * from author;
select * from book;
select * from publisher;
select * from version_book;
select * from member_;
select * from borrow;
select * from return_borrow;
select e.emp_id,e.fname,e.lname,e.rank_emp,r.rank_salary from employee e, rank_salary r where e.rank_emp = r.rank_level order by rank_emp asc;
// to see each employee first and last name with his rank and salary
select avg(r.rank_salary),l.dept_id from lib_dept l, employee e, rank_salary r where e.dept_no = l.dept_id and e.rank_emp = r.rank_level group by dept_id;
// to see the avg salary in each department
select count(e.emp_id),l.dept_id from lib_dept l, employee e where e.dept_no = l.dept_id group by dept_id;
// to see the number of employee
select * from (borrow b join return_borrow r on b.INVOICE_NO = r.INVOICE_NO);
// to show the borroed version and when it returned
select b.invoice_no,(e.fname||' '||e.lname) as employee_name, (m.fname||' '||m.lname) as member_name,
bo.bname as book_name, v.type_ver, b.date_of_borrow,b.deadline,r.date_of_returning
from borrow b, return_borrow r,employee e, member_ m, version_book v,book bo  where
b.INVOICE_NO = r.INVOICE_NO and b.ISBN = v.ISBN and b.emp_id = e.emp_id and b.mem_id = m.mem_id and v.book_id = bo.book_id;
// this query work as receipt
select (m.fname||' '|| m.lname) as member_name ,b.INVOICE_NO, r.fee from member_ m join(borrow b join return_borrow r on b.INVOICE_NO = r.INVOICE_NO) on m.mem_id = b.mem_id;
//to show first and last name of member with there inovice number and fees
select emp_id, fname,lname, dept_name from lib_dept d join employee e on e.dept_no = d.dept_id;
//Retrieve the details of employees along with their department names
spool off;
desc version_book
desc shelve
//////////////////////////
////spool/////////////////
//////////////////////////