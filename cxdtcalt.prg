** cxdtcalt
** ** 2026г Смирнова
** Идет формирование таблиц  - их в конце формирования надо сохранить в fox2x as 866 !
CLOSE TABLES
** Смирнова Н.А.
** 26.06.2017
** программа получения Цеховые детальные товарные калькуляции ПО НОВОМУ.  
*!*	1. В таблице  calc_all.dbf заполняем поле  zaxlist_t по cex_t
*!*	2. перебирая таблицу формируем calcallt.dbf по новому правилу для учета затрат нетоварных заходов в полях _DRUG товарных цехов
*!*	3. Из calcallt.dbf копированием определенных полей получаем calcdset.dbf 
TM0=seco()

WAIT 'Подготавливаем calc_all.dbf к формированию цех. кальк. по тов. маршруту' WINDOW NOWAIT NOCLEAR   
USE &ad_norm.cexlisti.dbf IN 0
SELECT cexlisti
ON ERROR inde on coddet+codizd+STR(zaxlist)+cex tag DTIZLSTALL
SET ORDER TO DTIZLSTALL
ON ERROR 
USE &ad_norm.calc_all.dbf IN 0
SELECT calc_all
ON ERROR inde on coddet+codizd+STR(zaxlist) tag DETIZLIST 
SET ORDER TO DETIZLIST 
ON ERROR 
SET RELATION TO coddet+codizd+STR(zaxlist)+cex INTO cexlisti
REPLACE cex_t WITH cexlisti.cex_t, nzax_t with cexlisti.nzax  FOR FOUND([cexlisti])
SET RELATION TO 
** не всем парам д=и есть соответствие с изделием, поэтому
sele cexlisti 
INDEX ON coddet+STR(zaxlist)+cex TAG detzax unique
SELECT calc_all
SET RELATION TO coddet+STR(zaxlist)+cex INTO cexlisti
REPLACE cex_t WITH cexlisti.cex_t, nzax_t with cexlisti.nzax  FOR FOUND([cexlisti]) and empty(calc_all.cex_t)
SET RELATION TO 
 
** 1.
GO top
m.codizd=' '
m.coddet=''
m.cex_t=' '
m.zaxlist_t=1

SCAN 
	** проверим что работаем с новой парой изд-дет
	**	IF calc_all.codizd<>m.codizd or calc_all.coddet<>m.coddet
	IF calc_all.codizd+calc_all.coddet<>m.codizd+m.coddet 
		REPLACE zaxlist_t WITH 1
	ELSE 
	** проверяем изменился ли цех товарный
		IF calc_all.cex_t<>m.cex_t 
		** если изменился увеличиваем счетчик
			REPLACE zaxlist_t WITH m.zaxlist_t+1
		ELSE
		** товарный заход остается тот же 
			REPLACE zaxlist_t WITH m.zaxlist_t
		ENDIF 
	ENDIF  
	SCATTER MEMVAR 
ENDSCAN
USE IN cexlisti
**2 .
WAIT WINDOW 'формирую цеховые калькуляции на ДСЕ по товарному маршруту' NOWAIT  

**создаем структуру таблицы цеховых калькуляций:     
creat table &ad_norm.calcalltS (codizd c(11),coddet c(11),quant n(7,2),cex c(3),;
	nzax c(2),zaxlist n(2,0),;
	trud_sob n(11,5),trud_vxod n(11,5),trud_drug n(11,5),;
	zarp_sob n(11,5),zarp_vxod n(11,5),zarp_drug n(11,5),;
	prem_sob n(11,5),prem_vxod n(11,5),prem_drug n(11,5),;
	mater_sob n(11,5),mater_vxod n(11,5),mater_drug n(11,5),;
	p_f_sob n(11,5),p_f_vxod n(11,5),p_f_drug n(11,5),;
	got_sob n(11,5),got_vxod n(11,5),got_drug n(11,5),;
	vspm_sob n(11,5),vspm_vxod n(11,5),vspm_drug n(11,5),;
	maxlevel n(2,0))

COPY TO &ad_norm.calcallt TYPE FOX2X as 866
    USE &ad_norm.calcallt
  ERASE &ad_norm.calcalltS.dbf

