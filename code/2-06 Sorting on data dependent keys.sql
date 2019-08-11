select ename, 
       job,
       sal,
       comm,
       case when job = 'salesman' then comm  
            else sal  
       end as ordered
  from emp
 order by 5
/*-- don't use the CASE expression twice 
 order by case when job = 'salesman' then comm  
               else sal  
          end desc
*/

/* --But you can defer the use of the CASE expression
   -- to the ORDER BY as long as the CASE expression
   -- is not in the SELECT list.

   select ename,
          job,
          sal,
          comm
     from emp
    order by case when ...
*/