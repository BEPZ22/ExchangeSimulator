CREATE INDEX "USER"."INDICE_FK_BILLETERA" ON "USER"."BILLETERA" ("BIL_FK_USUARIO", "BIL_FK_CRIPTOMONEDA") 
PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
TABLESPACE "USERS" ;
/
CREATE INDEX "USER"."INDICE_NOMBRE_CRIPTOMONEDA" ON "USER"."CRIPTOMONEDA" ("CRI_NOMBRE") 
PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
TABLESPACE "USERS" ;
/
CREATE INDEX "USER"."INDICE_STATUS_ORDEN" ON "USER"."ORDEN" ("ORD_ID", "ORD_STATUS") 
PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
TABLESPACE "USERS" ;
/
CREATE INDEX "USER"."INDICE_FK_USUARIO_ORDEN" ON "USER"."ORDEN" ("ORD_FK_USUARIO", "ORD_STATUS", "ORD_TIPO", "ORD_MERCADO", "ORD_MONEDA") 
PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
TABLESPACE "USERS" ;
/
CREATE INDEX "USER"."INDICE_NOMBRE_MERCADO" ON "USER"."MERCADO" ("MER_TIPO") 
PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
TABLESPACE "USERS" ;
/
CREATE INDEX "USER"."INDICE_REPORTE_PROMEDIO" ON "USER"."ORDEN" ("ORD_MONEDA","ORD_FECHA_CREACION","ORD_MERCADO","ORD_TIPO") 
PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
TABLESPACE "USERS" ;
/
CREATE INDEX "USER"."INDICE_REPORTE_NO_EFECTUADAR" ON "USER"."ORDEN" ("ORD_STATUS","ORD_MONEDA","ORD_MERCADO") 
PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
TABLESPACE "USERS" ;
/
CREATE INDEX "USER"."INDICE_CRIPTOMONEDA_PRONOSTICO" ON "USER"."PRONOSTICO" ("PRO_ID_CRIPTOMONEDA") ;

