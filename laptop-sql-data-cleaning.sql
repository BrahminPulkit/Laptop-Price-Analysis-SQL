SELECT * FROM sql_cx_live.laptopdata;

create table laptops_backup like laptopdata;

insert into laptops_backup
select * from sql_cx_live.laptopdata;

select data_length / 1024 from information_schema.tables
where table_schema = 'sql_cx_live'
and table_name = 'laptopdata';


select * from laptopdata;

alter table laptopdata drop column `Unnamed: 0`;
select * from laptopdata;

DELETE FROM laptopdata
WHERE Company IS NULL
  AND TypeName IS NULL
  AND Inches IS NULL
  AND ScreenResolution IS NULL
  AND Cpu IS NULL
  AND Ram IS NULL
  AND Memory IS NULL
  AND Gpu IS NULL
  AND OpSys IS NULL
  AND Weight IS NULL
  AND Price IS NULL;


select count(*) from laptopdata;

Alter table laptopdata modify column Inches decimal(10, 1);


UPDATE laptopdata
SET Ram = REPLACE(Ram, 'GB', '');

Alter table laptopdata modify column Ram integer;


select * from laptopdata;

ALTER TABLE laptopdata
ADD COLUMN id INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;


UPDATE laptopdata
SET Weight = REPLACE(Weight, 'kg', '');


UPDATE laptopdata l1
SET Price = (
    SELECT ROUND(Price)
    FROM laptopdata l2
    WHERE l2.id = l1.id
);

UPDATE laptopdata l1
SET Price = (
    SELECT ROUND(Price)
    FROM laptopdata l2
    WHERE l2.id = l1.id
);


alter table laptopdata modify column Price integer;

select OpSys from laptopdata;

-- mac 
-- windows
-- linux
-- no os
-- Android chrome (others)

SELECT 
    OpSys,
    CASE
        WHEN OpSys LIKE '%mac%' THEN 'macos'
        WHEN OpSys LIKE '%windows%' THEN 'windows'
        WHEN OpSys LIKE '%linux%' THEN 'linux'
        WHEN OpSys LIKE '%No OS%' THEN 'N/A'
        ELSE 'other'
    END AS os_clean
FROM laptopdata;

UPDATE laptopdata
SET OpSys = 
    CASE
        WHEN LOWER(OpSys) LIKE '%mac%' THEN 'macos'
        WHEN LOWER(OpSys) LIKE '%windows%' THEN 'windows'
        WHEN LOWER(OpSys) LIKE '%linux%' THEN 'linux'
        WHEN LOWER(OpSys) LIKE '%no os%' THEN 'N/A'
        ELSE 'other'
    END;


ALTER TABLE laptopdata
ADD COLUMN Gpu_brand VARCHAR(255) AFTER Gpu,
ADD COLUMN Gpu_name VARCHAR(255) AFTER Gpu_brand;

select Gpu, substring_index(Gpu, ' ', 1) from laptopdata;

UPDATE laptopdata
SET Gpu_brand = SUBSTRING_INDEX(Gpu, ' ', 1);

update laptopdata
set Gpu_name =  replace(Gpu, Gpu_brand, '');


Alter table laptopdata drop column Gpu;

select * from laptopdata;

ALTER TABLE laptopdata
ADD COLUMN Cpu_brand VARCHAR(255) AFTER Cpu,
ADD COLUMN Cpu_name VARCHAR(255) AFTER Cpu_brand,
ADD COLUMN Cpu_speed DECIMAL(10, 1) AFTER Cpu_name;

select Cpu, substring_index(Cpu, ' ', 1) from laptopdata;

UPDATE laptopdata
SET Cpu_brand = SUBSTRING_INDEX(Cpu, ' ', 1);

select Cpu, substring_index(Cpu, ' ', -1) from laptopdata;


SELECT 
    Cpu,
    CAST(
        REPLACE(SUBSTRING_INDEX(Cpu, ' ', -1), 'GHz', '')
        AS DECIMAL(10,2)
    ) AS cpu_speed_ghz
FROM laptopdata;



                 
UPDATE laptopdata
SET Cpu_speed = CAST(
    REPLACE(SUBSTRING_INDEX(Cpu, ' ', -1), 'GHz', '')
    AS DECIMAL(10,2)
);


