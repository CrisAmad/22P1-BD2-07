select * from bd_platvideo.tbl_suscriptores;
select * from bd_platvideo.tbl_productos;
select * from bd_platvideo.tbl_ciclos_facturacion;
select * from bd_platvideo.tbl_cartera;
select * from bd_platvideo.tbl_fact_detalle;
Select * from bd_platvideo.tbl_fact_resumen;


/*1. Funciones almacenadas: Crear una función almacenada que devuelva el valor real o valor porcentual 
(según se indique) de una tarifa que se encuentre en la tabla tarifas.*/

drop procedure bd_platvideo.SP_TARIFA;
delimiter //
CREATE PROCEDURE bd_platvideo.SP_TARIFA(
    in p_id                 int,
    in p_valor 	            varchar(45)
)

BEGIN
    declare Gesti1               varchar(45);
    declare Gesti2                varchar(45);
	declare v_nombre           varchar(45); 
    declare v_valor_real       decimal(12,2);
    declare v_valor_porcentual decimal(12,2);
    declare v_eleccion         decimal(12,2);
    declare resultados              varchar(400);

    select nombre, valor_real,valor_procentual into v_nombre,v_valor_real,v_valor_porcentual 
      from bd_platvideo.tbl_tarifas where id_tarifa =  p_id;
        
        CASE
		  when p_valor = 'real'         then    set v_eleccion = v_valor_real  ; 
		  when p_valor = 'porcentual'   then    set v_eleccion = v_valor_porcentual;  
		  else set v_eleccion = null;
		END CASE;
        
    set Gesti1 = v_eleccion;
    set Gesti2 = v_nombre;
    set resultados = concat(Gesti1, ': ' , Gesti2);
    select resultados;
    
END;

CALL bd_platvideo.SP_TARIFA(

   4,              #p_id
   'real'    #p_valor

);

/*2.Procedimientos almacenados: Crear un procedimiento almacenado para generar facturas. 
Una factura se genera a partir de una orden activa en la cartera. 
Por medio de esa orden obtiene los datos de la oferta del catálogo registrada para el cliente. 
Para cada factura, se debe registrar en la tabla de detalle, todas las ofertas de catálogo del cliente en las cuales el día de la fecha de pago coincida con el día calendario de ciclo indicado como parámetro.
En el detalle de factura, el concepto corresponde al título del catálogo ordenado por el cliente, así como el monto y los cálculos respectivos. Para aquellos clientes que apliquen, considerar ingresar un cargo por descuento de tercera edad.*/

drop function bd_platvideo.fn_Valor_Real;
delimiter // 
create function bd_platvideo.VALOR_REAL (
p_valor_real decimal(12,2)
) returns decimal(12,2) deterministic 

begin 
case 
 p_valor_real
 when 1 then return 15.00;
 when 2 then return 10.00;
 when 3 then return 25.00;
 when 4 then return 20.00;
  else return 00;

end case;
end //
delimiter ; 

select bd_platvideo.VALOR_REAL ( 2 ) Valor_real;

delimiter //
create procedure SP_GENERADOR_FACTURA (in dia_calendario int)
begin

Insert into tbl_fact_resumen (fecha_emision,fecha_vencimiento,total_unidades,subtotal_pagar,isv_total,total_pagar,idorden)
Select NOW(),now(), count(d.id_producto), b.precio_venta, 0 , b.precio_venta, a.idorden

From tbl_cartera A
inner join TBL_catalogo B ON A.ID_cat = b.id_Cat
inner join TBL_cat_prods c on b.id_cat = c.iid_Cat
inner join tbl_productos d on c.id_producto = d.id_producto
inner join tbl_suscriptores e on a.id_suscriptor = e.id_suscriptor
inner join tbl_ciclos_facturacion f on e.idciclo = f.idciclo
where f.dia_calendario = dia_calendario;

