select top 1 with ties
       ename,
	   sal, 
	   job,
       deptno
  from emp
 order by row_number() 
          over(partition by deptno order by sal desc);		  