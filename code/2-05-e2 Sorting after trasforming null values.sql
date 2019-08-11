select ename, job, coalesce(comm,0) as [commission]
  from emp
 order by coalesce(comm, 0), desc