SELECT calc_all
GO top
m.codizd=''
m.coddet=' '
m.cex_t=''
Z_zaxlist_t=1
m.zaxlist=0
  	Z_trud_drug = 0
  	Z_zarp_drug = 0
  	Z_prem_drug = 0
  	Z_mater_drug = 0
  	Z_p_f_drug = 0
  	Z_got_drug = 0
  	Z_vspm_drug = 0

**   для сбора собственных затрат по нетоварным заходам,  (!empty(cex_t) and cex<>cex_t )
** (1,1) - '104',  (2,1)   - '125', (3,1)   - '???',
**
** 1 - cex_t, 2 -trud_sob, 3 - zarp_sob, 4 - prem_sob 
** 
DIMENSION n_tov(4,4)
STORE 0 TO n_tov
**
SCAN 
	** проверим что работаем с новой парой изд-дет
	IF calc_all.codizd<>m.codizd or calc_all.coddet<>m.coddet
	** надо проверить есть ли накопленные затраты других(т.е. была ли в обработке предыдущая деталь) , их надо записать до ввода новой записи, в текущую 
		IF m.codizd+m.coddet<>' '
		** только для первой пары еще нет накопленных затрат и записи в calcallt
		** здесь надо записать нетоварные заходы с накопленными собственными затратами
		
			SELECT calcallt
			for i=1 to 4
				if !empty(n_tov(i,1))
					APPEND BLANK
					repl codizd with m.codizd, coddet with m.coddet, ;
					cex with n_tov(i,1), quant with m.quant, ;
					nzax with '99', zaxlist WITH 99, maxlevel with m.maxlevel, ;
					trud_sob WITH n_tov(i,2), ;
					zarp_sob WITH n_tov(i,3), ;
					prem_sob WITH  n_tov(i,4),;
					trud_drug WITH Z_trud_drug, ;
					zarp_drug WITH Z_zarp_drug, ;
					prem_drug WITH Z_prem_drug, ;
					mater_drug WITH Z_mater_drug, ;
					p_f_drug WITH Z_p_f_drug, ;
					got_drug WITH Z_got_drug, ;
					vspm_drug WITH Z_vspm_drug
				endif
			endfor
			SELECT calc_all
		ENDIF 
		SELECT calc_all
		SCATTER MEMVAR 
		SELECT calcallt
		** обнулим для новой пары сбор нетоварных заходов собственных затрат
		STORE 0 TO n_tov
                **
		APPEND BLANK
		GATHER MEMVAR 
		REPLACE zaxlist WITH zaxlist_t , nzax with m.nzax_t

		** начинаем собирать затраты других для ниже лежащих записей (!! для изделий и узлов сразу есть затраты других!!!)
      		Z_trud_drug = trud_sob + trud_vxod+trud_drug
	      	Z_zarp_drug = zarp_sob + zarp_vxod+zarp_drug
	      	Z_prem_drug = prem_sob + prem_vxod+prem_drug
      		Z_mater_drug = mater_sob + mater_vxod+mater_drug
	      	Z_p_f_drug = p_f_sob + p_f_vxod+p_f_drug
	      	Z_got_drug = got_sob + got_vxod+got_drug
      		Z_vspm_drug = vspm_sob + vspm_vxod+vspm_drug
		** 08.10.18 обнулим все НЕ СОБСТВЕННЫЕ затраты 1 захода- 
		**их принесем в отдельном блоке 
		**или заполним труд, зарпл и прем других по нетоварному
		REPLACE trud_drug WITH 0, ;
			zarp_drug WITH 0, ;
			prem_drug WITH 0, ;
			mater_drug WITH 0, ;
			p_f_drug WITH 0, ;
			got_drug WITH 0, ;
			vspm_drug WITH 0, ;
                        trud_vxod WITH 0, ;
			zarp_vxod WITH 0, ;
			prem_vxod WITH 0, ;
			mater_vxod WITH 0, ;
			p_f_vxod WITH 0, ;
			got_vxod WITH 0, ;
			vspm_vxod WITH 0, ;
			mater_sob WITH 0, ;
			p_f_sob WITH 0, ;
			got_sob WITH 0, ;
			vspm_sob WITH 0
 
		** 08.10.18
	ELSE
		IF calc_all.zaxlist_t<>z_zaxlist_t 
			** если изменился товарный заход, делаем запись и вписываем накопленные величины для затрат других 
			SCATTER MEMVAR 
			SELECT calcallt
			APPEND BLANK
			GATHER MEMVAR 
			REPLACE zaxlist WITH zaxlist_t, nzax with m.nzax_t
		** других оставим как есть в calc_all?
		** записывать из накопленного относительно узлов - неправильно!!
			** записываем накопленные величины для затрат других 
		**	REPLACE trud_drug WITH Z_trud_drug, ;
		**			zarp_drug WITH Z_zarp_drug, ;
		**			prem_drug WITH Z_prem_drug, ;
		**			mater_drug WITH Z_mater_drug, ;
		**			p_f_drug WITH Z_p_f_drug, ;
		**			got_drug WITH Z_got_drug, ;
		**			vspm_drug WITH Z_vspm_drug
			
			** запоминаем текущие затраты для ниже лежащих записей в затраты других 
		      	Z_trud_drug = Z_trud_drug + m.trud_sob + m.trud_vxod
		      	Z_zarp_drug = Z_zarp_drug + m.zarp_sob + m.zarp_vxod
	      		Z_prem_drug = Z_prem_drug + m.prem_sob + m.prem_vxod
		      	Z_mater_drug = Z_mater_drug + m.mater_sob + m.mater_vxod
		      	Z_p_f_drug = Z_p_f_drug + m.p_f_sob + m.p_f_vxod
	      		Z_got_drug = Z_got_drug + m.got_sob + m.got_vxod
		      	Z_vspm_drug = Z_vspm_drug + m.vspm_sob + m.vspm_vxod
		ELSE
		** товарный заход остается тот же надо проверить цех товарный равен цеху обычному
			IF cex_t<>cex
				** внутри товарного встретили нетоварный цехозаход - 
				SCATTER MEMVAR 
				SELECT calcallt
				** то его затраты надо положить сразу в ДРУГИХ, не добавляя новой записи

				REPLACE trud_drug WITH trud_drug + M.trud_sob+M.trud_vxod, ;
					zarp_drug WITH zarp_drug + m.zarp_sob + m.zarp_vxod, ;
					prem_drug WITH prem_drug + m.prem_sob + m.prem_vxod, ;
				 	mater_drug WITH mater_drug + m.mater_sob + m.mater_vxod, ;
				  	p_f_drug WITH p_f_drug + m.p_f_sob + m.p_f_vxod, ;
				  	got_drug WITH got_drug + m.got_sob + m.got_vxod, ;
				  	vspm_drug WITH vspm_drug + m.vspm_sob + m.vspm_vxod
				
				** и запомнить в накопительных переменных других новое состояние других относительно этой точки
			      	Z_trud_drug = trud_drug + trud_sob + trud_vxod
			      	Z_zarp_drug = zarp_drug + zarp_sob + zarp_vxod
			      	Z_prem_drug = prem_drug + prem_sob + prem_vxod
		      		Z_mater_drug = mater_drug + mater_sob + mater_vxod
			      	Z_p_f_drug = p_f_drug + p_f_sob + p_f_vxod
			      	Z_got_drug = got_drug + got_sob + got_vxod
			      	Z_vspm_drug = vspm_drug + vspm_sob + vspm_vxod

                ** запомним нетоварный цех и увеличим значения накопленных собственных нетоварных затрат
				if m.cex='104'
					store m.cex to N_tov(1,1)
					store n_tov(1,2)+m.trud_sob to n_tov(1,2)
					store n_tov(1,3)+m.zarp_sob to n_tov(1,3)
					store n_tov(1,4)+m.prem_sob to n_tov(1,4)
				else
					if m.cex='125'
						store m.cex to N_tov(2,1)
						store n_tov(2,2)+m.trud_sob to n_tov(2,2)
						store n_tov(2,3)+m.zarp_sob to n_tov(2,3)
						store n_tov(2,4)+m.prem_sob to n_tov(2,4)

					else
						if !empty(N_tov(3,1)) or iif(empty(N_tov(3,1)),str(n_tov(3,1),3),n_tov(3,1))=(m.cex)
							store m.cex to N_tov(3,1)
							store n_tov(3,2)+m.trud_sob to n_tov(3,2)
							store n_tov(3,3)+m.zarp_sob to n_tov(3,3)
							store n_tov(3,4)+m.prem_sob to n_tov(3,4)
						else
							** эта ситуация не должна встречаться никогда!
							store m.cex to N_tov(4,1)
							store n_tov(4,2)+m.trud_sob to n_tov(4,2)
							store n_tov(4,3)+m.zarp_sob to n_tov(4,3)
							store n_tov(4,4)+m.prem_sob to n_tov(4,4)
						endif 
					endif
				endif

			ELSE
				** внутри товарного встретили  тот же товарный цехозаход - 
				** УВЕЛИЧИМ  ЗАТРАТЫ собственные ДЛЯ ТОВАРНОГО ЗАХОДА
				SCATTER MEMVAR 
				SELECT calcallt
				REPLACE trud_sob WITH trud_sob+M.trud_sob , ;
					trud_vxod WITH trud_vxod + M.trud_vxod, ;
					zarp_sob WITH zarp_sob+M.zarp_sob , ;
					zarp_vxod WITH zarp_vxod + M.zarp_vxod, ;
					prem_sob WITH prem_sob+M.prem_sob , ;
					prem_vxod WITH prem_vxod + M.prem_vxod, ;
					mater_sob WITH mater_sob+M.mater_sob , ;
					mater_vxod WITH mater_vxod + M.mater_vxod, ;
					p_f_sob WITH p_f_sob+M.p_f_sob , ;
					p_f_vxod WITH p_f_vxod + M.p_f_vxod, ;
					got_sob WITH got_sob+M.got_sob , ;
					got_vxod WITH got_vxod + M.got_vxod, ;
					vspm_sob WITH vspm_sob+M.vspm_sob , ;
					vspm_vxod WITH vspm_vxod + M.vspm_vxod
				** и запомнить в накопительных переменных затраты других для ниже лежащих записей  
				** иp текущей строки 
			      	Z_trud_drug = trud_drug + trud_sob + trud_vxod
			      	Z_zarp_drug = zarp_drug + zarp_sob + zarp_vxod
			      	Z_prem_drug = prem_drug + prem_sob + prem_vxod
		      		Z_mater_drug = mater_drug + mater_sob + mater_vxod
			      	Z_p_f_drug = p_f_drug + p_f_sob + p_f_vxod
			      	Z_got_drug = got_drug + got_sob + got_vxod
 			      	Z_vspm_drug = vspm_drug + vspm_sob + vspm_vxod

			ENDIF 
		ENDIF 
	ENDIF  
	SELECT calc_all
	SCATTER MEMVAR 
	z_zaxlist_t=m.zaxlist_t
