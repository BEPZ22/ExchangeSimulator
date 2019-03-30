create or replace 
procedure calculo_de_crip_segun_mer(id_usuario number) is
usuarios number :=0;
begin
Declare 
id_criptomoneda number;
saldo_usuario number;
saldo number;
monto number;
random_monto number;
begin
 for i in 1..3 loop
  select usu_saldo into saldo from usuario where usu_id = id_usuario;
      if saldo <> 0 then
            id_criptomoneda:= Eleccion_Criptomoneda_Cv(0);
            select cr.cri_precio.pre_precio_mercado into monto from criptomoneda cr where cr.cri_id = id_criptomoneda;
            saldo_usuario :=moneda_conversion(saldo,id_usuario,i,monto);
          begin 
                random_monto:= saldo_usuario;
                update billetera BI set BI.bil_monto = (BI.bil_monto + random_monto)
                ,Bi.Bil_Equivalente.pre_equivalente_dolares = Bi.Bil_Equivalente.pre_equivalente_dolares + calculo_equivalente_dolares(monto,random_monto)
                where BI.bil_fk_usuario = id_usuario and BI.bil_fk_criptomoneda = id_criptomoneda;
           end;
      end if;
 
end loop;
   
  end;
  
end ;
/
create or replace 
procedure crear_ordenes(cantidad_usuario number)is 
usuarios number := 0;
begin 
  declare 
  minimo_usuario number;
  maximo_usuario number;
  random_id integer;
  cantidad integer; 
  saldo_usuario number(28,8);
  criptomoneda1 number;
  tipo_compra varchar2(50);
  mercado1 number;
  tipo_orden varchar2(50);
  precio_crip number(28,8);
  monto_crip number(28,8);
  precioMercado number(28,8);
  begin
  cantidad := cantidad_usuario;
  while 0 < cantidad loop
        SELECT usu_id into usuarios FROM (SELECT usu_id FROM   usuario ORDER BY DBMS_RANDOM.VALUE) WHERE  rownum = 1;
        dbms_output.put_line('usuario a comprar ' || random_id);
        SELECT trunc(dbms_random.value(1,4)) into mercado1 FROM dual;
        select cri_id into criptomoneda1 from criptomoneda where cri_id= eleccion_criptomoneda_CV(mercado1);
        if usuarios > 0 then 
        tipo_compra :=compra_o_vende(0);
          if 'venta' = tipo_compra then 
              saldo_usuario := validar_saldo(usuarios,criptomoneda1);
              dbms_output.put('saldo usuario '|| saldo_usuario);
              if saldo_usuario >0 then  
                tipo_orden:= generar_tipo_orden(0);
                monto_crip :=generar_monto(usuarios,criptomoneda1,tipo_compra,saldo_usuario);
                precio_crip:=generar_precio(mercado1,monto_crip,criptomoneda1,tipo_orden);
                dbms_output.put_line('usuario-> ' || usuarios||' tipo de compra-> '||tipo_compra);
                if saldo_usuario - monto_crip > 0 and precio_crip > 0 then
                  select cri.cri_precio.pre_precio_mercado into precioMercado from criptomoneda cri where cri.cri_id= criptomoneda1;
                  update billetera bi set bi.bil_monto = saldo_usuario - monto_crip
                  , bi.bil_equivalente.pre_equivalente_dolares = (saldo_usuario - monto_crip) * precioMercado where bi.bil_fk_usuario = usuarios 
                  and bi.bil_fk_criptomoneda = criptomoneda1;               
                   insert into orden (ord_tipo,ord_precio_compra_venta,ord_monto,ord_moneda,ord_mercado,ord_fecha_creacion,ord_fk_usuario,ord_status,ord_tipo_orden)
                   values
                  (tipo_compra,precio_crip,monto_crip,criptomoneda1,mercado1,sysdate,usuarios,'activo',tipo_orden);  
                 saldo_usuario := 0;
                else
                  dbms_output.put_line('El usuario no puede quedar en saldo negativo');
                end if;
              else 
                dbms_output.put_line('El usuario no posee saldo');
              end if;
          else
              dbms_output.put('El usuario comprar '|| usuarios);
              tipo_orden:= generar_tipo_orden(0);
              monto_crip :=generar_monto(usuarios,criptomoneda1,tipo_compra,saldo_usuario);
              precio_crip:=generar_precio(mercado1,monto_crip,criptomoneda1,tipo_orden);             
              insert into orden (ord_tipo,ord_precio_compra_venta,ord_monto,ord_moneda,ord_mercado,ord_fecha_creacion,ord_fk_usuario,ord_status,ord_tipo_orden)
              values
              (tipo_compra,0,monto_crip,criptomoneda1,mercado1,sysdate,usuarios,'activo',tipo_orden);        
          end if;
        else
          dbms_output.put_line('No existe usuario para generar una orden');
        end if;
        usuarios := 0;
        cantidad:= cantidad -1;
    end loop;
  end;
