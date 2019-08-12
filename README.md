In this repository, I store SQL programs I created on basis of Anthony Molinaro's Amazon best selling book "SQL cookbook." I made quite a few revision and add some variant examples derived from the origin SQL challenges in the book so as to make the collection of SQL recipes here better suitable for a SQL job interview.

To get started run `build_shcema.sql` to establish the database ([table](https://www.oreilly.com/library/view/sql-cookbook/0596009763/pr04.html#I__tt3)) the author refer to throughout the book.

# Recipe 1

## Recipe 1.3 
Find all the employees in department 10 who earn a commission, and along with those in department 20 who earn at most \$2000 but at least \$1000. Order the result by department number.

## Recipe 1.6 
Give `sal` and `comm` aliased name `salary` and `commission`. Then show all the employees with salary more than \$2000 by referencing the alias of `sal` in a WHERE clause.

> Always give the result of an inline view (or subquery) a temporary name!

## Recipe 1.7 
Show employees in department 10 with their position titles in the format: "[name] works as a [title]."

## Recipe 1.8 
Show employee names (`ename`), salaries (`sal`), and a new column `status` indicating people are paid less than \$2000 as `underpaid`, those paid between \$4000 or more as `overpaid` and others as `ok`. 

## Recipe 1.9.e
Return the first 5 employees with highest salary in the dataset.

## Recipe 1.9.g 
(group-by version) Return the list of employees with the highest salary in each department.

## Recipe 1.9.g2 
(similar to group-by version, but with the CTE method)

## Recipe 1.10 
Use a simply random generator function for sampling from your dataset. 

## Recipe 1.11 
Add a new column to flag null commission values.

## Recipe 1.13 
List all the employees with a job title "clerk" or "analyst" and whose name starting with letter "A" or ending with letter "R." 
> Only use single quotes with string. 



# Recipe 2
## Recipe 2.3 
Show employee names and jobs from table `emp` and sort by the last two characters in the `job` field.

> Use SUBSTRING() to return a continuous subset from a string.

## Recipe 2.4.e 
Sort results from `emp` by `comm` , some of which are null. Let non-null values show up first.

> A null value is smaller** than any real number.

## Recipe 2.4.g 
Sort results from `emp` by `comm`, after null values in the filed `comm` have been transformed to integer zero.

## Recipe 2.5
Sort by a particular field after transforming null values to zero.

## Recipe 2.6 
If `job` is 'salesman' sort on `comm`; otherwise, sort by `sal`.
> You can use the CASE expression to dynamically change how results are sorted.



# Recipe 3

## Recipe 3.1 
Stack one row sets atop another with heterogeneous number and order of fields. In specific, show people from department = 10 on top of all the department names.
> Use "NULL" as a place holder when you want a certain field to be blank in the result.

## Recipe 3.3v 
Return rows in one table with additional information appended from another tables.

Give a view like the one below and append remaining columns with corresponding values.

```sql
create view v1 as
select ename, job, sal
  from emp
 where job = 'CLERK';
```
> In SQL, a view is a virtual table based on the result-set of an SQL statement.

The result looks like this:

![](https://i.postimg.cc/Fzd4Lc11/screenshot-243.png)

```sql
--- 3-03v inner join with a view + where.sql
select e.empno,
       e.ename,
	   e.job,
	   e.sal,
	   e.deptno
  from emp as [e], v1
 where e.ename = v1.ename
   and e.job = v1.job
   and e.sal = v1.sal;
```

## Recipe 3.3i 
(continued) Use `inner join` (inner is optional) instead to perform the same task.
```sql
--- 3-03i inner join with normal join on.sql
select e.empno,
       e.ename,
	   e.job,
	   e.sal,
	   e.deptno
  from emp as [e] join v
    on e.ename = v.ename
   and e.job = v.job
   and e.sal = v.sal;
```

## Recipe 3.4* 
Show all the department numbers in Table `dept` but not in Table `emp`.

```sql
--- 3-04m find things in one table but not in another.sql
select distinct deptno
  from dept
 where deptno not in 
(
select deptno
  from emp
);
```
Use DISTINCT() to avoid returning duplicate results (that is, more than one person come from the department missing from Table `deptno`)

Another issue arises from the fact that the NOT IN expression actually consists of multiple OR operations. And in SQL, the condition "TRUE or NULL" results in **true**, but the condition =="FALSE or NULL" results in **null**==. It implies that once we have null in a multiple-OR condition, we would continue to have null result.

To solve this issue (that is, a multiple-OR-conditions-like NOT IN expression possibly contains NULL comparison outcomes), use a correlated subquery in conjunction with ==NOT EXISTS.== 

```sql
--- 3-04b find things not in another table.sql
select distinct deptno 
  from dept as [d]
 where not exists
(
select null   
  from emp as [e]
 where d.deptno = e.deptno  
);
```



## Recipe 3.5 
List all the departments that have no employee.
Note: we have the full list of departments in Table `dept`, and the full list of employees in Table `emp`.

> As in Recipes 3.4 and 3.5: we should place the table with **more** information to be in the **outer** query.

```sql
--- 3-05 list departments with no employees.sql
select d.* , e.*
  from dept as [d] left join emp as [e]
    on d.deptno = e.deptno
 where e.deptno is null; 
--- note: we filter for nulls in Table emp. 
```



## Recipe 3.6 
Return all employees, the location of the department where they work, and the date of bonus if they received one. (order by location). The result should look like this one:

![](https://i.postimg.cc/k58sNTW3/screenshot-302.png)

> That is, Use outer join the third table without interfering the joining results of the preceding tables.

## Recipe 3.7 
Count duplicates and missing data. Compare with Table`emp` an artificial table v2 that contains duplicated data of employee "WARD" and people who do not work in department 10 . Try to show the duplicated data and missing data from v2 in comparison to Table `emp`. 

```sql
create view v2 as
select * from emp where deptno != 10
 union all
select * from emp where ename = 'WARD'; --- WARD is added one more time.
```

![](https://i.postimg.cc/yxwWTyFt/screenshot-303.png)

The solution code could be broken into two major parts. ==In the first part, we identify the missing data from Table v2. In the second part, we filter for duplicated data that show in Table v2==.

```sql
--- Section 1
select *
  from 
(
select e.empno, e.ename, e.job, e.mgr, 
       e.hiredate, e.sal, e.comm, e.deptno, 
	   count(*) as cnt
  from emp e
 group by empno, ename, job, mgr, hiredate, sal, comm, deptno
) e
 where not exists
(
select null 
  from 
(
select v.empno, v.ename, v.job, v.mgr, v.hiredate,
       v.sal, v.comm, v.deptno, count(*) as cnt
  from v2 as v
 group by empno, ename, job, mgr, hiredate, sal, comm, deptno
) v
 where v.empno    = e.empno
   and v.ename    = e.ename
   and v.job      = e.job
   and v.mgr      = e.mgr
   and v.hiredate = e.hiredate
   and v.sal      = e.sal
   and v.deptno   = e.deptno
   and v.cnt      = e.cnt
   and coalesce(v.comm, 0) = coalesce(e.comm, 0)
)
```

The outcome of the section 1 looks like this:

![](https://i.postimg.cc/G2P1fJw6/screenshot-305.png)

Similarly. We want to filter for duplicates that occur in Table v2.

```sql
--- section 2
select *
  from (
select v.empno, v.ename, v.job, v.mgr, v.hiredate,
       v.sal, v.comm, v.deptno, count(*) as cnt
  from v2 as v
 group by v.empno, v.ename, v.job, v.mgr, v.hiredate,
       v.sal, v.comm, v.deptno
       ) v
 where not exists (
select null
  from (
select e.empno, e.ename, e.job, e.mgr, e.hiredate,
       e.sal, e.comm, e.deptno, count(*) as cnt
  from emp as e
 group by empno, ename, job, mgr, hiredate, sal, comm, deptno
       ) e
 where v.empno    = e.empno
   and v.ename    = e.ename
   and v.job      = e.job 
   and v.mgr      = e.mgr
   and v.hiredate = e.hiredate
   and v.sal      = e.sal
   and v.deptno   = e.deptno
   and v.cnt      = e.cnt
   and coalesce(v.comm, 0) = coalesce(e.comm, 0)
       )
```

![](https://i.postimg.cc/1zHHYf7J/screenshot-306.png)

> Union only combines distinct data as opposed to Union ALL.



## Recipe 3.8 
Return the name of employees in department 10 along with the location of respective department. The result is as the following: 

![](https://i.postimg.cc/5yvpgphF/screenshot-307.png)

>  Avoid cartesian product 
```sql
--- 3-08 avoid cartesian product.sql
select e.ename, d.loc
  from emp e, dept d
 where e.deptno = 10
   and e.deptno = d.deptno
```

## Recipe 3.9d* 
Aggregate the salaries (from table `emp`) and the bonus (from table `emp_bonus`) for people in department 10 only. Issues come from that someone received multiple bonus, thus appearing twice, which causes the guy's salaries double-counted. 

> Introduction to windowed functions ([link](https://sqlsunday.com/2013/03/31/windowed-functions/))

```sql
--- 3.9d sum distinct.sql
select deptno,
       sum(distinct sal) as total_sal,
	   sum(bonus) as total_bonus
  from (
select e.empno,
       e.ename,
	   e.sal,
	   e.deptno,
	   e.sal * case when eb.type = 1 then 0.1
	                when eb.type = 2 then 0.2
					else 0.3
				end as bonus
  from emp e, emp_bonus3_9 eb
 where e.empno = eb.empno
   and e.deptno = 10
       ) x
 group by deptno       
```



## Recipe 3.9o 
```sql
--- 3.9o pandas' transformation.sql 
--- step 2.
select d.deptno,
       d.total_sal,
       sum(e.sal * case when eb.type = 1 then 0.1
                        when eb.type = 2 then 0.2
                        else 0.3 end) as total_bonus
--- step 1.                         
  from (
select deptno, sum(sal) as total_sal
  from emp
 where deptno = 10
 group by deptno
       ) d,
       emp e,
       emp_bonus3_9 eb
 where e.deptno = d.deptno
   and e.empno = eb.empno
 group by d.deptno, d.total_sal
```



## Recipe 3.10 
Similar to Recipe 3.9 we are interested in the departmental aggregate with respect to salaries and bonus in department 10, but this time we change the bonus program such that only a subset of employees (actually a certain one was the single bonus receiver) in department 10 receive bonus (7839 and 7782 didn't receive a bonus in this case). 

```sql
--- 3-10 outer join.sql
--- step 2. aggregate
select deptno,
       sum(distinct sal) as total_sal,
       sum(bonus) as total_bonus
  from (
--- step 1. calculate bonus
select e.empno,
       e.ename,
       e.sal,
       e.deptno,
       e.sal*case when eb.type is null then 0
                  when eb.type = 1 then 0.1
                  when eb.type = 2 then 0.2
                  else 0.3 end as bonus
  from emp e left outer join emp_bonus3_10 eb
    on e.empno = eb.empno
 where e.deptno = 10
       ) x
 group by deptno
```

> Don't forget to put the alias for the subquery.

## Recipe 3.11 
Return missing data from multiple tables to be shown on a single result table. 

Suppose we modify Table `emp` with one extra data of employee whose department number is missing by copying existing data from employee "KING":

```sql 
insert into emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
select 1111, 'YODA', 'JEDI', null, hiredate, sal, comm, null
  from emp
 where ename = 'KING';  
```

Two approaches to solve this request:

```sql
--- 3-11a full outer join.sql
select d.deptno, d.dname, e.ename
  from dept d full outer join emp e
    on e.deptno = d.deptno
```

```sql
--- 3-11b full outer join.sql
select d.deptno, d.dname, e.ename
  from dept d left outer join emp e
    on e.deptno = d.deptno
 union
select d.deptno, d.dname, e.ename
  from dept d right outer join emp e
    on e.deptno = d.deptno
```



## Recipe 3.12 
Compare WARD's commission with those of the rest of people respectively in the same department. The issue here is that some employees do not receive commission.

```sql
--- 3-12 convert null to zero.sql
select ename, comm, coalesce(comm, 0)
  from emp
 where coalesce(comm, 0) < (select comm
                              from emp
                             where ename = `WARD`)
```



# Recipe 7

## Recipe 7.1 
Compute average salary by department.

```sql
select deptno, avg(sal)
  from emp
 group by deptno
```

```sql
select distinct deptno, 
       avg(sal) over(partition by deptno)
  from emp
```

## Recipe 7.6 
Return the running total of salary in each department.

```sql
-- layout the outer query first
select o.ename, 
       o.sal,
       (
-- follow by lay out the second query
-- aggregation funciton returns a scalar           
select sum(d.empno)
  from emp d
 where d.empno <= o.empno
-- end of the inner query           
       )
-- end of the outer query       
 where emp o       
```

## Recipe 7.7 
(continued) Generate a running product on, say, `empno`.

```sql
select o.empno, 
-- After screen out of outer query,
-- elaborate the inner query
       (
select exp(sum(ln(d.empno))) as running_product      
  from emp d
 where d.empno <= o.empno   
   and d.deptno = o.deptno               
       )
-- write the outer query first
-- screen out people in dept 10 first
  from emp o
 where o.deptno = 10  
 
-- note: don't forget the expression "d.deptno = o.deptno"
```

## Recipe 7.8 
Return the running difference of column `sal`. 

```sql
with tbl as
(
	select row_number()
           over (partition by deptno order by empno) as rn,
           deptno,
           empno,
           ename,
           sal
      from emp
)
-- no comma needed to end the rigth parenthesis.

-- ISNULL() can handle the null value facing the first entry.
select o.deptno, o.empno, o.sal, o.rn, d.rn, isnull(o.sal-d.sal, o.sal) difference
  from tbl o 
  left join tbl d
    on o.rn = d.rn + 1 and o.deptno = d.deptno 
-- don't misse the department equality, because
-- you had used "partitiona by deptno" before.
```

## Recipe 7.9 
Return the mode of `sal` for each department.

Comparison: Rank(), Dense_Rank() and Row_NUMBER()

```sql
select deptno,
       sal
  from
(
-- step 2. dense rank
select deptno, 
       sal,
       dense_rank() over(order by cnt desc) as rnk 
  from 
(    
-- step 1. count all
select deptno,
       sal,
       count(*) as cnt
  from emp
 group by deptno, sal   
-- If you only want to show the mode of a particular department
-- then remove all the "deptno," and add "where deptno = 10"
-- here, for example.    
) x 
) y
-- step 3. choose rank = 1
where rnk = 1

/* result: 
deptno	sal
30	1250.00
20	3000.00
*/
-- note: there is no mode in department 10,
-- because no duplicates in salary are shown in department 10.
```


