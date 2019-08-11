In this repository, I store SQL programs I created on basis of Anthony Molinaro's Amazon best selling book "SQL cookbook." I made quite a few revision and add some variant examples derived from the origin SQL challenges in the book so as to make the collection of SQL recipes here better suitable for a SQL job interview.

To get started run `build_shcema.sql` to establish the database ([table](https://www.oreilly.com/library/view/sql-cookbook/0596009763/pr04.html#I__tt3)) the author refer to throughout the book.

# Recipe

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

## Recipe 2.3 
Show employee names and jobs from table `emp` and sort by the last two characters in the `job` field.

## Recipe 2.4.e 
Sort results from `emp` by `comm` , some of which are null. Let non-null values show up first.

> Null values are smaller than any real number.

## Recipe 2.4.g 
Sort results from `emp` by `comm`, after null values in the filed `comm` have been transformed to integer zero.

## Recipe 2.6 
If `job` is 'salesman' sort on `comm`; otherwise, sort by `sal`.

> You can use the CASE expression to dynamically change how results are sorted.

## Recipe 3.1 
Stack one row sets atop another with heterogeneous number and order of fields.

## Recipe 3.3w 
Return rows in one table with additional information appended from another tables.

## Recipe 3.3i 
(continued) Use `inner join` (inner is optional) instead to perform the same task.

## Recipe 3.4 
Retrieve values from one table that are missing from another table.

## Recipe 3.5 
Reversely, retrieve (supplement) missing values in one table from another table

> Conclusion based on ## Recipes 3.4 and 3.5: we should place the table with **more** information to be in the **outer** query.

## Recipe 3.6 
Return all employees, the location of the department where they work, and the date of bonus if they received one. (order by location).

> That is, Use outer join the third table without interfering the joining results of the preceding tables.

## Recipe 3.7 
Count duplicates and missing data. Compare an artificial table V with duplicated data of employee "WARD" and people who do not work in department 10 with the `emp` table. Try to show the duplicated data and missing data from V.

## Recipe 3.8 
Avoid cartesian product 

## Recipe 3.9d 
Aggregate the salaries (from table `emp`) and the bonus (from table `emp_bonus`) for people in department 10 only. Issues come from that someone received multiple bonus, which duplicates the amount of the guy's salaries. 

## Recipe 3.9o 
(*)(continued) Use OVER() to tackle this issue.

## Recipe 3.10 
Similar to Recipe 3.9 we are interested in the departmental aggregate with respect to salaries and bonus in department 10, but this time we change the bonus program such that only a subset of employees (actually a certain one was the single bonus receiver) in department 10 receive bonus (7839 and 7782 didn't receive a bonus in this case). 

## Recipe 3.11 
Return missing data from multiple tables to be shown on a single result table.

## Recipe 3.12 
Compare WARD's salaries with the rest of people in the same department.

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


