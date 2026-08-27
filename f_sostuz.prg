** f_sostuz.prg
** 2026г Смирнова
** файл  надо сохранить в fox2x as 866 и проиндексировать!!

CLOSE TABLES
*!*	CLEAR 
WAIT 'Подождите, обновляю базу данных <6.3. Сборочных единиц (узлов) и подбора узлов> ' WINDOW NOWAIT NOCLEAR 
*****************  Разузловка узлов  *******************

** запомним активную строку экрана, чтобы на неё вернуться
akt_str=_PLINENO

priv AllQuant,MaxLevel, shablon, svscr
@ 0,70
@ 0,70 say "Разузловка узлов..."

TM=seco()
ERASE &ad_norm.out_uzel.CDX

if !file('&ad_norm.out_uzel.dbf')
   use &ad_norm.outizd
   copy to &ad_norm.out_uzel TYPE FOX2X as 866
   CLOSE TABLES 
endif

use &ad_norm.out_uzel
ZAP				
CLOSE TABLES

sele dist a1.codizd,a2.chnom as oboznizd ;
          from &ad_norm.specific a1,&ad_norm.sprin a2 ;
          into dbf &ad_norm.uzel ;
          where a1.codizd=a2.coddet
 ** получена таблица UZEL.dbf  -  в  VF7   !!
sele 3
use &ad_norm.izdel orde codizd
sele uzel
set rela to codizd into izdel
dele all for codizd=izdel.codizd
pack
inde on oboznizd tag oboznizd

CLOSE TABLES

sele 1 
use &ad_norm.SPECIFIC
set orde to CodIzd
sele 2
use &ad_norm.out_uzel						&& пока она пустая
copy to &ad_norm.temp TYPE FOX2X as 866
sele 3
use &ad_norm.temp 
index on coddet tag temp
sele 4
use &ad_norm.uzel orde tag oboznizd
set dele on
counter = 0
allcount = reccount()
scan
 store 1 to MaxLevel, AllQuant
 m.currizd = codizd
 m.obizd = oboznizd

	@ 1,70
	@ 1,70 SAY "Узел: " + obizd
 sele specific
 seek (m.CurrIzd)
 if !found()
  loop
 else
  do fndcodkons
 endif
 sele out_uzel
 append from &ad_norm.temp
 sele temp
 zap
 sele uzel
** do scrlprocs
endscan
sele 4
set dele off
set filter to
     
@ 0,70
@ 1,70

CLOSE TABLES
erase &ad_norm.temp.dbf
erase &ad_norm.temp.cdx

@ 0,70
@ 0,70 say 'Добавляю в out_uzel детали с нулевой применяемостью...'
sele dist b1.codizd,b2.coddet,b2.quant as allquant ;
     from &ad_norm.out_uzel b1,&ad_norm.specific b2 into dbf &ad_norm.prom ;
     where b1.coddet=b2.codizd.and.b2.quant=0
     
CLOSE TABLES

sele 2
use &ad_norm.out_uzel excl 
appe from &ad_norm.prom
erase &ad_norm.prom.dbf
@ 0,70
@ 0,70 say 'Индексирую  out_uzel.dbf ...'
inde on coddet tag coddet   
inde on coddet+codizd tag detizd
inde on codizd+coddet tag izddet   
inde on codizd tag codizd
clos data
@ 0,70
@ 0,70 say 'Разуловка узлов прошла за '+ str((seco()-TM)/60,6,1)+' мин.' 

**************** обновление подбор узла
WAIT 'Подождите, обновляю базу данных ПОДБОР ДЕТАЛЕЙ УЗЛА - podborUZ.dbf  ' WINDOW NOWAIT NOCLEAR 

USE PODBORUZ
zap
** эти же данные зачитывали при формировании PODBOR.dbf в искусственную таблицу PODBORS.dbf
** APPEND FROM &ad_vig.PODBOR.DAT TYPE SDF as 866

APPEND FROM &ad_norm.PODBORS.dbf
** ERASE &ad_norm.PODBORS.dbf		&&*********!!!!!!!!!!!!!!!!
CLOSE TABLES 

select distinct p.coddet_osn ,P.coddet,p.prizn ,O.CODIZD,o.allquant AS QUANT ;
 from &ad_norm.OUT_UZEL o,&ad_norm.podborUZ p,&ad_norm.PODBOR3 D ;
 where o.coddet =p.coddet_osn AND O.CODIZD =D.CODIZD ;
 INTo dbf podbor1
 
INDEX ON CODIZD+coddet_OSN tag coddet_OSN
INDEX ON CODIZD+ CODDET FOR coddet_osn!= coddet TAG CODIZD 

CLOSE TABLES 

SELE 1
USE &ad_norm.PODBOR1 ALIAS A1 ORDE CODIZD
SELE 2
USE &ad_norm.OUT_UZEL ORDE IZDDET
SELE 1
SET RELA TO CODIZD+CODDET INTO OUT_UZEL
DELETE all for found(2)
PACK 
CLOSE TABLES 

SELECT CODIZD,coddet_osn ,count(*) as kol ;
  from &ad_norm.podbor1 ;
  into dbf &ad_norm.pom_podbor group by CODIZD,coddet_osn
	
