select distinct productid, prodname from prodcoffee;


--Q1: 
Select prodname, January_2012, February_2012, March_2012, April_2012, May_2012, June_2012, July_2012, August_2012, September_2012, October_2012, November_2012, December_2012,
January_2013, February_2013, March_2013, April_2013, May_2013, June_2013, July_2013, August_2013, September_2013, October_2013, November_2013, December_2013 from (
Select b.prodname , to_char(factdate, 'yyyymm') as mon, sum(a.actsales)as totsales 
from factcoffee a
inner join 
prodcoffee b 
on a.productid = b.productid
group by prodname,to_char(factdate, 'yyyymm'))
PIVOT (
sum(totsales) 
FOR Mon in ('201201' as January_2012, 
            '201202' as February_2012, 
            '201203' as March_2012, 
            '201204' as April_2012, 
            '201205' as May_2012, 
            '201206' as June_2012, 
            '201207' as July_2012, 
            '201208' as August_2012, 
            '201209' as September_2012, 
            '201210' as October_2012, 
            '201211' as November_2012, 
            '201212' as December_2012, 
            '201301' as January_2013, 
            '201302' as February_2013, 
            '201303' as March_2013, 
            '201304' as April_2013, 
            '201305' as May_2013, 
            '201306' as June_2013, 
            '201307' as July_2013, 
            '201308' as August_2013, 
            '201309' as September_2013, 
            '201310' as October_2013, 
            '201311' as November_2013, 
            '201312' as December_2013)
);

--Q2:

--2.	In each state, identify the product with greatest sales for the year 2012.
create view maxsales_2012 as 
Select * from (SELECT c.Statename, b.prodname,
sum(a.actsales) sumsales,
row_number() over (partition by statename order by sum(actsales) Desc ) as rankid 
from factcoffee a , prodcoffee b, states c, areacode d
where a.areaid= d.areaid and d.stateid= c.stateid and b.productid= A.Productid
and extract(year from factdate) = 2012
group by prodname, statename)
Where rankid =1 ;
select * from maxsales_2012;

--1) 
--i)	Identify the states where the best selling product remained the same in 2013 (compared to best selling product in 2012)

create view maxsales_2013 as 
Select * from (SELECT c.Statename, b.prodname,
sum(a.actsales) sumsales,
rank() over (partition by statename order by sum(actsales) Desc ) as rankid 
from factcoffee a , prodcoffee b, states c, areacode d
where a.areaid= d.areaid and d.stateid= c.stateid and b.productid= A.Productid
and extract(year from factdate) = 2013
group by prodname, statename)
Where rankid =1 ;


Select a.statename from 
maxsales_2013 a inner join maxsales_2012 b  
on a.statename=b.statename 
where a.prodname = b.prodname;

--ii)	Identify the states where the best selling product has changed.
Select a.statename from 
maxsales_2013 a inner join maxsales_2012 b  
on a.statename=b.statename 
where a.prodname != b.prodname;

--iii.	Identify the products that were best in 2012 but not in 2013.

Select a.prodname from 
maxsales_2012 a left join maxsales_2013 b  
on a.statename=b.statename 
where a.prodname != b.prodname;--- None

--iv.	Identify the top two best selling products that are common to both 2012 and 2013.
select * from (select prodname, sum(sumsales) as sumsales_all ,
rank() over  (order by sum(sumsales) desc) as rankid 
from maxsales_2012
group by prodname) where rankid in (1,2);


--Q3: 
with cumsales as (select statename,sum(actsales) sumsales,sum(actprofit) sumprofit, row_number() over(order by sum(actsales) desc) rowsales from factcoffee a , states b , areacode c where a.areaid = c.areaid and c.stateid = b.stateid group by statename),
totalcount as (select count(*) as totcount from cumsales),
totsales as (select sum(sumsales) as totsumsales, sum(sumprofit) as totsumprofit from cumsales),
cumtotsales as (select rowsales, sum(sumsales) over (order by rowsales) Csales,sum(sumprofit) over (order by rowsales) Cprofit from cumsales)
select totcount,totsumsales,totsumprofit, rowsales,csales,cprofit,round(100*rowsales/totcount,2) , round(cprofit/totsumprofit *100,2) 
from totalcount,totsales,cumtotsales
where csales>=0.5*totsumsales and rownum = 1;

--Q4: 
select areaid, Yr2012, yr2013, ROUND((100*(yr2013- yr2012)/abs(yr2012)),2) as perc_change 
from (select areaid, sum(actprofit) as totprofit, extract(year from factdate) as yr
from factcoffee 
group by areaid, extract(year from factdate))
Pivot(
sum(totprofit) 
For yr in (2012 as Yr2012, 2013 as Yr2013) 
)
order by perc_change; 

