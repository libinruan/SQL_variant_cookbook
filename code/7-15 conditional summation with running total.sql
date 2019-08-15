--- 7-15 conditional summation with running total.sql
select case when b1.trs = 'py' then 'payable'
            else 'receivable' end as [transaction type],
       b1.amt,     
       (
--- step 1. 
select sum(case when b2.trs = 'rc' then -b2.amt
                else b2.amt end)
  from bal1 b2
 where b2.id <= b1.id
       ) as balance
  from bal1 b1;