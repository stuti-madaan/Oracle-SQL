CREATE Table ProdCoffee (
ProductID NUMBER PRIMARY KEY,
ProdName  varchar(20),
Prodline  varchar(20),
Prodtype  varchar(20),
Prodvar   varchar(20),
CONSTRAINT ch_line CHECK (ProdLine IN ('Beans', 'Leaves')),
CONSTRAINT ch_type CHECK (Prodtype IN ('Coffee', 'Espresso', 'Herbal Tea', 'Tea')),
CONSTRAINT ch_var  CHECK (Prodvar IN ('Regular', 'Decaf')));


CREATE Table States (
StateID   number PRIMARY KEY,
Statename varchar(15),
StateMkt  varchar(15) CONSTRAINT ch_state CHECK (StateMkt IN ('East', 'West', 'Central', 'South')),
StateSize varchar(15) CONSTRAINT ch_size CHECK (Statesize IN ('Major Market', 'Small Market')));

CREATE Table Areacode (
AreaID   number PRIMARY KEY,
StateID References States (StateID));

CREATE Table FactCoffee (
ProductID  number,
AreaID     number,
FactDate    DATE,
Inventory   number,
Budsales    number,
Budmargin   number,
BudCOGS     Number,
Budprofit   number,
ActSales    Number,
ActMargin   Number,
ActCOGS     Number,
ActProfit   Number,
ActExpenses Number,
ActMarkCost Number,
CONSTRAINT pk_factcoffee PRIMARY KEY (ProductID, AreaID, FactDate),
CONSTRAINT fk_productID FOREIGN KEY (ProductID) REFERENCES ProdCoffee (ProductID) on DELETE CASCADE,
CONSTRAINT fk_areacode FOREIGN KEY (AreaID) REFERENCES Areacode (AreaID));