--Q5: 
select a.statename, a.prodname, Yr2012_p, yr2013_p, perc_change_p, Yr2012_s, yr2013_s, perc_change_s  
from (
select statename, prodname, Yr2012_p, yr2013_p, ROUND((100*(yr2013_p- yr2012_p)/abs(yr2012_p)),2) as perc_change_p 
from (select statename, prodname, sum(actprofit) as totprofit,extract(year from a.factdate) as yr
from factcoffee a, prodcoffee b, states c, areacode d where a.productid=b.productid and c.stateid = d.stateid and d.areaid= a.areaid 
group by statename, prodname, extract(year from factdate))
Pivot(
sum(totprofit) 
For yr in (2012 as Yr2012_p, 2013 as Yr2013_p))
where Yr2012_p is not null and Yr2013_p is not null  and  Yr2012_p<>0
order by perc_change_p) a ,
(select statename, prodname, Yr2012_s, yr2013_s, ROUND((100*(yr2013_s- yr2012_s)/abs(yr2012_s)),2) as perc_change_s 
from (select statename, prodname, sum(actsales) as totsales,extract(year from a.factdate) as yr
from factcoffee a,  prodcoffee b ,states c, areacode d where a.productid=b.productid and c.stateid = d.stateid and D.areaid= a.areaid 
group by statename, prodname, extract(year from factdate))
Pivot(
sum(totsales) 
For yr in (2012 as Yr2012_s, 2013 as Yr2013_s))
where Yr2012_s is not null and Yr2013_s is not null  and  Yr2012_s<>0
order by perc_change_s) b 
where a.prodname = b.prodname and a.statename = b.statename and perc_change_p <= 0 and  yr2012_p-yr2013_p >= 500 
order by perc_change_p; 

--Q6 :

select a.areaid, a.prodname, Yr2012_p, yr2013_p, perc_change_p, Yr2012_s, yr2013_s, perc_change_s  , diff_p, diff_s
from (
select areaid, prodname, Yr2012_p, yr2013_p, ROUND((100*(yr2013_p- yr2012_p)/abs(yr2012_p)),2) as perc_change_p, (yr2013_p- yr2012_p) as diff_p 
from (select areaid, prodname, sum(actprofit) as totprofit,extract(year from a.factdate) as yr
from factcoffee a, prodcoffee b  where a.productid=b.productid 
group by areaid, prodname, extract(year from factdate))
Pivot(
sum(totprofit) 
For yr in (2012 as Yr2012_p, 2013 as Yr2013_p))
where Yr2012_p is not null and Yr2013_p is not null  and  Yr2012_p<>0
order by perc_change_p) a ,
(select areaid, prodname, Yr2012_s, yr2013_s, ROUND((100*(yr2013_s- yr2012_s)/abs(yr2012_s)),2) as perc_change_s ,(yr2013_s- yr2012_s) as diff_s
from (select areaid, prodname, sum(actsales) as totsales,extract(year from a.factdate) as yr
from factcoffee a, prodcoffee b  where a.productid=b.productid 
group by areaid, prodname, extract(year from factdate))
Pivot(
sum(totsales) 
For yr in (2012 as Yr2012_s, 2013 as Yr2013_s))
where Yr2012_s is not null and Yr2013_s is not null  and  Yr2012_s<>0
order by perc_change_s) b 
where a.prodname = b.prodname and a.areaid = b.areaid and perc_change_p >= 0 and  perc_change_s >= 0 and yr2013_p >=1000
order by perc_change_p desc; 
/**read and understand the above question **/


select a.areaid, a.prodname, Yr2012_p, yr2013_p, perc_change_p, Yr2012_s, yr2013_s, perc_change_s  , diff_p, diff_s
from (
select areaid, prodname, Yr2012_p, yr2013_p, ROUND((100*(yr2013_p- yr2012_p)/abs(yr2012_p)),2) as perc_change_p, (yr2013_p- yr2012_p) as diff_p 
from (select areaid, prodname, sum(actprofit) as totprofit,extract(year from a.factdate) as yr
from factcoffee a, prodcoffee b  where a.productid=b.productid 
group by areaid, prodname, extract(year from factdate))
Pivot(
sum(totprofit) 
For yr in (2012 as Yr2012_p, 2013 as Yr2013_p))
where Yr2012_p is not null and Yr2013_p is not null  and  Yr2012_p<>0
order by perc_change_p) a ,
(select areaid, prodname, Yr2012_s, yr2013_s, ROUND((100*(yr2013_s- yr2012_s)/abs(yr2012_s)),2) as perc_change_s ,(yr2013_s- yr2012_s) as diff_s
from (select areaid, prodname, sum(actsales) as totsales,extract(year from a.factdate) as yr
from factcoffee a, prodcoffee b  where a.productid=b.productid 
group by areaid, prodname, extract(year from factdate))
Pivot(
sum(totsales) 
For yr in (2012 as Yr2012_s, 2013 as Yr2013_s))
where Yr2012_s is not null and Yr2013_s is not null  and  Yr2012_s<>0
order by perc_change_s) b 
where a.prodname = b.prodname and a.areaid = b.areaid and perc_change_p >= 0 and  perc_change_s >= 0 and perc_change_s<=50 and yr2013_s <=200
order by perc_change_p desc; 