end crear_ordenes;
/
create or replace 
procedure actualizar_billetera_usuario(tipo varchar2,id_usuario number,id_mercado number,
monto number,monto1 number,id_criptomoneda number) is usuarios number := 0;
begin
declare
montoTotal number(28,8);
montoResto number(28,8);
id_criptomoneda1 number;
nombre_mercado1 varchar2(50);
precioMercado number(28,8);
precioCriptomoneda number(28,8);
  begin
    if monto > monto1 then
      montoTotal:= monto1;
      montoResto := monto - monto1;
    end if;
    if monto1 > monto then
      montoTotal:= monto;
      montoResto := monto1 - monto;
    else
      montoTotal := monto;
      montoResto := monto;
    end if;
    if 'venta' = tipo then 
      select cri.cri_precio.pre_precio_mercado into precioCriptomoneda from criptomoneda cri where cri.cri_id= id_criptomoneda;
      update billetera bi set bi.bil_equivalente.pre_equivalente_dolares = bi.bil_monto * precioCriptomoneda
      , bi.bil_monto = bi.bil_monto - montoResto
      where bi.bil_fk_usuario = id_usuario and bi.bil_fk_criptomoneda = id_criptomoneda1;
    end if;
    if 'compra' = tipo then
      select DECODE(me.mer_tipo,'Bitcoin','BIT','Ethereum','ETH','Frabeau','FAB'), me.mer_tasa_cambio.pre_precio_mercado 
      into nombre_mercado1, precioMercado from mercado me where me.mer_id = id_mercado;
      select cri.cri_id, cri.cri_precio.pre_precio_mercado into id_criptomoneda1, precioCriptomoneda from criptomoneda cri 
      where cri_nombre= nombre_mercado1;
      montoTotal := montoTotal * precioCriptomoneda;
      montoTotal := montoTotal / precioMercado;
      update billetera bi set bi.bil_monto = bi.bil_monto + montoTotal
      , bi.bil_equivalente.pre_equivalente_dolares = (bi.bil_monto + montoTotal) * precioMercado
      where bi.bil_fk_usuario = id_usuario 
      and bi.bil_fk_criptomoneda = id_criptomoneda1;
    end if;
  end;
end;
/
create or replace 
procedure match_entre_ordenes (id_orden number)is
begin
Declare
id_usuario number;
tipo varchar(20);
precio number(28,8);
id_criptomoneda number;
id_mercado number;
id_usuario1 number;
tipo1 varchar(20);
precio1 number(28,8);
id_criptomoneda1 number;
id_mercado1 number;
id_orden1 number;
id_referencia number;
monto number(28,8);
tipo_orden varchar2(50);
monto1 number(28,8);
tipo_orden1 varchar2(50);