ENDSCAN
USE IN calc_all
SELECT calcallt
copy to &ad_norm.calc_


************************** теперь надо принести ************************************************ 
**************************I.   материальные затраты на 1 товарные заходы  *****************************************
sele 2
use &ad_norm.norm_mat alia a2 orde detcex
SELECT calcallt
set rela to coddet+cex into a2
repl all mater_sob with a2.norma*a2.price for allt(nzax)=='1' and a2.typ='M'
repl all p_f_sob with a2.norma*a2.price for allt(nzax)=='1' and a2.typ='F'

** чтобы не привязываться к конкретному цеху-получателю ПКИ ;
	из-за возможных ошибок в нормативных картах, ;
	ПКИ привязываем к первому цеху по ВТМ...
set rela to coddet into a2

repl all got_sob with a2.norma*a2.price for zaxlist=1 and a2.typ='P'

sele 2
use c:\normativ\vspm_sum alia a2 orde detcex  && проверить формирование vspm_sum
SELECT calcallt
set rela to coddet+cex into a2
repl all vspm_sob with a2.sum_vspm for zaxlist=1 
set rela to

SELECT calcallt
wait nowa wind 'Индексирую таблицу цеховых калькуляций по товарным маршрутам...'
inde on cex+coddet+allt(nzax)+codizd tag cexdetzaxi
inde on cex+codizd+coddet+allt(nzax) tag cexizddtzx
inde on coddet+cex+allt(nzax)+codizd tag detcexzaxi
inde on codizd+cex+allt(nzax)+coddet tag izdcexzxdt
inde on CODDET+CODIZD+STR(ZAXLIST) tag detizlist
inde on codizd+coddet+cex+allt(nzax) tag izddtcexzx
inde on CODIZD+CODDET+STR(ZAXLIST) tag izddetlist
inde on coddet+cex+allt(nzax) tag detcexzx_u uniq


