select e.empno,
       e.ename,
	   e.job,
	   e.sal,
	   e.deptno
  from emp as [e], v
 where e.ename = v.ename
   and e.job = v.job
   and e.sal = v.sal