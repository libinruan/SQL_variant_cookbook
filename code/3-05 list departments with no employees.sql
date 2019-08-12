--- 3-05 list departments with no employees.sql
select d.* , e.*
  from dept as [d] left join emp as [e]
    on d.deptno = e.deptno
 where e.deptno is null 
--- note: we filter for nulls  