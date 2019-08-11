--- 3-04 find things in one table but not in another.sql
select deptno
  from dept
 where deptno not in 
(
select deptno
  from emp
)