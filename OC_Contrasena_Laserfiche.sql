USE [SBO_CANELLA]
GO
/****** Object:  StoredProcedure [dbo].[OC_Contrasena_Laserfiche]    Script Date: 16/02/2022 04:14:16 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[OC_Contrasena_Laserfiche]
	@ordencompra as bigint = null,
	@nombredocumento as varchar(50) = null
as
begin
-- Autor: Alex García
-- Fecha: 09/06/2021
-- Bitácora: 
-- 20210609 - Se cambio la forma de obtener el PO desde el archivo, ahora el archivo solo tiene el número de la PO
-- 20210618 - Se cambio el correo electrónico para las pruebas
-- 20211109 - Se agrego la descripción del medio de pago
-- 20211119 - Se arreglo BUG de PO de Canella, el dueño de la orden no es vendedor / devuelve dos decimales en el monto de compra
-- 20211123 - Se agrego el campo del saldo de la orden de compra
-- 20211124 - Se agrego una función que calcula el saldo de la orden de compra
-- 20211213 - Se cambia el correo electrónico para que apunte a producción
-- 20220113 - Se agrego al proveedor de contado

	-- Declara variables
	declare @error as varchar(150)
	--declare @ordencompra as bigint = null
	--declare @nombredocumento as varchar(50) = '2000503.pdf'
	declare @proveedor as varchar(50) 

	-- Obtiene a partir del nombre el número de OC, proceso por nombre
	if @ordencompra is null
	begin
		-- Se quita la extensión del archivo para procesarlo
		set @nombredocumento = REPLACE(@nombredocumento,'.pdf','')
		set @nombredocumento = REPLACE(@nombredocumento,'.PDF','')

		-- Valida que la orden de compra sea número	
		--if isnumeric(substring(@nombredocumento,8,8)) = 0 
		if ISNUMERIC(@nombredocumento) = 0
		begin
			set @error = 'Nombre del documento incorrecto'

			select @error
		end

		else
		begin
			--set @ordencompra = CAST(substring(@nombredocumento,8,8) as bigint)
			set @ordencompra = @nombredocumento

			-- Revisa si es un proveedor de contado
			select @proveedor = PRO.PymCode 
			from OCRD PRO, OPOR OC
			where PRO.CardCode = OC.CardCode
			and OC.DocNum = 26295

			-- Si es proveedor de contado
			if @proveedor is null
			begin
				-- Realiza la consulta
				select top 1 OC.DocNum as NoOrdenCompra
				, OC.CardName as NombreProveedor
				, PRO.AddID as NitProveedor
				, PRO.Address as DirProveedor
				, PRO.E_Mail as EmailProveedor
				--, 'aarrecis@canella.com.gt' as EmailProveedor
				, PRO.CardCode as IdProveedor
				, OC.Comments as Solicitante
				--, DEP.SlpName as DeptoSolicitante
				, cast (OC.DocTotal as decimal (10,2)) as MontoCompra
				, OC.DocDate as FechaCompra
				, @nombredocumento as NombreDocumento
				--, PRO.PymCode as MedioPago
				, MEP.Descript as MedioPago
				, case OC.CANCELED
				when 'Y' then 'Si'
				else 'No'
				end as Cancelada
				, case OC.DocStatus
				when 'O' then 'Abierta'
				when 'C' then 'Cerrada'
				end as EstadoDocumento
				, case PRO.WTLiable
				when 'Y' then 'Sujeto a retención'
				else 'No es Sujeto a retención'
				end as Regimen
				, CPAG.PymntGroup as Diasdepago
				, EMP.empid as CodigoEmpleado
				, EMP.lastName as ApellidosEmpleado
				, EMP.firstName as NombreEmpleado
				, emp.dept as CodigoDepartamento
				, DEPA.Name as NombreDepartamentoEmpleado
				, PUE.posID as CodigoPuestoEmpleado
				, PUE.descriptio as PuestoEmpleado

				, cast (isnull((select top 1 (OC.DocTotal - (PA.SumApplied + FA.WTSum)) as SaldoOrdenCompra
				from OPOR OC, POR1 D_OC, VPM2 PA, OPCH FA 
				where D_OC.LineNum = 0
				and FA.DocEntry = D_OC.TrgetEntry
				and PA.docentry = D_OC.TrgetEntry
				and D_OC.DocEntry = OC.DocEntry
				and OC.DocNum = @ordencompra),OC.DocTotal) as decimal (10,2)) as SaldoOrdenCompra

				--, 0 as SaldoOrdenCompra
				from OPOR OC, OCRD PRO, OHEM EMP, 
				--OSLP DEP, 
				OCTG CPAG
				, OUDP DEPA, OHPS PUE, OPYM MEP
				where 
				--MEP.PayMethCod = PRO.PymCode
				--and 
				PUE.posID = EMP.position
				and DEPA.Code = EMP.dept
				and CPAG.GroupNum = OC.GroupNum
				--and DEP.SlpCode = EMP.salesPrson
				and EMP.empID = OC.OwnerCode
				and PRO.CardCode = OC.CardCode
				and OC.DocNum = @ordencompra

			end

			else 
			begin
				-- Realiza la consulta
				select OC.DocNum as NoOrdenCompra
				, OC.CardName as NombreProveedor
				, PRO.AddID as NitProveedor
				, PRO.Address as DirProveedor
				, PRO.E_Mail as EmailProveedor
				--, 'aarrecis@canella.com.gt' as EmailProveedor
				, PRO.CardCode as IdProveedor
				, OC.Comments as Solicitante
				--, DEP.SlpName as DeptoSolicitante
				, cast (OC.DocTotal as decimal (10,2)) as MontoCompra
				, OC.DocDate as FechaCompra
				, @nombredocumento as NombreDocumento
				--, PRO.PymCode as MedioPago
				, MEP.Descript as MedioPago
				, case OC.CANCELED
				when 'Y' then 'Si'
				else 'No'
				end as Cancelada
				, case OC.DocStatus
				when 'O' then 'Abierta'
				when 'C' then 'Cerrada'
				end as EstadoDocumento
				, case PRO.WTLiable
				when 'Y' then 'Sujeto a retención'
				else 'No es Sujeto a retención'
				end as Regimen
				, CPAG.PymntGroup as Diasdepago
				, EMP.empid as CodigoEmpleado
				, EMP.lastName as ApellidosEmpleado
				, EMP.firstName as NombreEmpleado
				, emp.dept as CodigoDepartamento
				, DEPA.Name as NombreDepartamentoEmpleado
				, PUE.posID as CodigoPuestoEmpleado
				, PUE.descriptio as PuestoEmpleado

				, cast (isnull((select top 1 (OC.DocTotal - (PA.SumApplied + FA.WTSum)) as SaldoOrdenCompra
				from OPOR OC, POR1 D_OC, VPM2 PA, OPCH FA 
				where D_OC.LineNum = 0
				and FA.DocEntry = D_OC.TrgetEntry
				and PA.docentry = D_OC.TrgetEntry
				and D_OC.DocEntry = OC.DocEntry
				and OC.DocNum = @ordencompra),OC.DocTotal) as decimal (10,2)) as SaldoOrdenCompra

				--, 0 as SaldoOrdenCompra
				from OPOR OC, OCRD PRO, OHEM EMP, 
				--OSLP DEP, 
				OCTG CPAG
				, OUDP DEPA, OHPS PUE, OPYM MEP
				where 
				MEP.PayMethCod = PRO.PymCode
				and 
				PUE.posID = EMP.position
				and DEPA.Code = EMP.dept
				and CPAG.GroupNum = OC.GroupNum
				--and DEP.SlpCode = EMP.salesPrson
				and EMP.empID = OC.OwnerCode
				and PRO.CardCode = OC.CardCode
				and OC.DocNum = @ordencompra

			end

		end

	end

	else
	begin
		-- Valida que la orden de compra sea número
		if ISNUMERIC(@ordencompra) = 0
		begin
			set @error = 'Número de documento incorrecto'

			select @error		
		end

		else
		begin

			-- Revisa si es un proveedor de contado
			select @proveedor = PRO.PymCode 
			from OCRD PRO, OPOR OC
			where PRO.CardCode = OC.CardCode
			and OC.DocNum = 26295

			-- Si es proveedor de contado
			if @proveedor is null
			begin
				-- Realiza la consulta
				select top 1 OC.DocNum as NoOrdenCompra
				, OC.CardName as NombreProveedor
				, PRO.AddID as NitProveedor
				, PRO.Address as DirProveedor
				, PRO.E_Mail as EmailProveedor
				--, 'aarrecis@canella.com.gt' as EmailProveedor
				, PRO.CardCode as IdProveedor
				, OC.Comments as Solicitante
				--, DEP.SlpName as DeptoSolicitante
				, cast (OC.DocTotal as decimal (10,2)) as MontoCompra
				, OC.DocDate as FechaCompra
				, @nombredocumento as NombreDocumento
				--, PRO.PymCode as MedioPago
				, MEP.Descript as MedioPago
				, case OC.CANCELED
				when 'Y' then 'Si'
				else 'No'
				end as Cancelada
				, case OC.DocStatus
				when 'O' then 'Abierta'
				when 'C' then 'Cerrada'
				end as EstadoDocumento
				, case PRO.WTLiable
				when 'Y' then 'Sujeto a retención'
				else 'No es Sujeto a retención'
				end as Regimen
				, CPAG.PymntGroup as Diasdepago
				, EMP.empid as CodigoEmpleado
				, EMP.lastName as ApellidosEmpleado
				, EMP.firstName as NombreEmpleado
				, emp.dept as CodigoDepartamento
				, DEPA.Name as NombreDepartamentoEmpleado
				, PUE.posID as CodigoPuestoEmpleado
				, PUE.descriptio as PuestoEmpleado

				, cast (isnull((select top 1 (OC.DocTotal - (PA.SumApplied + FA.WTSum)) as SaldoOrdenCompra
				from OPOR OC, POR1 D_OC, VPM2 PA, OPCH FA 
				where D_OC.LineNum = 0
				and FA.DocEntry = D_OC.TrgetEntry
				and	PA.docentry = D_OC.TrgetEntry
				and D_OC.DocEntry = OC.DocEntry
				and OC.DocNum = @ordencompra),OC.DocTotal) as decimal (10,2)) as SaldoOrdenCompra

				--, 0 as SaldoOrdenCompra
				from OPOR OC, OCRD PRO, OHEM EMP, 
				--OSLP DEP, 
				OCTG CPAG
				, OUDP DEPA, OHPS PUE, OPYM MEP
				where 
				--MEP.PayMethCod = PRO.PymCode
				--and 
				PUE.posID = EMP.position
				and DEPA.Code = EMP.dept
				and CPAG.GroupNum = OC.GroupNum
				--and DEP.SlpCode = EMP.salesPrson
				and EMP.empID = OC.OwnerCode
				and PRO.CardCode = OC.CardCode
				and OC.DocNum = @ordencompra

			end

			else 
			begin
				-- Realiza la consulta
				select OC.DocNum as NoOrdenCompra
				, OC.CardName as NombreProveedor
				, PRO.AddID as NitProveedor
				, PRO.Address as DirProveedor
				, PRO.E_Mail as EmailProveedor
				--, 'aarrecis@canella.com.gt' as EmailProveedor
				, PRO.CardCode as IdProveedor
				, OC.Comments as Solicitante
				--, DEP.SlpName as DeptoSolicitante
				, cast (OC.DocTotal as decimal (10,2)) as MontoCompra
				, OC.DocDate as FechaCompra
				, @nombredocumento as NombreDocumento
				--, PRO.PymCode as MedioPago
				, MEP.Descript as MedioPago
				, case OC.CANCELED
				when 'Y' then 'Si'
				else 'No'
				end as Cancelada
				, case OC.DocStatus
				when 'O' then 'Abierta'
				when 'C' then 'Cerrada'
				end as EstadoDocumento
				, case PRO.WTLiable
				when 'Y' then 'Sujeto a retención'
				else 'No es Sujeto a retención'
				end as Regimen
				, CPAG.PymntGroup as Diasdepago
				, EMP.empid as CodigoEmpleado
				, EMP.lastName as ApellidosEmpleado
				, EMP.firstName as NombreEmpleado
				, emp.dept as CodigoDepartamento
				, DEPA.Name as NombreDepartamentoEmpleado
				, PUE.posID as CodigoPuestoEmpleado
				, PUE.descriptio as PuestoEmpleado
					
				, cast (isnull((select top 1 (OC.DocTotal - (PA.SumApplied + FA.WTSum)) as SaldoOrdenCompra
				from OPOR OC, POR1 D_OC, VPM2 PA, OPCH FA 
				where D_OC.LineNum = 0
				and FA.DocEntry = D_OC.TrgetEntry
				and PA.docentry = D_OC.TrgetEntry
				and D_OC.DocEntry = OC.DocEntry
				and OC.DocNum = @ordencompra),OC.DocTotal) as decimal (10,2)) as SaldoOrdenCompra

				--, 0 as SaldoOrdenCompra
				from OPOR OC, OCRD PRO, OHEM EMP, 
				--OSLP DEP, 
				OCTG CPAG
				, OUDP DEPA, OHPS PUE, OPYM MEP
				where 
				MEP.PayMethCod = PRO.PymCode
				and 
				PUE.posID = EMP.position
				and DEPA.Code = EMP.dept
				and CPAG.GroupNum = OC.GroupNum
				--and DEP.SlpCode = EMP.salesPrson
				and EMP.empID = OC.OwnerCode
				and PRO.CardCode = OC.CardCode
				and OC.DocNum = @ordencompra

			end

		end

	end

end
