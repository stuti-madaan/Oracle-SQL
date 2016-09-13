--------------------------     PART A   : COFFEE SALES  ------------------------------------
-- A
-- 1.	In each state, find the area codes with sales more than 10% the average sales of all area codes within that state for the year 2013. 

SELECT a.Statename, b.AreaID, SUM(c.actsales) , AVG(a.avgsales)
FROM  AreaCode b ,factcoffee c, (
SELECT Statename, StateID, AVG(totsales) as avgsales 
FROM (
SELECT a.Statename,a.StateID, c.AreaID, SUM(b.actsales) AS totsales 
FROM States a , factcoffee b, AreaCode c 
WHERE a.stateid = c.stateid AND c.areaid = b.areaid and EXTRACT(YEAR From b.factdate) = 2013
GROUP BY a.Statename,a.StateID, c.AreaID)
GROUP BY Statename,StateID) a 
WHERE a.stateid = b.stateid and c.areaid = b.areaid and EXTRACT(YEAR FROM c.factdate) = 2013
GROUP BY a.Statename, b.AreaID
HAVING (1.1* AVG(a.avgsales) < SUM(c.actsales));

--2.Find the products with profit margins as percentage of sales (profits/sales) 
--of at least 15%. Display the results in descending order of total actual sales.  
--Round the percentage to two digits using ROUND(….,2) function.

SELECT a.ProductID, Prodname, ROUND(100* (SUM(ActProfit)/SUM(actsales)),2) as profitmargins, SUM(actsales) as totsales
FROM PRODCOFFEE a, FACTCOFFEE b 
WHERE a.productid = b.productid
GROUP BY a.ProductID, Prodname
HAVING ROUND(100* (SUM(ActProfit)/SUM(actsales)),2) >=15
ORDER BY totsales DESC ;

--3.	Find AreaIDs where the total profits from leaves in 2012 are two times greater than that from beans.
SELECT unique AREAID, beans_col, leaves_col
FROM (SELECT b.AREAID,a.prodline, SUM(b.actprofit) as totprofit
FROM Prodcoffee a , Factcoffee b 
WHERE a.Productid = b.productid 
AND 
EXTRACT(YEAR from b.factdate) = 2012
GROUP BY b.AREAID, A.Prodline
)
PIVOT (
SUM(totprofit) 
FOR Prodline in ('Beans' as beans_col, 'Leaves' as leaves_col)
)
WHERE LEAVES_COL > 2* BEANS_COL 
AND Leaves_col > 0 ;

-- B
--1.	Which are the top 5 area codes with declining profits and how much did the profits decline for these 5 area codes?
SELECT * 
FROM (SELECT AREAID, 100*((Yr2013- Yr2012)/abs(Yr2012)) as prc_chng
FROM (SELECT AREAID, EXTRACT(YEAR from factdate) as year_no, sum(actprofit) as totprofit
FROM Factcoffee 
GROUP BY AREAID, EXTRACT(YEAR from factdate))
PIVOT (
SUM(totprofit) 
FOR year_no in (2012 as yr2012, 2013 as yr2013))
WHERE Yr2012<>0 AND Yr2012 IS NOT NULL AND Yr2013 IS NOT NULL
ORDER BY prc_chng ASC)
WHERE ROWNUM<=5;

--2.	Among the five profit-declining area codes, are the profits consistently declining for all products? 
--If not, identify the products for which they had significantly higher profit decline.

SELECT * 
FROM (SELECT AREAID,prodname, 100*((Yr2013- Yr2012)/abs(Yr2012)) as prc_chng
FROM (SELECT a.AREAID,b.prodname, EXTRACT(YEAR from a.factdate) as year_no, sum(a.actprofit) as totprofit
FROM Factcoffee a, Prodcoffee b 
WHERE a.productid= b.productid AND a.AREAID in (925,845,816,626,508)
GROUP BY a.AREAID,b.prodname, EXTRACT(YEAR from a.factdate))
PIVOT (
SUM(totprofit) 
FOR year_no in (2012 as yr2012, 2013 as yr2013))
WHERE Yr2012<>0 AND Yr2012 IS NOT NULL AND Yr2013 IS NOT NULL
ORDER BY AREAID, prc_chng ASC);

