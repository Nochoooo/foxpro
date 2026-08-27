** razuzl_p.prg
** 2026г Смирнова
** Выгруженный с SQL файл sprin (? КУДА, ?dbf ) надо сохранить в fox2x as 866 и проиндексировать!!
CLOSE TABLES
*!*	CLEAR 
WAIT CLEAR 
WAIT 'Подождите, обновляю базу данных <6.2. Полное разузлование>' WINDOW NOWAIT NOCLEAR 

** запомним активную строку экрана, чтобы на неё вернуться
akt_str=_PLINENO
***********************************************
**формирование полного разузлованного состава изделий,
**включая ДСЕ с 0-вой применяемостью и подборы

** формируем структуру таблицы разузловки изделий:
creat table &ad_norm.outizd_pS (codizd c(11),coddet c(11),maxlevel n(2,0),;
	allquant n(10,3),quant_norm n(10,3),quant_m_k n(10,3),;
	quant_kvi n(10,3),quant_teh n(10,3),quant_exp n(10,3),quant_obr n(10,3))
** Надо в DOS варианте
COPY TO &ad_norm.outizd_p type fox2x as 866
USE &ad_norm.outizd_p
ERASE &ad_norm.outizd_pS.dbf

	**составляем перечень изделий - СЕ (сборочные единицы), не входящие в другие СЕ
	sele 1
	use &ad_norm.specific orde detizd
	sele 2
	use &ad_norm.izdel orde codizd
	sele dist codizd from &ad_norm.specific into dbf &ad_norm.prom

	set rela to codizd into specific,codizd into izdel
	**copy to dob_izd for !found(1) and !found(2)
	**copy to dob_izd for !found(2)
	** ??? этот блок можно убить, т.к. всё это оказалось невостребованным далее  ???
CLOSE TABLES


**разузловываем изделия
priv AllQuant,MaxLevel, shablon, svscr

@ 0,80
@ 0,80 say "Разузловка изделий..."
NewRec=0
sele 1 
use &ad_norm.SPECIFIC
set orde to izddet
sele 2
use &ad_norm.outizd_p
copy to &ad_norm.temp TYPE FOX2X as 866			&& из пустой табл создаеттся пустая табл. temp
sele 3
use &ad_norm.temp 
index on coddet tag temp
sele 4
use &ad_norm.Izdel orde tag oboznizd
set dele on
set filter to podgrup!='z'.and.catalog!=' '
counter = 0
allcount = reccount()
scan
	store 1 to MaxLevel, AllQuant
	m.currizd = codizd
	m.obizd = oboznizd
	
	@ 1,80
	@ 1,80 SAY "Изделие:" + obizd
	sele specific
	seek (m.CurrIzd)
	if !found()
		loop
	else
		do fndcodkons
	endif
	sele outizd_p
	append from &ad_norm.temp
	sele temp
	zap
	sele izdel
endscan

@ 0,80
@ 1,80

CLOSE TABLES 

erase temp.dbf
erase temp.cdx

sele 2
use &ad_norm.outizd_p excl 
@ 0,80
@ 0,80 say 'Индексирую outizd_p...'
inde on codizd+coddet tag izddet   
inde on coddet+codizd tag detizd

@ 0,80
@ 0,80 say 'Выбираю состав недостающих изделий из нормативных карт...'
sele 2
set orde to izddet
sele 1
use &ad_norm.normmato 
on erro inde on codizd+coddet tag izddet
set orde to izddet
on erro
set rela to codizd into outizd_p
copy to &ad_norm.sost_dob for codizd!=outizd_p.codizd and coddet!=codizd TYPE FOX2X as 866
set rela to
@ 0,80
@ 0,80 say 'Добавляю состав недостающих изделий из нормативных карт...'
sele 2		&& outizd_p
appe from &ad_norm.sost_dob
**erase sost_dob.dbf
@ 0,80
@ 0,80 say 'Проставляю применяемость из нормативных карт...'
** на детали с нулевой применяемостью
set rela to codizd+coddet into normmato
repl all quant_norm with normmato.allquant for found(1)
@ 0,80
@ 0,80 say 'Формирую таблицу несоответствия применяемости...'
** в разузловке и из нормативных карт
copy to &ad_norm.err_prim for found(1) and allquant!=normmato.allquant TYPE FOX2X as 866
@ 0,80
@ 0,80 say 'Добавляю применяемость на КВИ, тех.нужды и образцы...'
@ 1,80 say ' !!! используется таблица dop_prim из п. 6.1. !!! ' color w+/n*
sele 1
use &ad_norm.dop_prim orde izddet
sele 2		&& outizd_p
set rela to codizd+coddet into dop_prim
repl all quant_m_k with dop_prim.quant_m_k,quant_kvi with dop_prim.quant_kvi,;
         quant_teh with dop_prim.quant_teh,quant_obr with dop_prim.quant_obr,;
         quant_exp with dop_prim.quant_exp for codizd+coddet=dop_prim.codizd+dop_prim.coddet
CLOSE TABLES
*!*	erase out_prom.dbf
*!*	erase out_prom.cdx

