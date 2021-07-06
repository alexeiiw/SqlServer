create table REP_CONTRATOS_FORECAST (
	CONTRATO_NO int,
	CONTRATO_TIPO varchar(02),
	COD_CLIENTE_SAP varchar(20),
	NOMBRE_COMERCIAL varchar(250),
	NIT_CLIENTE varchar(50),
	VIP bit,
	FACTURACION_MES_1 float,
	FACTURACION_MES_2 float,
	FACTURACION_MES_3 float,
	FACTURACION_MES_ACTUAL float			
)