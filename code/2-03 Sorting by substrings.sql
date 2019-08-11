select ename, job, substring(job, len(job)-2, 2) as [last_two]
  from emp
 order by substring(job, len(job)-2, 2)