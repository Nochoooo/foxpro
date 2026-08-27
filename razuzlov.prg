** razuzlov.prg
** 2026г Смирнова
** надо сохранить в fox2x as 866 и проиндексировать!!
CLOSE TABLES
*!*	CLEAR 
WAIT 'Подождите, обновляю базs данных <6.1. Изделий (без 0-вой применяемости)>' WINDOW NOWAIT NOCLEAR 

** запомним активную строку экрана, чтобы на неё вернуться
akt_str=_PLINENO

**формируем структуру таблицы разузловки изделий:
creat table &ad_norm.outizdS (codizd c(11),coddet c(11),maxlevel n(2,0),;
	allquant n(10,3),quant_norm n(10,3),quant_m_k n(10,3),;
	quant_kvi n(10,3),quant_teh n(10,3),quant_exp n(10,3),quant_obr n(10,3))

** Надо в DOS варианте
COPY TO &ad_norm.outizd TYPE FOX2X as 866
USE &ad_norm.outizd
ERASE &ad_norm.outizdS.dbf

	**составляем перечень изделий - СЕ (сборочные единицы), не входящие в другие СЕ
		sele 1
		use &ad_norm.specific orde detizd
		sele 2
		use &ad_norm.izdel orde codizd
		
		sele dist codizd from &ad_norm.specific ;
		into dbf &ad_norm.prom
		
		set rela to codizd into specific,codizd into izdel
		copy to &ad_norm.dob_izd for !found(1) and !found(2)
		sele 2
		**appe from dob_izd &&- перечень СЕ, которых нет в таблице финальных изделий
	** ??? этот блок можно убить, т.к. всё это оказалось невостребованным далее  ???
CLOSE TABLES 

**разузловываем изделия
priv AllQuant,MaxLevel, shablon, svscr

@ 0,80
@ 0,80 say "Разузловка изделий..."
NewRec=0
sele 1 
use &ad_norm.SPECIFIC
set orde to CodIzd
sele 2
use &ad_norm.OutIzd				&& открыли пустую табл для заполнения
**zap
copy to &ad_norm.temp TYPE FOX2X as 866			&& получили пустую промеж таблицу нужной структуры, аналогичной OutIzd
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
	sele outizd
	append from &ad_norm.temp
	sele temp
	zap
	sele izdel
	** do scrlprocs
endscan

@ 0,80
@ 1,80

sele 4
set dele off
set filter to

@ 0,80
@ 0,80 say 'Считаю применяемость на КВИ, тех.нужды и образцы...'

sele dist codizd,coddet,quant_m_k,quant_kvi,quant_teh,quant_exp,quant_obr ;
          from &ad_norm.normmato into dbf &ad_norm.dop_prim ;
          where quant_kvi+quant_teh+quant_exp+quant_obr>0
inde on codizd+coddet tag izddet   

@ 0,80 
@ 0,80 say 'Формирую состав зап.частей...'
sele a1.codizd,a1.coddet,a1.quant as allquant,00 as maxlevel ;
     from &ad_norm.specific a1,&ad_norm.izdel a2 into dbf &ad_norm.sost_zch ;
     where a1.codizd=a2.codizd and uppe(left(allt(a2.podgrup),1))='Z'
kz_zch=_tally     
CLOSE TABLES 

@ 0,80 
erase temp.dbf
erase temp.cdx
sele 1
use &ad_norm.sost_zch
sele 2
use &ad_norm.outizd excl 
@ 0,80
@ 0,80 say 'Индексирую outizd...'
inde on codizd+coddet tag izddet   
inde on coddet+codizd tag detizd
@ 0,80
@ 0,80 say 'Добавляю состав зап.частей '+ALLTRIM(STR(kz_zch))+'зап.'
sele 1
set rela to coddet into outizd
repl all maxlevel with outizd.maxlevel
set rela to
sele 2		&& outizd
set orde to izddet
appe from &ad_norm.sost_zch
@ 0,80
@ 0,80 say 'Выбираю состав недостающих изделий из нормативных карт normmato ...'
sele 1
use &ad_norm.normmato 		&&   alia a1
on erro inde on codizd+coddet tag izddet
set orde to izddet
on erro
set rela to codizd into outizd
copy to &ad_norm.sost_dob for codizd!=outizd.codizd and coddet!=codizd TYPE FOX2X as 866
kz_dob=_tally
set rela to
@ 0,80
@ 0,80 say 'Добавляю состав недостающих изделий из нормативных карт '+ALLTRIM(STR(kz_dob))+'зап.'
sele 2			&& outizd
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
kz_err=_tally