/*Lemon Tea in 508, Earl Grey Tea in Area 816,Decaf Irish Cream in 626, Caffe Mocha and Mint Tea in 845 Seem to be the products with most declining Profits. 
For Area 925, two products were there in 2012 which were shut down and three new products were introduced in 2013. Overall profits are going down*/

-- C.: DOUBT
-- 1.	All the budgeted numbers are expected targets for 2012 and 2013. 
--Identify the top 5 states for the year 2012 that have substantially higher actual numbers relative to budgeted numbers for profits and sales.

--PROFIT
SELECT * FROM(SELECT Statename, sum(actprofit)/sum(budprofit) as ratioprofit
FROM Areacode a , Factcoffee b , States c
WHERE EXTRACT(YEAR from FACTDATE) = 2012
AND a.areaid = b.areaid and c.stateid = a.stateid
GROUP BY Statename)
WHERE ratioprofit >= 1 AND ROWNUM<=5
ORDER BY ratioprofit DESC;

--SALES
SELECT * FROM(SELECT Statename, sum(actSales)/sum(budsales) as ratiosales
FROM Areacode a , Factcoffee b , States c
WHERE EXTRACT(YEAR from FACTDATE) = 2012
AND a.areaid = b.areaid and c.stateid = a.stateid
GROUP BY Statename
HAVING (sum(actSales)/sum(budsales) >= 1)
ORDER BY ratiosales DESC
) WHERE ROWNum<=5;

--2.	Identify area codes within these 5 states that beat budgeted sales and profits significantly (You need to define what significant means here).  
SELECT Statename,A.Areaid, sum(actSales)/sum(budsales) as ratiosales,sum(actprofit)/sum(budprofit) as ratioprofit,sum(actsales),sum(budsales)
FROM Areacode a , Factcoffee b , States c
WHERE EXTRACT(YEAR from FACTDATE) = 2012 and Statename in ('Nevada','Iowa','Conneticut','New Hampshire','Oregon')
AND a.areaid = b.areaid and c.stateid = a.stateid
GROUP BY Statename,A.areaid
HAVING ((sum(actSales)-sum(budsales))/abs(sum(budsales)) >= 0.1 OR (sum(actprofit)-sum(budprofit))/abs(sum(budprofit)) >= 0.1)
ORDER BY ratiosales DESC, ratioprofit DESC;

-- D. 
--1.	In each market, which products have the greatest increase in profits? 
DROP VIEW temp_data;
CREATE VIEW temp_data AS
SELECT statemkt,prodname, 100*((Yr2013- Yr2012)/abs(Yr2012)) as prc_chng
FROM (SELECT statemkt,b.prodname, EXTRACT(YEAR from a.factdate) as year_no, sum(a.actprofit) as totprofit
FROM Factcoffee a, Prodcoffee b,State_Mkt_Sales c 
WHERE a.productid= b.productid and c.productid = a.productid
GROUP BY statemkt,b.prodname, EXTRACT(YEAR from a.factdate))
PIVOT (
SUM(totprofit) 
FOR year_no in (2012 as yr2012, 2013 as yr2013))
WHERE Yr2012<>0 AND Yr2012 IS NOT NULL AND Yr2013 IS NOT NULL
ORDER BY statemkt,prc_chng DESC;

SELECT b.STATEMKT,b.PRODNAME ,max_chg
FROM (SELECT STATEMKT, MAX(PRC_CHNG)as max_chg
FROM temp_data GROUP BY STATEMKT)a, temp_data b 
WHERE a.STATEMKT = b.STATEMKT
AND a.max_chg = b.PRC_CHNG;

--2.	In each market, which product types have greatest increase in sales? 
DROP VIEW temp_data;
CREATE VIEW temp_data AS
SELECT statemkt,prodtype, 100*((Yr2013- Yr2012)/abs(Yr2012)) as prc_chng
FROM (SELECT statemkt,b.prodtype, EXTRACT(YEAR from a.factdate) as year_no, sum(a.actsales) as totsales
FROM Factcoffee a, Prodcoffee b,State_Mkt_Sales c 
WHERE a.productid= b.productid and c.productid = a.productid
GROUP BY statemkt,b.prodtype, EXTRACT(YEAR from a.factdate))
PIVOT (
SUM(totsales) 
FOR year_no in (2012 as yr2012, 2013 as yr2013))
WHERE Yr2012<>0 AND Yr2012 IS NOT NULL AND Yr2013 IS NOT NULL
ORDER BY statemkt,prc_chng DESC;