CLOSE TABLES  
************************* II.  затраты входящих и других по первому заходу узлов *****************************
*************************  пересобрать затраты других для всех кроме 1захода НЕ НАДО, 
*************************      т.к. их собирали сразу из calc_all !!!

 do f_rasschet

WAIT ' Готовим информацию товарных подетальных калькуляций (calcdset.dbf) ' WINDOW NOWAIT NOCLEAR 
********работа с полностью заполненной затратами таблицей ***************************************

** напрямую брать уникальные записи неправильно, т.к. из-за вариантов маршрута
** есть когда цех 104 становится товарным при сдаче на 850!! 
** - пара узел-деталь определяет набор цехозаходов!!!

** Товарные калькуляции. 
**Надо выбирать дсе с изделиями с мах заходом, 850 добавлять отдельно,если деталь встречается в россыпи и отдельно получать список дсе чисто с 850 
** 1  получим полный список изд-дет обходя нетоварные 99 зах
SELECT codizd,coddet,MAX(zaxlist),cex ;
 FROM &ad_norm.calcallt where zaxlist<>99 ;
 INTO dbf &ad_norm.sp ;
 GROUP BY coddet,codizd
** выберем из всех, где нет 850
SELECT dist codizd,coddet,cex ;
 FROM &ad_norm.sp ;
 INTO dbf &ad_norm.sp1  ;
 WHERE cex<>'850' and cex<>'840' ;
 GROUP BY coddet