select 
replace(replace(Cpu, Cpu_brand, ''),substring_index(replace(Cpu, Cpu_brand, ' '), ' ', -1),'')
from laptopdata;

SELECT 
TRIM(
    REPLACE(
        REPLACE(Cpu, Cpu_brand, ''),
        SUBSTRING_INDEX(REPLACE(Cpu, Cpu_brand, ' '), ' ', -1),
        ''
    )
) AS Cpu_name
FROM laptopdata;

update laptopdata
SET Cpu_name = TRIM(
    REPLACE(
        REPLACE(Cpu, Cpu_brand, ''),
        SUBSTRING_INDEX(REPLACE(Cpu, Cpu_brand, ' '), ' ', -1),
        ''
    )
);

alter table laptopdata drop column Cpu;


select ScreenResolution , 
substring_index(substring_index(ScreenResolution, ' ', -1), 'x', -1),
substring_index(substring_index(ScreenResolution, ' ', -1), 'x', -1)
from laptopdata;


Alter table laptopdata

add column Resolution_width Integer After ScreenResolution,
add column Resolution_hight Integer After Resolution_width;

update laptopdata
set Resolution_width = substring_index(substring_index(ScreenResolution, ' ', -1), 'x', -1),
Resolution_hight = substring_index(substring_index(ScreenResolution, ' ', -1), 'x', -1);

select * from laptopdata;


Alter table laptopdata
add column Touch_screen Integer After Resolution_hight;

select ScreenResolution like '%Touch%' from laptopdata;

update laptopdata
set Touch_screen = ScreenResolution like '%Touch%';

alter table laptopdata 
drop column ScreenResolution;

select * from laptopdata;

select Cpu_name, 
substring_index(trim(Cpu_name), ' ', 2)
from laptopdata;

update laptopdata
set Cpu_name = substring_index(trim(Cpu_name), ' ', 2);

select distinct Cpu_name from laptopdata;

select Memory from laptopdata;

alter table laptopdata
add column Memory_type varchar(255) after Memory,
add column Primary_storage integer after Memory_type,
add column Secondary_storage integer after Memory;


select Memory,
case 
	when Memory like '%SSD%' and Memory like'%HDD%' Then 'Hybrid'
    when Memory like '%SSD%' then 'SSD'
    when Memory like '%HDD%' then 'HDD'
    when Memory like '%Flash Storage%' then 'Flash Storage'
    when Memory like '%Hybrid%' and Memory like 'HDD' then 'Hybrid'
    else Null
end as 'Memory _type'
from laptopdata;

update laptopdata
set Memory_type = case 
	when Memory like '%SSD%' and Memory like'%HDD%' Then 'Hybrid'
    when Memory like '%SSD%' then 'SSD'
    when Memory like '%HDD%' then 'HDD'
    when Memory like '%Flash Storage%' then 'Flash Storage'
    when Memory like '%Hybrid%' and Memory like 'HDD' then 'Hybrid'
    else Null
end;

select Memory,
Regexp_substr( substring_index(Memory, '+', 1), '[0-9]+'),
case 
when Memory like '%+%' then Regexp_substr(substring_index(Memory, '+', -1), '[0-9]+') else 0 end
from laptopdata;

update laptopdata
set Primary_storage = Regexp_substr( substring_index(Memory, '+', 1), '[0-9]+'),
Secondary_storage = case when Memory like '%+%' then Regexp_substr(substring_index(Memory, '+', -1), '[0-9]+') else 0 end;


select Primary_storage ,
case when Primary_storage <= 2 then Primary_storage*1024 else Primary_storage end,
case when Secondary_storage <= 2 then Secondary_storage*1024 else Secondary_storage end
from laptopdata;

update laptopdata
set Primary_storage = case when Primary_storage <= 2 then Primary_storage*1024 else Primary_storage end,
Secondary_storage = case when Secondary_storage <= 2 then Secondary_storage*1024 else Secondary_storage end;

select * from laptopdata;

alter table laptopdata drop column Memory;

select * from laptopdata;

Alter table laptopdata drop column Gpu_name;


select * from laptopdata;




