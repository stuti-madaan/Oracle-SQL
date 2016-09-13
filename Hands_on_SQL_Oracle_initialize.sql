CREATE TABLE Ex1cust (
     CustSSN   	Char(11)  not null,
     CustName  	varchar(20)  not null,
     CustState 	char(2) not null,
     CustZip   	number(5) not null,
     PRIMARY KEY (CustSSN) );
INSERT INTO Ex1Cust VALUES ('111-11-1111', 'Konana', 'TX', 78750);
INSERT INTO Ex1Cust VALUES ('222-22-2222', 'Hasler', 'TX', 78750);
INSERT INTO Ex1Cust VALUES ('111-11-1111', 'Konana', 'TX', 78750);
ALTER TABLE Ex1Cust ADD CONSTRAINT Check_state CHECK (Custstate IN ('TX', 'OK'));
INSERT INTO Ex1Cust VALUES ('333-33-3333', 'Hasler', 'NM', 78740);
INSERT INTO Ex1Cust VALUES ('333-33-3333', 'Hasler', 'OK', 78740);


CREATE TABLE Ex1Acct (
     AcctNumber 	char(9) not null,
     AcctBalance 	real not null,
     AcctHolder 	char(11) not null,
     PRIMARY KEY (AcctNumber) ,
     FOREIGN KEY (AcctHolder) references Ex1cust (custssn) ON DELETE CASCADE);
INSERT INTO Ex1Acct VALUES ('111111111', 546.78, '111-11-1111');
INSERT INTO Ex1Acct VALUES ('222222222', 8000.78, '333-33-3333');
INSERT INTO Ex1Acct VALUES ('111112222', 546.78, '121-11-1111');
INSERT INTO Ex1Acct VALUES ('111112222', 547.75, '111-11-1111');

CREATE TABLE Ex1trans (
     TransNumber  char(5) not null,
     TransAcct  	char(9) not null,
     TransDate  	Date not null,
     TransAmount real not null,
     PRIMARY KEY (TransNumber),
     FOREIGN KEY (TransAcct) references Ex1acct (AcctNumber));

INSERT INTO Ex1Trans VALUES ('12345', '111111111', sysdate, 56.75);
INSERT INTO Ex1Trans VALUES ('12350', '111111111', sysdate, 86.75);
INSERT INTO Ex1Trans VALUES ('12350', '111112222', sysdate, 120.75);

DELETE FROM Ex1Acct WHERE Acctnumber = '111111111';
DELETE FROM Ex1Acct where Acctnumber = '222222222';

DROP Table Ex1trans;
DROP Table Ex1Acct;
DROP Table Ex1Cust;

DROP Table Ex1Acct;

select * from Ex1Acct;