begin
  select ord_fk_usuario,ord_tipo,ord_precio_compra_venta,ord_moneda,ord_mercado,ord_monto,ord_tipo_orden 
  into id_usuario,tipo,precio,id_criptomoneda,id_mercado,monto,tipo_orden
  from orden where Ord_Id = id_orden and ord_status = 'activo';
    
  select ord_fk_usuario,ord_tipo,ord_precio_compra_venta,ord_moneda,ord_mercado,ord_id,ord_monto,ord_tipo_orden 
  into id_usuario1,tipo1,precio1,id_criptomoneda1,id_mercado1,id_orden1,monto1,tipo_orden1
  from orden where ord_fk_usuario <> id_usuario and ord_status = 'activo' and ord_tipo <> tipo and ord_mercado = id_mercado
  and ord_moneda = id_criptomoneda and rownum =1;
  
  if tipo = 'compra' and monto >0 and monto1 > 0 then
    if (monto > monto1) then 
     update orden set ord_monto = monto1 , ord_status = 'procesado' where ord_id = id_orden;
     update orden set  ord_status = 'procesado' where ord_id = id_orden1;
     EXECUTE IMMEDIATE 'ALTER TRIGGER fluctuar_mercado DISABLE';
     insert into orden (ord_tipo,ord_monto,ord_precio_compra_venta,ord_moneda,ord_mercado,ord_fecha_creacion,ord_fk_usuario,ord_status,ord_tipo_orden)
     values
     (tipo,monto-monto1,precio,id_criptomoneda,id_mercado,sysdate,id_usuario,'activo',tipo_orden);
      EXECUTE IMMEDIATE 'ALTER TRIGGER fluctuar_mercado ENABLE';
     id_referencia:=referencia(0)+1;
     
     insert into operacion (ope_tipo,ope_dato,ope_referencia,ope_fk_orden)
     values
     (tipo,datos(monto1,sysdate),id_referencia,id_orden);
     
    insert into operacion (ope_tipo,ope_dato,ope_referencia,ope_fk_orden)
     values
     (tipo1,datos(monto1,sysdate),id_referencia,id_orden1);
     
      actualizar_billetera_usuario(tipo,id_usuario,id_mercado, monto,monto1,id_criptomoneda);
      actualizar_billetera_usuario(tipo1,id_usuario1,id_mercado1,monto,monto1,id_criptomoneda1);
     
    end if;
    if (monto1 > monto) then
      update orden set ord_monto = monto, ord_status = 'procesado' where ord_id = id_orden1;
      update orden set  ord_status = 'procesado' where ord_id = id_orden;
      EXECUTE IMMEDIATE 'ALTER TRIGGER fluctuar_mercado DISABLE';
      insert into orden (ord_tipo,ord_monto,ord_precio_compra_venta,ord_moneda,ord_mercado,ord_fecha_creacion,ord_fk_usuario,ord_status,ord_tipo_orden)
      values
      (tipo1,monto1-monto,precio1,id_criptomoneda1,id_mercado1,sysdate,id_usuario1,'activo',tipo_orden1);
      EXECUTE IMMEDIATE 'ALTER TRIGGER fluctuar_mercado ENABLE';
      id_referencia:=referencia(0)+1;
     
     insert into operacion (ope_tipo,ope_dato,ope_referencia,ope_fk_orden)
     values
     (tipo,datos(monto,sysdate),id_referencia,id_orden);
     
    insert into operacion (ope_tipo,ope_dato,ope_referencia,ope_fk_orden)
     values
     (tipo1,datos(monto,sysdate),id_referencia,id_orden1);
     
      actualizar_billetera_usuario(tipo,id_usuario,id_mercado, monto,monto1,id_criptomoneda);
      actualizar_billetera_usuario(tipo1,id_usuario1,id_mercado1,monto,monto1,id_criptomoneda1);
    
    end if;
    if monto = monto1 then
      update orden set ord_status = 'procesado' where ord_id = id_orden1 or ord_id = id_orden;
           
      id_referencia:=referencia(0)+1;
     
     insert into operacion (ope_tipo,ope_dato,ope_referencia,ope_fk_orden)
     values
     (tipo,datos(monto1,sysdate),id_referencia,id_orden);
     
    insert into operacion (ope_tipo,ope_dato,ope_referencia,ope_fk_orden)
     values
     (tipo1,datos(monto1,sysdate),id_referencia,id_orden1);
     
      actualizar_billetera_usuario(tipo,id_usuario,id_mercado, monto,monto1,id_criptomoneda);
      actualizar_billetera_usuario(tipo1,id_usuario1,id_mercado1,monto,monto1,id_criptomoneda1);
    
    end if;
  end if;
  if 'venta' = tipo and monto >0 and monto1 > 0 then
      if (monto > monto1) then 
     update orden set ord_monto = monto1 , ord_status = 'procesado' where ord_id = id_orden;
     update orden set  ord_status = 'procesado' where ord_id = id_orden1;
     EXECUTE IMMEDIATE 'ALTER TRIGGER fluctuar_mercado DISABLE';
     insert into orden (ord_tipo,ord_monto,ord_precio_compra_venta,ord_moneda,ord_mercado,ord_fecha_creacion,ord_fk_usuario,ord_status,ord_tipo_orden)
     values
     (tipo,monto-monto1,precio,id_criptomoneda,id_mercado,sysdate,id_usuario,'activo',tipo_orden);
     EXECUTE IMMEDIATE 'ALTER TRIGGER fluctuar_mercado ENABLE';
     id_referencia:=referencia(0)+1;
     
     insert into operacion (ope_tipo,ope_dato,ope_referencia,ope_fk_orden)
     values
     (tipo,datos(monto1,sysdate),id_referencia,id_orden);
     
    insert into operacion (ope_tipo,ope_dato,ope_referencia,ope_fk_orden)
     values
     (tipo1,datos(monto1,sysdate),id_referencia,id_orden1);
     
      actualizar_billetera_usuario(tipo,id_usuario,id_mercado, monto,monto1,id_criptomoneda);
      actualizar_billetera_usuario(tipo1,id_usuario1,id_mercado1,monto,monto1,id_criptomoneda1);
     
    end if;
    if (monto1 > monto) then
      update orden set ord_monto = monto , ord_status = 'procesado' where ord_id = id_orden1;
      update orden set  ord_status = 'procesado' where ord_id = id_orden;
      EXECUTE IMMEDIATE 'ALTER TRIGGER fluctuar_mercado DISABLE';
      insert into orden (ord_tipo,ord_monto,ord_precio_compra_venta,ord_moneda,ord_mercado,ord_fecha_creacion,ord_fk_usuario,ord_status,ord_tipo_orden)
      values
      (tipo1,monto1-monto,precio1,id_criptomoneda1,id_mercado1,sysdate,id_usuario1,'activo',tipo_orden1);
      EXECUTE IMMEDIATE 'ALTER TRIGGER fluctuar_mercado ENABLE';
      id_referencia:=referencia(0)+1;
     
     insert into operacion (ope_tipo,ope_dato,ope_referencia,ope_fk_orden)
     values
     (tipo,datos(monto,sysdate),id_referencia,id_orden);
     
    insert into operacion (ope_tipo,ope_dato,ope_referencia,ope_fk_orden)
     values
     (tipo1,datos(monto,sysdate),id_referencia,id_orden1);
     
      actualizar_billetera_usuario(tipo,id_usuario,id_mercado, monto,monto1,id_criptomoneda);
      actualizar_billetera_usuario(tipo1,id_usuario1,id_mercado1,monto,monto1,id_criptomoneda1);
    
    end if;
    if monto = monto1 then 
      update orden set ord_status = 'procesado' where ord_id = id_orden1 or ord_id = id_orden;
                 
      id_referencia:=referencia(0)+1;
     
     insert into operacion (ope_tipo,ope_dato,ope_referencia,ope_fk_orden)
     values
     (tipo,datos(monto1,sysdate),id_referencia,id_orden);
     
    insert into operacion (ope_tipo,ope_dato,ope_referencia,ope_fk_orden)
     values 
     (tipo1,datos(monto1,sysdate),id_referencia,id_orden1);
     
      actualizar_billetera_usuario(tipo,id_usuario,id_mercado, monto,monto1,id_criptomoneda);
      actualizar_billetera_usuario(tipo1,id_usuario1,id_mercado1,monto,monto1,id_criptomoneda1);
    
    end if;
  end if;
  if monto = 0 or monto1 = 0 then
    dbms_output.put_line('Monto invalido, el monto deberia ser mayor a cero');
    end if;
