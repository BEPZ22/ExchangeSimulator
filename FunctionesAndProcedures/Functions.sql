create or replace 
function referencia(id_operacion number) return number is referencia1 number;
begin
  begin
    select nvl(max(ope_referencia),0) into referencia1 from operacion;
    return referencia1;
    exception
    when NO_DATA_FOUND then
    referencia1:=0;
  end;
  return referencia1;
end;
/
create or replace function compra_o_vende (algo number) return varchar2 is tipo Varchar2(50);
begin
  Declare 
  valor number;
  begin
    select trunc(dbms_random.value(1,3)) into valor from dual;
    case
    when valor = 1 then tipo:= 'compra';
    
    when valor = 2 then tipo:= 'venta';
    
    when valor = 3 then  tipo:='venta';
    
    end case;
    
   end; 
return tipo;
end;
/
create or replace 
function eleccion_criptomoneda_CV(id_mercado number) return number is 
id_criptomoneda number;
begin
  Declare
  maximo_criptomoneda number;
  minimo_criptomoneda number;
  criptomoneda1 number;
  nombre_mercado varchar2(50);
    Begin
    criptomoneda1 := valida_criptomoneda_existe(0);
    if criptomoneda1 >0 and id_mercado <> 0 then
      select DECODE(me.mer_tipo,'Bitcoin','BIT','Ethereum','ETH','Frabeau','FAB') 
      into nombre_mercado from mercado me where me.mer_id = id_mercado;
      SELECT cri_id into id_criptomoneda FROM (SELECT cri_id FROM criptomoneda where cri_nombre <> nombre_mercado 
      ORDER BY DBMS_RANDOM.VALUE) WHERE rownum = 1;
    else
      SELECT cri_id into id_criptomoneda FROM (SELECT cri_id FROM criptomoneda ORDER BY DBMS_RANDOM.VALUE) 
      WHERE rownum = 1;
    end if;
    
    End;
return Id_Criptomoneda;
end;
/
create or replace 
function moneda_conversion(saldo number,id_usurio number,i number, monto number) return number is saldo_usu number;
begin
  Declare
  monto_mercado number;
  Begin
  monto_mercado:= monto;
     if saldo >= monto_mercado then 
        saldo_usu:= saldo-monto_mercado;
        update usuario set usu_saldo=saldo_usu where usu_id = Id_Usurio;
        saldo_usu:=1;
      else 
        saldo_usu:= saldo/monto_mercado;
        update usuario set usu_saldo=0 where usu_id = Id_Usurio;
      end if;
  End;
return saldo_usu;
end;
/
create or replace function valida_usuario_existente(id_usu number)return number is usuarios number;
 begin
 if id_usu = 0 then
  SELECT usu_id into usuarios FROM usuario WHERE rownum = 1;
  return usuarios;
 else
  SELECT usu_id into usuarios FROM usuario WHERE usu_id = id_usu;
  return usuarios;
 end if;
 exception
 WHEN NO_DATA_FOUND THEN
 usuarios :=0;
return usuarios;
 end;
/
create or replace 
function saldo_criptomoneda_CV (usuarios number) return number is 
saldo number;
begin 
declare
random_id number;
maximo_criptomoneda number;
minimo_criptomoneda number;
saldo_criptomoneda number;
criptomoneda1 number; 
  begin
    criptomoneda1 := valida_criptomoneda_existe(0);
    if criptomoneda1 >0 then
    /*  select MIN(cri_id),MAX(cri_id) into minimo_criptomoneda,maximo_criptomoneda from criptomoneda;
     SELECT trunc(dbms_random.value(minimo_criptomoneda,maximo_criptomoneda)) into random_id FROM dual;*/
     SELECT cri_id into random_id FROM (SELECT cri_id FROM criptomoneda ORDER BY DBMS_RANDOM.VALUE) WHERE  rownum = 1;
     select bi.bil_monto into saldo from billetera bi 
     where bi.bil_fk_usuario = usuarios and bil_fk_criptomoneda=random_id;
    end if;
  end;
return saldo;
end;
/
create or replace 
function seleccion_mercado (algo number)  return number is mercado1 number;
Begin
   SELECT mer_id into mercado1 FROM (SELECT mer_id FROM mercado ORDER BY DBMS_RANDOM.VALUE) WHERE  rownum = 1;
