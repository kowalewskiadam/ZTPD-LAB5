--Ćwiczenie 1

--A

INSERT INTO USER_SDO_GEOM_METADATA
VALUES (
'FIGURY',
'KSZTALT',
MDSYS.SDO_DIM_ARRAY(
 MDSYS.SDO_DIM_ELEMENT('X', 0, 20, 0.1),
 MDSYS.SDO_DIM_ELEMENT('Y', 0, 20, 0.1) ),
 null
);

--B

SELECT SDO_TUNE.ESTIMATE_RTREE_INDEX_SIZE(3000000,8192,10,2,0) from dual;

--C

CREATE INDEX figury_idx
ON figury(ksztalt)
INDEXTYPE IS MDSYS.SPATIAL_INDEX_V2;

--D

select ID
from FIGURY
where SDO_FILTER(KSZTALT,
SDO_GEOMETRY(2001,null,
 SDO_POINT_TYPE(3,3,null),
 null,null)) = 'TRUE';
 
 --E
 
select ID
from FIGURY
where SDO_RELATE(KSZTALT,
 SDO_GEOMETRY(2001,null,
 SDO_POINT_TYPE(3,3,null),
 null,null),
 'mask=ANYINTERACT') = 'TRUE';

--Ćwiczenie 2

--A

select CITY_NAME MIASTO, SDO_NN_DISTANCE(1) ODL
from MAJOR_CITIES 
where SDO_NN(GEOM,(select geom from major_cities where CITY_NAME='Warsaw'),
 'sdo_num_res=10 unit=km',1) = 'TRUE' and CITY_NAME != 'Warsaw';
 
 --B
 
select CITY_NAME MIASTO
from MAJOR_CITIES
where SDO_WITHIN_DISTANCE(GEOM,(select geom from major_cities where CITY_NAME='Warsaw'),
 'distance=100 unit=km') = 'TRUE' and CITY_NAME != 'Warsaw';
 
 --C
 
select a.cntry_name, b.city_name from country_boundaries a, major_cities b
where SDO_RELATE(b.geom, a.geom, 'mask=inside') = 'TRUE' and a.cntry_name = 'Slovakia';
 
 --D
 
select b.cntry_name PANSTWO, 
SDO_GEOM.SDO_DISTANCE(a.geom, b.geom, 1, 'unit=km') ODL
from country_boundaries a, country_boundaries b where a.cntry_name = 'Poland' and b.cntry_name != 'Poland'
and b.cntry_name not in (
select b.cntry_name from country_boundaries a, country_boundaries b
where SDO_RELATE(b.geom, a.geom, 'mask=TOUCH') = 'TRUE' and a.cntry_name = 'Poland'
 );
 
--Ćwiczenie 3

--A

select
 B.CNTRY_NAME AS CNTRY_NAME,
 SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(A.GEOM, B.GEOM, 1), 1, 'unit=km') AS ODLEGLOSC
from COUNTRY_BOUNDARIES A, COUNTRY_BOUNDARIES B where A.CNTRY_NAME = 'Poland'
and b.cntry_name in (
select b.cntry_name from country_boundaries a, country_boundaries b
where SDO_RELATE(b.geom, a.geom, 'mask=TOUCH') = 'TRUE' and a.cntry_name = 'Poland'
 );
 
 --B
 
select cntry_name from country_boundaries order by
SDO_GEOM.sdo_area(geom, 1, 'unit=SQ_KM') desc fetch first 1 row only;

--C

select SDO_GEOM.sdo_area(SDO_GEOM.SDO_MBR(
SDO_GEOM.SDO_UNION((select geom from major_cities where city_name = 'Warsaw'),
(select geom from major_cities where city_name = 'Lodz'), 1)), 
1, 'unit=SQ_KM') AS SQ_KM 
from dual ;

--D

select SDO_GEOM.SDO_UNION((select geom from country_boundaries where cntry_name = 'Poland'),
(select geom from major_cities where city_name = 'Prague'), 1).GET_DIMS() ||
SDO_GEOM.SDO_UNION((select geom from country_boundaries where cntry_name = 'Poland'),
(select geom from major_cities where city_name = 'Prague'), 1).GET_LRS_DIM() ||
concat('0', SDO_GEOM.SDO_UNION((select geom from country_boundaries where cntry_name = 'Poland'),
(select geom from major_cities where city_name = 'Prague'), 1).GET_GTYPE()) as GTYPE
from dual;

--E

select b.city_name CITY_NAME, a.cntry_name CNTRY_NAME from country_boundaries a, major_cities b
where SDO_RELATE(b.geom, a.geom, 'mask=inside') = 'TRUE' ORDER BY
SDO_GEOM.SDO_DISTANCE((SDO_GEOM.SDO_CENTROID(a.geom)), b.geom, 1, 'unit=km') FETCH FIRST 1 ROW ONLY;

--F

select a.name, 
sum(SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(a.geom, b.geom), 1, 'unit=km')) AS DLUGOSC
from rivers a, country_boundaries b where SDO_RELATE(a.geom, b.geom, 'mask=ANYINTERACTION') = 'TRUE' 
and b.cntry_name = 'Poland' group by a.name;