end;
exception
when NO_DATA_FOUND then
dbms_output.put_line('No se encontro una orden para hacer match');
end;
/
create or replace 
procedure regresion_lineal(monto number, id_criptomoneda number) is regresion number := 0;
begin
declare
id_pronostico numeric(20);
  begin
    begin
      select nvl(max(pro_id),0) into id_pronostico from pronostico where pro_id_criptomoneda = id_criptomoneda;
      exception
      when no_data_found then
      id_pronostico := 0;
    end;
    id_pronostico := id_pronostico +1;
    insert into pronostico (pro_id,pro_id_cuadrado,pro_id_criptomoneda,pro_monto,pro_monto_id)
    values (id_pronostico,id_pronostico*id_pronostico,id_criptomoneda, monto, monto*id_pronostico);
  end;
end;
/
create or replace 
procedure programa_principal(cantidad number, repeticiones number) is usuarios number := 0;
begin
Declare 
minimo_usuario number;
maximo_usuario number;
minimo_orden number;
maximo_orden number;
  begin
    select min(usu_id), max(usu_id) into minimo_usuario , maximo_usuario from usuario;
    for r in 1..repeticiones loop
      for u in minimo_usuario..maximo_usuario loop
        Calculo_De_Crip_Segun_Mer(u);
      end loop;
    end loop;
      crear_ordenes(cantidad);
      select min(ord_id), max(ord_id) into minimo_orden , maximo_orden from orden;
      for o in minimo_orden..maximo_orden loop
        match_entre_ordenes(o);
      end loop;
  end;
