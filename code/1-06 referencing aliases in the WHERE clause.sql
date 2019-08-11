/* the following is false.

select sal as [salary], comm as [commission]
  from emp
 where salary < 5000;

*/ 

select ename, salary, commission
  from (
select ename, sal as salary, comm as commission
  from emp
       ) x  --- Don't forget it.
 where salary >= 2000;
 
-- note: you need to use an outer query to reference 
-- aliases, window functions, aggregation function, etc.

