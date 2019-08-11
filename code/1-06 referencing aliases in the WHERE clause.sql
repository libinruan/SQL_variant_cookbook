/* the following is false.

select sal as [salary], comm as [commission]
  from emp
 where salary < 5000;

*/ 

select *
  from (
select sal as salary, comm as commission
  from emp
       ) x
 where salary < 5000;
 
-- note: you need to use an outer query to reference 
-- aliases, window functions, aggregation function, etc.