end;
/
create or replace 
procedure 
reporte_regresion_lineal (id_criptomoneda number, fecha date) is reporte varchar2(300);
begin
declare
suma_monto number(28,8);
suma_id_cuadrado number(28,8);
suma_id number(28,8);
suma_monto_id number(28,8);
contador_id number;
d number(28,8);
b number(28,8);
divisor number(28,8);
nombre_criptomoneda varchar2(50);
  begin
        select cri_nombre into nombre_criptomoneda from criptomoneda where cri_id = id_criptomoneda;
        select sum(pro_monto),sum(pro_id_cuadrado),sum(pro_monto_id),sum(pro_id),count(pro_id)
        into suma_monto,suma_id_cuadrado, suma_monto_id, suma_id, contador_id
        from pronostico where pro_id_criptomoneda = 1;
        divisor :=(contador_id*suma_id_cuadrado)-(suma_id*suma_id);
        d:=(suma_monto*suma_id_cuadrado)-(suma_monto_id*suma_id);
        d:=d/divisor;
        b:=(contador_id*suma_monto_id)-(suma_id*suma_monto);
        b:= b/divisor;
    b := d + (b * (fecha-sysdate));
    dbms_output.put_line('Para la criptomoneda '|| nombre_criptomoneda || ' para la fecha '|| fecha || ' el pronostico es de '|| b);    
  end;
  exception
  when no_data_found then
  dbms_output.put_line('Disculpe la criptomoneda solicitada no existe');
