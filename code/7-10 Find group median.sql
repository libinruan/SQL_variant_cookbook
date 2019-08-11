
-- step 3. compute the median part I
select deptno, avg(sal) as median
  from 
(

-- step 2. locate the median by the CASE expression
select *,
       cast(x.total as float)/2 as mid,
	   ceiling(cast(x.total as float)/2) as next 
  from 
(
-- step 1. count all and assign row number
select deptno,
       ename,
	   sal,
	   count(*) over (partition by deptno) total,
	   row_number() over (partition by deptno order by sal) rn
  from emp
) x
) y

-- step 3. compute the median part II
 where (total%2 = 0 and rn in (mid, next))
    or (total%2 = 1 and rn = next)
 group by deptno
-- note: no double equal sign is needed. modulo symbol is %
