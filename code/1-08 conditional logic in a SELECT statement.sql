select ename as [name],
       sal as [salary],
       case when sal < 2000 then 'underpaid'
            when sal >= 4000 then 'overpaid'
            else 'ok'
       end as [status]
from emp
