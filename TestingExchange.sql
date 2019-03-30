--Examples
Declare 
minimo number;
maximo number;
begin
select min(usu_id), max(usu_id) into minimo , maximo from usuario;
  for i in minimo..maximo loop
  Calculo_De_Crip_Segun_Mer(i);
  end loop;
end;

--jejeje


--select bi.bil_id,Bi.Bil_Monto,Bi.Bil_Equivalente.pre_precio_mercado,Bi.Bil_Equivalente.pre_equivalente_dolares,Bi.Bil_Fk_Criptomoneda,Bi.Bil_Fk_Usuario
--from billetera bi;

select bi.bil_id,Bi.Bil_Monto,Bi.Bil_Equivalente.pre_precio_mercado,
Bi.Bil_Equivalente.pre_equivalente_dolares,Bi.Bil_Fk_Criptomoneda,Bi.Bil_Fk_Usuario
from billetera bi where Bi.Bil_Fk_Usuario = 66 and Bi.Bil_Fk_Criptomoneda = 7;


--jejejejeje

Declare 
minimo number;
maximo number;
begin
select min(ord_id), max(ord_id) into minimo , maximo from orden;
  for i in minimo..maximo loop
  Match_Entre_Ordenes(i);
  end loop;
end;

--jejejejejeje

--execute crear_ordenes(100);
select * from orden;

--jejejejejejejjejeje

select bi.bil_id,Bi.Bil_Monto,Bi.Bil_Equivalente.pre_precio_mercado,
Bi.Bil_Equivalente.pre_equivalente_dolares,Bi.Bil_Fk_Criptomoneda,Bi.Bil_Fk_Usuario
from billetera bi where Bi.Bil_Fk_Usuario in (97,73)  and Bi.Bil_Fk_Criptomoneda = 13;

--jejejejejej
select Cri.Cri_Id,Cri.Cri_Precio.pre_precio_mercado,Cri.Cri_Precio.pre_equivalente_dolares,Cri.Cri_Nombre 
from criptomoneda cri where Cri.Cri_Id = 13;


select * from orden where Ord_Fk_Usuario = 97