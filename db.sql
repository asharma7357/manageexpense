create table me_trans_dtl_stg(
	trans_id number,
	member_name	varchar2(500 char),
	trans_dt	varchar2(30 char),
	ACCT_NAME	varchar2(100 char),
	CATEG		varchar2(1000 char),
	SUB_CATEG	varchar2(1000 char),
	COMMENTS	varchar2(4000 char),
	TRANS_AMT	varchar2(1000 char)
)
tablespace me_data;

create table me_user_mst(
	ID				NUMBER not null,
	LOGIN_ID		VARCHAR2(1000 CHAR) not null,
	LOGIN_PWD		VARCHAR2(1000 CHAR) not null,
	USER_FNAME		VARCHAR2(200 CHAR) not null,
	USER_MNAME		VARCHAR2(200 CHAR),
	USER_LNAME		VARCHAR2(200 CHAR),
	USER_EMAIL_ID	VARCHAR2(3000 CHAR) not null,
	USER_PHONE_NO	VARCHAR2(50 CHAR) not null,
	INSERT_DT		DATE not null,
	UPDATE_DT		DATE
)
tablespace me_data;

alter table me_user_mst add constraint me_user_mst_pk1 primary key (id) using index tablespace me_index;

create table ME_CATEG_MST(
	ID			NUMBER not null,
	INC_EXP		CHAR(1 CHAR) not null,
	CATEG		VARCHAR2(100 CHAR) not null,
	SUB_CATEG	VARCHAR2(100 CHAR) not null
)
tablespace me_data;

alter table me_categ_mst add constraint me_categ_mst_pk1 primary key (id) using index tablespace me_index;

create table me_group_mst(
	ID			NUMBER not null,
	USER_ID		NUMBER not null,
	GROUP_TYPE	CHAR(1 CHAR) not null,
	GROUP_NAME	VARCHAR2(30 CHAR) not null)
tablespace me_data;

alter table me_group_mst add constraint me_group_mst_pk1 primary key (id) using index tablespace me_index;
alter table me_group_mst add constraint me_group_mst_fk1 foreign key (user_id) references me_user_mst(id);

drop table me_group_memeber purge;

create table me_group_member(
	ID				NUMBER not null,
	GROUP_ID		NUMBER not null,
	MEMBER_ID		VARCHAR2(4000 CHAR),
	MEMBER_EMAIL_ID	VARCHAR2(3000 CHAR),
	MEMBER_PHONE_NO	VARCHAR2(50 CHAR)
)
tablespace me_data;

alter table me_group_member add constraint me_group_member_pk1 primary key (id) using index tablespace me_index;
alter table me_group_member add constraint me_group_member_fk1 foreign key (group_id) references me_group_mst(id);

create table me_bank_mst(
	ID			NUMBER NOT NULL,
	BANK_NAME	VARCHAR2(100 CHAR) NOT NULL)
TABLESPACE ME_DATA;

ALTER TABLE ME_BANK_MST ADD CONSTRAINT ME_BANK_MST_PK1 PRIMARY KEY (ID) USING INDEX TABLESPACE ME_INDEX;

DROP TABLE ME_ACCOUNT_MST;

CREATE TABLE ME_ACCOUNT_MST(
	ID				NUMBER NOT NULL,
	USER_ID			NUMBER NOT NULL,
	ACCT_NAME		VARCHAR2(100 CHAR) NOT NULL,
	BANK_ID			NUMBER NOT NULL,
	ACCT_TYPE		VARCHAR2(100 CHAR) NOT NULL,
	INITIAL_AMT		NUMBER,
	INITIAL_AMT_DT	DATE
)
TABLESPACE ME_DATA;