select * from temp_data;

SELECT b.STATEMKT,b.PRODTYPE 
FROM (SELECT STATEMKT, MAX(PRC_CHNG)as max_chg
FROM temp_data GROUP BY STATEMKT)a, temp_data b 
WHERE a.STATEMKT = b.STATEMKT
AND a.max_chg = b.PRC_CHNG;

--3.	Have all products within the product types show similar behavior, or some products within a product type have greatest increase in sales?

DROP VIEW temp_data;
CREATE VIEW temp_data AS
SELECT prodtype,prodname, 100*((Yr2013- Yr2012)/abs(Yr2012)) as prc_chng
FROM (SELECT b.prodtype,b.prodname, EXTRACT(YEAR from a.factdate) as year_no, sum(a.actsales) as totsales
FROM Factcoffee a, Prodcoffee b 
WHERE a.productid= b.productid  
GROUP BY b.prodtype,prodname, EXTRACT(YEAR from a.factdate))
PIVOT (
SUM(totsales) 
FOR year_no in (2012 as yr2012, 2013 as yr2013))
WHERE Yr2012<>0 AND Yr2012 IS NOT NULL AND Yr2013 IS NOT NULL
ORDER BY prodtype,prc_chng DESC;
/*% change in sales by products within Espresso isclose to 4% for all. Finding the max below*/

SELECT b.prodtype,b.PRODNAME
FROM (SELECT prodtype, MAX(PRC_CHNG)as max_chg
FROM temp_data GROUP BY prodtype)a, temp_data b 
WHERE a.prodtype = b.prodtype
AND a.max_chg = b.PRC_CHNG;

--E.
--1.	Which top 5 states have the lowest market expenses as a percentage of their sales?  
SELECT * FROM(
SELECT STATENAME, 100*(SUM(ACTEXPENSES)/SUM(ACTSALES)) as exp_ratio
FROM States a, areacode c, factcoffee b 
WHERE a.stateid = c.stateid and c.areaid = b.areaid
GROUP BY STATENAME
ORDER BY exp_ratio
) WHERE ROWNUM <=5;

--2.	Do the above 5 states also have the highest profits as a percentage of sales?
SELECT * FROM(
SELECT STATENAME, 100*(SUM(ACTPROFIT)/SUM(ACTSALES)) as profit_ratio
FROM States a, areacode c, factcoffee b 
WHERE a.stateid = c.stateid and c.areaid = b.areaid
GROUP BY STATENAME
ORDER BY profit_ratio DESC
) WHERE ROWNUM <=5;
/*YES..except California!*/

--3.	Are there any particular product(s) within these markets with the least marketing expenses? 
DROP VIEW TEMP_EXP;
CREATE VIEW temp_exp AS 
SELECT STATEMKT, PRODNAME,100*(SUM(ACTEXPENSES)/SUM(ACTSALES)) as exp_ratio,SUM(ACTEXPENSES) as Tot_expenses
FROM States a, areacode c, factcoffee b,prodcoffee d 
WHERE a.stateid = c.stateid and c.areaid = b.areaid and d.productid = B.Productid
GROUP BY STATEMKT, PRODNAME
ORDER BY Statemkt, exp_ratio Asc;

SELECT b.STATEMKT,b.PRODNAME
FROM (SELECT STATEMKT, MIN(EXP_ratio)as min_exp
FROM temp_exp GROUP BY STATEMKT)a, temp_exp b 
WHERE a.STATEMKT = b.STATEMKT
AND a.min_exp = b.exp_ratio;

SELECT b.STATEMKT,b.PRODNAME
FROM (SELECT STATEMKT, MIN(Tot_Expenses)as min_exp
FROM temp_exp GROUP BY STATEMKT)a, temp_exp b 
WHERE a.STATEMKT = b.STATEMKT
AND a.min_exp = b.Tot_expenses;