@ 0,80
@ 0,80 say 'Добавляю применяемость на КВИ, тех.нужды и образцы...'

use &ad_norm.dop_prim  IN 0 orde izddet		&& alia a1 
sele 2		&& outizd
set rela to codizd+coddet into dop_prim
repl all quant_m_k with dop_prim.quant_m_k,quant_kvi with dop_prim.quant_kvi,;
         quant_teh with dop_prim.quant_teh,quant_obr with dop_prim.quant_obr,;
         quant_exp with dop_prim.quant_exp for codizd+coddet=dop_prim.codizd+dop_prim.coddet
CLOSE TABLES 
** erase out_prom.dbf
** erase out_prom.cdx

@ 0,80
@ 1,80
@ 0,80 say 'Формирую состав цеховых ДСЕ по изделиям...'

**составляем таблицу <prom> цехов-изготовителей изделий:
sele dist a1.codizd,a2.coddet,1 as allquant,a2.cex,;
	str(a2.zaxcex,1,0) as nzax,a2.zaxlist ;
	from &ad_norm.izdel a1,&ad_norm.cexlist1 a2 ;
	into dbf &ad_norm.prom ;
	where a1.codizd=a2.coddet

**формируем таблицу перечня цеховых ДСЕ по изделиям
sele dist a1.codizd,a2.codizd as coduzla,a2.coddet,a1.allquant,a2.cex,;
	str(a2.zaxcex,1,0) as nzax,a2.zaxlist ;
	from &ad_norm.outizd a1,&ad_norm.cexlist1 a2 ;
	into dbf &ad_norm.izddetcx ;
	where a1.coddet=a2.codizd ;
	grou by a1.codizd,a2.coddet,a2.cex,a2.zaxcex
	
appe from &ad_norm.prom
@ 0,80
@ 0,80 say 'Индексирую...'
inde on coddet+codizd+cex+nzax tag detizdcxzx
inde on codizd+coddet+cex+nzax tag izddetcxzx

** !!!!!!!!!!!!!!!!!!!
@ 0,80
@ 0,80 say 'Начинаем формировать разузлованный состав изделий с подборными ДСЕ...'
sele * from &ad_norm.outizd into dbf &ad_norm.outizd_aS
** Надо в DOS варианте
COPY TO &ad_norm.outizd_a TYPE FOX2X as 866
USE &ad_norm.outizd_a
ERASE &ad_norm.outizd_aS.dbf


@ 0,80
@ 0,80 say 'Индексирую outizd_a ...'
inde on coddet+codizd tag detizd
inde on codizd+coddet tag izddet
CLOSE TABLES

**!!!!!!!!!!!!!!!!!!!!!!!!!!! ПРИНЕСЕМ в это место формирование подборных по выгрузке из ORACLE!!
*** Ранее формировалось отдельным внешним модулем "norm"  Столяровой см присланный файл sm.prg  !!!!
***  в нём же было ОБОРУДОВАНИЕ , NORMA , NORMAD и PODBOR  ,PODBORuz 
*** перенесем оттуда сюда нужный блок c PODBOR . в п.6.3 блок с PODBORuz
WAIT 'Подождите, обновляю базу данных ПОДБОР - PODBOR.dbf ' WINDOW NOWAIT NOCLEAR 
*************!!!!!!!!!!!!!!!!!!*************************************
*** т.к. из текстового файла при зачитывании полей ЧИСЛОВЫХ в VF7 могут теряться значения,
**  то сначала создадим таблицу со структурой, где ВСЕ поля СИМВОЛЬНЫЕ.
** получим в неё данные из файла DAT, а затем их загрузим в правильную таблицу!!!
creat table &ad_norm.PODBORS (coddet_osn C(11),coddet C(11), prizn c(1),codizd C(11),allquant c(10))

appe from &ad_vig.PODBOR.dat type sdf  as 866
USE 		&& эту таблицу PODBORS не убиваем, она нужна в п.6.3 !!!
*********!!!!!!!!!!!!!!!!************************************************************

