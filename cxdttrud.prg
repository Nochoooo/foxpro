** cxdttrud.prg
** 2026г Смирнова
** Выгруженный файл надо сохранить в fox2x as 866 и проиндексировать!!
CLOSE TABLES
*!*	CLEAR 
WAIT 'Подождите, обновляю базу данных <9.1. Формирование CEX_TRUD>' WINDOW NOWAIT NOCLEAR 
*********************************************************************************************************
** cxdttrud.prg 24.12.2012
*********************************************************************************************************
** proc f_cxdttrud		&& формирование БД цеховых детальных и суммарных детальных трудозатрат

wait 'Формирую БД цеховых подетальных трудозатрат по полным цеховым маршрутам' WINDOW NOWAIT NOCLEAR 
sele 1
**21/01/2013
**use c:\normativ\procprem orde cexuch alia a1
use &ad_norm.procprem 
on erro index on cex+allt(uch) tag cexuch 
SET ORDER TO cexuch
on erro
***21/01/2013
sele dist b1 as cex,uch,b3 as coddet,nzax_all,zaxlist,' ' as nmarsh,;
	n_oper,t1,r1,t2,vid_opl,vich,s3,nzax,;
	000.0 as prem_proc,00000.00000 as prem ;
	from &ad_norm.oper\opertrud ;
	into dbf &ad_norm.oper\optrdprc ;
	where vich>0 and t1>0 and zaxlist<>0
***11/02/2013 Учитываем , что в opertrud.zaxlist не д.б. 0
***			 если 0, то не берем в счет

set rela to cex+allt(uch) into procprem
repl all prem_proc with procprem.prem_proc for cex+allt(uch)=procprem.cex+allt(procprem.uch)
set rela to cex into procprem
**repl all prem_proc with a1.prem_proc for cex=a1.cex
*** если премии цех-участок нет, то берем по цеху
repl all prem_proc with procprem.prem_proc for empty(procprem.uch) and prem_proc=0
repl all prem with r1*prem_proc/100

sele cex,coddet,nzax_all,zaxlist,nmarsh,;
	sum(t1/vich) as t1,sum(r1/vich) as r1,sum(t2/vich) as t2,;
	sum(iif(left(vid_opl,1)='2',t1/vich,00000.00000)) as t_sd,;
	sum(iif(left(vid_opl,1)='7',t1/vich,00000.00000)) as t_povr,;
	sum(iif(s3='2',t1/vich,00000.00000)) as t_ton,;
	sum(iif(s3='2',1,0)) as quant_ton,nzax,prem_proc,sum(prem/vich) as prem ;
	from &ad_norm.oper\optrdprc ;
	into dbf &ad_norm.cex_trdaS ;
	grou by cex,coddet,nzax_all

** Надо в DOS варианте
COPY TO &ad_norm.cex_trda type fox2x as 866
USE
ERASE &ad_norm.cex_trdaS.dbf

sele 0
use &ad_norm.cex_trda excl
inde on cex+coddet+allt(nzax_all) tag cexdetzax
inde on coddet+cex+allt(nzax_all) tag detcexzax
inde on cex+coddet+allt(nzax)+allt(nzax_all) tag cexdetzaxt
inde on coddet+cex+allt(nzax)+allt(nzax_all) tag detcexzaxt

wait 'Формирую БД цеховых подетальных трудозатрат по товарным цеховым заходам' WINDOW NOWAIT NOCLEAR 
*** просуммировала и премию!!!
sele dist cex,coddet,nzax,sum(t1) as t1,sum(r1) as r1,sum(t2) as t2,;
		sum(t_sd) as t_sd,sum(t_povr) as t_povr,sum(t_ton) as t_ton,;
		sum(quant_ton) as quant_ton,nmarsh,prem_proc,sum(prem) as prem ;
	from &ad_norm.cex_trda ;
	into dbf &ad_norm.cex_trudS ;
	grou by cex,coddet,nzax

COPY TO &ad_norm.cex_trud type fox2x as 866
USE
ERASE &ad_norm.cex_trudS.dbf

sele 0
use &ad_norm.cex_trud excl
inde on cex+coddet+allt(nzax) tag cexdetzax
inde on coddet+cex+allt(nzax) tag detcexzax

CLOSE TABLES 

if  adir(dr,ad_normS,'d')>0		&& adir(dr,'y:\normativ','d')=1
	wait 'Обновляю cex_trud.dbf в сети ... '+ad_normS WINDOW NOWAIT NOCLEAR  
	USE &ad_norm.cex_trud
	? '<9.1. Формирование CEX_TRUD> - В cети обновляем таблицу cex_trud.dbf !'
	ON ERROR ? '<9.1. Формирование CEX_TRUD> - Проблема! В cети НЕ ОБНОВЛЕНА таблица cex_trud.dbf!'
	copy to &ad_normS.cex_trud with cdx TYPE FOX2X as 866
	ON ERROR 
	
	USE &ad_norm.cex_trda
	? '<9.1. Формирование CEX_TRUD> - В cети обновляем таблицу cex_trda.dbf !'
	ON ERROR ? '<9.1. Формирование CEX_TRUD> - Проблема! В cети НЕ ОБНОВЛЕНА таблица cex_trda.dbf!'
	copy to &ad_normS.cex_trda with cdx TYPE FOX2X as 866
	ON ERROR 
	USE 
	WAIT 'Базы данных cex_trud.dbf , cex_trda.dbf обновлены в сети!' WINDOW NOWAIT NOCLEAR &&  time 1
ELSE 
	wait 'Вы не подключены к сети! В cети НЕ ОБНОВЛЕНЫ таблицы cex_trud.dbf , cex_trda.dbf ...' WINDOW NOWAIT NOCLEAR 	&&  time 1
	? '<9.1. Формирование CEX_TRUD> - В cети НЕ ОБНОВЛЕНЫ таблицы cex_trud.dbf , cex_trda.dbf !'
ENDIF 

**До запуска след пункта висит сообщение о результате обновления по текущему пункту!
RETURN 