--F. DOUBT
--1.	Which 5 states have the highest marketing expenses as a percentage of sales?
--Are these marketing expenses justified? (Note: you need to think how you will justify high marketing expenses)?
SELECT * FROM(
SELECT STATENAME, 100*(SUM(ACTEXPENSES)/SUM(ACTSALES)) as exp_ratio,sum(actprofit) as tot_profit,
SUM(ACTEXPENSES) as totexpen,SUM(ACTSALES) as tot_sales
FROM States a, areacode c, factcoffee b 
WHERE a.stateid = c.stateid and c.areaid = b.areaid
GROUP BY STATENAME
ORDER BY exp_ratio DESC
) WHERE ROWNUM <=5;

--2.	In each of these 5 states, do any area codes spend too much on marketing expenses relative to others? 

SELECT STATENAME,c.Areaid, 100*(SUM(ACTEXPENSES)/SUM(ACTSALES)) as exp_ratio, sum(ACTEXPENSES) as totexp
FROM States a, areacode c, factcoffee b 
WHERE a.stateid = c.stateid and c.areaid = b.areaid
AND STATENAME  in ('New Mexico','New Hampshire','Missouri','Utah','Wisconsin')
GROUP BY STATENAME,c.Areaid
ORDER BY STATENAME, exp_ratio DESC,totexp desc;


--G.
--1.	You are in a high-level strategy meeting to discuss how to improve performance. 
--This may involve shutting down stores in losing area codes and/or expanding in very profitable/high growth area.  
--Evaluate the data and recommend which stores to close and where? 

select a.areaid, a.statename, a.perinc as perprofit, b.perinc as persales from 
(select areaid, statename, fyear, syear, 100*(syear-fyear)/abs(fyear) as perinc
from (
select * from (
select areacode.areaid,statename, extract(year from factdate) as years, sum(actprofit) as totprofits
from areacode,states,factcoffee
where areacode.areaid=factcoffee.areaid and states.stateid= areacode.stateid
group by areacode.areaid,statename, extract(year from factdate)
)
pivot (sum(totprofits)
for years in (2012 as fyear,2013 as syear)
))
where fyear<>0
order by perinc ASC) a,
(select areaid, statename, fyear, syear, 100*(syear-fyear)/abs(fyear) as perinc
from (
select * from (
select areacode.areaid,statename, extract(year from factdate) as years, sum(actsales) as totsales
from areacode,states,factcoffee
where areacode.areaid=factcoffee.areaid and states.stateid= areacode.stateid
group by areacode.areaid,statename, extract(year from factdate)
)
pivot (sum(totsales)
for years in (2012 as fyear,2013 as syear)
))
where fyear<>0
order by perinc ASC) b 
where a.areaid = b.areaid
order by perprofit asc , persales desc;
---Well established store that might be making losses and then discounts, so ,a lot of sales

--2.	Where should the firm focus on expanding?
select a.areaid, a.statename, a.perinc as perprofit, b.perinc as persales from 
(select areaid, statename, fyear, syear, 100*(syear-fyear)/abs(fyear) as perinc
from (
select * from (
select areacode.areaid,statename, extract(year from factdate) as years, sum(actprofit) as totprofits
from areacode,states,factcoffee
where areacode.areaid=factcoffee.areaid and states.stateid= areacode.stateid
group by areacode.areaid,statename, extract(year from factdate)
)
pivot (sum(totprofits)
for years in (2012 as fyear,2013 as syear)
))
where fyear<>0
order by perinc ASC) a,
(select areaid, statename, fyear, syear, 100*(syear-fyear)/abs(fyear) as perinc
from (
select * from (
select areacode.areaid,statename, extract(year from factdate) as years, sum(actsales) as totsales
from areacode,states,factcoffee
where areacode.areaid=factcoffee.areaid and states.stateid= areacode.stateid
group by areacode.areaid,statename, extract(year from factdate)
)
pivot (sum(totsales)
for years in (2012 as fyear,2013 as syear)
))
where fyear<>0
order by perinc ASC) b 
where a.areaid = b.areaid and b.perinc <=0 
order by perprofit desc;
---------------------------------------------------
select areaid, statename, fyear, syear, 100*(syear-fyear)/abs(fyear) as perinc
from (
select * from (
select areacode.areaid,statename, extract(year from factdate) as years, sum(actprofit) as totprofits
from areacode,states,factcoffee
where areacode.areaid=factcoffee.areaid and states.stateid= areacode.stateid
group by areacode.areaid,statename, extract(year from factdate)
)
pivot (sum(totprofits)
for years in (2012 as fyear,2013 as syear)
))
where fyear<>0
order by perinc DESC;



