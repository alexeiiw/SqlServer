alter procedure Generar_REP_CONTRATOS_FORECAST 
-- SP para llenar el reporte de Forecast de contratos de arrendamiento SISCON (contratos no facturados)
-- Autor Alex García, 21/06/2021
-- Bitacora:
--(
	-- Define parametros
	--@mes as int,
	--@anio as int
--)
as

begin
	-- Define variables
	declare @nocontrato int 
	declare @contratotipo varchar(02)
	declare @clientesap varchar(20)
	declare @nombrecomercial varchar(250)
	declare @nitcliente varchar(50)
	declare @vip bit
	declare @totalfacturacion float
	declare @mesactual varchar(50)
	declare @mes int
	declare @anio int

	-- Obtiene los parametros de mes y año
	set @mes = MONTH(GETDATE())
	set @anio = YEAR(GETDATE())

	-- Borra la tabla del reporte
	delete REP_CONTRATOS_FORECAST

	-- Recorre el cursor para llenar a los clientes con contratos vigentes de SISCON
	DECLARE Cursor_Datos1 CURSOR FOR

	select ENC.CONTRATO_NO, ENC.CONTRATO_TIPO, ENC.COD_CLIENTE, ENC.NOMBRE_COMERCIAL, ENC.NIT_CLIENTE, ENC.VIP
	from COT_CONTRATOS_ENC ENC
	where ENC.CONTRATO_NO in (
	select CONTRATO_NO
	from COT_CONTRATOS_DET_DESPACHO
	where ESTATUS_ARTICULO = 1 and ENC.CONTRATO_TIPO = 'R'
	group by CONTRATO_NO)
	--and ENC.COD_CLIENTE in ('C000361', 'C000708', 'C000534', 'C000040', 'C006284')
	order by ENC.CONTRATO_NO	

	OPEN Cursor_Datos1 
	FETCH NEXT FROM Cursor_Datos1 INTO 
	@nocontrato, @contratotipo, @clientesap, @nombrecomercial, @nitcliente, @vip
	WHILE @@FETCH_STATUS = 0 	

	begin

		-- Inserta los códigos de SAP de los articulos duplicados en despachos
		insert into REP_CONTRATOS_FORECAST values (@nocontrato, @contratotipo, @clientesap, @nombrecomercial, @nitcliente, @vip, null, null, null, null)

		FETCH NEXT FROM Cursor_Datos1 INTO 
		@nocontrato, @contratotipo, @clientesap, @nombrecomercial, @nitcliente, @vip

	end		

	-- Cierra el cursor
	CLOSE Cursor_Datos1
	DEALLOCATE Cursor_Datos1

	-- Recorro la tabla para colocar la facturación del mes actual
	DECLARE Cursor_Datos2 CURSOR FOR

	select COD_CLIENTE_SAP, CONTRATO_NO from REP_CONTRATOS_FORECAST

	OPEN Cursor_Datos2
	FETCH NEXT FROM Cursor_Datos2 INTO 
	@clientesap, @nocontrato
	WHILE @@FETCH_STATUS = 0 	

	begin

		set @totalfacturacion = 0.00

		select @totalfacturacion = sum(DocTotal)
		from SBO_CANELLA.dbo.oinv 
		where (OwnerCode = 414 or OwnerCode = 138 or OwnerCode = 411 or OwnerCode = 413)
		and cardcode = @clientesap 
		and U_Contrato = @nocontrato
		and MONTH(DocDate) = @mes 
		and YEAR(docdate) = @anio 
		group by DocTotal

		print @nocontrato
		print @clientesap

		-- Actualiza la tabla
		update REP_CONTRATOS_FORECAST set FACTURACION_MES_ACTUAL = @totalfacturacion where COD_CLIENTE_SAP = @clientesap and CONTRATO_NO = @nocontrato

		FETCH NEXT FROM Cursor_Datos2 INTO 
		@clientesap, @nocontrato

	end
	
	-- Cierra el cursor
	CLOSE Cursor_Datos2
	DEALLOCATE Cursor_Datos2

	-- Recorro la tabla para colocar la facturación del mes actual - 1
	DECLARE Cursor_Datos3 CURSOR FOR

	select COD_CLIENTE_SAP, CONTRATO_NO from REP_CONTRATOS_FORECAST

	OPEN Cursor_Datos3
	FETCH NEXT FROM Cursor_Datos3 INTO 
	@clientesap, @nocontrato
	WHILE @@FETCH_STATUS = 0 	

		begin

		set @totalfacturacion = 0.00

		select @totalfacturacion = sum(DocTotal)
		from SBO_CANELLA.dbo.oinv 
		where (OwnerCode = 414 or OwnerCode = 138 or OwnerCode = 411 or OwnerCode = 413)
		and cardcode = @clientesap 
		and U_Contrato = @nocontrato
		and MONTH(DocDate) = (@mes - 1)
		and YEAR(docdate) = @anio 
		group by DocTotal

		print @nocontrato
		print @clientesap

		-- Actualiza la tabla
		update REP_CONTRATOS_FORECAST set FACTURACION_MES_3 = @totalfacturacion where COD_CLIENTE_SAP = @clientesap and CONTRATO_NO = @nocontrato

		FETCH NEXT FROM Cursor_Datos3 INTO 
		@clientesap, @nocontrato

	end

	-- Cierra el cursor
	CLOSE Cursor_Datos3
	DEALLOCATE Cursor_Datos3

	-- Recorro la tabla para colocar la facturación del mes actual - 2
	DECLARE Cursor_Datos4 CURSOR FOR

	select COD_CLIENTE_SAP, CONTRATO_NO from REP_CONTRATOS_FORECAST

	OPEN Cursor_Datos4
	FETCH NEXT FROM Cursor_Datos4 INTO 
	@clientesap, @nocontrato 
	WHILE @@FETCH_STATUS = 0 	

		begin

		set @totalfacturacion = 0.00
		
		select @totalfacturacion = sum(DocTotal)
		from SBO_CANELLA.dbo.oinv 
		where (OwnerCode = 414 or OwnerCode = 138 or OwnerCode = 411 or OwnerCode = 413)
		and cardcode = @clientesap 
		and U_Contrato = @nocontrato
		and MONTH(DocDate) = (@mes - 2)
		and YEAR(docdate) = @anio 
		group by DocTotal

		print @nocontrato
		print @clientesap

		-- Actualiza la tabla
		update REP_CONTRATOS_FORECAST set FACTURACION_MES_2 = @totalfacturacion where COD_CLIENTE_SAP = @clientesap and CONTRATO_NO = @nocontrato

		FETCH NEXT FROM Cursor_Datos4 INTO 
		@clientesap, @nocontrato

	end

	-- Cierra el cursor
	CLOSE Cursor_Datos4
	DEALLOCATE Cursor_Datos4

	-- Recorro la tabla para colocar la facturación del mes actual - 3
	DECLARE Cursor_Datos5 CURSOR FOR

	select COD_CLIENTE_SAP, CONTRATO_NO from REP_CONTRATOS_FORECAST

	OPEN Cursor_Datos5
	FETCH NEXT FROM Cursor_Datos5 INTO 
	@clientesap, @nocontrato
	WHILE @@FETCH_STATUS = 0 	

		begin

		set @totalfacturacion = 0.00
		
		select @totalfacturacion = sum(DocTotal)
		from SBO_CANELLA.dbo.oinv 
		where (OwnerCode = 414 or OwnerCode = 138 or OwnerCode = 411 or OwnerCode = 413)
		and cardcode = @clientesap 
		and U_Contrato = @nocontrato
		and MONTH(DocDate) = (@mes - 3)
		and YEAR(docdate) = @anio 
		group by DocTotal

		print @nocontrato
		print @clientesap

		-- Actualiza la tabla
		update REP_CONTRATOS_FORECAST set FACTURACION_MES_1 = @totalfacturacion where COD_CLIENTE_SAP = @clientesap and CONTRATO_NO = @nocontrato

		FETCH NEXT FROM Cursor_Datos5 INTO 
		@clientesap, @nocontrato

	end

	-- Cierra el cursor
	CLOSE Cursor_Datos5
	DEALLOCATE Cursor_Datos5

	-- Muestra los datos de la tabla
	declare @sqlCommand varchar(1000)
	
	print @mes

	-- Contruye la consulta sql 
	if @mes = 6
		set @sqlCommand = 'select CONTRATO_NO, CONTRATO_TIPO, COD_CLIENTE_SAP, NOMBRE_COMERCIAL, NIT_CLIENTE, case vip when ''1'' then ''SI'' else ''NO'' end as VIP, facturacion_mes_1 as FACTURACION_MARZO, facturacion_mes_2 as FACTURACION_ABRIL, facturacion_mes_3 as FACTURACION_MAYO, facturacion_mes_actual as FACTURACION_JUNIO from REP_CONTRATOS_FORECAST'

	if @mes = 7
		set @sqlCommand = 'select CONTRATO_NO, CONTRATO_TIPO, COD_CLIENTE_SAP, NOMBRE_COMERCIAL, NIT_CLIENTE, case vip when ''1'' then ''SI'' else ''NO'' end as VIP, facturacion_mes_1 as FACTURACION_ABRIL, facturacion_mes_2 as FACTURACION_MAYO, facturacion_mes_3 as FACTURACION_JUNIO, facturacion_mes_actual as FACTURACION_JULIO from REP_CONTRATOS_FORECAST'

	if @mes = 8
		set @sqlCommand = 'select CONTRATO_NO, CONTRATO_TIPO, COD_CLIENTE_SAP, NOMBRE_COMERCIAL, NIT_CLIENTE, case vip when ''1'' then ''SI'' else ''NO'' end as VIP, facturacion_mes_1 as FACTURACION_MAYO, facturacion_mes_2 as FACTURACION_JUNIO, facturacion_mes_3 as FACTURACION_JULIO, facturacion_mes_actual as FACTURACION_AGOSTO from REP_CONTRATOS_FORECAST'

	if @mes = 9
		set @sqlCommand = 'select CONTRATO_NO, CONTRATO_TIPO, COD_CLIENTE_SAP, NOMBRE_COMERCIAL, NIT_CLIENTE, case vip when ''1'' then ''SI'' else ''NO'' end as VIP, facturacion_mes_1 as FACTURACION_JUNIO, facturacion_mes_2 as FACTURACION_JULIO, facturacion_mes_3 as FACTURACION_AGOSTO, facturacion_mes_actual as FACTURACION_SEPTIEMBRE from REP_CONTRATOS_FORECAST'

	if @mes = 10
		set @sqlCommand = 'select CONTRATO_NO, CONTRATO_TIPO, COD_CLIENTE_SAP, NOMBRE_COMERCIAL, NIT_CLIENTE, case vip when ''1'' then ''SI'' else ''NO'' end as VIP, facturacion_mes_1 as FACTURACION_JULIO, facturacion_mes_2 as FACTURACION_AGOSTO, facturacion_mes_3 as FACTURACION_SEPTIEMBRE, facturacion_mes_actual as FACTURACION_OCTUBRE from REP_CONTRATOS_FORECAST'

	if @mes = 11
		set @sqlCommand = 'select CONTRATO_NO, CONTRATO_TIPO, COD_CLIENTE_SAP, NOMBRE_COMERCIAL, NIT_CLIENTE, case vip when ''1'' then ''SI'' else ''NO'' end as VIP, facturacion_mes_1 as FACTURACION_AGOSTO, facturacion_mes_2 as FACTURACION_SEPTIEMBRE, facturacion_mes_3 as FACTURACION_OCTUBRE, facturacion_mes_actual as FACTURACION_NOVIEMBRE from REP_CONTRATOS_FORECAST'

	if @mes = 12
		set @sqlCommand = 'select CONTRATO_NO, CONTRATO_TIPO, COD_CLIENTE_SAP, NOMBRE_COMERCIAL, NIT_CLIENTE, case vip when ''1'' then ''SI'' else ''NO'' end as VIP, facturacion_mes_1 as FACTURACION_SEPTIEMBRE, facturacion_mes_2 as FACTURACION_OCTUBRE, facturacion_mes_3 as FACTURACION_NOVIEMBRE, facturacion_mes_actual as FACTURACION_DICIEMBRE from REP_CONTRATOS_FORECAST'

	print @sqlCommand

	-- Ejecuta la consulta sql
	--set @sqlCommand = 'select * from REP_CONTRATOS_FORECAST'
	exec (@sqlCommand)

end