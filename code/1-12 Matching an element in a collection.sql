select ename, job
  from emp
 where job in ('CLERK', 'ANALYST')
   and (ename like 'a%' or ename like '%r')
-- note: use only single quote.