--__Incomplete__

--Q7:
SET TRIMSPOOL ON
spool C:\Users\stuti\Desktop\Q7.csv
select to_char(factdate, 'yyyymm') as month_name, 
sum(actsales) as tot_sales
from factcoffee 
group by to_char(factdate, 'yyyymm');
spool off         


select  mon, prod1 , prod2, prod3 , prod4, prod5, prod6,
prod7, prod8, prod9,prod10, prod11, prod12, prod13
from (select  productid,extract(month from factdate) as mon,sum(actsales) as tot_sales_2013
from factcoffee a, areacode b , states c where c.stateid = b.stateid and a.areaid = b.areaid
group by statename, productid, extract(month from factdate))
pivot(
sum(tot_sales_2013)
for productid in (1 as prod1,
                  2 as prod2,
                  3 as prod3,
                  4 as prod4,
                  5 as prod5,
                  6 as prod6,
                  7 as prod7,
                  8 as prod8,
                  9 as prod9,
                  10 as prod10,
                  11 as prod11,
                  12 as prod12,
                  13 as prod13))
order by mon;



select  statename, mon,prod1 , prod2, prod3 , prod4, prod5, prod6,
prod7, prod8, prod9,prod10, prod11, prod12, prod13
from (select statename, productid,to_char(factdate, 'yyyymm') as mon,sum(actsales) as tot_sales_2013
from factcoffee a, areacode b , states c where b.stateid = c.stateid and a.areaid = b.areaid
group by statename, productid, to_char(factdate, 'yyyymm'))
pivot(
sum(tot_sales_2013)
for productid in (1 as prod1,
                  2 as prod2,
                  3 as prod3,
                  4 as prod4,
                  5 as prod5,
                  6 as prod6,
                  7 as prod7,
                  8 as prod8,
                  9 as prod9,
                  10 as prod10,
                  11 as prod11,
                  12 as prod12,
                  13 as prod13))
order by statename, mon;
--INCOMPLETE

--Q8:
alter table factcoffee add quarter varchar2(2);
update factcoffee set quarter = 'Q' || to_char(factdate, 'Q') ;
select ProductId, AreaID, FactDate, Quarter from factcoffee;
--sales--
select yrs, Q1, Q2, Q3, Q4 from (select quarter, extract(year from factdate) as yrs ,sum(actsales) as totsales
from factcoffee
group by quarter, extract(year from factdate))
pivot(
sum(totsales)
for quarter in ('Q1' as Q1, 'Q2' as Q2, 'Q3' as Q3, 'Q4' as Q4)
)order by yrs;
--profits--


select yrs, Q1, Q2, Q3, Q4 from (select quarter, extract(year from factdate) as yrs ,sum(actprofit) as totprofit
from factcoffee
group by quarter, extract(year from factdate))
pivot(
sum(totprofit)
for quarter in ('Q1' as Q1, 'Q2' as Q2, 'Q3' as Q3, 'Q4' as Q4)
)order by yrs;

--Q9:

Create table combined as
select a.statename, b.prodname, c.quarter, sum(c.actsales) as totsales, sum(c.actprofit) as totprofit, sum(c.actmarkcost) as totmarket, 
round(100*(sum(c.actmargin)/ sum(c.actsales)),2) as perc_margin, rank() over (partition by a.statename, b.prodname order by sum(c.actsales) Desc ) as rankid
from factcoffee c , prodcoffee b , states a, areacode d 
where c.areaid = d.areaid and b.productid = c.productid and a.stateid = d.stateid
group by a.statename, b.prodname, c.quarter;
select * from combined;

------PART B -----------
--Q1: 
select a.regmanager, round(sum(c.ordsales),1) as totsales , rank() over (order by sum(c.ordsales) desc) as rankid
from managers a, customers b , orderdet c
where b.custreg = a.regid and b.custid = C.Custid
group by a.regmanager;

