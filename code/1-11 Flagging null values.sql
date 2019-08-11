select *, 
       case when comm is null then -1
	        when comm < 0 then -2
			else comm
			end as flag
  from emp