ALTER TABLE ME_ACCOUNT_MST ADD CONSTRAINT ME_ACCOUNT_MST_PK1 PRIMARY KEY (ID) USING INDEX TABLESPACE ME_INDEX;
alter table ME_ACCOUNT_MST add constraint ME_ACCOUNT_MST_fk1 foreign key (user_id) references me_user_mst(id);
alter table ME_ACCOUNT_MST add constraint ME_ACCOUNT_MST_fk2 foreign key (BANK_id) references me_BANK_mst(id);


drop table me_trans_mst purge;

create table me_trans_mst(
	ID					NUMBER not null,
	GROUP_ID			NUMBER,
	USER_ID				NUMBER not null,
	ACCT_ID				NUMBER not null,
	CATEG_ID			NUMBER not null,
	TRANS_DT			DATE not null,
	TRANS_AMT			NUMBER(10,2) not null,
	TRANS_DESC			VARCHAR2(4000 CHAR) not null,
	GROUP_MEMBER_ID	NUMBER
)
tablespace me_data;

alter table me_trans_mst add constraint me_trans_mst_pk1 primary key (id) using index tablespace me_index;
alter table me_trans_mst add constraint me_trans_mst_fk1 foreign key (group_id) references me_group_mst(id);
alter table me_trans_mst add constraint me_trans_mst_fk2 foreign key (user_id) references me_user_mst(id);
alter table me_trans_mst add constraint me_trans_mst_fk3 foreign key (acct_id) references me_account_mst(id);
alter table me_trans_mst add constraint me_trans_mst_fk4 foreign key (categ_id) references me_categ_mst(id);
alter table me_trans_mst add constraint me_trans_mst_fk5 foreign key (group_member_id) references me_group_member(id);


insert into ME_USER_MST (ID,LOGIN_ID,LOGIN_PWD,USER_FNAME,USER_MNAME,USER_LNAME,USER_EMAIL_ID,USER_PHONE_NO,INSERT_DT,UPDATE_DT)
values(1,'asharma','asharma','Abhishek','','Sharma','abhishek.sharma6829@gmail.com','9891371276',sysdate,null);
insert into ME_USER_MST (ID,LOGIN_ID,LOGIN_PWD,USER_FNAME,USER_MNAME,USER_LNAME,USER_EMAIL_ID,USER_PHONE_NO,INSERT_DT,UPDATE_DT)
values(2,'hsingh','hsingh','Harmanpreet','','Singh','hpsudan@gmail.com','9953650566',sysdate,null);
insert into ME_USER_MST (ID,LOGIN_ID,LOGIN_PWD,USER_FNAME,USER_MNAME,USER_LNAME,USER_EMAIL_ID,USER_PHONE_NO,INSERT_DT,UPDATE_DT)
values(3,'rkhan','rkhan','Rahil','','Khan','rashidali.rahil@gmail.com','9717598457',sysdate,null);
insert into ME_USER_MST (ID,LOGIN_ID,LOGIN_PWD,USER_FNAME,USER_MNAME,USER_LNAME,USER_EMAIL_ID,USER_PHONE_NO,INSERT_DT,UPDATE_DT)
values(4,'schangia','schangia','Samira','','Changia','changia.samira@gmail.com','9891651919',sysdate,null);

