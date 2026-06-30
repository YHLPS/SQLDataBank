use [DBName]

DECLARE @var_name varchar(255) = 'value';
SELECT @var_name as var_name;

-- 
DECLARE @Names TABLE (name varchar(255));

INSERT INTO
  @Names (name)
values
  ('val1'),
  ('val2'),
  ('val 3') 

SELECT *
from @Names 


SELECT
      @var_name,
      @var_name + row_number() over (
        order by name
      ),
      name
    from @Names