INDEX ON coddet TAG coddet

** ниже к нему добавим записи чисто россыпи и сделаем выбор строк
** по этому списку ДСЕ sp1 возьмем для добавки записи с 850 из calcallt

SELECT dist c.* ;
from &ad_norm.calcallt c, &ad_norm.sp1 s ;
INTO dbf &ad_norm.sp1_850  ;
 WHERE c.coddet=s.coddet AND (c.cex='850' or c.cex='840') ;
 GROUP BY c.coddet,c.cex 

** 2 выберем пары изд-дет, у которых есть 850, проиндексируем по дсе ;
**  и выберем детали которых нет в sp1
SELECT dist codizd,coddet,cex,MAX(max_zaxlis) as mzaxl ;
 FROM &ad_norm.sp INTO dbf &ad_norm.sp2 ;
 WHERE cex='850' or cex='840' ;
 GROUP BY coddet,cex
INDEX ON coddet TAG coddet
SET RELATION TO coddet INTO sp1
COPY TO &ad_norm.sp2_ FOR !FOUND([sp1])
Sele sp1
Append from  &ad_norm.sp2_

SELECT dist c.* from &ad_norm.calcallt c, &ad_norm.sp1 s ;
 INTO dbf &ad_norm.sp1_ ;
 WHERE c.coddet+c.codizd=s.coddet+s.codizd 
Append from  &ad_norm.sp1_850
inde on coddet+cex+STR(zaxlist) TAG detcexzax
************************************************

SELECT dist c.* ;
from &ad_norm.calcallt c ;
INTO dbf &ad_norm.sp_all  ;
 GROUP BY c.coddet,c.cex,c.zaxlist 

SET RELATION TO coddet+cex+STR(zaxlist) into sp1_
COPY TO &ad_norm.sp3_ FOR !FOUND([sp1_]) and cex<>'104'
Sele sp1_
Append from  &ad_norm.sp3_

*******
INDEX ON coddet+STR(zaxlist) TAG detzax
** теперь отсюда выберем информацию для товарных калькуляций

******************************************************************************

copy to &ad_norm.calcdset FIELDS coddet,cex,nzax,zaxlist,;
	trud_sob,trud_vxod,trud_drug,;
	zarp_sob,zarp_vxod,zarp_drug,;
	prem_sob,prem_vxod,prem_drug,;
	mater_sob,mater_vxod,mater_drug,;
	p_f_sob,p_f_vxod,p_f_drug,;
	got_sob,got_vxod,got_drug,;
	vspm_sob,vspm_vxod,vspm_drug TYPE FOX2X as 866

USE &ad_norm.calcdset

INDEX ON CEX+CODDET+allt(NZAX) TAG CEXDETZAX
INDEX ON CODDET+STR(ZAXLIST) TAG DETLIST
INDEX ON CODDET+CEX+allt(NZAX) TAG DETCEXZAX