--------------------------------- PART B : OFFICE PRODUCT ------------------------------------

--Question 1.
--DONE

--Question 2.
--a)
select (a.totorder/(a.totorder+b.totorder)) as perc_returned FROM
(select  count(orderid)as totorder from orders where status = 'Returned' ) a,
(select  count(orderid) as totorder from orders where status is null ) b 
;
--b)
select sum(ordsales)  
from orderdet a , Orders b 
where a.orderid = b.orderid
and b.status='Returned';

--c)
select * from (select a.custid,C.Custname, count(a.orderid) as canc_ord
from orderdet a , orders b , customers c
where a.orderid=b.orderid and c.custid = a.custid
and b.status='Returned'
group by a.custid,C.Custname
order by canc_ord desc) where rownum<=5;

select * from(select a.CustID, sum(ordsales)  as tot_sales
from orderdet a , Orders b 
where a.orderid = b.orderid
and b.status='Returned'
group by a.custid
order by tot_sales desc) where rownum<=5;

--Question 3.
--a).: doubt 
select * from(select a.CustID,c.custname, sum(ordsales)  as tot_sales
from orderdet a , Orders b,customers c 
where a.orderid = b.orderid and c.custid = a.custid
and b.status is NULL
group by a.custid,c.custname
order by tot_sales desc) where rownum<=10;

--b).
select * from (
select a.custid, b.prodcat, count(a.orderid) as totorders
from orderdet a , products b 
where a.prodid = b.prodid
group by a.custid, b.prodcat
order by a.custid, totorders desc)
Pivot(
sum(totorders) 
for prodcat in ('Technology' as tech, 'Furniture' as furn, 'Office Supplies' as ofc))
Where (abs(tech-furn)>=5 or abs(tech-ofc)>=5 or abs(ofc-furn)>=5 )
order by Tech desc, furn desc, ofc desc;

/*These people tend to buyu Office Supplies more often . They can have a potential to buy tht Office Furniture as well*/


--Question 4.
--a.) 
select ((sum(actsales)- sum(theosales))/sum(theosales))*100 as prc_chng FROM(
Select b.custid, b.orderid, a.prodid, a.prodname, (a.unitprice * b.ordqty*(1-b.orddiscount) + b.ordshipcost) as theosales, b.ordsales as actsales
from products a , Orderdet b 
where a.prodid = b.prodid);

--b). 
select regid, regmanager, ((sum(actsales)- sum(theosales))/sum(theosales))*100 as prc_chng From (
Select c.regid, c.regmanager,(a.unitprice * b.ordqty*(1-b.orddiscount) + b.ordshipcost) as theosales, b.ordsales as actsales
from products a , Orderdet b ,managers c,customers d
where a.prodid = b.prodid and c.regid = d.custreg and d.custid= b.custid)
group by regid, regmanager;
/**Sam and William are*/

--Question 5.
--a).
select prodid, prodname from products where Regexp_Like(prodname, '^.*[0-9]+.*$');

--b).
select * from (select prodname, sum(ordsales) as totsales 
from products a , orderdet b 
where a.prodid = b.prodid and extract(year from B.Orddate) = 2011
group by prodname
order by totsales DESC)where rownum <=5;

--c).
select * from (select prodname, sum(ordsales * prodmargin) as totmargin 
from products a , orderdet b 
where a.prodid = b.prodid 
group by prodname
order by totmargin DESC)where rownum <=10;

--d).
select * from (select prodname, sum(ordsales) as totsales 
from products a , orderdet b 
where a.prodid = b.prodid 
group by prodname
order by totsales ASC)where rownum <=10;