return mercado1;
end;
/
create or replace function valida_criptomoneda_existe(id_cri number)return number is criptomoneda1 number;
 begin
  if id_cri = 0 then 
    SELECT cri_id into criptomoneda1 FROM criptomoneda WHERE rownum =1;
    return criptomoneda1;
  else
    SELECT cri_id into criptomoneda1 FROM criptomoneda WHERE cri_id = id_cri;
    return criptomoneda1;
  end if;
 exception
 WHEN NO_DATA_FOUND THEN
 criptomoneda1 :=0;
return criptomoneda1;
 end;
/
create or replace function valida_direccion_existe(id_dir number)return number is direccion1 number;
 begin
 if id_dir = 0 then
  SELECT dir_id into direccion1 FROM direccion WHERE rownum =1;
  return direccion1;
 else
  SELECT dir_id into direccion1 FROM direccion WHERE dir_id = id_dir;
  return direccion1;
 end if;
 exception
 WHEN NO_DATA_FOUND THEN
 direccion1 :=0;
return direccion1;
 end;
/
create or replace function valida_mercado_existe(id_mer number)return number is mercado1 number;
 begin
 if id_mer = 0 then
  SELECT mer_id into mercado1 FROM mercado WHERE rownum =1;
  return mercado1;
 else
  SELECT mer_id into mercado1 FROM mercado WHERE mer_id = id_mer;
  return mercado1;
 end if;
 exception
 WHEN NO_DATA_FOUND THEN
 mercado1 :=0;
return mercado1;
 end;
/

create or replace function validar_saldo (usuario number, criptomoneda number) return number is 
saldo number(28,8);
begin
select bil_monto into saldo from billetera 
where bil_fk_usuario = usuario and bil_fk_criptomoneda = criptomoneda; 
return saldo;
end;
/
create or replace 
function generar_monto(usuarios number,criptomoneda1 number,tipo_compra varchar2, saldo_usuario number)
return number is monto_crip number(28,8);
begin
   if 'venta'=tipo_compra then
    select dbms_random.value(0,saldo_usuario) into monto_crip from billetera where bil_fk_usuario = usuarios 
    and bil_fk_criptomoneda= criptomoneda1;
    dbms_output.put_line('venta saldo '||monto_crip);
    return monto_crip;
  else
    select dbms_random.value(0,1) into monto_crip from billetera where bil_fk_usuario = usuarios 
    and bil_fk_criptomoneda= criptomoneda1; 
    dbms_output.put_line('compra saldo '||monto_crip);
    return monto_crip;
end if;
end;
/
create or replace function calculo_equivalente_dolares (mercado number, monto_cri number) return number is monto_dolares number(28,13);
begin
    monto_dolares := mercado*monto_cri;     
return monto_dolares;
end;
/
create or replace 
function generar_tipo_orden(algo number) 
return varchar2 is tipo varchar2(50);
begin
declare
valor number;
  begin
  select trunc(dbms_random.value(1,4)) into valor from dual;
  
  case
    when valor =1 then tipo:= 'StopLimit';
    when valor =2 then tipo:= 'Limit';
    when valor =3 then tipo:= 'Market';
    else tipo:='Market';
  end case;
  end;
return tipo;
end;
/
create or replace 
function generar_precio(mercado1 number ,monto_crip number ,criptomoneda1 number, tipo_orden varchar2)
return number is precio_crip number(28,8);
begin
declare 
monto_random number(28,8);
monto number(28,8);
begin
    monto := 1;
  if 'Market' = tipo_orden then
    precio_crip := monto;
  else 
    select dbms_random.value(-2,2) into monto_random from dual;
    dbms_output.put_line('monto venta random '||monto_random);
    if  monto + monto_random > 0 then
      precio_crip := monto + monto_random;
    else if monto + monto_random = 0 then
     precio_crip := monto;
    else
      precio_crip := (monto + monto_random) * (-1);
    end if;
    end if;
  end if;
  end;
   dbms_output.put_line('monto venta total '||precio_crip);
  return precio_crip;
end;