CLOSE TABLES 
if adir(dr,ad_normS,'d')>0		&& adir(dr,'y:\normativ','d')=1
	wait 'Обновляю в сети ... '+ad_normS WINDOW NOWAIT  
	USE &ad_norm.calc_all
	? '<11.5. Цеховые детальные товарные калькуляции> - В cети обновляем таблицу calc_all.dbf!'
	ON ERROR ? '<11.5. Цеховые детальные товарные калькуляции> - Проблема! В cети НЕ ОБНОВЛЕНА таблица calc_all.dbf!'
	copy to &ad_normS.calc_all with cdx TYPE FOX2X as 866
	ON ERROR 
	
	USE &ad_norm.calcallt
	? '<11.5. Цеховые детальные товарные калькуляции> - В cети обновляем таблицу calcallt.dbf!'
	ON ERROR ? '<11.5. Цеховые детальные товарные калькуляции> - Проблема! В cети НЕ ОБНОВЛЕНА таблица calcallt.dbf!'
	copy to &ad_normS.calcallt with cdx TYPE FOX2X as 866
	ON ERROR 

	USE &ad_norm.calcdset
	? '<11.5. Цеховые детальные товарные калькуляции> - В cети обновляем таблицу calcdset.dbf!'
	ON ERROR ? '<11.5. Цеховые детальные товарные калькуляции> - Проблема! В cети НЕ ОБНОВЛЕНА таблица calcdset.dbf!'
	copy to &ad_normS.calcdset with cdx TYPE FOX2X as 866
	ON ERROR 

	USE 
	WAIT 'Базы данных calc_all.dbf , calcallt.dbf , calcdset.dbf обновлены в сети!' WINDOW NOWAIT NOCLEAR &&  time 1
ELSE 
	wait 'Вы не подключены к сети! В cети НЕ ОБНОВЛЕНЫ таблицы calc_all.dbf , calcallt.dbf , calcdset.dbf ...' WINDOW NOWAIT NOCLEAR 	&&  time 1
	? '<11.5. Цеховые детальные товарные калькуляции> - В cети НЕ ОБНОВЛЕНЫ таблицы calc_all.dbf , calcallt.dbf , calcdset.dbf !'
ENDIF    

CLOSE TABLES  

RETURN 


***************************************************
***********************************************
*********** Расчет узловых затрат *************
***********************************************
proc f_rasschet
WAIT 'Считаю трудовые затраты 1захода по узлам...' WINDOW NOWAIT NOCLEAR 
***********************************************
** формируем вспомогательный файл последних заходов ДСЕ  
**при формировании последних заходов ДСЕ необходимо учитывать ;
	в какую сборку входит ДСЕ,...
** поэтому...
sele codizd,coddet,cex,nzax,max(zaxlist) as zaxlist_mx ;
	from &ad_norm.calcallt ;
	into dbf &ad_norm.posl_zax ;
	grou by codizd,coddet,cex
inde on codizd+coddet+cex+allt(nzax) tag idetcexzax

WAIT 'формирую перечень цеховых узлов и изделий:'  WINDOW NOWAIT NOCLEAR 
sele dist codizd,00 as maxlevel ;
	from &ad_norm.specific ;
	into dbf &ad_norm.uzel
inde on codizd tag codizd

CLOSE TABLES 

sele 1
use &ad_norm.calcallt alia a1 excl
sele 2
use &ad_norm.uzel alia a2 orde codizd
sele 1
inde on coddet+cex+allt(nzax) tag detcexzx_u uniq
set rela to coddet into a2

** формирую промежуточный файл узловых затрат UZL_ZATR
copy to &ad_norm.uzl_zatr for coddet=a2.codizd and zaxlist=1  
use &ad_norm.uzl_zatr
repl all codizd with coddet
inde on coddet+str(zaxlist) tag detlist

inde on coddet+cex+allt(nzax) tag detcexzax1 for zaxlist=1
inde on coddet+cex+allt(nzax) tag detcexzax

CLOSE TABLES 

*******************************************************************
sele 1
use &ad_norm.calcallt alia a1 orde detcexzaxi excl
sele 2
use &ad_norm.uzl_zatr alia a2 orde detcexzax1 excl

calc max(maxlevel) to MX

sele 3
use &ad_norm.posl_zax alia a3 orde idetcexzax excl