INDEX ON CODIZD+coddet_osn  tag coddet_osn
CLOSE TABLES 

sele 2
use &ad_norm.pom_podbor alias a2 orde coddet_osn 
sele 1
use &ad_norm.podbor1 alias a1 orde coddet_osn
sele 1
set rela to CODIZD+coddet_osn into a2
          
REPL all a1.quant with a1.quant/a2.kol

CLOSE TABLES 

ERASE &ad_norm.podborUZ.dbf
ERASE &ad_norm.podborUZ.cdx
** создается в п. 6.1 - и остается до следующего пересоздания!!!
*!*	ERASE &ad_norm.podbor3.dbf
*!*	ERASE &ad_norm.podbor3.cdx
ERASE &ad_norm.podbor1.cdx

USE &ad_norm.podbor1
COPY TO &ad_norm.podborUZ TYPE FOX2X as 866

USE &ad_norm.podborUZ
INDEX ON coddet_OSN tag coddet_OSN
INDEX ON codizd+coddet_osn tag izddet_osn
INDEX ON codizd+coddet_OSN+coddet tag izdosndet

ERASE &ad_norm.podbor1.dbf

CLOSE TABLES 
@ 0,70 
** вернемся на активную строку, чтобы продолжить вывод
**ON ERROR CLEAR WINDOW 
@ akt_str,110 say SPACE(10)
**ON ERROR 

if adir(dr,ad_normS,'d')>0		&& adir(dr,'y:\normativ','d')=1
	wait 'Обновляю OUT_UZEL.DBF в сети ... '+ad_normS WINDOW NOWAIT NOCLEAR 
	use &ad_norm.OUT_UZEL 
	? '<6.3. Сборочных единиц (узлов) и подбора узлов> - В cети обновляем таблицу OUT_UZEL.DBF !'
	ON ERROR ? '<6.3. Сборочных единиц (узлов) и подбора узлов> - Проблема! В cети НЕ ОБНОВЛЕНА таблица OUT_UZEL.DBF !'
	copy to &ad_normS.OUT_UZEL with cdx TYPE FOX2X as 866 
	ON ERROR 
	USE 
	
	wait 'Обновляю podborUZ.dbf в сети ... '+ad_normS WINDOW NOWAIT  
	USE &ad_norm.podborUZ
	? '<6.3. Сборочных единиц (узлов) и подбора узлов> - В cети обновляем таблицу podborUZ.dbf!'
	ON ERROR ? '<6.3. Сборочных единиц (узлов) и подбора узлов> - Проблема! В cети НЕ ОБНОВЛЕНА таблица podborUZ.dbf!'
	copy to &ad_normS.podborUZ with cdx TYPE FOX2X as 866
	ON ERROR 
	USE 
	WAIT 'Базы данных OUT_UZEL.DBF , podborUZ.dbf обновлены в сети!' WINDOW NOWAIT NOCLEAR &&  time 1
	
else
	WAIT 'Вы не подключены к сети! В сети НЕ ОБНОВЛЕНЫ таблицы OUT_UZEL.DBF , podborUZ.dbf ...' WINDOW NOWAIT NOCLEAR &&  time 1 
	? '<6.3. Сборочных единиц (узлов) и подбора узлов>  - В cети НЕ ОБНОВЛЕНЫ таблицы OUT_UZEL.DBF , podborUZ.dbf !'
ENDIF    


**До запуска след пункта висит сообщение о результате обновления по текущему пункту!
RETURN 

*********************************************
Proc fndcodkons
Priv CodIzd,CodDet,Quant,CurrRec,CurrArea,NewRec
MaxLevel = MaxLevel + 1
m.CodIzd = CodIzd
do while CodIzd = m.CodIzd
 if Quant != 0
    scatter memvar
    NewRec = recno()
    AllQuant = AllQuant * m.Quant
    sele temp
    Seek (m.CodDet)
    if !found()
       append blank
       repl CodDet with m.CodDet,maxlevel with m.maxlevel;
       codizd with m.currizd, AllQuant with m.AllQuant
    else
       if MaxLevel < m.MaxLevel and MaxLevel != 0
          repl MaxLevel with m.MaxLevel,AllQuant with m.AllQuant + AllQuant    
       else
          repl AllQuant with m.AllQuant + AllQuant         
       endif   
    endif
    sele specific
    if MaxLevel != 0
       seek m.CodDet
       if found()                     && Узел !
          do fndcodkons
       else                           && Деталь !
          sele temp
          repl MaxLevel with 0
          sele Specific
       endif
    endif
    go NewRec  
    if m.Quant=0
       m.AllQuant = 0
    else
       m.AllQuant = m.AllQuant / m.Quant 
    endif   
 endif

 skip   
enddo
MaxLevel = MaxLevel - 1
RETURN 
***********************************************
proc scrlprocs
******** отражение хода процесса
para przt
priv sscroll
counter=counter+1
sscroll=''
sscroll=padr(padr(sscroll,round(counter/allcount*50,0),'-'),50,' ')
wait sscroll window nowait
retu