USE &ad_norm.PODBOR
zap
** где будет и какой формат??
** пока как раньше - Но учтем кодировку 866 !!
appe from &ad_norm.PODBORS		&&*********!!!!!эту таблицу PODBORS не убиваем, она нужна в п.6.3 !!!!!!!!!
USE

select  DISTINCT C.CODIZD ;
  from &ad_norm.CEXLIST C ;
  where C.NMARSH=1 AND C.QUANT=0 ;
  INTO  dbf &ad_norm.podbor2
** это список сборок завода !!!
CLOSE TABLES 

select  DISTINCT C.CODIZD,C.CODDET ;
  from &ad_norm.CEXLIST C,&ad_norm.PODBOR2 P ;
  where P.CODIZD=C.CODDET  ;
  INTo dbf &ad_norm.podbor3
 ** эта таблица нужна в п. 6.3 !!
 ** это список внутренних узлов, входящих в др. сборки (в т.ч. в изделия)  (уз - уз)
CLOSE TABLES 

select distinct p.coddet_osn ,P.coddet,p.prizn, O.CODIZD,o.allquant ;
 from &ad_norm.OUTIZD o,&ad_norm.podbor p,&ad_norm.PODBOR3 D ;
 where o.coddet =p.coddet_osn ;  
  AND O.CODIZD =D.CODIZD ;
 INTo dbf &ad_norm.podbor1
	
INDEX ON CODIZD+coddet_OSN tag coddet_OSN
INDEX ON CODIZD+ CODDET FOR coddet_osn!= coddet TAG CODIZD 

CLOSE TABLES

 SELE 1
 USE &ad_norm.PODBOR1 ALIAS A1 ORDE CODIZD
 SELE 2
 USE &ad_norm.OUTIZD ORDE IZDDET
 SELE 1
 SET RELA TO CODIZD+CODDET INTO OUTIZD
 dele all for found(2)
 pack
 CLOSE TABLES 

 sele CODIZD,coddet_osn ,count(*) as kol ;
  from &ad_norm.podbor1;
  into dbf &ad_norm.pom_podb group by CODIZD,coddet_osn
** для расчета применяемости подборных в изделии	
INDEX ON CODIZD+coddet_osn  tag coddet_osn
CLOSE TABLES 

sele 2
use &ad_norm.pom_podb alias a2 orde coddet_osn 
sele 1
use &ad_norm.podbor1 alias a1 orde coddet_osn
sele 1
 set rela to CODIZD+coddet_osn into a2
          
 REPL all a1.allquant with a1.allquant/a2.kol

CLOSE TABLES 
ERASE &ad_norm.podbor.dbf
ERASE &ad_norm.podbor.cdx
ERASE &ad_norm.podbor2.dbf
ERASE &ad_norm.podbor1.cdx

USE &ad_norm.podbor1
COPY TO &ad_norm.podbor TYPE FOX2X as 866

use &ad_norm.podbor
INDEX ON coddet_OSN tag coddet_OSN
INDEX ON codizd+coddet_osn tag izddet_osn
INDEX ON codizd+coddet_OSN+coddet tag izdosndet
inde on coddet_osn+codizd+coddet tag detosnizd
inde on coddet+codizd tag detizd

ERASE &ad_norm.podbor1.dbf

CLOSE TABLES  
** осталось выложить podbor в сеть!!

@ 0,80
@ 0,80 say 'Принесем из подбора (podbor.dbf) информацию в outizd_a ...'
**@ 1,80 say ' !!! используется таблица PODBOR.dbf из программы - NORMA !!! ' color w+/n*
sele 2
use &ad_norm.podbor 
on erro inde on coddet_osn+codizd+coddet tag detosnizd
set orde to detosnizd
on erro inde on coddet+codizd tag detizd
set orde to detizd
on erro

  *** 26032014 Смирнова Н.А. (если у подборного узла(знач в coddet!) нет значения в maxlevel,
  ***  то ошибка в расчетах ООТиЗ )
  *** сначала до удаления первичных данных из outizd_a сохраним сведения о maxlevel
  *** в выборке подборных по основной детали
sele 2		&&	  podbor
copy to &ad_norm.dob_pdb1 for uppe(prizn)='P' TYPE FOX2X as 866 
sele 1
use &ad_norm.outizd_a orde detizd

sele coddet_osn,coddet,codizd,allquant,prizn,00 as maxlevel ;
    from &ad_norm.dob_pdb1 ;
    into dbf &ad_norm.dob_podb