end;
/
create or replace 
procedure reporte_promedio_mercado (id_criptomoneda number, fecha date) is reporte varchar2(300);
begin
declare
compra1 number;
venta1 number;
compra2 number;
venta2 number;
compra3 number;
venta3 number;
  begin
    --compra
    select count(ord_id) into compra1 from orden where ord_moneda = id_criptomoneda and to_char(ord_fecha_creacion,'dd/MM/yy') = to_char(fecha,'dd/MM/yy') 
    and ord_mercado =1 and ord_tipo = 'compra';
    select count(ord_id) into compra2 from orden where ord_moneda = id_criptomoneda and to_char(ord_fecha_creacion,'dd/MM/yy') = to_char(fecha,'dd/MM/yy')  
    and ord_mercado =2 and ord_tipo = 'compra';
    select count(ord_id) into compra3 from orden where ord_moneda = id_criptomoneda and to_char(ord_fecha_creacion,'dd/MM/yy') = to_char(fecha,'dd/MM/yy')  
    and ord_mercado =3 and ord_tipo = 'compra';
    --venta
    select count(ord_id) into venta1 from orden where ord_moneda = id_criptomoneda and to_char(ord_fecha_creacion,'dd/MM/yy') = to_char(fecha,'dd/MM/yy')  
    and ord_mercado =1 and ord_tipo = 'venta';
    select count(ord_id) into venta2 from orden where ord_moneda = id_criptomoneda and to_char(ord_fecha_creacion,'dd/MM/yy') = to_char(fecha,'dd/MM/yy')  
    and ord_mercado =2 and ord_tipo = 'venta';
    select count(ord_id) into venta3 from orden where ord_moneda = id_criptomoneda and to_char(ord_fecha_creacion,'dd/MM/yy') = to_char(fecha,'dd/MM/yy')  
    and ord_mercado =3 and ord_tipo = 'venta';
    dbms_output.put_line('La lista se imprimira de mayor a menor');
    dbms_output.put_line('-------Compra-------');
    dbms_output.put_line('Fecha      Mercado   Cantidad');
    if compra1>compra2 then
      if compra1>compra3 then
        dbms_output.put_line(fecha||'  Bitcoin   '|| compra1);
        if compra2>compra3 then
          dbms_output.put_line(fecha||'  Ethereum  '|| compra2);        
          dbms_output.put_line(fecha||'  Fabreau   '|| compra3);  
        else
          dbms_output.put_line(fecha||'  Fabreau   '|| compra3); 
          dbms_output.put_line(fecha||'  Ethereum  '|| compra2);         
        end if;
      else 
          dbms_output.put_line(fecha||'  Fabreau   '|| compra3); 
          dbms_output.put_line(fecha||'  Bitcoin   '|| compra1);
          dbms_output.put_line(fecha||'  Ethereum  '|| compra2); 
      end if;
    else
      if compra2>compra3 then
          dbms_output.put_line(fecha||'  Ethereum  '|| compra2);
          if compra3>compra1 then
            dbms_output.put_line(fecha||'  Fabreau   '|| compra3); 
            dbms_output.put_line(fecha||'  Bitcoin   '|| compra1);
          else
            dbms_output.put_line(fecha||'  Bitcoin   '|| compra1);
            dbms_output.put_line(fecha||'  Fabreau   '|| compra3); 
          end if;
      else
          dbms_output.put_line(fecha||'  Fabreau   '|| compra3); 
          dbms_output.put_line(fecha||'  Ethereum  '|| compra2);   
          dbms_output.put_line(fecha||'  Bitcoin   '|| compra1);
      end if;
    end if; 
   dbms_output.put_line('');
   dbms_output.put_line('-------Venta-------');
   dbms_output.put_line('Fecha      Mercado   Cantidad');
   if venta1>venta2 then
        if venta1>venta3 then
          dbms_output.put_line(fecha||'  Bitcoin   '|| venta1);
          if venta2>venta3 then
            dbms_output.put_line(fecha||'  Ethereum  '|| venta2);        
            dbms_output.put_line(fecha||'  Fabreau   '|| venta3);  
          else
            dbms_output.put_line(fecha||'  Fabreau   '|| venta3); 
            dbms_output.put_line(fecha||'  Ethereum  '|| venta2);         
          end if;
        else 
            dbms_output.put_line(fecha||'  Fabreau   '|| venta3); 
            dbms_output.put_line(fecha||'  Bitcoin   '|| venta1);
            dbms_output.put_line(fecha||'  Ethereum  '|| venta2); 
        end if;
      else
        if venta2>venta3 then
            dbms_output.put_line(fecha||'  Ethereum  '|| venta2);
            if venta3>venta1 then
              dbms_output.put_line(fecha||'  Fabreau   '|| venta3); 
              dbms_output.put_line(fecha||'  Bitcoin   '|| venta1);
            else
              dbms_output.put_line(fecha||'  Bitcoin   '|| venta1);
              dbms_output.put_line(fecha||'  Fabreau   '|| venta3); 
            end if;
        else
            dbms_output.put_line(fecha||'  Fabreau   '|| venta3); 
            dbms_output.put_line(fecha||'  Ethereum  '|| venta2);   
            dbms_output.put_line(fecha||'  Bitcoin   '|| venta1);
        end if;
      end if;
  end;
end;
/
create or replace 
procedure reporte_orden_no_efectuadar (id_criptomoneda number, id_mercado number) is reporte varchar2(300);
begin
declare
  cursor cur is
    select ord_tipo,ord_precio_compra_venta, ord_monto
    from orden where ord_status= 'activo' and ord_moneda= id_criptomoneda and ord_mercado = id_mercado;
