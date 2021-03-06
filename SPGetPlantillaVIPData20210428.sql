USE [Canella_SISCON]
GO
/****** Object:  StoredProcedure [dbo].[GetPlantillaVIPData]    Script Date: 27/04/2021 11:51:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GetPlantillaVIPData]
(
  @NoContrato   VARCHAR(50), 
  @fecha_desde  varchar(10) = null,
  @fecha_hasta  varchar(10) = null,
  @mes integer = null,
  @anio integer = null, 
  @operacion integer -- 0 operación con rango de fechas -- 1 operación con mes / año
)
AS
BEGIN

--declare @NoContrato   VARCHAR(50) = 4068
--declare @operacion integer = 1
--declare @fecha_desde  varchar(10) = null
--declare @fecha_hasta  varchar(10) = null
--declare @mes integer = 1
--declare @anio integer = 2021 

if (@operacion = 0) -- Operación con rango de fechas
begin

	SELECT  
		  --distinct (cont.Serie ) Serie,	
		   l.BkGrandesRealizadas ConsumoMes105, 
	       l.ColorRealizadas ConsumoMes120,
	       '' TipoDeEquipoBWColor, 
		   --ccdr.AREA  UbicacionEquipoDentroEmpresa, 
		   l.Direccion UbicacionEquipoDentroEmpresa,
		   --ccdr.DIRECCION_EQUI_EMPRESA  DireccionUbicacionEquipo,
		   SCON.[Dirección] as DireccionUbicacionEquipo,
		   --ccdr.AGENCIA_DEPTO DepartamentoMunicipio, 
		   ISNULL(l.Depatamento+' / ','')+'  '+ ISNULL(l.Municipio,'') DepartamentoMunicipio,
		   --ccdr.ZONA_GEOGRAFICA zona, 
		   l.Zona Zona,
		   ccdr.CENTRO_COMERCIAL  Edificio, 
		   '' Nivel,
	       '' NoDeBoleta, 
		   l.FecUltLect  FechaDeLecturaAnterior101, 
		   l.Ultimo_Contador  ContadorAnterior101BW, 
		   l.FechaLectActual  FechaDeLecturaActual101, 
		   l.Contador_Actual  ContadorActual101BW,
		   (l.Contador_Actual - l.Ultimo_Contador) ConsumoMes101BW,
	       l.ContadorAnterior105Color, 
		   l.FechaLectActual FechaLecturaActual105, 
		   l.FecUltLect  FechaLecturaAnterior105, 
		   l.ContadorActual105Color,  
		   l.TotalCopiasImpresionesCARTAColor, 
		   l.FecUltLect  FechaLecturaAnterior120, 
		   l.ContadorAnterior120DobleCartaColor,  
		   l.FechaLectActual  FechaDeLecturaActual120, 
	       l.ContadorActual120DobleCartaColor,
		   l.TotalCopiasImpresionesDOBLECARTAColor, 
		   DATEDIFF(DAY, l.FecUltLect,l.FechaLectActual) DiasEntreTomaDeLecturas, 
		   0 ExcedenteImpresionesBW,  
		   0 ExcedenteImpresionesColor, 
		   0 CostoExcedentePorEquipoBW,  
		   0 CostoExcedentePorEquipoColor,
	       '' TipoDeCambio, 
		   ccdr.NOMBRE_EQUIPO NombreImpresora, 
		   --ccdr.DIRECCION_IP DireccionIP, 
   		   SCON.[Comentario] as DireccionIP,
		   ccdr.MAC_ADDRESS MACAddress,  
		   ccdr.ID_EQUIPO_CLIENTE CodigoIdentificacionImpresoraPorCliente,  
		   ccdr.CENTRO_COMERCIAL CentroComercial,  
		   ccdr.NUMERO_AGENCIA NumeroAgencia, 
		   ccdr.AREA  Area,  
		   --ccdr.AGENCIA_DEPTO AgenciaDepartamento, 
   		   SCON.[Agencia/Depto] as AgenciaDepartamento,
		   --ccdr.ZONA_GEOGRAFICA ZonaGeograficaClasificadoPorCliente,  
   		   SCON.[Zona] as ZonaGeograficaClasificadoPorCliente,
		   ccdr.ENCARGADO_EQUIPO PersonaEncargadaEquipo,
	       ccdr.TEL_ENCARGADO_EQUIPO TelefonoPersonaEncargadaEquipo,  
		   ccdr.CUOTA_FIJA CuotaFijaPorEquipo, 
		   ccdr.VOLUMEN_BN DerechoAImpresionesBW, 
		   ccdr.VOLUMEN_COLOR DerechoAImpresionesColor, 
		   ccdr.DIRECCION_EQUI_EMPRESA,
		   l.Serie,
		   T0.CONTRATO_NO Contrato,		
			T0.COD_CLIENTE CodigoClienteSAP,	
			T0.NOMBRE_CLIENTE NombreEmpresaTitulardelContrato,
			T0.NIT_CLIENTE NITEmpresaTitulardelContrato,
			T0.DIRECCION_CLIENTE DireccionEmpresaTitulardelContrato,
			T0.NOMBRE_COMERCIAL NombreEmpresaAFacturar, 
			T0.NIT_CLIENTE NITEmpresaAFacturar,	
			T0.DIRECCION_CLIENTE DireccionEmpresaFacturar,
			(SELECT T2.Descripcion from VW_SBO_PRODUCTOS T2 where T2.Cod_Producto  = ccdr.COD_ARTICULO ) Modelo,	
			ccdr.AssetID,
			T0.COD_USUARIO_VENDEDOR Vendedor,
			T0.CONTRATO_TIPO TipoDeContrato,
			T0.Moneda,
			T0.EXCEDENTE_CARTA_BN CostoExcedenteBW,
			T0.EXCEDENTE_CARTA_COLOR CostoExcedenteColor
	FROM 
		Lecturas..[HistorialDeLecturas] l 
		INNER JOIN COT_CONTRATOS_DET_DESPACHO ccdr ON ccdr.NUMERO_SERIE COLLATE DATABASE_DEFAULT =  l.Serie COLLATE DATABASE_DEFAULT and ccdr.ESTATUS_ARTICULO = '1' and  ccdr.TIPO_LINEA = 'M'	
		INNER JOIN Cot_Contratos_Enc T0 ON ccdr.CONTRATO_NO  = t0.CONTRATO_NO
		inner join [128.1.5.79].[SCON].dbo.[Datos Actuales] SCON on SCON.Serie COLLATE DATABASE_DEFAULT = l.Serie
	WHERE 	T0.CONTRATO_NO  = @NoContrato
		and l.FechaLectActual  BETWEEN   convert(datetime,@fecha_desde,120)  AND   convert(datetime,@fecha_hasta,120)
		and T0.CONTRATO_NO  = @NoContrato

end

else -- Operación por mes / año
begin 

	SELECT  
		  --distinct (cont.Serie ) Serie,	
		   l.BkGrandesRealizadas ConsumoMes105, 
	       l.ColorRealizadas ConsumoMes120,
	       '' TipoDeEquipoBWColor, 
		   --ccdr.AREA  UbicacionEquipoDentroEmpresa, 
		   l.Direccion UbicacionEquipoDentroEmpresa,
		   --ccdr.DIRECCION_EQUI_EMPRESA  DireccionUbicacionEquipo,
		   SCON.[Dirección] as DireccionUbicacionEquipo,
		   --ccdr.AGENCIA_DEPTO DepartamentoMunicipio, 
		   ISNULL(l.Depatamento+' / ','')+'  '+ ISNULL(l.Municipio,'') DepartamentoMunicipio,
		   --ccdr.ZONA_GEOGRAFICA zona, 
		   l.Zona Zona,
		   ccdr.CENTRO_COMERCIAL  Edificio, 
		   '' Nivel,
	       '' NoDeBoleta, 
		   l.FecUltLect  FechaDeLecturaAnterior101, 
		   l.Ultimo_Contador  ContadorAnterior101BW, 
		   l.FechaLectActual  FechaDeLecturaActual101, 
		   l.Contador_Actual  ContadorActual101BW,
		   (l.Contador_Actual - l.Ultimo_Contador) ConsumoMes101BW,
	       l.ContadorAnterior105Color, 
		   l.FechaLectActual FechaLecturaActual105, 
		   l.FecUltLect  FechaLecturaAnterior105, 
		   l.ContadorActual105Color,  
		   l.TotalCopiasImpresionesCARTAColor, 
		   l.FecUltLect  FechaLecturaAnterior120, 
		   l.ContadorAnterior120DobleCartaColor,  
		   l.FechaLectActual  FechaDeLecturaActual120, 
	       l.ContadorActual120DobleCartaColor,
		   l.TotalCopiasImpresionesDOBLECARTAColor, 
		   DATEDIFF(DAY, l.FecUltLect,l.FechaLectActual) DiasEntreTomaDeLecturas, 
		   0 ExcedenteImpresionesBW,  
		   0 ExcedenteImpresionesColor, 
		   0 CostoExcedentePorEquipoBW,  
		   0 CostoExcedentePorEquipoColor,
	       '' TipoDeCambio, 
		   ccdr.NOMBRE_EQUIPO NombreImpresora, 
		   --ccdr.DIRECCION_IP DireccionIP, 
   		   SCON.[Comentario] as DireccionIP,
		   ccdr.MAC_ADDRESS MACAddress,  
		   ccdr.ID_EQUIPO_CLIENTE CodigoIdentificacionImpresoraPorCliente,  
		   ccdr.CENTRO_COMERCIAL CentroComercial,  
		   ccdr.NUMERO_AGENCIA NumeroAgencia, 
		   ccdr.AREA  Area,  
		   --ccdr.AGENCIA_DEPTO AgenciaDepartamento, 
   		   SCON.[Agencia/Depto] as AgenciaDepartamento,
		   --ccdr.ZONA_GEOGRAFICA ZonaGeograficaClasificadoPorCliente,  
   		   SCON.[Zona] as ZonaGeograficaClasificadoPorCliente,
		   ccdr.ENCARGADO_EQUIPO PersonaEncargadaEquipo,
	       ccdr.TEL_ENCARGADO_EQUIPO TelefonoPersonaEncargadaEquipo,  
		   ccdr.CUOTA_FIJA CuotaFijaPorEquipo, 
		   ccdr.VOLUMEN_BN DerechoAImpresionesBW, 
		   ccdr.VOLUMEN_COLOR DerechoAImpresionesColor, 
		   ccdr.DIRECCION_EQUI_EMPRESA,
		   l.Serie,
		   T0.CONTRATO_NO Contrato,		
			T0.COD_CLIENTE CodigoClienteSAP,	
			T0.NOMBRE_CLIENTE NombreEmpresaTitulardelContrato,
			T0.NIT_CLIENTE NITEmpresaTitulardelContrato,
			T0.DIRECCION_CLIENTE DireccionEmpresaTitulardelContrato,
			T0.NOMBRE_COMERCIAL NombreEmpresaAFacturar, 
			T0.NIT_CLIENTE NITEmpresaAFacturar,	
			T0.DIRECCION_CLIENTE DireccionEmpresaFacturar,
			(SELECT T2.Descripcion from VW_SBO_PRODUCTOS T2 where T2.Cod_Producto  = ccdr.COD_ARTICULO ) Modelo,	
			ccdr.AssetID,
			T0.COD_USUARIO_VENDEDOR Vendedor,
			T0.CONTRATO_TIPO TipoDeContrato,
			T0.Moneda,
			T0.EXCEDENTE_CARTA_BN CostoExcedenteBW,
			T0.EXCEDENTE_CARTA_COLOR CostoExcedenteColor
	FROM 
		Lecturas..[HistorialDeLecturas] l 
		INNER JOIN COT_CONTRATOS_DET_DESPACHO ccdr ON ccdr.NUMERO_SERIE COLLATE DATABASE_DEFAULT =  l.Serie COLLATE DATABASE_DEFAULT and ccdr.ESTATUS_ARTICULO = '1' and  ccdr.TIPO_LINEA = 'M'	
		INNER JOIN Cot_Contratos_Enc T0 ON ccdr.CONTRATO_NO  = t0.CONTRATO_NO
		inner join [128.1.5.79].[SCON].dbo.[Datos Actuales] SCON on SCON.Serie COLLATE DATABASE_DEFAULT = l.Serie
	WHERE 	T0.CONTRATO_NO  = @NoContrato
	and l.Year = @anio and l.Mes = @mes

end



	
	/*
	--SE OBTIENEN LAS LECTURAS GRABADAS, DESDE PROSONE
	SELECT 
		--MAX(ID) ID,
		ID, 
		Serie 
	INTO #tmp
	FROM 
		Lecturas..[HistorialDeLecturas]
	WHERE 
		NoContrato = @NoContrato 	
		--and FechaLectActual  BETWEEN @fecha_desde and @fecha_hasta	
			
	--GROUP BY 
	--	Serie

	-- SE OBTIENE EL CALCULO DE CONSUMO DE CONTADOR105
	SELECT 
		l.Serie, 
		l.BkGrandesRealizadas  AS ConsumoMes105
	INTO #ConsumoMes105
	FROM 
		Lecturas..[HistorialDeLecturas] l
		INNER JOIN #tmp t ON l.ID = t.ID
	-------CAMBIOS REALIZADOS  POR MODIFICACIONES EN LECTURAS 
	--WHERE 
		--l.FechaLectActual  BETWEEN @fecha_desde and @fecha_hasta	


	SELECT 
		l.Serie, 
		l.ColorRealizadas AS ConsumoMes120
	INTO #ConsumoMes120
	FROM 
		Lecturas..[HistorialDeLecturas] l INNER JOIN #tmp t ON l.ID = t.ID
	--------CAMBIOS REALIZADOS  POR MODIFICACIONES EN LECTURAS 
	--WHERE 
		---l.FechaLectActual  BETWEEN @fecha_desde and @fecha_hasta	
		






	--SE EXTRAE LA INFORMACION DE SISCON 
	SELECT 
			T1.NUMERO_SERIE Serie,
			T0.CONTRATO_NO Contrato,		
			T0.COD_CLIENTE CodigoClienteSAP,	
			T0.NOMBRE_CLIENTE NombreEmpresaTitulardelContrato,
			T0.NIT_CLIENTE NITEmpresaTitulardelContrato,
			T0.DIRECCION_CLIENTE DireccionEmpresaTitulardelContrato,
			T0.NOMBRE_COMERCIAL NombreEmpresaAFacturar, 
			T0.NIT_CLIENTE NITEmpresaAFacturar,	
			T0.DIRECCION_CLIENTE DireccionEmpresaFacturar,
			(SELECT T2.Descripcion from VW_SBO_PRODUCTOS T2 where T2.Cod_Producto  = T1.COD_ARTICULO ) Modelo,	
			T1.AssetID,
			T0.COD_USUARIO_VENDEDOR Vendedor,
			T0.CONTRATO_TIPO TipoDeContrato,
			T0.Moneda,
			T0.EXCEDENTE_CARTA_BN CostoExcedenteBW,
			T0.EXCEDENTE_CARTA_COLOR CostoExcedenteColor
	INTO #Contratos
	FROM Cot_Contratos_Enc T0
		inner join COT_CONTRATOS_DET_DESPACHO T1 on T0.CONTRATO_NO = T1.CONTRATO_NO and T1.ESTATUS_ARTICULO ='1' and T1.TIPO_LINEA ='M'
		WHERE T0.Contrato_No  = @NoContrato 
		AND CONTRATO_ESTADO = 3 
		AND CONTRATO_TIPO = 'R'
		AND ISNULL(T1.NUMERO_SERIE, '') <> ''
	GROUP BY T0.CONTRATO_NO,  T0.COD_CLIENTE,  T0.NOMBRE_CLIENTE, T0.NIT_CLIENTE, T0.DIRECCION_CLIENTE, T0.NOMBRE_COMERCIAL, T1.AssetID, T0.COD_USUARIO_VENDEDOR ,
	T0.CONTRATO_TIPO, T0.Moneda, T0.EXCEDENTE_CARTA_BN, T0.EXCEDENTE_CARTA_COLOR, T1.NUMERO_SERIE, T1.COD_ARTICULO 
	

	SELECT 
	     ID, 
		l.Serie 
	INTO 
		#MaxContadores 
	FROM #Contratos cont LEFT OUTER JOIN Lecturas..[HistorialDeLecturas] l
			ON l.Serie  COLLATE DATABASE_DEFAULT = cont.Serie  COLLATE DATABASE_DEFAULT
	--WHERE 
		--l.FechaLectActual  BETWEEN @fecha_desde and @fecha_hasta	
		
	--GROUP BY 
	--	l.Serie



	SELECT 
		l.* 
	INTO 
		#HistorialLecturas 
	FROM 
		Lecturas..[HistorialDeLecturas] l INNER JOIN #MaxContadores c ON l.ID = c.ID
		--and l.FechaLectActual  BETWEEN @fecha_desde and @fecha_hasta	
		

	SELECT 
		   --distinct (cont.Serie ) Serie,	
		   ConsumoMes105, 
	       ConsumoMes120,
	       '' TipoDeEquipoBWColor, 
		   --ccdr.AREA  UbicacionEquipoDentroEmpresa, 
		   l.Direccion UbicacionEquipoDentroEmpresa,
		   ccdr.DIRECCION_EQUI_EMPRESA  DireccionUbicacionEquipo,
		   --ccdr.AGENCIA_DEPTO DepartamentoMunicipio, 
		   ISNULL(l.Depatamento+' / ','')+'  '+ ISNULL(l.Municipio,'') DepartamentoMunicipio,
		   --ccdr.ZONA_GEOGRAFICA zona, 
		   l.Zona Zona,
		   ccdr.CENTRO_COMERCIAL  Edificio, 
		   '' Nivel,
	       '' NoDeBoleta, 
		   l.FecUltLect  FechaDeLecturaAnterior101, 
		   l.Ultimo_Contador  ContadorAnterior101BW, 
		   l.FechaLectActual  FechaDeLecturaActual101, 
		   l.Contador_Actual  ContadorActual101BW,
		   (l.Contador_Actual - l.Ultimo_Contador) ConsumoMes101BW,
	       l.ContadorAnterior105Color, 
		   l.FechaLectActual FechaLecturaActual105, 
		   l.FecUltLect  FechaLecturaAnterior105, 
		   l.ContadorActual105Color,  
		   l.TotalCopiasImpresionesCARTAColor, 
		   l.FecUltLect  FechaLecturaAnterior120, 
		   l.ContadorAnterior120DobleCartaColor,  
		   l.FechaLectActual  FechaDeLecturaActual120, 
	       l.ContadorActual120DobleCartaColor,
		   l.TotalCopiasImpresionesDOBLECARTAColor, 
		   DATEDIFF(DAY, l.FecUltLect,l.FechaLectActual) DiasEntreTomaDeLecturas, 
		   0 ExcedenteImpresionesBW,  
		   0 ExcedenteImpresionesColor, 
		   0 CostoExcedentePorEquipoBW,  
		   0 CostoExcedentePorEquipoColor,
	       '' TipoDeCambio, 
		   ccdr.NOMBRE_EQUIPO NombreImpresora, 
		   ccdr.DIRECCION_IP DireccionIP, 
		   ccdr.MAC_ADDRESS MACAddress,  
		   ccdr.ID_EQUIPO_CLIENTE CodigoIdentificacionImpresoraPorCliente,  
		   ccdr.CENTRO_COMERCIAL CentroComercial,  
		   ccdr.NUMERO_AGENCIA NumeroAgencia, 
		   ccdr.AREA  Area,  
		   ccdr.AGENCIA_DEPTO AgenciaDepartamento, 
		   ccdr.ZONA_GEOGRAFICA ZonaGeograficaClasificadoPorCliente,  
		   ccdr.ENCARGADO_EQUIPO PersonaEncargadaEquipo,
	       ccdr.TEL_ENCARGADO_EQUIPO TelefonoPersonaEncargadaEquipo,  
		   ccdr.CUOTA_FIJA CuotaFijaPorEquipo, 
		   ccdr.VOLUMEN_BN DerechoAImpresionesBW, 
		   ccdr.VOLUMEN_COLOR DerechoAImpresionesColor, 
		   ccdr.DIRECCION_EQUI_EMPRESA
		   ---
		   ,cont.*
		   /*
		   ,cont.Contrato
		   ,cont.CodigoClienteSAP
		   ,cont.DireccionEmpresaTitulardelContrato
		   ,cont.NITEmpresaTitulardelContrato
		   ,cont.DireccionEmpresaTitulardelContrato
		   ,cont.NombreEmpresaAFacturar
		   ,cont.NITEmpresaAFacturar
		   ,cont.DireccionEmpresaFacturar
		   ,cont.Modelo
		   ,cont.ASSETID
		   ,cont.Vendedor
		   ,cont.TipoDeContrato
		   ,cont.MONEDA
		   ,cont.CostoExcedenteBW
		   ,cont.CostoExcedenteColor
		   */
	FROM #Contratos cont 
		left  JOIN #HistorialLecturas l
			ON l.Serie  COLLATE DATABASE_DEFAULT = cont.Serie  COLLATE DATABASE_DEFAULT and l.FechaLectActual  BETWEEN @fecha_desde and @fecha_hasta	
		left  JOIN #tmp t
			ON l.ID = t.ID
		left JOIN #ConsumoMes105 ConMes105
			ON ConMes105.Serie = l.Serie
		left JOIN #ConsumoMes120 ConMes120
			ON ConMes120.Serie = l.Serie
		left JOIN COT_CONTRATOS_DET_DESPACHO ccdr
			ON ccdr.NUMERO_SERIE COLLATE DATABASE_DEFAULT =  l.Serie COLLATE DATABASE_DEFAULT and ccdr.ESTATUS_ARTICULO = '1' and  ccdr.TIPO_LINEA = 'M'	


			DROP TABLE #tmp
			DROP TABLE #ConsumoMes105
			DROP TABLE #ConsumoMes120
			DROP TABLE #Contratos
			DROP TABLE #HistorialLecturas
			DROP TABLE #MaxContadores

			*/
		
END
