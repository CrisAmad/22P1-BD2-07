Select a.idfactura,
concat("(",a.id_producto, ",", a.cantidad, "," , b.nombre, ")") fila
from bd_sample.tbl_items_factura a
left join bd_sample.tbl_productos b
on a.id_producto= b.id_producto
where a.id_factura= 30;

select
concat("(", id_factura, "," , fecha_emision, ",", id_subscriptor, ")") fila
from bd_sample.tbl_facturas
where id_factura < 6;

select saldounidades, precioventa
from bd_facturacion.tbl_productos 
where id_producto=1000;

drop procedure if exists SP_CREAR_CADENA;
delimiter //
create procedure SP_CREAR_CADENA (in p_max int)
BEGIN
declare i int default 1;
declare v_id_factura varchar (25);
declare v_fecha_emision varchar(25);
declare v_id_subscriptor varchar(25);
declare v_lista varchar (1000) default "";

  set v_lista = "";
    
    while i < p_max do 
		set i = i+1;
        
		select 
			id_factura, fecha_emision, id_subscriptor
		into 
			v_id_factura, v_fecha_emision, v_id_subscriptor
		from bd_sample.tbl_facturas where id_factura = i; 
        
        set v_lista = concat(lista,' ,[{',v_id_factura, ' , ' ,v_fecha_emision, ' , ' ,v_id_subscriptor, '}] ');
	
    end while;
    select v_lista;

END;

call SP_CREAR_CADENA( 5 );

drop procedure bd_sample.SP_CREAR_TICKETS;

delimiter //
CREATE PROCEDURE bd_sample.SP_CREAR_TICKETS(
  in p_inicio int,
  in p_final  int
)

BEGIN
    declare  i int default 0;  
	declare  v_idticket  int ; 
	declare  v_idfactura int; 
	declare  v_numero_random int;
	declare  v_fecha_creacion datetime; 
    declare  v_fecha_emision datetime; 
    
    set i = p_inicio; 
    set v_idticket = null;
 

    

	select p_final;
    
      while i < p_final + 1 do 
      
		select  id_factura, fecha_emision
		into    v_idfactura, v_fecha_emision
		from bd_sample.tbl_facturas_selectas where orden = i;
        
        set v_numero_random = ceil( RAND()*(10000-0)+10000 );
        
        insert into bd_sample.tbl_tickets_promo( 
			idticket, idfactura, numero_random,	fecha_creacion)
		values( 
			v_idticket, 	v_idfactura,	v_numero_random, v_fecha_emision);
        
	set i = i+1; 
	end while;
    

END;

call  bd_sample.SP_CREAR_TICKETS(
   6, 10
)