mercado1 varchar2(50);
criptomoneda1 varchar2(50);
  begin
    select cri_nombre into criptomoneda1 from criptomoneda where cri_id = id_criptomoneda;
    select mer_tipo into mercado1 from mercado where mer_id = id_mercado;
    dbms_output.put_line('Criptomoneda     Mercado     Tipo     Precio      Monto');
    for i in cur loop
       dbms_output.put_line('    '||criptomoneda1 ||'          '||mercado1||'     '
       ||i.ord_tipo||'      '||i.ord_precio_compra_venta||'       '||i.ord_monto);
    end loop;
  end;
end;
/
create or replace 
procedure
reporte_compra_alta(id_mercado number, id_criptomoneda number) is reporte varchar2(50);
begin
declare
cursor cur is 
  select ord_precio_compra_venta, ord_id, ord_fk_usuario from orden where ord_tipo = 'venta' and ord_moneda = id_criptomoneda
  and ord_mercado = id_mercado and ord_status = 'procesado';
id_ord number;
id_ord_compra number;
id_usuario number;
id_usuario_compra number;
referencia1 number;
precio number(28,8);
nombre_compra varchar2(50);
nombre_venta varchar2(50);
nombre_mercado varchar2(50);
nombre_criptomoneda varchar2(50);
  begin
  precio := 0;
  for i in cur loop
    if precio < i.ord_precio_compra_venta then
      precio := i.ord_precio_compra_venta;
      id_ord := i.ord_id;
      id_usuario := i.ord_fk_usuario;
    end if;
  end loop; 
  select cri_nombre into nombre_criptomoneda from criptomoneda where cri_id = id_criptomoneda;
  select mer_tipo into nombre_mercado from mercado where mer_id = id_mercado ;
  select ope_referencia into referencia1 from operacion where ope_fk_orden =id_ord;
  select ope_fk_orden into id_ord_compra from operacion where ope_referencia = referencia1 and ope_fk_orden <> id_ord;
  select usu_primer_nombre ||' '|| usu_primer_apellido into nombre_venta from usuario where usu_id = id_usuario;
  select usu_primer_nombre ||' '|| usu_primer_apellido into nombre_compra from usuario where usu_id = 
  (select ord_fk_usuario from orden where ord_id = id_ord_compra);
  dbms_output.put_line('Mercado   '||nombre_mercado ||'   Criptomoneda   '|| nombre_criptomoneda);
  dbms_output.put_line('Precio           Comprador         Vendedor');
  dbms_output.put_line(precio||'       '||nombre_compra||'       '||nombre_venta);
  end;
end;
/
create or replace procedure
reporte_cantidad_tipo_orden(id_criptomoneda number, id_mercado number) is reporte varchar2(50);
begin
declare
mercado1 varchar2(50);
criptomoneda1 varchar2(50);
cantidad number;
  begin
    select mer_tipo into mercado1 from mercado where mer_id=id_mercado;
    select cri_nombre into criptomoneda1 from criptomoneda where cri_id = id_criptomoneda;
    dbms_output.put_line('TipoOrden     Mercado     Criptomoneda     Cantidad');
    select count(ord_tipo) into cantidad from orden where ord_status='procesado' and ord_mercado = id_mercado and ord_moneda = id_criptomoneda
    and ord_tipo = 'venta' and ord_tipo_orden ='Market';
    dbms_output.put_line('Market     '||mercado1||'     '||criptomoneda1||'     '||cantidad);
    select count(ord_tipo) into cantidad from orden where ord_status='procesado' and ord_mercado = id_mercado and ord_moneda = id_criptomoneda
    and ord_tipo = 'venta' and ord_tipo_orden ='Limit';
    dbms_output.put_line('Limit      '||mercado1||'     '||criptomoneda1||'     '||cantidad);
    select count(ord_tipo) into cantidad from orden where ord_status='procesado' and ord_mercado = id_mercado and ord_moneda = id_criptomoneda
    and ord_tipo = 'venta' and ord_tipo_orden = 'StopLimit';
    dbms_output.put_line('StopLimit  '||mercado1||'     '||criptomoneda1||'     '||cantidad);
  end;
