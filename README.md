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

> Window functions operate on a set of rows and return a single value for each row from the underlying query. The term window describes the set of rows on which the function operates. A window function uses values from the rows in a window to calculate the returned values.

```sql
--- 7-01a groupwise average.sql
select deptno, avg(sal) 
  from emp
 group by deptno
```

```sql
--- 7-01o groupwise average.sql
select distinct deptno, 
       avg(sal) over(partition by deptno)
  from emp
```

## Recipe 7.2
Min/Max value in a column.
```sql
--- 7-02a groupwise minmax.sql
select deptno, min(sal) min_sal, max(sal) max_sal
  from emp
 group by deptno
```
```sql
--- 7-02o groupwise minmax.sql
select distinct deptno, 
       min(sal) over (partition by deptno)
  from emp
```

## Recipe 7.3
```sql
--- 7-03s groupwise sum.sql
select deptno, 
       sum(sal) as sum_sal
  from emp
 group by deptno
```
> The SUM function ignores nulls. To force groups with null values of aggreates to show in the result, we need to explicitly identify the presence of the group.
> ```sql 
> --- 7-03n sum with null.sql
> select deptno, sum(comm)
>   from emp
>  where deptno in (10,30)
>  group by deptno
> ```

## Recipe 7.4
Count the number of employees in each department.
```sql
--- 7.4 count.sql
select deptno, 
       count(*) as cnt
  from emp
 group by deptnop
```

## Recipe 7.5
Count the number of non-null comm.
```sql
--- 7.5 count non-null.sql
select count(comm)
  from emp
```

## Recipe 7.6* 
Return the running total of salary in each department.

```sql
--- 7-06 double loop.sql
--- layout the outer query first
select o.ename, 
       o.sal,
       (
--- follow by lay out the second query
--- aggregation funciton returns a scalar           
select sum(d.empno)
  from emp d
 where d.empno <= o.empno
--- end of the inner query           
       )
--- end of the outer query       
 where emp o       
```

## Recipe 7.7 
(continued) Generate a running product on, say, `empno`.

```sql
--- 7.7 running product.sql
select o.empno, 
--- After screen out of outer query,
--- elaborate the inner query
       (
select exp(sum(log(d.empno))) as running_product 
  from emp d
 where d.empno <= o.empno   
   and d.deptno = o.deptno               
       )
--- write the outer query first
--- screen out people in dept 10 first
  from emp o
 where o.deptno = 10  
-- note: don't forget the expression "d.deptno = o.deptno"
```
> In SQL Server, use "log" to return the natural logarithm of a number.
## Recipe 7.8* 
Return the one-order difference of column `sal` in each department.

```sql
--- 7.8 return one-order difference.sql
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
--- No comma needed to end the rigth parenthesis.
--- ISNULL() can handle the null value facing the first entry.
select o.deptno, 
       o.empno, 
       o.sal, 
       o.rn, 
       d.rn, 
       isnull(o.sal-d.sal, o.sal) difference
  from tbl o 
  left join tbl d
    on o.rn = d.rn + 1 and o.deptno = d.deptno;
    
--- Don't misse the department equality, because
--- You had used "partitiona by deptno" before.
```

## Recipe 7.9* 
Return the mode of `sal` for each department.

