/* select COD_PLAN, count(COD_PLAN)
from TarifasPT
group by COD_PLAN

select * 
from TarifasPA
where COD_PLAN = '3609'

select * 
from TarifasPT 

select * 
from PlanesTarifas
where COD_PLANTARIF = 'F11'

select * 
from PlanesAdicionales
where COD_ESPEC_PROD = 2121

select * 
from Servicios
where COD_SERVICIO = 1

select * from RelacionPlanesAdicionales

select * from RelacionServicios 

select * from RelacionPlanesAdicionales where COD_PLANTARIF = 'F11' order by RELACION

select * from PlanesAdicionales where COD_ESPEC_PROD = 2100 

select A.COD_PLANTARIF, A.COD_SERVICIO, A.RELACION, B.DES_SERVICIO, B.COD_ACTABO, 
B.DES_ACTABO, B.TECNOLOGIA
from RelacionServicios A, Servicios B
where B.COD_SERVICIO = A.COD_SERVICIO 
and COD_PLANTARIF = 'F11' 
order by A.RELACION

select * from Servicios where COD_SERVICIO = 54

select A.COD_PLANTARIF, A.DES_PLANTARIF, A.TIPO_PLAN, B.COD_PROD_OFERTADO, C.DES_ESPEC_PROD,
B.RELACION
from PlanesTarifas as A, RelacionPlanesAdicionales as B, PlanesAdicionales C
where C.CANAL = 'VENTA'
and C.COD_ESPEC_PROD = B.COD_PROD_OFERTADO
and B.COD_PLANTARIF = A.COD_PLANTARIF
and A.COD_PLANTARIF = 'F11'
order by B.RELACION

select A.COD_PLANTARIF, A.DES_PLANTARIF, A.TIPO_PLAN, B.COD_PROD_OFERTADO, C.DES_ESPEC_PROD,
B.RELACION
from PlanesTarifas as A, RelacionPlanesAdicionales as B, PlanesAdicionales C
where C.CANAL = 'VENTA'
and C.COD_ESPEC_PROD = B.COD_PROD_OFERTADO
and B.COD_PLANTARIF = A.COD_PLANTARIF
and A.COD_PLANTARIF = 'F11'
order by B.RELACION 

select * from RelacionPlanesAdicionales where COD_PLANTARIF = '27'

select * from PlanesAdicionales where COD_ESPEC_PROD = '225'

select * from TarifasPA where COD_PLAN = '27'

select * from PlanesTarifas where COD_PLANTARIF = 'G02'

select * from PlanesTarifas where COD_PLANTARIF = '130' 

select COD_PLANTARIF, DES_PLANTARIF, [ IMP_CARGOBASICO ], TIPO_PLAN
from PlanesTarifas
where COD_PLANTARIF in ('G02','F85','F11','F10','K68','K71','K82','K85','K58','K61','K63',
'K66','K73','K76','K78','K81')
order by [ IMP_CARGOBASICO ]

select * from TarifasPA */

/* 
select count(*) from Facturas

select * into FacturasCopia from Facturas

select sum(ORIGINAL_AMOUNT) from Facturas where OPEN_AMOUNT <> 0

alter table Facturas alter column OHINVTYPE integer

select top 10 * from Facturas

update Facturas set DUE_DATE = '20' + substring(DUE_DATE,7,2) + '/' + substring(DUE_DATE,4,2) + '/' +
substring(DUE_DATE,1,2)

select top 10 DUE_DATE, 
'20' + substring(DUE_DATE,7,2) + '/' + substring(DUE_DATE,4,2) + '/' +
substring(DUE_DATE,1,2)
from Facturas

select format(sum(ORIGINAL_AMOUNT),'C','es-GT') 
from Facturas 
where year(CUTOFF_DATE) = 2019 
--and month(CUTOFF_DATE) = 06 
and OPEN_AMOUNT <> 0
*/

select year(CUTOFF_DATE) as "año",
month(CUTOFF_DATE) as "mes", 
format(sum(ORIGINAL_AMOUNT),'C','es-GT') as "total facturación",
format(sum(OPEN_AMOUNT), 'C','es-GT') as "no recuperado", 
format((sum(OPEN_AMOUNT)/(sum(ORIGINAL_AMOUNT))),'P') as "porcentaje"
from Facturas
where --year(CUTOFF_DATE) = 2017
--and month(CUTOFF_DATE) = 06
OHINVTYPE = 5 
--and OPEN_AMOUNT <> 0
group by year(CUTOFF_DATE) ,
month(CUTOFF_DATE)
order by "año",
"mes"
--"porcentaje" asc

