**  _deccxla.prg
** 2026г Смирнова
** На Y: надо сохранить в TYPE FOX2X as 866 и проиндексировать!!

CLOSE TABLES
*!*	CLEAR 
**4.4.  Столбчатый полный (cexlst_a)
*********************************************************************
*расшифровка цех-списка (формирование cexlst_a и cexdse_a)
*********************************************************************
R=1
CXP=' '
prevcexgr=' '
scexgr=' '
poslcexgr=' '

wait wind nowa 'Подождите. Идет формирование полного столбчатого цех-списка'

creat table &ad_norm.cexlst_aS (codizd c(11),coddet c(11),zaxlist n(2,0),;
	nmarsh n(1,0),cex_post c(3),cex c(3),cex_poluch c(3),zaxcex n(2,0),;
	group c(2))
** Надо в DOS варианте
COPY TO &ad_norm.cexlst_a type fox2x as 866
USE 
erase &ad_norm.cexlst_aS.dbf

store seco() to TM1

sele 1
use &ad_norm.cexlist
count to R		&& запомнили количество записей 
sele 2
use &ad_norm.cexlst_a in 0
sele cexlist
counter = 0
scex = ''
v=1
allcount = reccount()

scan 
	cdet = coddet
	cexlst = allt(cexlist)
	cizd=codizd
	nzax = 0
	sele cexlst_a
	do while !empty(cexlst)
		n = at('-',cexlst)
		n_posl = at('-',cexlst,2)
		if n = 0
			cexgrp = cexlst
			cexlst = ''
		else
			cexgrp = left(cexlst,n-1)	&& цех + группа
			cexlst = substr(cexlst,n+1)	&& остаток строки цех-списка
			poslcex = alltrim(left(cexlst,3))	&&	цех-получатель ;
												из остатка строки цех-списка
			poslcexgr = alltrim(left(cexlst,n_posl-n-1))	&& цех-получатель;
															 + группа
		endif
		prevcex = scex
		prevcexgr = scexgr
		scex = alltrim(left(cexgrp,3))
		scexgr = alltrim(cexgrp)
		nzax = nzax + 1    
		sgrp = iif(len(cexgrp)=5,right(cexgrp,2),'')	&& введено 09.11.05
		sele cexlst_a
		append blank
		replace coddet with cdet, cex with scex, group with sgrp, ;
			zaxlist with nzax,codizd with cizd
	enddo
	sele cexlist
    scex = ''
    scexgr = ''
endscan

wait clear
sele cexlst_a
wait "Индексирую базу цех-списка..." WINDOW NOWAIT NOCLEAR 
inde on codizd+coddet+cex+str(zaxlist) tag izddtcxlst
inde on codizd+coddet+str(zaxlist) tag izddetlist for zaxlist>0
inde on coddet+codizd+str(1000-zaxlist) tag detlist_n
inde on coddet+codizd+str(zaxlist) tag detlist

do cex_zaxall		&& Проставляю номера заходов в cexlst_a

do postpolall		&& Проставляю поставщиков и получателей в cexlst_a

sele cexlst_a
inde on coddet+codizd+str(zaxlist) uniq tag detizdlist for zaxlist>0

do cexlstall		&& Проставляем номера цехов по маршруту в cexlst_a

sele cexlst_a
wait "Индексирую БД цех-списка cexlst_a..." WINDOW NOWAIT NOCLEAR 

inde on coddet+codizd+cex+str(zaxcex,2,0) tag detcexzax 
inde on cex+coddet+str(zaxcex,1,0)+cex_poluch tag cexdetpol
inde on cex+coddet+str(zaxcex,1,0) tag cexdetzax
inde on coddet+codizd+str(zaxlist) uniq tag marsh_u
inde on coddet+str(zaxlist)+codizd uniq tag detlist_mn for zaxlist>0
inde on coddet+str(1/zaxlist)+codizd uniq tag detlist_mx for zaxlist>0
inde on coddet+codizd+str(zaxlist) uniq tag detizd_mn for zaxlist>0
inde on coddet+codizd+str(100/zaxlist) uniq tag detizd_mx for zaxlist>0

wait wind nowa 'Создаем полную копию строчного цех-списка в столбчатом виде cexlstal.dbf'
copy to &ad_norm.cexlstal with cdx type fox2x as 866  && полный столбчатый цех-список в DOS варианте

sele dist coddet,cex,zaxlist,str(zaxcex,2,0) as nzax,cex_post,cex_poluch ;
	from &ad_norm.cexlst_a ;
	into table &ad_norm.cexdse_aS

COPY TO &ad_norm.cexdse_a type fox2x as 866	&& Надо в DOS варианте
USE 
ERASE &ad_norm.cexdse_aS.dbf
	
USE &ad_norm.cexdse_a IN 0
SELECT cexdse_a	

inde on coddet+cex+nzax tag detcexzax 
inde on cex+coddet+nzax tag cexdetzax 
inde on coddet+str(zaxlist,2,0) tag detlist
inde on coddet+str(zaxlist,2,0) tag detlist_d desc
	
wait 'База данных cexdse_a.dbf сформирована!' wind NOWAIT NOCLEAR 

