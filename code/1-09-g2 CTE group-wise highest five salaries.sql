with cte as (
select ename,
       sal,
	     job,
	     deptno,
	     row_number() 
       over(partition by deptno order by sal desc) as rn
  from emp
)
select *
  from cte
 where rn = 1