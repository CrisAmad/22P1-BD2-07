/*1. Modifique el procedimiento "sp_guardar_subscriptor " de tal forma que determine si los datos que recibe como parámetros pueden pertenecer a un subscriptor que existe. Si el subscriptor existe, se debe actualizar los datos del mismo, si el subscriptor no existe entonces debe de crearse un nuevo registro de subscriptor.*/
DROP procedure IF EXISTS `SP_GUARDAR_SUBSCRIPTOR`;
delimiter //
CREATE PROCEDURE SP_GUARDAR_SUBSCRIPTOR(
    in p_id_subscriptor int,
    in p_codigo_subscriptor int,
    in p_nombres varchar(25),
    in p_apellidos varchar(25)
)
BEGIN

declare v_check int;

    select id_subscriptor from tbl_subscriptores where id_subscriptor=p_id_subscriptor into v_check;

    if v_check is not null then
        update tbl_subscriptores
        set codigo_subscriptor=p_codigo_subscriptor, nombres=p_nombres,apellidos=p_apellidos
        where id_subscriptor=p_id_subscriptor;
    else
        insert into tbl_subscriptores (id_subscriptor,codigo_subscriptor,nombres,apellidos)
        values(p_id_subscriptor,p_codigo_subscriptor,p_nombres,p_apellidos);
    end if;
commit;
END;

# llamar tabla
call bd_sample.sp_guardar_subscriptor(
     null ,                                  #p_id_subscriptor
    202200001,                           # p_codigo_subscriptor 
    'Cristiano Mcqueen',                 # p_nombres
    'Ronaldo SIU'                         #p_apellidos
);

select*from bd_sample.tbl_subscriptores
where codigo_subscriptor = 202001040;

/*2. Modifique el procedimiento "sp_guardar_producto" añadiendo las instrucciones necesarias para que cumpla con los siguientes requerimientos: 
Agregar el parámetro porcentaje, para calcular el precio venta en base al porcentaje indicado. En caso de que no se indique un porcentaje, realizar el cálculo de acuerdo a las siguientes condiciones:
i.   Si el costo esta entre 0 y 3.99 entonces usar 30%
ii.  Si el costo esta entre 4 y 7.99 entonces usar 50%
iii. Si el costo es mayor a 8 entonces usar 60% */


drop procedure if exists SP_GUARDAR_PRODUCTO;
 Delimiter //
CREATE PROCEDURE SP_GUARDAR_PRODUCTO ( 
in p_id_producto int, 
in p_nombre varchar (45),
in p_descripcion varchar (45),
in p_precio_costo decimal (12,2),
in p_porcentaje decimal (12,2)
)

begin 
declare v_id_producto int;
declare v_nombre varchar( 45);
declare v_descripcion varchar (45);
declare v_precioCosto decimal (12,2);
declare v_precioVenta decimal (12,2);
declare v_porcentaje decimal (12,2);
declare v_Fecha_Insercion datetime;

set v_id_producto =p_productoId;
set v_nombre = p_nombre;
set v_descripcion =p_descripcion;
set v_precioCosto =p_precio_costo ;
set v_porcentaje = p_porcentaje ;
select now () into v_Fecha_Insercion;

case
when v_precioCosto between 0 and 3.99 then set v_porcentaje = 1.3 ;
when v_precioCosto between 4 and 7.99 then set v_porcentaje = 1.5 ;
when v_precioCosto  < 8 then               set v_porcentaje = 1.6 ;  
end case ;
set v_precioVenta= v_precioCosto + (v_precioCosto * v_porcentaje);

  if not exists tbl_productos_hits (select id_producto from tbl_productos = v_id_producto) then
insert into bd_sample.tbl_productos_hits (id_producto, nombre, descripcion, precio_costo, precio_venta, Fecha_Insercion)
values (v_id_producto, v_nombre, v_descripcion, v_precioCosto, v_precioVenta, v_Fecha_Insercion);

 else 
 
update tbl_productos 
set 
nombre = v_nombre,
descripcion= v_descripcion,               
precio_costo= v_precioCosto,               
precio_venta= v_precioVenta  
where id_producto= v_id_producto;
 
 end if;
 commit;
 END;

/*3. Modifique el procedimiento "sp_guardar_factura" de manera que identifique según el id da factura, si la misma ya existe, de ser asi, entonces que actualice los datos de la factura, de lo contrario que cree un registro nuevo.*/

