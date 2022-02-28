

#eliminar procedimiento
DROP procedure IF EXISTS `SP_GUARDAR_SUBSCRIPTOR`;

/*1. Cree el procedimiento almacenado "sp_guardar_subscriptor" para actualizar los campos de un subscriptor existente en la base de datos. */
DELIMITER //
CREATE  PROCEDURE  bd_sample.SP_GUARDAR_SUBSCRIPTOR ( 
    in p_codigo_subscriptor varchar (45),
    in p_nombres 			varchar(25),
    in p_apellidos 			varchar(25)
 )
BEGIN 
 
    update bd_sample.tbl_subscriptores
set nombres = p_nombres, apellidos = p_apellidos
where codigo_subscriptor = p_codigo_subscriptor;
    commit;
 END; 


call bd_sample.sp_guardar_subscriptor(
	202001040,    	         		# p_codigo_subscriptor 
    'Cristofer Enrique',			# p_nombres 			 
    'Amador Moncada' 		        #p_apellidos 		 
);




/* 2. Cree el procedimiento almacenado "sp_guardar_producto" para crear nuevos productos, debe recibir los parámetros el nombre, la descripción y el precio de costo del producto. El precio de venta debe ser calculado en razón de un 125% del precio de costo. */
DROP procedure IF EXISTS `SP_GUARDAR_PRODUCTO`;
DELIMITER //
CREATE  PROCEDURE  bd_sample.SP_GUARDAR_PRODUCTO (
in p_nombre varchar (45),
in p_descripcion varchar (45),
in p_precio_costo decimal (14),
in p_precio_venta decimal (14)

)
begin
declare v_nombre varchar (45);
declare v_descripcion varchar (45);
declare v_precio_costo decimal (14);
declare v_precio_venta decimal (14);

    set v_nombre= p_nombre;
    set v_descripcion= p_descripcion;
    set v_precio_costo = p_precio_costo;
    set v_precio_venta= p_precio_venta;
    
    insert into bd_sample.tbl_productos (
    nombre, descripcion, precio_costo, precio_venta)
    values (v_nombre, v_descripcion, v_precio_costo, v_precio_venta*1.25);
    
    
    commit;
    END;
    
    # Ejecutar procedimiento 
CALL bd_sample.sp_guardar_producto(
	"Plan God", 						# p_nombre
	"Plan Sobrenatural",    			# p_descripcion 
    12,	                                # p_precio_costo 			 
	12					                #p_precio_venta	 
);


/*3.Cree el procedimiento almacenado "sp_guardar_factura" que registre una nueva factura según los parámetros recibidos. 
*/
DROP procedure IF EXISTS `SP_GUARDAR_FACTURA`;
DELIMITER //
CREATE  PROCEDURE bd_sample.SP_GUARDAR_FACTURA(
    in p_fecha_emision    datetime,
    in p_id_subscriptor int ,
    in p_numero_items  int ,
    in p_isv_total   decimal(12),
    in p_subtotal    decimal(12),
    in p_totapagar   decimal(12)
 )
BEGIN 

    declare v_fecha_emision  datetime;
    declare v_id_subscriptor int;
    declare v_numero_items int;
    declare v_isv_total   decimal(12);
    declare v_subtotal    decimal(12);
    declare v_totapagar   decimal(12);


    set v_fecha_emision = p_fecha_emision; 
    set v_id_subscriptor = p_id_subscriptor;
    set v_numero_items = p_numero_items;
    set v_isv_total = p_isv_total;
    set v_subtotal =  p_subtotal;
    set v_totapagar = p_totapagar;

     insert into bd_sample.tbl_facturas (fecha_emision, id_subscriptor, numero_items, isv_total, subtotal, totapagar)
   values (v_fecha_emision, v_id_subscriptor,v_numero_items, v_isv_total ,v_subtotal, v_totapagar);

    commit;
 END;
 
 CALL bd_sample.sp_guardar_factura(
    '2020-07-01 01:20:10',                   # p_fecha_emision
    1,                                     # p_id_subscriptor
     4,                                    # p_numero_items
    30,                                  # p_isv_total
    14.99,                                    # p_subtotal
    80                                  # p_totapagar
);

/*Cree el procedimiento almacenado "sp_procesar_factura " que registre el proceso de facturación: 
Registra un producto de acuerdo un numero de factura en la tabla ítems factura.
Actualiza los valores de la factura con los valores totales*/

DROP procedure IF EXISTS sp_procesar_factura;
delimiter //
CREATE PROCEDURE sp_procesar_factura(
    in p_idFactura int,
    in p_idProducto int,
    in p_Cantidad int,
    in p_precio int
)
BEGIN
    declare v_idFactura int;
    declare v_idProducto int;
    declare v_Cantidad int;
    declare v_precio int;

    set v_idFactura = p_idFactura;
    set v_idProducto = p_idProducto;
    set v_Cantidad = p_Cantidad;
    set v_precio = p_precio;


    insert tbl_items_factura(id_factura,id_subscriptor,cantidad)
    values (v_idFactura,v_idProducto,v_Cantidad);

    update tbl_facturas
    Set numero_item=numero_item+1,
    subtotal= subtotal + v_precio,
    isv_total= (subtotal + v_precio)*0.18, 
    totapagar=(subtotal + v_precio)*1.18
    where id_factura=v_idFactura;
    
commit;
END;
