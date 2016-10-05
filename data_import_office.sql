
CREATE Table Customers (
CustID NUMBER CONSTRAINT pk_customers PRIMARY KEY,
CustName  varchar2(35),
CustReg  number(1,0),
CustState  varchar2(20 BYTE),
CustCity   varchar2(20 BYTE),
CustZip   NUMBER(5,0),
CustSeg   varchar2(15 BYTE),
CONSTRAINT ch_seg CHECK (CustSeg IN ('Corporate', 'Home Office','Small Business','Consumer')),
CONSTRAINT fk_reg FOREIGN KEY (CustReg) REFERENCES Managers (RegID) ON delete cascade);


CREATE Table Managers (
RegID NUMBER CONSTRAINT pk_managers PRIMARY KEY,
Region varchar2(10 BYTE) CONSTRAINT ch_region CHECK (Region IN ('East', 'South','West','Central')),
RegManager varchar2(10 BYTE));


CREATE Table Products (
ProdID NUMBER CONSTRAINT pk_products PRIMARY KEY,
ProdName varchar2(100 BYTE),
ProdCat varchar2(30 BYTE) CONSTRAINT ch_prodcat CHECK (ProdCat IN ('Office Supplies', 'Furniture', 'Technology')),
ProdSubCat varchar2(30 BYTE),
ProdCont varchar2(20 BYTE) CONSTRAINT ch_prodcont CHECK (prodcont IN ('Wrap Bag','Small Box','Jumbo Drum','Medium Box','Small Pack','Large Box','Jumbo Box')),
UnitPrice NUMBER(7,2),
ProdMargin NUMBER(5,3));


CREATE TABLE Orders (
OrderID NUMBER CONSTRAINT pk_ordid PRIMARY KEY,
Status Varchar2(10 BYTE));


drop table orderdet;
CREATE TABLE OrderDet (
OrderID NUMBER ,
CustID NUMBER, 
ProdID NUMBER,
OrdPriority varchar2(15 BYTE) CONSTRAINT ch_priority CHECK (OrdPriority IN ('Critical', 'High','Medium','Low','Not Specified')),
OrdDiscount NUMBER(3,2),
OrdShipMode VarChar2(15 BYTE) CONSTRAINT ch_shipmode CHECK(OrdShipMode IN ('Regular Air','Delivery Truck','Express Air')),
OrdDate DATE,
OrdShipDate DATE,
OrdShipCost NUMBER(5,2),
OrdQty NUMBER, 
OrdSales NUMBER(8,2),
CONSTRAINT pk_orderdet PRIMARY KEY (OrderID, CustID, ProdID), 
CONSTRAINT fk_customers FOREIGN KEY (CustID) REFERENCES Customers (CustID) ,
CONSTRAINT fk_orders FOREIGN KEY (OrderID) REFERENCES Orders (OrderID) ,
CONSTRAINT fk_products FOREIGN KEY (ProdID) REFERENCES Products (ProdID));




