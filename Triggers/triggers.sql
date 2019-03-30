create or replace 
trigger insertar_criptomoneda_mercado
after insert on mercado
declare
minimo_criptomoneda number;
maximo_criptomoneda number;
minimo_mercado number;
maximo_mercado number;
criptomoneda1 number;
mercado1 number;
cursor cur_crip is
(
  select cri_id from criptomoneda
);
begin
criptomoneda1 := valida_criptomoneda_existe(0);
mercado1 := valida_mercado_existe(0);
if criptomoneda1 > 0  and mercado1 > 0 then
  --select min(cri_id), max(cri_id) into minimo_criptomoneda, maximo_criptomoneda from criptomoneda;
  select max(mer_id) into maximo_mercado from mercado;
	 for cont_criptomoneda in cur_crip loop
				insert into crip_mer (crme_fecha, crme_descripcion, crme_fk_criptomoneda, crme_fk_mercado)
				values (sysdate,'algo',cont_criptomoneda.cri_id,maximo_mercado);
	 end loop;
end if;
end;
/
create or replace 
trigger insertar_merc_crip_inversa
after insert on criptomoneda
declare
minimo_criptomoneda number;
maximo_criptomoneda number;
minimo_mercado number;
maximo_mercado number;
criptomoneda1 number;
mercado1 number;
cursor cur_mer is
(
  select mer_id from mercado
);
begin
criptomoneda1 := valida_criptomoneda_existe(0);
mercado1 := valida_mercado_existe(0);
if criptomoneda1 > 0  and mercado1 > 0 then
  select max(cri_id) into maximo_criptomoneda from criptomoneda;
  --select min(mer_id),max(mer_id) into minimo_mercado,maximo_mercado from mercado;
	for cont_mercado in cur_mer loop
				insert into crip_mer (crme_fecha, crme_descripcion, crme_fk_criptomoneda, crme_fk_mercado)
				values (sysdate,'algo',maximo_criptomoneda,cont_mercado.mer_id);
	end loop;
end if;  
end;
/
create or replace 
trigger insertar_moneda_bil_usuario
after update of usu_fk_direccion on usuario
declare
maximo_usuario number;
maximo_criptomoneda number;
minimo_criptomoneda number;
criptomoneda1 number;
cursor cur_cri is
(
  select cri_id from criptomoneda
);
begin
criptomoneda1 := valida_criptomoneda_existe(0);
if criptomoneda1 >0 then
	select max(usu_id) into maximo_usuario from usuario;
  --select min(cri_id),count(cri_id) into minimo_criptomoneda,maximo_criptomoneda from Criptomoneda;
  dbms_output.put_line('antes del for');
	for cont_criptomoneda in cur_cri loop
				insert into billetera (bil_monto, bil_equivalente, bil_fk_usuario, bil_fk_criptomoneda)
				values (0,precios(0,0,0),maximo_usuario,cont_criptomoneda.cri_id);
        --minimo_criptomoneda:=minimo_criptomoneda+1;
	end loop;
end if;  
end;
/
create or replace 
trigger insertar_moneda_billetera
after insert on criptomoneda
declare
maximo_usuario number;
maximo_criptomoneda number;
minimo_usuario number;
criptomoneda1 number;
usuario1 number;
cursor cur_usu is
(
  select usu_id from usuario
);
begin
  criptomoneda1 := valida_criptomoneda_existe(0);
  usuario1 := valida_usuario_existente(0);
  if criptomoneda1 > 0 and usuario1 > 0 then
    --select count(usu_id) into maximo_usuario from usuario;
    --select min(usu_id) into minimo_usuario from usuario;
    select MAX(cri_id) into maximo_criptomoneda from criptomoneda;
    dbms_output.put_line('antes del for');
    for cont_usuario in cur_usu loop
          insert into billetera (bil_monto, bil_equivalente, bil_fk_usuario, bil_fk_criptomoneda)
          values (0,precios(0,0,0),cont_usuario.usu_id,maximo_criptomoneda);
         -- minimo_usuario:= minimo_usuario +1;
    end loop;
  end if;
end;
/
create or replace 
trigger insertar_ubicacion_usuario
after insert on usuario
declare
ultimo_id integer;
random_id integer;
usuario1 number;
direccion1 number;
begin
usuario1 := valida_usuario_existente(0);
direccion1 := valida_direccion_existe(0);
if usuario1 > 0 and direccion1 > 0 then
  SELECT trunc(dbms_random.value(1,( select MAX(dir_id) from direccion))) into random_id FROM dual;
  select MAX(usu_id) into ultimo_id from usuario;
  update usuario set usu_fk_direccion = random_id where usu_id = ultimo_id;
end if;
end;
/
create or replace 
trigger fluctuar_mercado
after insert on orden
declare
tipo varchar2(50);
nombre_criptomoneda varchar2(50);
precio number(28,8);
id_criptomoneda number;
id_mercado number;
monto number(28,8);
precio_criptomoneda number(28,8);
montoTotal number(28,8);
montoPorcentaje number(28,8);
maximo number;
precio_criptomoneda_equi number(28,8);
begin
  dbms_output.put_line('entro al trigger');
  select max(ord_id) into maximo from orden;
  select ord_tipo, ord_precio_compra_venta, ord_moneda, ord_mercado, ord_monto 
  into tipo, precio, id_criptomoneda, id_mercado, monto  from orden where ord_id = maximo;
  dbms_output.put_line('tipo de '|| tipo);
  if 'venta' = tipo then 
  dbms_output.put_line('entro con '|| tipo || 'monto '||monto||' precio '|| precio) ;
    select cri.cri_precio.pre_precio_mercado,cri.cri_nombre, cri.cri_precio.pre_equivalente_dolares
    into precio_criptomoneda, nombre_criptomoneda, precio_criptomoneda_equi
    from criptomoneda cri where cri_id = id_criptomoneda;
    montoTotal := monto * precio_criptomoneda;
    montoTotal := montoTotal * precio;
    montoTotal := montoTotal / monto;
    montoPorcentaje := ((montoTotal - precio_criptomoneda_equi) *100 )/ precio_criptomoneda_equi;
    update criptomoneda cri set cri.cri_precio.pre_precio_mercado = montoTotal, 
    cri.cri_precio.pre_precio_variacion = montoPorcentaje where cri_id = id_criptomoneda;
    regresion_lineal(montoTotal, id_criptomoneda);
    if 'BIT' = nombre_criptomoneda then 
      update mercado mer set Mer.Mer_Tasa_Cambio.pre_precio_mercado = montoTotal, 
      Mer.Mer_Tasa_Cambio.pre_precio_variacion = montoPorcentaje where Mer.Mer_Tipo = 'Bitcoin';
    end if;
    if 'ETH' = nombre_criptomoneda then 
      update mercado mer set Mer.Mer_Tasa_Cambio.pre_precio_mercado = montoTotal, 
      Mer.Mer_Tasa_Cambio.pre_precio_variacion = montoPorcentaje where Mer.Mer_Tipo = 'Ethereum';
    end if;
    if 'FAB' = nombre_criptomoneda then
      update mercado mer set Mer.Mer_Tasa_Cambio.pre_precio_mercado = montoTotal, 
      Mer.Mer_Tasa_Cambio.pre_precio_variacion = montoPorcentaje where Mer.Mer_Tipo = 'Frabeau';
    end if;
  end if;
end;