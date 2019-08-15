--- 7-9 use dense_rank to find mode.sql
select deptno,
       sal
  from (
--- step 2. dense rank
select deptno, 
       sal,
       dense_rank() over(order by cnt desc) as rnk 
  from (    
--- step 1. count by sal in each department
select deptno,
       sal,
       count(*) as cnt
  from emp
 group by deptno, sal   
--- If you only want to show the mode of a particular department
--- then remove all the "deptno," and add "where deptno = 10"
--- here, for example.    
       ) x 
       ) y
--- step 3. choose rank = 1
where rnk = 1

--- note: there is no mode in department 10,
--- because no duplicates in salary are shown in department 10.