--Q2:

select prodname,round(avg((ordshipdate - orddate)),2) as shipping_days 
from orderdet a,products b ,orders c
where a.prodid = b.prodid and a.orderid = c.orderid and c.status is null
group by prodname 
order by shipping_days Desc;

--Q3:
WITH cumsales as (SELECT custid, sum(ordsales) totsales , rank() over (order by sum(ordsales) desc) rowsales
from orderdet group by custid), 
totalcount as (select count(*) as totcount from cumsales),
totsales as (select sum(totsales) as totoftotsales from cumsales), 
cumtotsales as (select rowsales, sum(totsales) over (order by rowsales) Csales from cumsales)
select totcount, totoftotsales, rowsales, csales, round(100*rowsales/totcount,2), round(100*(csales/totoftotsales),2) as prop_sales
from totalcount, totsales, cumtotsales
where rowsales>=0.1*totcount AND rownum = 1;

--Q4: 
WITH cumsales as (SELECT custid, sum(ordsales) totsales ,count(orderid) as num_orders, rank() over (order by sum(ordsales) desc) rowsales
from orderdet group by custid), 
totalcount as (select count(*) as totcount from cumsales),
totsales as (select sum(totsales) as totoftotsales, sum(num_orders) as tot_numorders from cumsales), 
cumtotsales as (select rowsales, sum(totsales) over (order by rowsales) Csales,sum(num_orders) over (order by rowsales) Cnum from cumsales)
select totcount, totoftotsales,tot_numorders, rowsales, csales,cnum, round(100*rowsales/totcount,2), round(100*(csales/totoftotsales),2) as prop_sales,round(100*(cnum/tot_numorders),2) as prop_num
from totalcount, totsales, cumtotsales
where rowsales>=0.1*totcount AND rownum = 1;

--Q5:
select extract(year from a.orddate) as year_var, count(distinct a.orderid) as tot_num, 
count(distinct c.orderid) as ret_num, 
round(sum(ordsales),0) as totordersales,
round(sum(ordshipcost),0) as totordershipcost
from orderdet a inner join orders b on a.orderid = b.orderid 
left join (select orderid from orders where status='Returned') c 
on a.orderid = c.orderid 
group by extract(year from a.orddate)
order by year_var asc;

-- Q6:
select custcity, prodname , sum(ordsales) as totsales , rank() over (partition by A.Custcity order by sum(ordsales) desc) as rankid
from customers a , products b, orderdet c 
where c.custid = a.custid and c.prodid = B.Prodid
group by custcity, prodname
order by custcity, rankid;


---Q7: New Solution 
Create view cust_2010 as 
select * from (select custid, round(sum(ordsales),1) as totsales_2010, 
rank() over (order by round(sum(ordsales),1) desc) as rankid
from orderdet a, orders b 
where a.orderid=b.orderid and b.status is null 
and extract(year from orddate) =2010
group by custid
order by rankid)
where rankid in (1,2,3,4,5);


Create view cust_2011 as 
select * from (select custid, round(sum(ordsales),1) as totsales_2011, 
rank() over (order by round(sum(ordsales),1) desc) as rankid
from orderdet a, orders b 
where a.orderid=b.orderid and b.status is null 
and extract(year from orddate) =2011
group by custid
order by rankid)
where rankid in (1,2,3,4,5);


Create view cust_2012 as 
select * from (select custid, round(sum(ordsales),1) as totsales_2012, 
rank() over (order by round(sum(ordsales),1) desc) as rankid
from orderdet a, orders b 
where a.orderid=b.orderid and b.status is null 
and extract(year from orddate) =2012
group by custid
order by rankid)
where rankid in (1,2,3,4,5);


Create view cust_2013 as 
select * from (select custid, round(sum(ordsales),1) as totsales_2013, 
rank() over (order by round(sum(ordsales),1) desc) as rankid
from orderdet a, orders b 
where a.orderid=b.orderid and b.status is null 
and extract(year from orddate) =2013
group by custid
order by rankid)
where rankid in (1,2,3,4,5);

select * from cust_2010;
select * from cust_2011;
select * from cust_2012;
select * from cust_2013;

--(b) 
select a.custid
from cust_2010 a 
inner join cust_2011 b on a.custid = b.custid
inner join cust_2012 c on a.custid = c.custid
inner join cust_2013 d on a.custid = d.custid;

--(c) 
select custid
from cust_2010 
minus select custid from cust_2011 
minus select custid from cust_2012
minus select custid from cust_2013;