for i=1 to MX
   ** считаем затраты по узлу на 1-й заход в цех
   sele 2
   set orde to detcexzax1
   sele 1
   set rela to codizd+cex+'1' into a2,codizd+coddet+cex+allt(nzax) into a3
   WAIT 'Считаем затраты по узлу - Уровень вхождения - '+str(i,2,0) WINDOW NOWAIT NOCLEAR 
   
   repl all a2.trud_vxod with a2.trud_vxod+(trud_sob+trud_vxod)*quant,;
            a2.zarp_vxod with a2.zarp_vxod+(zarp_sob+zarp_vxod)*quant,;
            a2.prem_vxod with a2.prem_vxod+(prem_sob+prem_vxod)*quant,;
            a2.mater_vxod with a2.mater_vxod+(mater_sob+mater_vxod)*quant,;
            a2.p_f_vxod with a2.p_f_vxod+(p_f_sob+p_f_vxod)*quant,;
            a2.got_vxod with a2.got_vxod+(got_sob+got_vxod)*quant,;
            a2.vspm_vxod with a2.vspm_vxod+(vspm_sob+vspm_vxod)*quant,;
            a2.trud_drug with a2.trud_drug+trud_drug*quant,;
            a2.zarp_drug with a2.zarp_drug+zarp_drug*quant,;
            a2.prem_drug with a2.prem_drug+prem_drug*quant,;
            a2.mater_drug with a2.mater_drug+mater_drug*quant,;
            a2.p_f_drug with a2.p_f_drug+p_f_drug*quant,;
            a2.got_drug with a2.got_drug+got_drug*quant,;
            a2.vspm_drug with a2.vspm_drug+vspm_drug*quant ;
            for maxlevel=i and codizd=a2.coddet and found(3) ;
            and codizd!=coddet and allt(nzax)==allt(a3.nzax)
            
** 18/06/18 Смирнова. Добавлено условиу равенства NZAX в calc_all и posl_zax,
** т.к. есть детали со сложным маршрутом входящие в цех на 1,10,11 заходах.
** поэтому возьмем затраты из основной базы только с нужного захода ( and allt(nzax)==allt(a3.nzax) )
   **затраты на входящие ДСЕ считаем только на первый заход узла!!!
   
   set rela to
   
   ** считаем затраты узла по заходам
   sele 2
   set orde to detlist
   go top
   m.coddet=' '
   scan for maxlevel=i
      if coddet=m.coddet
         repl trud_drug with m.trud_sob+m.trud_vxod+m.trud_drug,;
              zarp_drug with m.zarp_sob+m.zarp_vxod+m.zarp_drug,;
              prem_drug with m.prem_sob+m.prem_vxod+m.prem_drug,;
              mater_drug with m.mater_sob+m.mater_vxod+m.mater_drug,;
              p_f_drug with m.p_f_sob+m.p_f_vxod+m.p_f_drug,;
              got_drug with m.got_sob+m.got_vxod+m.got_drug,;
              vspm_drug with m.vspm_sob+m.vspm_vxod+m.vspm_drug
      else      
         m.trud_drug=0
         m.zarp_drug=0
         m.prem_drug=0
         m.mater_drug=0
         m.p_f_drug=0
         m.got_drug=0
         m.vspm_drug=0
      endif
      scat memv
   endscan
   set orde to detcexzax
   
   ** записываем затраты на узел в основную таблицу CALCALLT
   sele 1
   set rela to coddet+cex+allt(nzax) into a2
	repl all trud_vxod with a2.trud_vxod,trud_drug with a2.trud_drug,;
		zarp_vxod with a2.zarp_vxod,zarp_drug with a2.zarp_drug,;
		prem_vxod with a2.prem_vxod,prem_drug with a2.prem_drug,;
		mater_vxod with a2.mater_vxod,mater_drug with a2.mater_drug,;
		p_f_vxod with a2.p_f_vxod,p_f_drug with a2.p_f_drug,;
		got_vxod with a2.got_vxod,got_drug with a2.got_drug,;
		vspm_vxod with a2.vspm_vxod,vspm_drug with a2.vspm_drug ;
	for coddet+cex+allt(nzax)=a2.coddet+a2.cex+allt(nzax) &&and a2.maxlevel=i 
   set rela to
endfor     

CLOSE TABLES 
RETURN 