end;
/
create or replace 
procedure
reporte_mercado_mas_usado(id_criptomoneda number, fecha date) is reporte varchar2(50);
begin
declare
cantidad1 number;
cantidad2 number;
cantidad3 number;
nombre varchar2(50);
  begin
    select count(ord_mercado) into cantidad1 from orden where ord_moneda = id_criptomoneda 
    and to_char(ord_fecha_creacion,'dd/MM/yyyy') = to_char(fecha,'dd/MM/yyyy') and ord_mercado = 1;
    select count(ord_mercado) into cantidad2 from orden where ord_moneda = id_criptomoneda 
    and to_char(ord_fecha_creacion,'dd/MM/yyyy') = to_char(fecha,'dd/MM/yyyy') and ord_mercado = 2;
    select count(ord_mercado) into cantidad3 from orden where ord_moneda = id_criptomoneda
    and to_char(ord_fecha_creacion,'dd/MM/yyyy') = to_char(fecha,'dd/MM/yyyy') and ord_mercado = 3;
    dbms_output.put_line('Criptomoneda    Mercado     Cantidad      Fecha');
    select cri_nombre into nombre from criptomoneda where cri_id = id_criptomoneda;
    if cantidad1 = 0 and cantidad2 =0 and cantidad3 = 0 then
      dbms_output.put_line(nombre||'             -------     '||cantidad3||'           '||fecha);
    else
      if cantidad1 > cantidad2 then
        if cantidad1 > cantidad3 then
            dbms_output.put_line(nombre||'             Bitcoin     '||cantidad1||'           '||fecha);
        else
          dbms_output.put_line(nombre||'             Frabeau     '||cantidad3||'           '||fecha);
        end if;
      else
        if cantidad2 > cantidad3 then
          dbms_output.put_line(nombre||'             Ethereum     '||cantidad2||'           '||fecha);
        else
          dbms_output.put_line(nombre||'             Frabeau     '||cantidad3||'           '||fecha);
        end if;
      end if;
    end if;
  end;
end;
/
create or replace 
procedure
reporte_cantidad_por_estado(id_criptomoneda number,estado varchar2) is reporte varchar2(50);
begin
declare
id_direccion number;
cursor cur is
select usu_id from usuario where usu_fk_direccion in 
(select distinct(usu_fk_direccion) from usuario u, direccion 
where dir_estado =estado and dir_id = usu_fk_direccion);
suma_compra number;
suma_venta number;
suma_compra_total number;
suma_venta_total number;
nombre varchar2(50);
  begin
  suma_compra_total:=0;
  suma_venta_total :=0;
  select cri_nombre into nombre from criptomoneda where cri_id = id_criptomoneda;
      for i in cur loop
        select count(ord_tipo) into suma_compra from orden where ord_tipo = 'compra' and ord_fk_usuario =i.usu_id 
        and ord_moneda= id_criptomoneda;
        select count(ord_tipo) into suma_venta from orden where ord_tipo = 'venta' and ord_fk_usuario =i.usu_id 
        and ord_moneda= id_criptomoneda;
        suma_compra_total:=suma_compra_total+suma_compra;
        suma_venta_total := suma_venta_total + suma_venta;
      end loop;
      dbms_output.put_line('Criptomoneda     Estado     Compras     Ventas');  
      dbms_output.put_line(nombre||'              '||estado||'     '||suma_compra_total||'           '||suma_venta_total); 
  end;
end;
/
create or replace 
procedure
reporte_paises_cripto(id_criptomoneda number) is reporte varchar2(50);
begin
declare
cursor cur is
select pa.ubi_nombre_pais pais,cri_nombre criptomoneda,count(cri_nombre) cantidad 
from direccion di, table(di.dir_pais) pa, usuario us, orden ord, criptomoneda cri
where usu_fk_direccion = dir_id and ord_fk_usuario = usu_id and ord_moneda= id_criptomoneda and cri_id = id_criptomoneda 
group by pa.ubi_nombre_pais,cri_nombre order by count(cri_nombre) desc;
  begin
    dbms_output.put_line('Cantidad         Criptomoneda     Pais');
    
    for i in cur loop
      dbms_output.put_line('   '||i.cantidad||'             '||i.criptomoneda||'              '|| i.pais);
    end loop;
  end;
end;