Insert Into tbl_fact_detalle
Select distinct
g.id_factura,FLOOR(1 + RAND() * 5),1,b.titulo,c.precio_venta,c.precio_venta,0,0,NOW()
FROM
tbl_cartera A
inner join TBL_catalogo B ON A.ID_cat = b.id_Cat
inner join TBL_cat_prods C on b.id_cat = c.iid_Cat
inner join TBL_productos D on c.id_producto = d.id_producto
inner join tbl_suscriptores E on a.id_suscriptor = e.id_suscriptor
inner join tbl_ciclos_facturacion F on e.idciclo = f.idciclo
inner join tbl_fact_resumen G on a.idorden = g.idorden
where F.dia_calendario = dia_calendario;

end //



/*3.Ejercicios elegibles (resolver por lo menos uno de los siguientes): Crear un procedimiento para registrar un suscriptor. 
El proceso debe permitir que se registre los datos de un suscriptor. 
Al momento de registrarlo, se le debe asignar el ciclo de facturación con el día calendario más cercano al día calendario de la inscripción más 20 días.*/

drop procedure bd_platvideo.SP_NUEVO_SUB;
delimiter //
CREATE PROCEDURE bd_platvideo.SP_NUEVO_SUB(
    in p_id_suscriptor      int, 
    in p_nombres            varchar(45),
    in p_apellidos 	        varchar(45),
	in p_telefono           varchar(45),
    in p_email              varchar(45),
	in p_usuario            varchar(45),
    in p_contrasena         varchar(400),
    in p_fechanacimiento    datetime,
    in p_edad               int,
    in p_fecha_ingreso       datetime,
    in p_fecha_modificacion  datetime,
    in p_fecha_ultima_act    datetime
)
BEGIN
    declare v_id_suscriptor int;  
    declare v_nombres       varchar(45); 
    declare v_apellidos     varchar(45);
    declare v_telefono      varchar(45);
	declare v_email         varchar(45);
    declare v_usuario       varchar(45);
    declare v_contrasena    varchar(400);
    declare v_fechanacimiento datetime;
    declare v_edad            int;
    declare v_fecha_ingreso       datetime;
    declare v_fecha_modificacion  datetime;
    declare v_fecha_ultima_act    datetime;
    declare v_id_ciclo            int;
    declare Gesti2                  int default 0;
	
    set v_id_suscriptor		= p_id_suscriptor ;
	set v_nombres	        = p_nombres; 
    set v_apellidos     	= p_apellidos;
    set v_telefono          = p_telefono;
    set v_email     	    = p_email;
    set v_usuario           = p_usuario;
    set v_contrasena     	= p_contrasena;
    set v_fechanacimiento   = p_fechanacimiento;
    set v_edad     	        = p_edad;
    set v_fecha_ingreso     = p_fecha_ingreso;
	set v_fecha_modificacion = p_fecha_modificacion;
    set v_fecha_ultima_act   = p_fecha_ultima_act;
    
 	insert into bd_platvideo.tbl_suscriptores(
		      id_suscriptor, nombres, apellidos, telefono, email, usuario, contrasena, fechanacimiento, edad, fecha_inrgreso, fecha_modificacion, fecha_ultima_act, idciclo  
		 )values(
			v_id_suscriptor, v_nombres, v_apellidos, v_telefono, v_email,v_usuario, v_contrasena, v_fechanacimiento, v_edad, v_fecha_ingreso, v_fecha_modificacion, v_fecha_ultima_act, bd_platvideo.id_result(v_fecha_ingreso)
		 );
  
END;

CALL bd_platvideo.SP_NUEVO_SUB( 
   	null, 					# p_id_suscriptor  
   'Jose',    			    # p_nombres 
	'Lagos',				    # p_apellidos			 
	98475132, 				    # p_telefono
	'',    	    # p_email 
	'JoseLag',				    # p_usuario			 
	'BasedeDatos_02', 				# p_contrasena
	now(),                      # p_fechanacimiento 
	21,				        # p_edad			 
	'2022-03-13 13:02:16' ,  # p_fecha_ingreso
        curdate(),				# p_fecha_modificacion			 
	curdate()        		# p_fecha_ultima_act
);


