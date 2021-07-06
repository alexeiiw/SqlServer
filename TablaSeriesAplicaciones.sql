create table SeriesAplicaciones (
ID int identity primary key,
Serie varchar(30) not null,
Fecha_Activo datetime null,
Fecha_Desactivo datetime null,
Aplicacion varchar(150) null,
Activo bit not null
) 