>  Comparison: Rank(), Dense_Rank() and Row_NUMBER()
>
> ![](https://i.postimg.cc/CK0W7wbN/screenshot-447.png)

```sql
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
```

## Recipe 7.10

Compute the median salary of department 20.

```sql
--- 7-10 median.sql
 select avg(sal)
  from (
select sal,
       count(*) over () as [total],
	   cast(count(*) over () as float) / 2 as [mid],
	   ceiling(cast(count(*) over () as float) / 2) as [next],
	   row_number() over (order by sal) as rn
  from emp
 where deptno = 20
       ) x
 where (total%2 = 0 and rn in (mid, next))
    or (total%2 != 0 and rn = next)
```

> Note: it is important to keep in mind that window functions are applied after the WHERE clause is evaluated.

## Recipe 7.11

Return the percentage of the sum of salaries in department 10 that contributes to the firm's total.

```sql
--- 7-11 percentage.sql
 select distinct dsum/total*100 as pct 
  from (
select deptno,
       sum(sal) over() total,
       sum(sal) over (partition by deptno) dsum
  from emp
       ) x
 where deptno = 10
```

> There are three employees in department 10. If you don't add the DISTINCT in the outer query. Two duplicated results will show.

> Conditional on the type definition of variable SAL, you may need to explicitly include CAST to convert integer to floating point.

## Recipe 7.12

Return the average of commission that includes and counts null values in department 30.

```sql
--- 7-12
select avg(coalesce(comm,0)) as avg_comm
  from emp
 where deptno = 30
```



## Recipe 7.13

Return the average of salaries without considering the maximum and the minimum

```sql
--- 7-13 conditional average.sql
select avg(sal)
  from (
--- step 1. find minimum and maximum
select sal, 
       min(sal) over () min_sal, 
       max(sal) over () max_sal
  from emp
       ) x
 where sal not in (min_sal, max_sal)
```

> For SQL Server, OVER() can only appear in the SELECT and ORDER BY clauses.

## Recipe 7.15**

Given the following table, return the balance based on transaction history.
```sql
--- 7-15 conditional summation with running total.sql
select case when b1.trs = 'py' then 'payable'
            else 'receivable' end as [transaction type],
       b1.amt,     
       (
--- step 1. 
select sum(case when b2.trs = 'rc' then -b2.amt
                else b2.amt end)
  from bal1 b2
 where b2.id <= b1.id
       ) as balance
  from bal1 b1;
```

# Recipe 8

## Recipe 8.1

Return the dates being added or subtracted 5 days, 5 months, and 5 years from the hiring date of employee 'CLARK' in department 10.
```sql
--- 8-01 add and subtract time.sql
select dateadd(day,5,hiredate) as hd_add_5d,
       dateadd(day,-5,hiredate) as hd_minus_5d,
       dateadd(month,5,hiredate) as hd_add_5m,
       dateadd(month,-5,hiredate) as hd_minus_5m,
       dateadd(year,5,hiredate) as hd_add_5y,
       dateadd(year,-5,hiredate) as hd_minus_5y
  from emp
 where deptno = 10
```
## Recipe 8.2
Find the HIREDATEs of employee ALEN and employee WARD.

> Think of DATEDIFF(unit, A, B)  as a function treating the first date, A, as the origin on the real line and returning the difference between A and B.

```sql
--- 8-02 date difference.sql
select datediff(day, ward_hd, allen_hd)  
  from (
select hiredate as ward_hd
  from emp
 where ename = 'WARD'
       ) x,
       (
select hiredate as allen_hd
  from emp
 where ename = 'ALLEN'
       ) y
```

## Recipe 8.3*

Determine the number of **weekday days** between hiring dates of 'BLAKE' and 'JONES.'

> Using semicolon in front of the With clause ([link](https://stackoverflow.com/questions/6938060/common-table-expression-why-semicolon#answer-6938089))

> ALTER TABLE() is used to add, delete, or modify columns ([link](https://www.w3schools.com/sql/sql_alter.asp))

Step 1. We need a pivotal table with a single field `id` running from 1 to 500 ([source](https://stackoverflow.com/questions/1393951/what-is-the-best-way-to-create-and-populate-a-numbers-table#answer-1407488)). The pivotal table can help us count valid (non-holiday) days between two dates.

```sql
declare @RunDate datetime
set @RunDate=GETDATE()

--- Check the existence of table v500
--- [dbo.] is optional.
if object_id('dbo.v500','U') is not null
	drop table dbo.v500

--- The beginning of the major part
create table v500 (id  datetime  not null)  
;with Nums(id) as
(select 1 as id
 union all
 select id+1 from Nums where id < 500
)

--- Use OPTION caluse to specify the indicated query hint.
insert into v500(id)
select id from Nums option(maxrecursion 10000)

--- Add primary key to v500 using ADD CONSTRAINT
alter table v500 
add constraint PK_v500 primary key clustered (id)

/*
--- Check execution efficiency
print convert(varchar(20), datediff(ms, @RunDate, GETDATE())) + ' milliseconds'
*/
---Check the length of result
select count(*) as total_number from v500
```
> The GO command is used to group SQL commands into batches which are sent to the server together. ([link](https://stackoverflow.com/questions/2299249/what-is-the-use-of-go-in-sql-server-management-studio-transact-sql#answer-2299255))

> CROSS JOIN() gets a row from one table and then creates a new row for each row in the other table. ([link](https://i.postimg.cc/ZnPzSVYy/screenshot-628.png))

> Using OBJECT_ID(par1, par2) to check whether an object exists or not. Check here for the list of the 2nd parameter. ([link](https://stackoverflow.com/questions/17546814/why-object-id-used-while-checking-if-a-table-exists-or-not#answer-20479221))
>
> > Example: if(object_id(N'[dbo].[YourTable]', 'U') is not null) ...

Step 2. First, you need to know which hiring date is earlier.

```sql
select case when ename = 'BLAKE' then hiredate end as blake_hd,
       case when ename = 'JONES' then hiredate end as jones_hd
  from emp
 where ename in ('BLAKE','JONES')
```

![](https://i.postimg.cc/TYTLLPLn/screenshot-629.png)

Step 3. Counting the length of the interval with a pivotal table

```sql
--- 8-03a search two items in a column.sql
--- step 2. counting the days inbetween
select x.*, v500.*, datename(dw, dateadd(day, v500.id-1, jones_hd))
  from ( 
--- step 1. Just in case BLAKE and JONES have multiple entries in the table
select max(case when ename = 'BLAKE' then hiredate end) as blake_hd,
       max(case when ename = 'JONES' then hiredate end) as jones_hd
  from emp
 where ename in ('BLAKE', 'JONES')
       ) x,
       v500
 where v500.id <= datediff(day,jones_hd, blake_hd) + 1       
```

![](https://i.postimg.cc/hPQwmKkP/screenshot-630.png)

Step 4. Answering the question

```sql
--- 8-03b search two items in a column.sql
--- step 2. flag the weekdays
select sum(case when datename(dw, dateadd(day, v500.id-1, jones_hd)) in ('SATURDAY','SUNDAY') 
           then 0 else 1 end) as days 
/* 
select x.*, v500.*, datename(dw, dateadd(day, v500.id-1, jones_hd))
*/
  from ( 
--- step 1. Just in case BLAKE and JONES have multiple entries in the table
select max(case when ename = 'BLAKE' then hiredate end) as blake_hd,
       max(case when ename = 'JONES' then hiredate end) as jones_hd
  from emp
 where ename in ('BLAKE', 'JONES')
       ) x,
       v500
 where v500.id <= datediff(day,jones_hd, blake_hd) + 1       

```
> If you want to exclude holidays as well, create a table HOLIDAYS and then exclude days listed in the HOLIDAYS table with the NOT IN clause.

> DATENAME() returns a character string representing the specified datepart (see argument table [here](https://docs.microsoft.com/en-us/sql/t-sql/functions/datename-transact-sql?view=sql-server-2017)) of the specified date.

## Recipe 8.4
Returns the number of months or years between the latest and oldest hiring dates.

![](https://i.postimg.cc/bNBjk6Vp/screenshot-631.png)

```sql
--- 8-04 datediff.sql
select datediff(year, min_hd, max_hd) years,
       datediff(month, min_hd, max_hd) months,
       cast(datediff(month, min_hd, max_hd) as decimal) / 12 fyears
  from (
select max(hiredate) as max_hd, 
       min(hiredate) as min_hd       
  from emp
       ) x
```
> See [here](https://www.w3schools.com/sql/func_sqlserver_datediff.asp) for DATEDIFF() 's argument table.

![](https://i.postimg.cc/2ytXbtkt/screenshot-632.png)

## Recipe 8.5

## Recipe 8.6

## Recipe 8.7


# Recipe 9

## Recipe 9.1 

## Recipe 9.2 

## Recipe 9.3 

## Recipe 9.4 

## Recipe 9.5 

## Recipe 9.6 

## Recipe 9.7 

## Recipe 9.8 

## Recipe 9.9 

## Recipe 9.10

## Recipe 9.11

## Recipe 9.12

## Recipe 9.13



# Recipe 10

## Recipe 10.1

## Recipe 10.2

## Recipe 10.3

## Recipe 10.4

## Recipe 10.5

Generate consecutive numeric values.

```sql
--- create a subquery block
with v500 (id) as (
select 1
  from t1
 union all
select id + 1
  from v500
 where id+1 <= 500 
) --- as
select * from v500
```