commit;

Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (1,'E','Account','Adjustment');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (2,'E','Automobile','Accessories');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (3,'E','Automobile','Misc');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (4,'E','Automobile','Fuel');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (5,'E','Automobile','Parking');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (6,'E','Automobile','Pollution Check');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (7,'E','Automobile','Service');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (8,'E','Automobile','Loan EMI');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (9,'E','Children','Accessories');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (10,'E','Children','Food');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (11,'E','Children','Grooming');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (12,'E','Children','Safety and Health Care');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (13,'E','Children','Clothing');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (14,'E','Children','Education');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (15,'E','Entertainment','Events');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (16,'E','Entertainment','Movies');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (17,'E','Entertainment','Sports');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (18,'E','Family','Gift');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (19,'E','Family','Grooming');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (20,'E','Family','Health Care');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (21,'E','Family','Shopping');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (22,'E','Food','Meal');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (23,'E','Food','Party');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (24,'E','Food','Restaurant');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (25,'E','Food','Snacks');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (26,'E','Food','Groceries');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (27,'E','HealthCare','Accessories');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (28,'E','HealthCare','Dental');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (29,'E','HealthCare','Eye Care');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (30,'E','HealthCare','Medicine');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (31,'E','HealthCare','Nutrition');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (32,'E','HealthCare','Consultancy');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (33,'E','HealthCare','Checkup');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (34,'E','Household','Appliances');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (35,'E','Household','Home Maintenance');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (36,'E','Household','Tools');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (37,'E','Household','Consumables');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (38,'E','Household','Rent');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (39,'E','Insurance','Automobile');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (40,'E','Insurance','Health');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (41,'E','Insurance','Home');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (42,'E','Insurance','Life');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (43,'E','Insurance','Other');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (44,'E','Loan','Car');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (45,'E','Loan','Home');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (46,'E','Loan','Education');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (47,'E','Loan','Mortage');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (48,'E','Loan','Other');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (49,'E','Office','Computer');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (50,'E','Office','Electronics');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (51,'E','Office','Furniture');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (52,'E','Office','Office Supply');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (53,'E','Office','Stationary');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (54,'E','Office','Others');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (55,'E','Home Office','Computer');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (56,'E','Home Office','Electronics');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (57,'E','Home Office','Furniture');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (58,'E','Home Office','Office Supply');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (59,'E','Home Office','Stationary');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (60,'E','Home Office','Others');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (61,'E','Personal','Account Transfer');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (62,'E','Personal','Clothing');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (63,'E','Personal','Grooming');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (64,'E','Personal','Electronics');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (65,'E','Personal','Stationary');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (66,'E','Personal','Accessories');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (67,'E','Personal','Others');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (68,'E','Tax','Others');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (69,'E','Tax','Property Tax');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (70,'E','Travel','Airplane');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (71,'E','Travel','Car Rental');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (72,'E','Travel','Entry Fee');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (73,'E','Travel','Food');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (74,'E','Travel','Hotel');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (75,'E','Travel','Misc');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (76,'E','Travel','Other');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (77,'E','Travel','Other Transportation');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (78,'E','Travel','Parking');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (79,'E','Travel','Taxi');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (80,'E','Travel','Toll');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (81,'E','Travel','Train');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (82,'E','Utilities','Credit Card');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (83,'E','Utilities','Electricity');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (84,'E','Utilities','Gas');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (85,'E','Utilities','Internet');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (86,'E','Utilities','Mobile Recharge');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (87,'E','Utilities','Telephone');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (88,'E','Vet','Food');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (89,'E','Vet','Health');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (90,'E','Vet','Utilities');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (91,'I','Income','Account Transfer');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (92,'I','Income','Cash');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (93,'I','Income','Pension');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (94,'I','Income','Personal Saving');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (95,'I','Income','Salary');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (96,'I','Income','Tax Refund');
Insert into ME_CATEG_MST (ID,INC_EXP,CATEG,SUB_CATEG) values (97,'I','Income','Part-time');
commit;


insert into me_group_mst(id,user_id,group_type,group_name)
values(1,1,'F','Home');
insert into me_group_mst(id,user_id,group_type,group_name)
values(2,1,'G','FriendsHangout');

commit;


insert into me_group_member(ID,GROUP_ID,MEMBER_ID,MEMBER_EMAIL_ID,MEMBER_PHONE_NO)
values(1,1,4,null,null);
insert into me_group_member(ID,GROUP_ID,MEMBER_ID,MEMBER_EMAIL_ID,MEMBER_PHONE_NO)
values(2,2,2,null,null);
insert into me_group_member(ID,GROUP_ID,MEMBER_ID,MEMBER_EMAIL_ID,MEMBER_PHONE_NO)
values(3,2,3,null,null);
commit;