sele dob_podb
  *** по основной детали в полученной выборке поле maxlevel
  *** теперь заполним значением из outizd_a.maxlevel 
set rela to coddet_osn+codizd into outizd_a
repl maxlevel with outizd_a.maxlevel for coddet_osn+codizd=outizd_a.coddet+outizd_a.codizd
set rela to
  *** теперь удалим из outizd_a те записи, что принесем из подбора
  ***26032014

sele 1		&& outizd_a
set rela to coddet+codizd into podbor
dele all for found(2) and uppe(podbor.prizn)='P'
pack
appe from &ad_norm.dob_podb
set rela to
CLOSE TABLES
@ 0,80
@ 1,80
erase prom.dbf

** вернемся на активную строку, чтобы продолжить вывод
** ON ERROR CLEAR 
@ akt_str,110 say SPACE(10)
** ON ERROR


if  adir(dr,ad_normS,'d')>0		&& adir(dr,'y:\normativ','d')=1
	wait 'Обновляю OUTIZD.dbf в сети ... '+ad_normS WINDOW NOWAIT  
	USE &ad_norm.OUTIZD
	? '<6.1. Изделий (без 0-вой применяемости)> - В cети обновляем таблицу OUTIZD.dbf!'
	ON ERROR ? '<6.1. Изделий (без 0-вой применяемости)> - Проблема! В cети НЕ ОБНОВЛЕНА таблица OUTIZD.dbf!'
	copy to &ad_normS.OUTIZD with cdx TYPE FOX2X as 866
	ON ERROR 
	IF kz_err>0
		? '    В Н И М А Н И Е    А Д М И Н И С Т Р А Т О Р !!!    '
		? 'Получена таблица несоответствия применяемости по разузловке '
		? 'в OUTIZD (allquant) и применяемости (quant_norm) , '
		? 'полученной из нормативных карт normmato.dbf .'
		? 'Отправьте таблицу <err_prim.dbf> в ОГТ для анализа! '
	ENDIF 
	
	wait 'Обновляю PODBOR.dbf в сети ... '+ad_normS WINDOW NOWAIT  
	USE &ad_norm.PODBOR
	? '<6.1. Изделий (без 0-вой применяемости)> - В cети обновляем таблицу PODBOR.dbf !'
	ON ERROR ? '<6.1. Изделий (без 0-вой применяемости)> - Проблема! В cети НЕ ОБНОВЛЕНА таблица PODBOR.dbf !'
	copy to &ad_normS.PODBOR with cdx TYPE FOX2X as 866
	ON ERROR 

	wait 'Обновляю OUTIZD_A.dbf в сети ... '+ad_normS WINDOW NOWAIT  
	USE &ad_norm.OUTIZD_A
	? '<6.1. Изделий (без 0-вой применяемости)> - В cети обновляем таблицу OUTIZD_A.dbf (с подборными) !'
	ON ERROR ? '<6.1. Изделий (без 0-вой применяемости)> - Проблема! В cети НЕ ОБНОВЛЕНА таблица OUTIZD_A.dbf (с подборными) !'
	copy to &ad_normS.OUTIZD_A with cdx TYPE FOX2X as 866
	ON ERROR 
	USE 
	WAIT 'Базы данных OUTIZD.dbf , PODBOR.dbf , OUTIZD_A.dbf обновлены в сети!' WINDOW NOWAIT NOCLEAR &&  time 1
ELSE 
	wait 'Вы не подключены к сети! В cети НЕ ОБНОВЛЕНЫ таблицы OUTIZD.dbf ,PODBOR.dbf , OUTIZD_A.dbf ...' WINDOW NOWAIT NOCLEAR 	&&  time 1
	? '<6.1. Изделий (без 0-вой применяемости)> - В cети НЕ ОБНОВЛЕНЫ таблицы OUTIZD.dbf ,PODBOR.dbf , OUTIZD_A.dbf !'
endif   

*****************
**До запуска след пункта висит сообщение о результате обновления по текущему пункту!
RETURN 

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

******************************************
proc scrlprocs
******** отражение хода процесса
para przt
priv sscroll
counter=counter+1
sscroll=''
sscroll=padr(padr(sscroll,round(counter/allcount*50,0),'-'),50,' ')
wait sscroll window nowait
RETURN 



