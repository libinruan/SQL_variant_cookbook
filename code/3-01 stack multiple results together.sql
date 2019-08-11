select ename as [ENAME AND DNAME], deptno as DEPTNO
  from emp
 where deptno = 10

 union all
 select top 1 '-------------------', null
   from emp
 
 union all
 select dname, deptno
   from dept

/* -- you can also replace the 2nd block 
   -- with this one. Use the pivot table 
   -- t1.
union all
select '-------------------', null
  from t1
*/