CREATE procedure [dbo].[Presentar_REP_CONTRATOS_FORECAST] 
(
	-- Define parametros
	@IdReporte			INT=null,
	@Usuario			VARCHAR(50)=null
)
as
begin
	-- Define variables
	declare @mes int

	-- Muestra los datos de la tabla
	declare @sqlCommand varchar(1000)

	-- Obtiene los parametros de mes y año
	set @mes = MONTH(GETDATE())

	print @mes

	-- Contruye la consulta sql 
	if @mes = 6
		set @sqlCommand = 'select CONTRATO_NO, CONTRATO_TIPO, case contrato_estado when 8 then ''Clausurado'' when 3 then ''Aprobado/Vigente'' when 1 then ''Grabado'' end as CONTRATO_ESTADO, COD_CLIENTE_SAP, NOMBRE_COMERCIAL, NIT_CLIENTE, case vip when ''1'' then ''SI'' else ''NO'' end as VIP, facturacion_mes_1 as FACTURACION_MARZO, facturacion_mes_2 as FACTURACION_ABRIL, facturacion_mes_3 as FACTURACION_MAYO, facturacion_mes_actual as FACTURACION_JUNIO from REP_CONTRATOS_FORECAST'

	if @mes = 7
		set @sqlCommand = 'select CONTRATO_NO, CONTRATO_TIPO, case contrato_estado when 8 then ''Clausurado'' when 3 then ''Aprobado/Vigente'' when 1 then ''Grabado'' end as CONTRATO_ESTADO, COD_CLIENTE_SAP, NOMBRE_COMERCIAL, NIT_CLIENTE, case vip when ''1'' then ''SI'' else ''NO'' end as VIP, facturacion_mes_1 as FACTURACION_ABRIL, facturacion_mes_2 as FACTURACION_MAYO, facturacion_mes_3 as FACTURACION_JUNIO, facturacion_mes_actual as FACTURACION_JULIO from REP_CONTRATOS_FORECAST'

	if @mes = 8
		set @sqlCommand = 'select CONTRATO_NO, CONTRATO_TIPO, case contrato_estado when 8 then ''Clausurado'' when 3 then ''Aprobado/Vigente'' when 1 then ''Grabado'' end as CONTRATO_ESTADO, COD_CLIENTE_SAP, NOMBRE_COMERCIAL, NIT_CLIENTE, case vip when ''1'' then ''SI'' else ''NO'' end as VIP, facturacion_mes_1 as FACTURACION_MAYO, facturacion_mes_2 as FACTURACION_JUNIO, facturacion_mes_3 as FACTURACION_JULIO, facturacion_mes_actual as FACTURACION_AGOSTO from REP_CONTRATOS_FORECAST'

	if @mes = 9
		set @sqlCommand = 'select CONTRATO_NO, CONTRATO_TIPO, case contrato_estado when 8 then ''Clausurado'' when 3 then ''Aprobado/Vigente'' when 1 then ''Grabado'' end as CONTRATO_ESTADO, COD_CLIENTE_SAP, NOMBRE_COMERCIAL, NIT_CLIENTE, case vip when ''1'' then ''SI'' else ''NO'' end as VIP, facturacion_mes_1 as FACTURACION_JUNIO, facturacion_mes_2 as FACTURACION_JULIO, facturacion_mes_3 as FACTURACION_AGOSTO, facturacion_mes_actual as FACTURACION_SEPTIEMBRE from REP_CONTRATOS_FORECAST'

	if @mes = 10
		set @sqlCommand = 'select CONTRATO_NO, CONTRATO_TIPO, case contrato_estado when 8 then ''Clausurado'' when 3 then ''Aprobado/Vigente'' when 1 then ''Grabado'' end as CONTRATO_ESTADO, COD_CLIENTE_SAP, NOMBRE_COMERCIAL, NIT_CLIENTE, case vip when ''1'' then ''SI'' else ''NO'' end as VIP, facturacion_mes_1 as FACTURACION_JULIO, facturacion_mes_2 as FACTURACION_AGOSTO, facturacion_mes_3 as FACTURACION_SEPTIEMBRE, facturacion_mes_actual as FACTURACION_OCTUBRE from REP_CONTRATOS_FORECAST'

	if @mes = 11
		set @sqlCommand = 'select CONTRATO_NO, CONTRATO_TIPO, case contrato_estado when 8 then ''Clausurado'' when 3 then ''Aprobado/Vigente'' when 1 then ''Grabado'' end as CONTRATO_ESTADO, COD_CLIENTE_SAP, NOMBRE_COMERCIAL, NIT_CLIENTE, case vip when ''1'' then ''SI'' else ''NO'' end as VIP, facturacion_mes_1 as FACTURACION_AGOSTO, facturacion_mes_2 as FACTURACION_SEPTIEMBRE, facturacion_mes_3 as FACTURACION_OCTUBRE, facturacion_mes_actual as FACTURACION_NOVIEMBRE from REP_CONTRATOS_FORECAST'

	if @mes = 12
		set @sqlCommand = 'select CONTRATO_NO, CONTRATO_TIPO, case contrato_estado when 8 then ''Clausurado'' when 3 then ''Aprobado/Vigente'' when 1 then ''Grabado'' end as CONTRATO_ESTADO, COD_CLIENTE_SAP, NOMBRE_COMERCIAL, NIT_CLIENTE, case vip when ''1'' then ''SI'' else ''NO'' end as VIP, facturacion_mes_1 as FACTURACION_SEPTIEMBRE, facturacion_mes_2 as FACTURACION_OCTUBRE, facturacion_mes_3 as FACTURACION_NOVIEMBRE, facturacion_mes_actual as FACTURACION_DICIEMBRE from REP_CONTRATOS_FORECAST'

	print @sqlCommand

	-- Ejecuta la consulta sql
	--set @sqlCommand = 'select * from REP_CONTRATOS_FORECAST'
	exec (@sqlCommand)
end