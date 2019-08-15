--- 8-03b search two items in a column.sql
--- step 2. flag the weekdays
select sum(case when datename(dw, dateadd(day, v500.id-1, jones_hd)) in ('SATURDAY','SUNDAY') 
           then 0 else 1 end) as days 
/* 
select x.*, v500.*, datename(dw, dateadd(day, v500.id-1, jones_hd))
*/
  from ( 
--- step 1. Just in case BLAKE and JONES have multiple entries in the table
select max(case when ename = 'BLAKE' then hiredate end) as blake_hd,
       max(case when ename = 'JONES' then hiredate end) as jones_hd
  from emp
 where ename in ('BLAKE', 'JONES')
       ) x,
       v500
 where v500.id <= datediff(day,jones_hd, blake_hd) + 1       
