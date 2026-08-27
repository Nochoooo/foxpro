** _cex_sp.prg
** 2026г Смирнова
** На Y: надо сохранить в fox2x as 866 и проиндексировать!!
CLOSE TABLES
*!*	CLEAR 
WAIT CLEAR 
WAIT 'Подождите, обновляю базу данных <Строчный (cexlist)>' WINDOW NOWAIT NOCLEAR 

** удаляем индексы, чтобы быстрее закачивать данные
erase &ad_norm.cexlist.cdx
erase &ad_norm.cexlistp.cdx

*************!!!!!!!!!!!!!!!!!!*************************************
*** т.к. из текстового файла при зачитывании полей ЧИСЛОВЫХ в VF7 могут теряться значения,
**  то сначала создадим таблицу со структурой, где ВСЕ поля СИМВОЛЬНЫЕ.
** получим в неё данные из файла DAT, а затем их загрузим в правильную таблицу!!!
creat table &ad_norm.cexlistpS (codizd c(11),POLE C(1),CODDET C(11),cex c(3),nmarsh c(1) , ;
			cexlist c(146),quant C(7),primech C(50),chnom c(40), naim c(35))

APPEND FROM &ad_vig.CEX_SP2.DAT TYPE SDF as 866
*********!!!!!!!!!!!!!!!!************************************************************

** 29.06.05 Новое. Обновление полного ВТМ (полная копия с Oracle)
use &ad_norm.cexlistp
zap
** где будет и какой формат??
** пока как раньше - Но учтем кодировку 866 !!
APPEND FROM &ad_norm.cexlistpS 		&&*********!!!!!!!!!!!!!!!!

inde on codizd+coddet tag izddet
inde on coddet+cexlist uniq tag detlist_u
inde on coddet+codizd tag detizd

ERASE &ad_norm.cexlistpS.dbf		&&*********!!!!!!!!!!!!!!!!
USE 

*************!!!!!!!!!!!!!!!!!!*************************************
*** т.к. из текстового файла при зачитывании полей ЧИСЛОВЫХ в VF7 могут теряться значения,
**  то сначала создадим таблицу со структурой, где ВСЕ поля СИМВОЛЬНЫЕ.
** получим в неё данные из файла DAT, а затем их загрузим в правильную таблицу!!!
creat table &ad_norm.cexlistS (codizd c(11),POLE C(1),CODDET C(11),cex c(3),nmarsh c(1) , ;
			cexlist c(166),quant C(7),primech C(50),chnom c(40), naim c(35))

APPEND FROM &ad_vig.CEX_SP.DAT TYPE SDF as 866
*********!!!!!!!!!!!!!!!!************************************************************

use &ad_norm.cexlist
zap
** где будет и какой формат??
** пока как раньше - Но учтем кодировку 866 !!
APPEND FROM &ad_norm.cexlistS 		&&*********!!!!!!!!!!!!!!!!
ERASE &ad_norm.cexlistS.dbf			&&*********!!!!!!!!!!!!!!!!

repl all nmarsh with 1 for nmarsh=0

** удаляем все маршруты кроме 1-го
dele all for nmarsh>1
pack

*** очищаем строку цех-списка от "грязи"
repl all cexlist with allt(strtran(cexlist,'*',''))
repl all cexlist with allt(strtran(cexlist,'316','315'))

** удаляем двойные маршруты
inde on codizd+coddet tag izddet_u uniq
copy to prom
set orde to
zap
appe from prom

WAIT 'Индексирую cexlist...' WINDOW NOWAIT NOCLEAR 
inde on codizd+coddet tag izddet
inde on coddet+codizd uniq tag detizd_m1u for nmarsh=1
inde on coddet+cexlist uniq tag detlist_u
inde on coddet+codizd tag detizd
USE &ad_norm.SPRIN IN 0 ORDE CODDET
SELE cexlist
SET RELA TO CODDET INTO SPRIN 
REPL ALL CHNOM WITH SPRIN.CHNOM,NAIM WITH SPRIN.NAIM
CLOSE TABLES 

if adir(dr,ad_normS,'d')>0		&&  adir(dr,'y:\normativ','d')=1
	wait 'Обновляю CEXLIST в сети ... '+ad_normS WINDOW NOWAIT  
	use &ad_norm.CEXLIST
	? '<4.1. Строчный (cexlist)> -В cети обновляем таблицу CEXLIST.dbf !'
	ON ERROR ? '<4.1. Строчный (cexlist)> -Проблема! В cети НЕ ОБНОВЛЕНА таблица CEXLIST.dbf !'
	COPY to &ad_normS.CEXLIST with cdx TYPE FOX2X as 866
	ON ERROR 
	
	wait 'Обновляю CEXLISTP в сети ... '+ad_normS WINDOW NOWAIT  
	use &ad_norm.CEXLISTP
	? '<4.1. Строчный (cexlist)> -В cети обновляем таблицу CEXLISTP.dbf !'
	ON ERROR ? '<4.1. Строчный (cexlist)> -Проблема! В cети НЕ ОБНОВЛЕНА таблица CEXLISTP.dbf !'
	COPY to &ad_normS.CEXLISTP with cdx TYPE FOX2X as 866
	ON ERROR 
	USE 
	WAIT 'Базы данных CEXLIST, CEXLISTP обновлены в сети!' WINDOW NOWAIT NOCLEAR &&  time 1
ELSE 
	WAIT 'Вы не подключены к сети! В сети НЕ ОБНОВЛЕНЫ таблицы строчных маршрутов CEXLIST, CEXLISTP...' WINDOW NOWAIT NOCLEAR &&  time 1 
	? '<4.1. Строчный (cexlist)> - В cети НЕ ОБНОВЛЕНЫ таблицы CEXLIST.dbf , CEXLISTP.dbf !'
ENDIF    

**До запуска след пункта висит сообщение о результате обновления по текущему пункту!
RETURN 