Insert into ME_BANK_MST (ID,BANK_NAME) values (1,'AXIS Bank');
Insert into ME_BANK_MST (ID,BANK_NAME) values (2,'Allahbad Bank');
Insert into ME_BANK_MST (ID,BANK_NAME) values (3,'Andra Bank');
Insert into ME_BANK_MST (ID,BANK_NAME) values (4,'Axis Corporate');
Insert into ME_BANK_MST (ID,BANK_NAME) values (5,'Bank of India');
Insert into ME_BANK_MST (ID,BANK_NAME) values (6,'Bank of Baroda - Corporate NetBanking');
Insert into ME_BANK_MST (ID,BANK_NAME) values (7,'Bank of Baroda - Retail NetBanking');
Insert into ME_BANK_MST (ID,BANK_NAME) values (8,'Bank of Maharashtra');
Insert into ME_BANK_MST (ID,BANK_NAME) values (9,'Canara Bank');
Insert into ME_BANK_MST (ID,BANK_NAME) values (10,'Central Bank of India');
Insert into ME_BANK_MST (ID,BANK_NAME) values (11,'City Union Bank');
Insert into ME_BANK_MST (ID,BANK_NAME) values (12,'Corporation Bank');
Insert into ME_BANK_MST (ID,BANK_NAME) values (13,'DENA Bank');
Insert into ME_BANK_MST (ID,BANK_NAME) values (14,'HDFC');
Insert into ME_BANK_MST (ID,BANK_NAME) values (15,'ICICI');
Insert into ME_BANK_MST (ID,BANK_NAME) values (16,'IDBI');
Insert into ME_BANK_MST (ID,BANK_NAME) values (17,'India Overseas Bank');
Insert into ME_BANK_MST (ID,BANK_NAME) values (18,'InduInd Bank');
Insert into ME_BANK_MST (ID,BANK_NAME) values (19,'Kotak Mahindra Bank');
Insert into ME_BANK_MST (ID,BANK_NAME) values (20,'Oriental Bank of Commerce');
Insert into ME_BANK_MST (ID,BANK_NAME) values (21,'PNB');
Insert into ME_BANK_MST (ID,BANK_NAME) values (22,'PNB Corporate NetBanking');
Insert into ME_BANK_MST (ID,BANK_NAME) values (23,'Punjab and Sind Bank');
Insert into ME_BANK_MST (ID,BANK_NAME) values (24,'SBI');
Insert into ME_BANK_MST (ID,BANK_NAME) values (25,'South Indian Bank');
Insert into ME_BANK_MST (ID,BANK_NAME) values (26,'Syndicate Bank');
Insert into ME_BANK_MST (ID,BANK_NAME) values (27,'UCO Bank');
Insert into ME_BANK_MST (ID,BANK_NAME) values (28,'Union Bank of India');
Insert into ME_BANK_MST (ID,BANK_NAME) values (29,'American Express');
Insert into ME_BANK_MST (ID,BANK_NAME) values (30,'Citi Bank');
Insert into ME_BANK_MST (ID,BANK_NAME) values (31,'HSBC');
commit;



select	*
from	(	select	trans_id as ID,
					1 as GROUP_ID,
					1 as USER_ID,
					(select mam.id from me_account_mst mam where mam.ACCT_NAME = stg.acct_name) as acct_id,
					(select mcm.id from me_categ_mst mcm where mcm.categ = stg.categ and mcm.sub_categ = stg.sub_categ) as CATEG_ID,
					stg.categ,
					stg.sub_categ,
					to_date(trans_dt,'rrrrmmddhh24miss') as TRANS_DT,
					trans_amt as TRANS_AMT,
					comments as TRANS_DESC,
					null as GROUP_MEMBER_ID
			from	me_trans_dtl_stg stg
		)
where	CATEG_ID is null;

update me_trans_dtl_stg set acct_name = 'Wallet' where acct_name='Cash';