DROP PROCEDURE bd_sample.SP_GUARDAR_FACTURA;
DELIMITER //
CREATE PROCEDURE bd_sample.SP_GUARDAR_FACTURA(
    in p_id_factura          int, 
    in p_fecha_emision      datetime,
    in p_id_subscriptor     int,
    in p_numero_items       int
)
BEGIN
declare v_check             int;
declare v_id_factura          int;
declare v_fecha_emision     datetime;
declare v_id_subscriptor     int;
declare v_numero_items         int;
declare v_isv_total         decimal(12,2);
declare v_subtotal          decimal(12,2);
declare v_totapagar         decimal(12,2);
declare v_precio_prod       decimal(12,2);

 set v_id_factura         = p_id_factura;
    set v_fecha_emision        = p_fecha_emision; 
    set v_id_subscriptor    = p_id_subscriptor;
    set v_numero_items      = p_numero_items;

if v_check is not null then
insert into bd_sample.tbl_facturas (
id_factura, fecha_emision, id_subscriptor, numero_items, isv_total, subtotal, totapagar
)value
(v_id_factura, v_fecha_emision,v_id_subscriptor,v_numero_items,v_isv_total,v_subtotal,v_totapagar);
    
    else
    
update  bd_sample.tbl_facturas
Set numero_items   = v_numero_items,
fecha_emision  = v_fecha_emision,
id_subscriptor = v_id_subscriptor
where id_factura   = v_id_factura;
end if;


 
 commit;
END;

CALL bd_sample.SP_GUARDAR_FACTURA(
  58,                         # p_id_factura
   curdate(),                # p_fecha_emision 
   18,                        # p_id_subscriptor
    5                         # p_numero_items
);

SELECT * FROM bd_sample.tbl_facturas;

/*4. Modifique el procedimiento "sp_procesar_factura" de manera que utilice el procedimiento sp_guardar_factura creado en el inciso anterior, para actualizar los valores de la factura, cada vez que se registre un nuevo producto.*/
DROP PROCEDURE bd_sample.SP_PROCESAR_FACTURA;
DELIMITER //
CREATE PROCEDURE bd_sample.SP_PROCESAR_FACTURA(
	in p_id_factura      	int, 
    in p_fecha_emision      datetime,
    in p_id_subscriptor 	int,
	in p_id_producto        int,
    in p_cantidad           int     
)
BEGIN
declare v_check int;
declare v_id_factura      	int;
declare v_fecha_emision     datetime;
declare v_id_subscriptor 	int;
declare v_numero_items 		int ;
declare v_isv_total         decimal(12,2);
declare v_subtotal          decimal(12,2);
declare v_totapagar         decimal(12,2);
declare v_precio_prod       decimal(12,2);
declare v_id_producto       int;
declare v_cantidad 	        int;

set v_id_factura 		= p_id_factura;
set v_fecha_emision	    = p_fecha_emision; 
set v_id_subscriptor	= p_id_subscriptor;
set v_id_producto       = p_id_producto;
set v_cantidad 	        = p_cantidad;
    
if v_check is not null then
select precio_venta into v_precio_prod  
from bd_sample.tbl_productos 
where id_producto = v_id_producto; 
         
set v_numero_items = numero_items+p_cantidad;
set v_subtotal    = p_cantidad*v_precio_prod;
set v_isv_total   = v_subtotal*0.15;
set v_totapagar   = v_subtotal*1.15;
         
insert into bd_sample.tbl_facturas (
id_factura, fecha_emision, id_subscriptor, numero_items, isv_total, subtotal, totapagar)
values
(v_id_factura, v_fecha_emision,v_id_subscriptor,v_numero_items,v_isv_total,v_subtotal,v_totapagar
 );
else
insert bd_sample.tbl_items_factura (id_factura,id_producto,cantidad)
values (v_id_factura,v_id_producto,v_cantidad);
		
select sum(cantidad) into v_numero_items
from bd_sample.tbl_items_factura 
where id_factura = v_id_factura; 

select precio_venta into v_precio_prod  
from bd_sample.tbl_productos 
where id_producto = v_id_producto; 

update  bd_sample.tbl_facturas
Set numero_items = v_numero_items,
fecha_emision =v_fecha_emision,
isv_total   = subtotal + v_precio_prod*v_cantidad*0.15,
subtotal    =  subtotal + v_precio_prod*v_cantidad,
totapagar=     subtotal*1.15
where id_factura = v_id_factura;
end if;
 commit;
END;

CALL bd_sample.SP_PROCESAR_FACTURA(
	39, 					# p_id_factura  
	curdate(),    			# p_fecha_emision 
   18,				        # p_id_subscriptor			 
	3 ,				        # p_id_producto
	3                       # p_cantidad
);
select *from bd_sample.tbl_items_factura;
select * from bd_sample.tbl_facturas;