select custid
from cust_2011 
minus select custid from cust_2010 
minus select custid from cust_2012
minus select custid from cust_2013;


select custid
from cust_2012 
minus select custid from cust_2011 
minus select custid from cust_2010
minus select custid from cust_2013;


select custid
from cust_2013
minus select custid from cust_2011 
minus select custid from cust_2012
minus select custid from cust_2010;

--Q7:INCOMPLETE

--(initial) 
select custid, yr2010, yr2011, yr2012, yr2013 from (select * from(
select extract(year from orddate) as yrs, custid, round(sum(ordsales),1) as totsales,
rank() over (partition by extract(year from orddate) order by round(sum(ordsales),1) desc ) as rankid
from orderdet a, orders b 
where a.orderid = b.orderid and b.status is null
group by extract(year from orddate), custid 
order by totsales desc) 
where rankid in (1,2,3,4,5))
pivot(
sum(totsales) for yrs in (2010 as yr2010, 2011 as yr2011, 2012 as yr2012, 2013 as yr2013));
--(ii)

select custid, yr2010, yr2011, yr2012, yr2013 from (select * from(
select extract(year from orddate) as yrs, custid, round(sum(ordsales),1) as totsales,
rank() over (partition by extract(year from orddate) order by round(sum(ordsales),1) desc ) as rankid
from orderdet a, orders b 
where a.orderid = b.orderid and b.status is null
group by extract(year from orddate), custid 
order by totsales desc) 
where rankid in (1,2,3,4,5))
pivot(
sum(totsales) for yrs in (2010 as yr2010, 2011 as yr2011, 2012 as yr2012, 2013 as yr2013))
where yr2010 is not null 
and yr2011 is not null
and yr2012 is not null 
and yr2013 is not null;

---(iii)
select distinct custid, yr2010, yr2011, yr2012, yr2013 from (select * from(
select extract(year from orddate) as yrs, custid, round(sum(ordsales),1) as totsales,
rank() over (partition by extract(year from orddate) order by round(sum(ordsales),1) desc ) as rankid
from orderdet a, orders b 
where a.orderid = b.orderid and b.status is null
group by extract(year from orddate), custid 
order by totsales desc) 
where rankid in (1,2,3,4,5))
pivot(
sum(totsales) for yrs in (2010 as yr2010, 2011 as yr2011, 2012 as yr2012, 2013 as yr2013))
;/*where (yr2010 is not null and yr2011 is null and yr2012 is null and yr2013 is  null)
or (yr2010 is  null and yr2011 is not null and yr2012 is null and yr2013 is  null)
or (yr2010 is  null and yr2011 is null and yr2012 is not null and yr2013 is  null) 
or (yr2010 is  null and yr2011 is null and yr2012 is null and yr2013 is not null);
*/
--Q8:
select Prodsubcat, Michigan, Washington from (select custstate, prodsubcat,count(distinct(orderid)) as num_ord
from customers a, orderdet b , products c 
where a.custid =b.custid and c.prodid=B.Prodid and custstate in ('Michigan','Washington') 
group by custstate,prodsubcat) 
pivot(
sum(num_ord)
For custstate in ('Michigan' as Michigan, 'Washington' as Washington))
;

--Q9:
select to_char(orddate, 'YYYY-Q') as Quarter, count(distinct orderid) as totOrders 
from orderdet 
group by to_char(orddate, 'YYYY-Q') 
order by Quarter;

--Q10:
select custseg, Q1_10,Q2_10,Q3_10,Q4_10,Q1_11,Q2_11,Q3_11,Q4_11,Q1_12,Q2_12,Q3_12,Q4_12, Q1_13,Q2_13,Q3_13,Q4_13 from (
select to_char(orddate, 'yyyy-Q') as quarter,custseg, round(sum(ordsales),2) as totsales
from customers  a , orderdet b 
where a.custid = b.custid
group by to_char(orddate, 'yyyy-Q'),custseg)
pivot(
sum(totsales) 
for quarter in ('2010-1' as Q1_10,
                '2010-2' as Q2_10,
                '2010-3' as Q3_10,
                '2010-4' as Q4_10,
                '2011-1' as Q1_11,
                '2011-2' as Q2_11,
                '2011-3' as Q3_11,
                '2011-4' as Q4_11,
                '2012-1' as Q1_12,
                '2012-2' as Q2_12,
                '2012-3' as Q3_12,
                '2012-4' as Q4_12,
                '2013-1' as Q1_13,
                '2013-2' as Q2_13,
                '2013-3' as Q3_13,
                '2013-4' as Q4_13
                ));