@ 1,80
@ 0,80 
@ 0,80 say 'формируем разузлованный состав изделий с подборными и взаимозаменяемыми ДСЕ...'
@ 1,80 say ' !!! используется таблица PODBOR.dbf из программы - NORMA !!! ' color w+/n*
sele 2
use &ad_norm.podbor 
on erro inde on coddet_osn+codizd+coddet tag detosnizd
set orde to detosnizd
on erro inde on coddet+codizd tag detizd
set orde to detizd
on erro
sele 1
use &ad_norm.outizd_p orde detizd
set rela to coddet+codizd into podbor
dele all for found(2)
pack
sele 2
copy to &ad_norm.dob_podb
sele 1
appe from &ad_norm.dob_podb
set rela to
CLOSE TABLES

@ 1,80
@ 0,80 
@ 0,80 say 'Формируем таблицу применяемости деталей в изделиях'

** Формируем таблицу применяемости деталей в изделиях
do formprimen
@ 0,80 
erase &ad_norm.prom.dbf

** вернемся на активную строку, чтобы продолжить вывод
** ON ERROR CLEAR WINDOW
@ akt_str,110  say SPACE(10)
** ON ERROR

IF adir(dr,ad_normS,'d')>0		&& adir(dr,'c:\normativ','d')=1
	wait 'Обновляю outizd_p.dbf в сети ... '+ad_normS WINDOW NOWAIT  
	use &ad_norm.outizd_p
	? '<6.2. Полное разузлование>  - В cети обновляем таблицу outizd_p.dbf !'
	ON ERROR ? '<6.2. Полное разузлование>  - Проблема! В cети НЕ ОБНОВЛЕНА таблица outizd_p.dbf !'
	copy to &ad_normS.outizd_p with cdx TYPE FOX2X as 866
	ON ERROR 
	
	wait 'Обновляю det_prim.dbf в сети ... '+ad_normS WINDOW NOWAIT  
	use &ad_norm.det_prim
	? '<6.2. Полное разузлование>  - В cети обновляем таблицу det_prim.dbf !'
	ON ERROR ? '<6.2. Полное разузлование>  - Проблема! В cети НЕ ОБНОВЛЕНА таблица det_prim.dbf !'
	copy to &ad_normS.det_prim with cdx TYPE FOX2X as 866
	ON ERROR 
	USE 
	WAIT 'Базы данных outizd_p.dbf , det_prim.dbf обновлены в сети!' WINDOW NOWAIT NOCLEAR 
ELSE 
	wait 'Вы не подключены к сети! В cети НЕ ОБНОВЛЕНЫ таблицы outizd_p.dbf , det_prim.dbf ...' WINDOW NOWAIT NOCLEAR 
	? '<6.2. Полное разузлование>  - В cети НЕ ОБНОВЛЕНЫ таблицЫ outizd_p.dbf , det_prim.dbf !'
ENDIF    

**До запуска след пункта висит сообщение о результате обновления по текущему пункту!
RETURN 


****************************************
Proc fndcodkons
Priv CodIzd,CodDet,Quant,CurrRec,CurrArea,NewRec
MaxLevel = MaxLevel + 1
m.CodIzd = CodIzd
do while CodIzd = m.CodIzd
IF ALLQUANT=0
 ALLQUANT=1
ENDIF
** if Quant != 0
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
** endif

 skip   
enddo
MaxLevel = MaxLevel - 1
RETURN 

*******************************************************
PROC formprimen
CLOSE TABLES 

*!*	wait wind nowa 'Формируем справочник применяемости деталей...'

@ 0,80 
@ 0,80 say 'Формируем справочник применяемости деталей...'
sele dist a1.codizd,a2.oboznizd,a1.coddet,a1.allquant ;
     from &ad_norm.outizd_p a1,&ad_norm.izdel a2 ;
     into dbf &ad_norm.prom ;
     where a1.codizd=a2.codizd and a1.allquant>0
inde on coddet+codizd tag detizd

creat table &ad_norm.det_primS (num_polz n(1,0),coddet c(11),primen memo)
** Надо в DOS варианте
COPY TO &ad_norm.det_prim TYPE FOX2X as 866
USE &ad_norm.det_prim
ERASE &ad_norm.det_primS.dbf
ERASE &ad_norm.det_primS.fpt

CLOSE TABLES
sele 1
use &ad_norm.prom orde detizd 
sele 2
use &ad_norm.det_prim 
sele 1
go top
scat memvar
m.primen=''
scan
   if !coddet=m.coddet
      sele 2
      appe blan
      @ 0,80
      @ 0,80 say 'Запись N '+str(recno(),6,0)
      repl coddet with m.coddet,primen with m.primen
      m.primen=''
   endif
   sele 1
   scat memvar
   m.primen=m.primen+' '+allt(oboznizd)+'/'+iif(int(allquant)=allquant,allt(str(allquant)),allt(str(allquant,5,2)))+';'
endscan
sele 2
@ 0,80 
@ 0,80 say 'Индексируем справочник применяемости деталей DET_PRIM.dbf'
inde on coddet tag coddet
CLOSE TABLES 

RETURN 