CLOSE TABLES 
** =messagebox(_PLINENO)
IF  MESSAGEBOX('Обновлять сетевые БД ?',36,'Внимание!!')=6 	&& 6 - ДА (36 - выделена по умолчанию ДА,если 292 -выделена НЕТ ) 
	&& 6 - ДА
	if adir(dr,ad_normS,'d')>0		&& adir(dr,'y:\normativ','d')=1 and uppe(YN)='Y'
	   wait wind nowa 'Обновляю сетевые БД...'
	   use &ad_norm.cexlstal
		? '<4.4.  Столбчатый полный (cexlst_a)>  - В cети обновляем таблицу cexlstal.dbf !'
		ON ERROR ? '<4.4.  Столбчатый полный (cexlst_a)> - Проблема! В cети НЕ ОБНОВЛЕНА таблица cexlstal.dbf !'
	   copy to &ad_normS.cexlstal with cdx TYPE FOX2X as 866
	    ON ERROR 

	   use &ad_norm.cexlst_a
		? '<4.4.  Столбчатый полный (cexlst_a)> - В cети обновляем таблицу cexlst_a.dbf !'
		ON ERROR ? '<4.4.  Столбчатый полный (cexlst_a)> - Проблема! В cети НЕ ОБНОВЛЕНА таблица cexlst_a.dbf !'
	   copy to &ad_normS.cexlst_a with cdx TYPE FOX2X as 866
	   ON ERROR 
	   
	   use &ad_norm.cexdse_a
		? '<4.4.  Столбчатый полный (cexlst_a)> - В cети обновляем таблицу cexdse_a.dbf !'
		ON ERROR ? '<4.4.  Столбчатый полный (cexlst_a)> - Проблема! В cети НЕ ОБНОВЛЕНА таблица cexdse_a.dbf !'
	   copy to &ad_normS.cexdse_a with cdx TYPE FOX2X as 866
	   ON ERROR 
	   USE
		WAIT 'Базы данных cexlstal.dbf , cexlst_a.dbf , cexdse_a.dbf обновлены в сети!' WINDOW NOWAIT NOCLEAR 
	else	&& НЕТ сети!!
		WAIT 'Вы не подключены к сети! В сети НЕ ОБНОВЛЕНЫ таблицы cтолбчатых маршрутов cexlstal.dbf , cexlst_a.dbf , cexdse_a.dbf...' WINDOW NOWAIT NOCLEAR &&  time 1 
		? '<4.4.  Столбчатый полный (cexlst_a)> - В cети НЕ ОБНОВЛЕНЫ таблицы cexlstal.dbf , cexlst_a.dbf , cexdse_a.dbf !'
	endif   
ELSE 
	WAIT 'Вы ОТКАЗАЛИСЬ обновлять в сети! В сети НЕ ОБНОВЛЕНЫ таблицы строчных маршрутов cexlstal.dbf , cexlst_a.dbf , cexdse_a.dbf...' WINDOW NOWAIT NOCLEAR &&  time 1 
	? '<4.4.  Столбчатый полный (cexlst_a)> - ОТКАЗАЛИСЬ обновлять в сети таблицы cexlstal.dbf , cexlst_a.dbf , cexdse_a.dbf !'
ENDIF 
**До запуска след пункта висит сообщение о результате обновления по текущему пункту!
** =messagebox(_PLINENO)
RETURN 

*****************************************************
proc cex_zaxall
WAIT 'Проставляю номера заходов в cexlst_a...' WINDOW NOWAIT NOCLEAR 

sele cexlst_a
set orde to izddtcxlst
go top
m.codizd=' '
m.coddet=' '
m.cex=' '
ZX=0

scan
    if codizd+coddet+cex=m.codizd+m.coddet+m.cex
       ZX=ZX+1
    else
       ZX=1
    endif
    repl zaxcex with ZX
    scat memvar
endscan    

retu
**********************************************************
proc postpolall
wait 'Проставляю поставщиков и получателей в cexlst_a...' WINDOW NOWAIT NOCLEAR   

sele cexlst_a

wait 'Проставляю поставщиков в cexlst_a...' WINDOW NOWAIT NOCLEAR  
set orde to detlist
go top
m.coddet=' '
m.codizd=' '
scan
    if codizd+coddet=m.codizd+m.coddet
       repl cex_post with m.cex
    endif
    scat memvar
endscan    

wait 'Проставляю получателей в cexlst_a...' WINDOW NOWAIT NOCLEAR  
set orde to detlist_n
go top
m.coddet=' '
m.codizd=' '
scan
    if codizd+coddet=m.codizd+m.coddet
       repl cex_poluch with m.cex
    endif
    scat memvar
endscan    

RETURN 
**********************************************************
proc cexlstall
WAIT 'Проставляю номера цехов по маршруту в cexlst_a...' WINDOW NOWAIT NOCLEAR 

sele cexlst_a
set orde to detizdlist
go top
m.codizd=' '
m.coddet=' '
m.cex=' '
ZX=0

scan
    if coddet+codizd=m.coddet+m.codizd
       NC=NC+1
    else
       NC=1
    endif
    repl zaxlist with NC
    scat memvar
endscan    

return	


