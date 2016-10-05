select b.prodname , to_char(factdate, 'yyyymm') as mon, sum(a.actsales)as totsales 
from factcoffee a
inner join 
products b 
on a.productid = b.prodid
group by prodname,to_char(factdate, 'yyyymm');


















