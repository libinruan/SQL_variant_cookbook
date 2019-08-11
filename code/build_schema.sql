drop table if exists emp;

create table emp (
     empno int not null,
     ename varchar(10) default null,
       job varchar(10) default null,
       mgr int default null,
  hiredate date default null,
       sal decimal(7,2) default null,
      comm decimal(7,2) default null,
    deptno int default null
);

drop table if exists dept;

create table dept (
  deptno decimal(2,0) default null,
   dname varchar(10) default null,
     loc varchar(10) default null
);

drop table if exists emp_bonus;

create table emp_bonus (
     empno int default null,
  received date default null,
      type int default null 
);

insert into emp values 
('7369','SMITH','CLERK','7902','1980-12-17','800.00',NULL,'20'),
('7499','ALLEN','SALESMAN','7698','1981-02-20','1600.00','300.00','30'),
('7521','WARD','SALESMAN','7698','1981-02-22','1250.00','500.00','30'),
('7566','JONES','MANAGER','7839','1981-04-02','2975.00',NULL,'20'),
('7654','MARTIN','SALESMAN','7698','1981-09-28','1250.00','1400.00','30'),
('7698','BLAKE','MANAGER','7839','1981-05-01','2850.00',NULL,'30'),
('7782','CLARK','MANAGER','7839','1981-06-09','2450.00',NULL,'10'),
('7788','SCOTT','ANALYST','7566','1982-12-09','3000.00',NULL,'20'),
('7839','KING','PRESIDENT',NULL,'1981-11-17','5000.00',NULL,'10'),
('7844','TURNER','SALESMAN','7698','1981-09-08','1500.00','0.00','30'),
('7876','ADAMS','CLERK','7788','1983-01-12','1100.00',NULL,'20'),
('7900','JAMES','CLERK','7698','1981-12-03','950.00',NULL,'30'),
('7902','FORD','ANALYST','7566','1981-12-03','3000.00',NULL,'20'),
('7934','MILLER','CLERK','7782','1982-01-23','1300.00',NULL,'10');

insert into dept values
('10','ACCOUNTING','NEW YORK'),
('20','RESEARCH','DALLAS'),
('30','SALES','CHICAGO'),
('40','OPERATIONS','BOSTON');

insert into emp_bonus values 
('7369','14-MAR-2005','1'),
('7900','14-MAR-2005','2'),
('7788','14-MAR-2005','3');

---

drop table if exists t1;
create table t1 (
  id int
);
insert into t1 (id)
values (1);
  
 
 