select *
  from emp
 where (deptno = 30 and coalesce(comm, 0) > 0)
    or (deptno = 10 and sal between 1000 and 2000)

---note: In the "BETWEEN A AND B" expression, 
---A has to be smaller than B.
---note: COALESCE returns the first non-null value.