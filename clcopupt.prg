** clcopupt.prg
** 2026г Смирнова
** Выгруженный файл надо сохранить в fox2x as 866 и проиндексировать!!
CLOSE TABLES
*!*	CLEAR 
WAIT 'Подождите, обновляю базу данных <9.4. Формирование SPCHAR_D' WINDOW NOWAIT NOCLEAR 
*************************************************************************
**** Формирование пооперационных калькуляций по товарным цехозаходам ****
********************** Формирование SPCHAR_D ****************************
*************************************************************************
** последнее изменение было 27.12.12
** запомним активную строку экрана, чтобы на неё вернуться
akt_str=_PLINENO

if adir(k,'&ad_norm.temp','d')=0
	! md &ad_norm.temp
endif
set defa to &ad_norm.temp
*!*	set path to c:\normativ;c:\normativ\oper

TM0=seco()

** последнее изменение 27.12.12
do calcopdt.prg		&& формирование calcoper и calcopal  - их в конце выкладываем в сеь!!!
 
*!*	Вызывается отдельный модуль calcopdt.prg , где формируем spr_sbor
*!*	do f_sprsbor	&&	формирование справочника сборочных единиц
*!*	30.07.2026 ** зачем??? его уже сформировали в do calcopdt

do f_cxtopcal	&&	формирование clcopupt - структуры БД цеховых операционных калькуляций ;
					на ДСЕ с перенумерованием уровней входимости и ;
					выставлением сквозных номеров операций  -- clcopupt в сеть НАДО выкладывть в сеть !!

do f_calcvxod	&& 	из clcopupt формирование clc_vxod БД затрат последних операций последних по маршруту ДСЕ ;
					для включения этих затрат в первые операции сборок, ;
					в которые входят данные ДСЕ в качестве входящих затрат

do r_calcvxod	&& 	окончательный расчет затрат на сборки (в clcopupt по clc_vxod );
					с учетом затрат на входящих в них ДСЕ

do r_sumzatr	&& 	расчет суммарных цеховых трудозатрат на ДСЕ (в clcopupt)

do f_cxdettov	&&  формирование БД цеховых детальных товарных трудозатрат (SPCHAR_D)
*!*					из clcopupt  -- spcharpu
*!*					из calcoper  -- spcharpd
*!*					Но SPCHAR_D заполняем по spcharpu

CLOSE TABLES

do spchar_u	&&  формирование БД цеховых участковых детальных товарных трудозатрат (SPCHARUC и дорабатываем SPCHAR_D)
			*!*	Сформированы SPCHARUS.dbf (поучастк.) и SPCHAR_D.dbf (цех.) труд. 
			*!*		их выкладываем в сеть!!  
			*!*	!!!	надо добавить calcopal , calcoper , clcopupt , clcopupa !!!
				

WAIT 'Длительность расчета '+allt(str((seco()-TM0)/60,10,1))+'  мин.' WINDOW NOWAIT NOCLEAR   && time 2 

set defa to &ad_norm.
*******************************************************
CLOSE TABLES
@ akt_str,110 say SPACE(10)

if  adir(dr,ad_normS,'d')>0		&& adir(dr,'y:\normativ','d')=1
	wait 'Обновляю spcharuc.dbf в сети ... '+ad_normS WINDOW NOWAIT NOCLEAR  
	USE &ad_norm.temp\spcharuc
	? '<9.4. Формирование SPCHAR_D> - В cети обновляем таблицу spcharuc.dbf !'
	ON ERROR ? '<9.4. Формирование SPCHAR_D> - Проблема! В cети НЕ ОБНОВЛЕНА таблица spcharuc.dbf!'
		copy to &ad_normS.spcharuc with cdx TYPE FOX2X as 866
	ON ERROR 
	
	USE &ad_norm.temp\spchar_d
	? '<9.4. Формирование SPCHAR_D> - В cети обновляем таблицу spchar_d.dbf !'
	ON ERROR ? '<9.4. Формирование SPCHAR_D> - Проблема! В cети НЕ ОБНОВЛЕНА таблица spchar_d.dbf!'
		copy to &ad_normS.spchar_d with cdx TYPE FOX2X as 866
	ON ERROR 
	
	USE &ad_norm.calcopal
	? '<9.4. Формирование SPCHAR_D> - В cети обновляем таблицу calcopal.dbf !'
	ON ERROR ? '<9.4. Формирование SPCHAR_D> - Проблема! В cети НЕ ОБНОВЛЕНА таблица calcopal.dbf!'
		copy to &ad_normS.calcopal with cdx TYPE FOX2X as 866
	ON ERROR 
	
	USE &ad_norm.calcoper
	? '<9.4. Формирование SPCHAR_D> - В cети обновляем таблицу calcoper.dbf !'
	ON ERROR ? '<9.4. Формирование SPCHAR_D> - Проблема! В cети НЕ ОБНОВЛЕНА таблица calcoper.dbf!'
		copy to &ad_normS.calcoper with cdx TYPE FOX2X as 866
	ON ERROR 

	USE &ad_norm.temp\clcopupt
	? '<9.4. Формирование SPCHAR_D> - В cети обновляем таблицу clcopupt.dbf !'
	ON ERROR ? '<9.4. Формирование SPCHAR_D> - Проблема! В cети НЕ ОБНОВЛЕНА таблица clcopupt.dbf!'
		copy to &ad_normS.clcopupt with cdx TYPE FOX2X as 866
	ON ERROR 
	USE 
	
	WAIT 'Базы данных spcharuc.dbf , spchar_d.dbf , calcopal.dbf , calcoper.dbf , clcopupt.dbf обновлены в сети!' WINDOW NOWAIT NOCLEAR 
ELSE 
	wait 'Вы не подключены к сети! В cети НЕ ОБНОВЛЕНЫ таблицы '+CHR(13)+;
			'spcharuc.dbf , spchar_d.dbf , calcopal.dbf , calcoper.dbf , clcopupt.dbf ...' WINDOW NOWAIT NOCLEAR 	&&  time 1
	? '<9.4. Формирование SPCHAR_D> - В cети НЕ ОБНОВЛЕНЫ таблицы spcharuc.dbf , spchar_d.dbf , calcopal.dbf , calcoper.dbf , clcopupt.dbf  !'
ENDIF 

**До запуска след пункта висит сообщение о результате обновления по текущему пункту!
CLOSE TABLES

RETURN 

*******************************************************
******* формирование цеховых калькуляций на ДСЕ *******
*******************************************************
proc f_cxtopcal
CLOSE TABLES
WAIT 'шаг 1. Формирую цеховые операционные калькуляции на ДСЕ'+chr(13)+;
	'по товарным цехозаходам по составам сборок по УПТ' WINDOW NOWAIT NOCLEAR 

@ 0,80
@ 0,80 say 'Создаем дополнительный перечень цеховых ДСЕ,;
 которых нет в БД <OPERTRUD> (ПКИ)'
sele 2
use &ad_norm.oper\opertrud alia a2
on erro inde on b3+b1+allt(nzax)+str(val(n_oper)) tag detcxzxopt
set orde to detcxzxopt
on erro
sele 1
use &ad_norm.cexlist1 alia a1
set rela to coddet+cex+allt(nzax) into a2
copy to &ad_norm.temp\dob_sostu for !found(2) TYPE FOX2X as 866	&& дополнительный перечень цеховых ДСЕ, которых нет в БД <OPERTRUD>

CLOSE TABLES 

** <cexlist1> - по товарному маршруту
** <cexlist0> - по полному маршруту
**  В данном случае собираем затраты только УПТ (t2) по ТОВАРНОМУ маршруту!!!
** 24.12.2024 Смирнова для сравнения заходов поставлено == точное равенство
@ 0,80
@ 0,80 say 'Собираем из БД <OPERTRUD> затраты УПТ (t2) по ТОВАРНОМУ маршруту в sostclopu'

sele dist a1.codizd,a1.coddet,a1.quant,a1.zaxlist,a1.cex,a1.nzax, ;
		a1.cex_post,a1.cex_poluch,a2.n_oper,a2.npp_oper, a2.uch ,a2.grup, ;
		a2.t2/a2.vich as trud,a2.r2/a2.vich as zarp ;
	from &ad_norm.cexlist1 a1, &ad_norm.oper\opertrud a2 ;
	into dbf &ad_norm.temp\sostclopu ;
	where a1.coddet=a2.b3 and a1.cex=a2.b1 and ;
			 alltrim(a2.nzax)==alltrim(str(a1.zaxcex)) ;
	group by a1.codizd,a1.coddet,a1.cex,a1.nzax,a2.npp_oper
	
*** одним словом работает некорректно!!!
**	where a1.cex+a1.coddet+allt(a1.nzax)=a2.b1+a2.b3+allt(a2.nzax) ;
**	grou by a1.codizd,a1.coddet,a1.cex,a1.nzax,a2.n_oper,a2.npp_oper,a2.uch
**22/01/2013  a1.nzax ,a2.npp_oper
**	grou by a1.codizd,a1.coddet,a1.cex,a1.zaxlist,a2.n_oper,a2.uch

@ 0,80
@ 0,80 say 'создаем структуру таблицы цеховых операционных калькуляций clcopupt.dbf ...'     
** 22/01/2013 дополняем структуру новыми полями о процентах премии - prem_proc, размере премии - prem, собственные затраты на премию - prem_sob,;
** затраты других цехов на премию - prem_drug,затрату на премию ДСЕ, входящих в сборку - prem_vxod,; 
** prem_sum n(11,5),prem_cex n(11,5)
*** хотя она и не нужна в SPChAR_D !!!!

creat table &ad_norm.temp\clcopuptS ;
	(codizd c(11),cex_sbor c(3),coddet c(11),quant n(7,2),maxlevel n(2,0),;
	cex c(3),zaxlist n(2,0),nzax c(2),n_oper c(8),npp_oper n(5,0),;
	posl_oper n(5,0),uch c(2),grup c(2),;
	trud n(11,5),trud_sob n(11,5),trud_drug n(11,5),trud_vxod n(11,5),;
	trud_sum n(11,5),trud_cex n(11,5),;
	zarp n(11,5),zarp_sob n(11,5),zarp_drug n(11,5),zarp_vxod n(11,5),;
	zarp_sum n(11,5),zarp_cex n(11,5),;
	prem_proc n(5,1),prem n(11,5),prem_sob n(11,5),prem_drug n(11,5),prem_vxod n(11,5),;
	prem_sum n(11,5),prem_cex n(11,5),;
	mater_sob n(11,5),mater_vxod n(11,5),mater_drug n(11,5),;
	p_f_sob n(11,5),p_f_vxod n(11,5),p_f_drug n(11,5),;
	got_sob n(11,5),got_vxod n(11,5),got_drug n(11,5),;
	vspm_sob n(11,5),vspm_vxod n(11,5),vspm_drug n(11,5))

COPY TO &ad_norm.temp\clcopupt TYPE FOX2X as 866
USE &ad_norm.temp\clcopupt
  ERASE &ad_norm.temp\clcopuptS.dbf

appe from &ad_norm.temp\sostclopu
appe from &ad_norm.temp\dob_sostu

sele 0	&&5
use &ad_norm.norm_mat alia a5 orde coddet
sele 0 	&&5
use &ad_norm.izdel alia a4 orde codizd
sele 0	 &&3
use &ad_norm.temp\spr_sbor alia a3 orde coduzla			&& его получили выполняя calcopdt.prg	 

sele clcopupt
**удаляем данные по сборкам, входящих сами в себя, кроме изделий
set rela to codizd into a4
dele all for coddet=codizd and !found(4)
pack

inde on coddet+codizd+str(zaxlist)+str(val(n_oper)) tag detizlstop
inde on codizd+coddet+cex+allt(nzax)+str(val(n_oper)) tag izddtcxzxt
inde on codizd+coddet+str(zaxlist)+str(val(n_oper)) tag izddtlstop

set rela to codizd into a3			&& a3  -- spr_sbor
repl all cex_sbor with a3.cex
**set rela to coddet into a3
set rela to codizd into a3
repl all maxlevel with a3.maxlevel

** удаляем состав сборочных единиц с 0-ым уровнем входимости, ;
	не вошедших в сформированный справочник сборочных единиц SPR_SBOR, ;
	т.к. они не входят ни в одно финальное изделие ;
	или их нет в цех-списках
dele all for maxlevel=0
pack

@ 0,80
@ 0,80 say 'В clcopupt ставим сквозные номера операций по всем деталям'

go top
**m.codizd=' '
**m.coddet=' '
scat memv
m.npp_oper=0  && для старта в 1 записи базы

scan
	if codizd+coddet=m.codizd+m.coddet
		repl npp_oper with m.npp_oper+1
	else
		repl npp_oper with 1
		** ставим посление сквозные номера операций
		skip -1
		repl posl_oper with m.npp_oper
		skip
	endif
	scat memv
endscan

@ 0,80

inde on coddet+codizd+str(npp_oper) tag detizdnpp
inde on codizd+coddet+str(npp_oper) tag izddetnpp
inde on str(maxlevel)+codizd+coddet+str(npp_oper) tag levizdtnpp

** переводим финальные изделия, которые в clcopupt входят сами в себя, ;
	в состав одного общего изделия с кодом "99999999999", ;
	вводим им 0-вой уровень входимости, и пересчитываем все уровни ;
	входимости начиная с 1-го (вместо 0-го) и, соответственно, ;
	увеличивая все последующие уровни на 1

repl all codizd with '99999999999', maxlevel with 0, quant with 1 ;
	for codizd=coddet
	
repl all maxlevel with maxlevel+1

@ 0,80
@ 0,80 say 'В clcopupt записываем материальные затраты на первую по порядку операцию ДСЕ'
** записываем материальные затраты на первую по порядку операцию ДСЕ
Set relation to coddet into a5		&&   for npp_oper=1		 a5  -- norm_mat
Repl all mater_sob with iif(a5.typ='M',a5.norma*a5.price,0),;
	p_f_sob with iif(a5.typ='F',a5.norma*a5.price,0),;
	got_sob with iif(a5.typ='P',a5.norma*a5.price,0),;
	vspm_sob with iif(a5.typ='V',a5.norma*a5.price,0) ;
	for npp_oper=1

@ 0,80
CLOSE TABLES 
wait clear

RETURN

***************************************************************************
******* формирование БД цеховых калькуляций последних операций ДСЕ ********
***************************************************************************
proc f_calcvxod		&& создаем БД калькуляций на сборки...

WAIT 'шаг 2. Формируем БД затрат последних операций по маршруту по ДСЕ'+chr(13)+;
	'для включения этих затрат в первые операции сборок, '+chr(13)+;
	'в которые входят данные ДСЕ в качестве входящих затрат (clc_vxod)' WINDOW NOWAIT NOCLEAR 

use &ad_norm.temp\clcopupt
copy to &ad_norm.temp\clc_vxodu for posl_oper!=0 TYPE FOX2X as 866
use &ad_norm.temp\clc_vxodu
inde on coddet+codizd tag detizd
inde on codizd+coddet tag izddet

CLOSE TABLES 
retu

***************************************************************************
******* расчет затрат входящих в сборки ДСЕ (окончательный расчет) ********
***************************************************************************
proc r_calcvxod		&& расчет затрат входящих в сборки ДСЕ

wait clear

WAIT 'шаг 3. Считаем затраты входящих в сборки ДСЕ в clcopupt' WINDOW NOWAIT NOCLEAR  

sele 2
use &ad_norm.temp\clc_vxodu alia a2 orde izddet	&& затраты на ДСЕ по последней операцией ;
									последнего захода перед передачей ;
									ее на сборку
**определяем максимальный уровень входимости сборки (первичные сборки):
**calc max(maxlevel) to MX
**calc min(maxlevel) to MN
sele max(maxlevel) from &ad_norm.temp\clcopupt into arra MX
sele min(maxlevel) from &ad_norm.temp\clcopupt into arra MN
i=MX

** ПРИМЕЧАНИЕ:
**	1. Эти затраты необходимо перенести на первую операцию первого захода ;
	сборки, куда входит конкретная ДСЕ, причем, если цех-сборщик узла ;
	и цех-изготовитель входящей ДСЕ один и тот же, то trud_vxod ДСЕ ;
	и trud_sob прибавляется к trud_vxod сборки, а если нет, ;
	то trud_vxod и trud_sob ДСЕ прибавляется к trud_drug сборки, ;
	но это уже предусмотрено, при расчете пооперационной трудоемкости других цехов ;
	в соответствующем модуле f_opertrud ;
	2. trud_drug и в первом, и во втором случае прибавляется к ;
	trud_drug сборки;
	3. далее расчет затрат на сборку по порядку следования операций ;
	идет обычным способом: на каждой операции к суммарной собственной ;
	трудоемкости trud_sob прибавляется трудоемкость предыдущей операции ;
	данного захода в цех trud, если это первая операция на данном заходе,;
	то trud_sbor=trud, если это последняя операция на заходе, то trud_sob ;
	равна сумме всех операций на данном заходе. ;
	4. Если происходит передача изготовления ДСЕ в другой цех, ;
	то в этом случае суммарная собственна трудоемкость trud_sob ;
	с последней операции цеха-поставщика переходит в трудоемкость других ;
	цехов trud_drug цеха-изготовителя. Примечание: ;
					на всех операциях первого захода первого по маршруту ;
					цеха-изготовителя trud_drug=0 
**	ЗАМЕЧАНИЕ: ;
	перед расчетом необходимо выверить все БД, частности, ;
	чтобы цех-изготовитель ДСЕ, входящий в сборку по последнему порядковому ;
	номеру захода по цех-списку был один и тотже, что и цех-сборщик узла, ;
	куда входит конкретная ДСЕ, ;
	Тогда вся трудоемкость других цехов trud_drug этой ДСЕ должна ;
	прибавляться к трудоемкости trud_drug самого узла

sele 1
use &ad_norm.temp\clcopupt alia a1
on erro inde on coddet+str(npp_oper)+codizd tag detnppizd
set orde to detnppizd
on erro inde on coddet+codizd+str(npp_oper) tag detizdnpp
set orde to detizdnpp
on erro inde on coddet+codizd+str(zaxlist)+str(val(n_oper)) tag detizlstop
set orde to detizlstop
on erro inde on codizd+coddet+str(npp_oper) tag izddetnpp
set orde to izddetnpp
on erro

for i=MX to MN step -1
	WAIT 'шаг 3. Считаем затраты входящих в сборки ДСЕ в clcopupt'+CHR(13)+ ;
		' уровень входимости в сборки -'+ALLTRIM(str(i)) WINDOW NOWAIT NOCLEAR  

	calcsbor='&ad_norm.temp\clcsb_'+allt(str(i))
	sost_sbor='&ad_norm.temp\sostsb'+allt(str(i))
** 1 шаг.
**	считаем суммарные собственные затраты и затраты других цехов
	sele 1
	set orde to izddetnpp

	m.coddet=' '
	m.codizd=' '
	m.cex=' '
	go top
	
	scan for maxlevel=i
		if coddet+codizd=m.coddet+m.codizd
			if cex=m.cex
				repl trud_sob with trud+m.trud_sob,;
					trud_drug with m.trud_drug,;
					trud_vxod with m.trud_vxod,;
					zarp_sob with zarp+m.zarp_sob,;
					zarp_drug with m.zarp_drug,;
					zarp_vxod with m.zarp_vxod,;
					mater_sob with m.mater_sob,;
					mater_vxod with m.mater_vxod,;
					mater_drug with m.mater_drug,;
					p_f_sob with m.p_f_sob,;
					p_f_vxod with m.p_f_vxod,;
					p_f_drug with m.p_f_drug,;
					got_sob with m.got_sob,;
					got_vxod with m.got_vxod,;
					got_drug with m.got_drug,;
					vspm_sob with m.vspm_sob,;
					vspm_vxod with m.vspm_vxod,;
					vspm_drug with m.vspm_drug
			else
** собственные материальные затраты при передаче ДСЕ в другой цех ;
	должны обнуляться
				repl trud_vxod with 0,trud_sob with trud,trud_drug with m.trud_drug+m.trud_sob+m.trud_vxod,;
					zarp_vxod with 0,zarp_sob with zarp,zarp_drug with m.zarp_drug+m.zarp_sob+m.zarp_vxod,;
					mater_vxod with 0,mater_sob with 0,mater_drug with m.mater_drug+m.mater_sob+m.mater_vxod,;
					p_f_vxod with 0,p_f_sob with 0,p_f_drug with m.p_f_drug+m.p_f_sob+m.p_f_vxod,;
					got_vxod with 0,got_sob with 0,got_drug with m.got_drug+m.got_sob+m.got_vxod,;
					vspm_vxod with 0,vspm_sob with 0,vspm_drug with m.vspm_drug+m.vspm_sob+m.vspm_vxod
			endif
		else
			repl trud_sob with trud,zarp_sob with zarp
		endif
		scat memv
	endscan

** 2 шаг.
*!*	**	set rela to codizd+coddet into a2	&& 17.10.05 попробуем не связывать ;
*!*			и не копировать собственные затраты во входящие в последних ;
*!*			по порядку операциях clcopupt, а сразу копировать их в CLC_VXOD 

** 3 шаг.
*!*	**	repl all trud_vxod with trud_sob,zarp_vxod with zarp_sob,;
*!*			mater_vxod with mater_sob,p_f_vxod with p_f_sob,;
*!*			got_vxod with got_sob,vspm_vxod with vspm_sob ;
*!*			for npp_oper=a2.npp_oper and maxlevel=i			&& 17.10.05 попробуем не связывать ;
*!*			и не копировать собственные затраты во входящие в последних ;
*!*			по порядку операциях clcopupt, а сразу копировать их в CLC_VXOD 

** примечание по шагу 3: ;
	можно применить второй способ переноса собственных затрат ;
	во входящие затраты по последней операции входящих в сборку ДСЕ: ;
	шаг 2 выполнить перед шагом 4, а шаг 3 выполнять без связывания ;
	двух БД, т.к. связывание нужно только, чтобы определить последнюю ;
	сквозную операцию входящей ДСЕ, но эта операция уже определена ;
	в clcopupt, тогда 3 шаг:

*!*	**	repl all trud_vxod with trud_sob,zarp_vxod with zarp_sob,;
*!*			mater_vxod with mater_sob,p_f_vxod with p_f_sob,;
*!*			got_vxod with got_sob,vspm_vxod with vspm_sob ;
*!*			for npp_oper=posl_npp and maxlevel=i	

** 2 шаг.
	set rela to codizd+coddet into a2	&& a2 -- clc_vxod , 17.10.05 попробуем не копировать ;
		собственные затраты во входящие в последних ;
		по порядку операциях clcopupt, а сразу копировать их в CLC_VXOD ;
		как сумму собственных и входящих затрат из clcopupt

** 4 шаг.
*!*	**	repl all a2.trud_drug with trud_drug,a2.trud_vxod with trud_vxod,;
*!*			a2.zarp_drug with zarp_drug,a2.zarp_vxod with zarp_vxod,;
*!*			a2.mater_drug with mater_drug,a2.mater_vxod with mater_vxod,;
*!*			a2.p_f_drug with p_f_drug,a2.p_f_vxod with p_f_vxod,;
*!*			a2.got_drug with got_drug,a2.got_vxod with got_vxod,;
*!*			a2.vspm_drug with vspm_drug,a2.vspm_vxod with vspm_vxod ;
*!*			for npp_oper=a2.npp_oper and maxlevel=i	

	repl all a2.trud_drug with trud_drug,a2.trud_vxod with trud_sob+trud_vxod,;
		a2.zarp_drug with zarp_drug,a2.zarp_vxod with zarp_sob+zarp_vxod,;
		a2.mater_drug with mater_drug,a2.mater_vxod with mater_sob+mater_vxod,;
		a2.p_f_drug with p_f_drug,a2.p_f_vxod with p_f_sob+p_f_vxod,;
		a2.got_drug with got_drug,a2.got_vxod with got_sob+got_vxod,;
		a2.vspm_drug with vspm_drug,a2.vspm_vxod with vspm_sob+vspm_vxod ;
		for npp_oper=a2.npp_oper and maxlevel=i	
	
** 5 шаг.	измененный 
	sele 1
	set orde to detizdnpp

** файл состава сборок i-го уровня для проверки
	sele dist maxlevel,codizd,coddet,quant,;
		trud_drug,trud_vxod,zarp_drug,zarp_vxod,;
		mater_drug,mater_vxod,p_f_drug,p_f_vxod,;
		got_drug,got_vxod,vspm_drug,vspm_vxod ;
	from &ad_norm.temp\clc_vxodu ;
	into dbf &sost_sbor. ;
	where maxlevel=i ;
	grou by codizd,coddet

** файл суммарных затрат по составу сборок i-го уровня
	sele dist maxlevel,codizd,;
		sum(trud_drug*quant) as trud_drug,sum(trud_vxod*quant) as trud_vxod,;
		sum(zarp_drug*quant) as zarp_drug,sum(zarp_vxod*quant) as zarp_vxod,;
		sum(mater_drug*quant) as mater_drug,sum(mater_vxod*quant) as mater_vxod,;
		sum(p_f_drug*quant) as p_f_drug,sum(p_f_vxod*quant) as p_f_vxod,;
		sum(got_drug*quant) as got_drug,sum(got_vxod*quant) as got_vxod,;
		sum(vspm_drug*quant) as vspm_drug,sum(vspm_vxod*quant) as vspm_vxod ;
	from &ad_norm.temp\clc_vxodu ;
	into dbf &calcsbor. ;
	where maxlevel=i ;
	grou by codizd

	set rela to codizd into a1		&&  a1 -- clcopupt
	set skip to a1

** 6 шаг. измененный 
		repl all a1.trud_drug with trud_drug,a1.trud_vxod with trud_vxod,;
			a1.zarp_drug with zarp_drug,a1.zarp_vxod with zarp_vxod,;
			a1.mater_drug with mater_drug,a1.mater_vxod with mater_vxod,;
			a1.p_f_drug with p_f_drug,a1.p_f_vxod with p_f_vxod,;
			a1.got_drug with got_drug,a1.got_vxod with got_vxod,;
			a1.vspm_drug with vspm_drug,a1.vspm_vxod with vspm_vxod ;
			for a1.npp_oper=1 and codizd=a1.coddet

	set rela to
	sele 1

endfor

**ПОЯСНЕНИЯ к алгоритму работы модуля расчета затрат на изготовление сборок:;
	после формирования БД (CLC_VXOD) затрат по составам сборок, ;
	отнесенных на последнюю операцию (по сквозной нумерации), ;
	начинается расчет суммарных затрат на ДСЕ, входящих в сборки i-го уровня ;
	входимости (с самого нижнего);
	1 шаг. по известному алгоритму в БД (clcopupt) для сборок i-го уровня ;
		входимости производится расчет суммарных (накопительных) затрат ;
		(TRUD_SOB) и (TRUD_DRUG) по операциям входящих в узел ДСЕ;
	2 шаг. связываем БД (clcopupt) и (CLC_VXOD) по полям ;
		<CODIZD> <CODDET> и <NPP_OPER> и при их равенстве в обеих БД ;
	3 шаг. в БД (clcopupt) i-го уровня собственные суммарные затраты ;
		(TRUD_SOB) по каждой входящей в сборку ДСЕ копируются в поле ;
		(TRUD_VXOD), при этом следует обратить внимание, что если последняя ;
		операция входящей в сборку ДСЕ делается в цехе, который производит ;
		сборку самого узла, то суммарная трудоемкость этого последнего ;
		захода имеет не нулевое значение и переносится в поле (TRUD_VXOD),;
		а если цех-сборщик узла и последний цех-изготовитель не один, ;
		то (TRUD_SOB) и (TRUD_VXOD) соответственно равны 0; 
		(повторно напоминаю: последний заход ДСЕ перед установкой ;
		в узел всегда идет в цех-сборщик) (примеры.....) ;
	4 шаг. переносим в БД (CLC_VXOD) из БД (clcopupt) суммарные затраты ;
		(TRUD_DRUG) и (TRUD_VXOD) по каждой входящей в сборку ДСЕ i-го уровня;
	5 шаг. связываем поле <CODDET> БД (clcopupt) и <CODIZD> (CLC_VXOD) ;
		  в отношении один ко многим и при их равенстве в обеих БД ;
		  (пример связывания...) ;
	6 шаг. суммаруем из БД (CLC_VXOD) трудоемкость (TRUD_DRUG) и (TRUD_VXOD) ;
		входящих в сборку ДСЕ i-го уровня входимости с учетом их ;
		применяимости, в первой по сквозному порядку операции ДСЕ ;
		в БД (clcopupt) (код ДСЕ (clcopupt) = коду сборки (CLC_VXOD)) ;
	7 шаг. переходим на более высокий уровень входимости и ;
		все начинаем с шага 1

wait clear
CLOSE TABLES

retu

***************************************************************************
************** расчет суммарных цеховых трудозатрат на ДСЕ ****************
***************************************************************************
proc r_sumzatr		&& расчет суммарных цеховых трудозатрат на ДСЕ

WAIT 'шаг 4. Считаем суммарные цеховые трудозатраты на ДСЕ в clcopupt' WINDOW NOWAIT NOCLEAR 

use &ad_norm.temp\clcopupt
on erro inde on coddet+codizd+cex+str(zaxlist)+str(npp_oper) tag dtizcxzxop
set orde to dtizcxzxop
on erro

go top
scat memv
	
scan
	if coddet+codizd+cex=m.coddet+m.codizd+m.cex
	**	repl trud_sum with trud+m.trud_sum,;
			zarp_sum with zarp+m.trud_sum
	** ошибка!! исправлено 06.06.2017 зарп+трудоемк!!
		repl trud_sum with trud+m.trud_sum,;
			zarp_sum with zarp+m.zarp_sum
	else
		repl trud_sum with trud,zarp_sum with zarp
	endif
	scat memv
endscan

wait clear
CLOSE TABLES 
retu

***************************************************************************
**** формирование БД цеховых детальных товарных трудозатрат (SPCHAR_D) ****
***************************************************************************
proc f_cxdettov
WAIT 'шаг 5. Формируется БД цеховых детальных товарных трудозатрат SPCHAR_0 ' WINDOW NOWAIT NOCLEAR  

creat table &ad_norm.temp\spchar_0S ;
	(codizd c(11),cex_sbor c(3),coddet c(11),cex c(3),zaxlist n(2,0),;
	nzax c(2),n_oper c(8),npp_oper n(5,0),posl_oper n(5,0),trud_dsob n(11,5),;
	trud_dvxod n(11,5),trud_ddrug n(11,5),trud_dtov n(11,5),;
	truddtovcx n(11,5),trud_sob n(11,5),trud_vxod n(11,5),trud_drug n(11,5),;
	trud_tovar n(11,5),trud_tovcx n(11,5),date_izm d)
*** 08/01/2013 Date_izmen заменено на date_izm
COPY TO &ad_norm.temp\spchar_0 TYPE FOX2X as 866 
    USE &ad_norm.temp\spchar_0
  ERASE &ad_norm.temp\spchar_0S.dbf

*!*	**creat table spchar_d ;
*!*		(coddet c(11),cex c(3),zaxlist n(2,0),nzax c(2),trud_dsob n(11,5),;
*!*		trud_dvxod n(11,5),trud_dtov n(11,5),truddtovcx n(11,5),;
*!*		trud_sob n(11,5),trud_vxod n(11,5),trud_tovar n(11,5),;
*!*		trud_tovcx n(11,5),date_izmen d)

** формируем промежуточный файл SPCHARPR по заходам выборкой уникальных ;
	цеховых детальных трудозатрат из БД clcopupt

WAIT 'шаг 5. Формируется БД цеховых детальных товарных трудозатрат SPCHAR_0 '+CHR(13)+ ;
	'из clcopupt формируем spcharpu' WINDOW NOWAIT NOCLEAR  
** УПТ:
** ее собирали в clcopupt по ТОВАРНОВМУ маршруту!!!
use &ad_norm.temp\clcopupt
inde on coddet+codizd+cex+nzax+str(10000-npp_oper) tag dtizcxzxnp
copy to &ad_norm.temp\prom TYPE FOX2X as 866 
use &ad_norm.temp\prom
inde on coddet+codizd+cex+nzax tag dtizcxzx_u uniq
copy to &ad_norm.temp\spcharpu fiel codizd,cex_sbor,coddet,zaxlist,cex,nzax,npp_oper,;
	posl_oper,n_oper,trud_sob,trud_vxod,trud_drug TYPE FOX2X as 866

WAIT 'шаг 5. Формируется БД цеховых детальных товарных трудозатрат SPCHAR_0 '+CHR(13)+ ;
	'из calcoper формируем spcharpd' WINDOW NOWAIT NOCLEAR  
** Действующая трудоемкость (t1) :
**!!! ее собирали по ПОЛНОМУ маршруту, 
**!!! следовательно заходы не сойдутся с выборкой по ТОВАРНОМУ маршруту УПТ!!!!!!!!!
use &ad_norm.temp\calcoper
inde on coddet+codizd+cex+nzax+str(10000-npp_oper) tag dtizcxzxnp
copy to &ad_norm.temp\prom TYPE FOX2X as 866 
use &ad_norm.temp\prom
inde on coddet+codizd+cex+nzax tag dtizcxzx_u uniq
copy to &ad_norm.temp\spcharpd fiel codizd,cex_sbor,coddet,zaxlist,cex,nzax,npp_oper,;
	posl_oper,n_oper,trud_sob,trud_vxod,trud_drug TYPE FOX2X as 866
CLOSE TABLES

** формируется БД SPCHAR_D на основе  
sele 1
use &ad_norm.temp\spcharpu alia a1
inde on coddet+codizd+cex+nzax tag detizdcxzx
sele 2
use &ad_norm.temp\spcharpd alia a2
inde on coddet+codizd+cex+nzax tag detizdcxzx
sele 3
use &ad_norm.temp\spchar_0 alia a3
appe from &ad_norm.temp\spcharpu
**appe from spcharpd
set rela to coddet+codizd+cex+nzax into a1,coddet+codizd+cex+nzax into a2		&&spcharpd

*** 22.01.2013 почему все данные берем из spcharpd alia a2, а не a1???
***в spcharpd все заходы по полному маршруту, 
*** а нам надо по товарному. Значит будем брать из spcharpu alia a1
*** Смирнова, сделаем наоборот...

*!*	** repl all trud_dsob with a2.trud_sob,trud_dvxod with a2.trud_vxod,;
*!*		trud_ddrug with a2.trud_drug,trud_dtov with a2.trud_sob+a2.trud_vxod,;
*!*		truddtovcx with a2.trud_sob+a2.trud_vxod,;
*!*		trud_tovar with trud_sob+trud_vxod,trud_tovcx with trud_sob+trud_vxod,;
*!*		posl_oper with a2.posl_oper

repl all trud_dsob with a1.trud_sob,trud_dvxod with a1.trud_vxod,;
	trud_ddrug with a1.trud_drug,trud_dtov with a1.trud_sob+a1.trud_vxod,;
	truddtovcx with a1.trud_sob+a1.trud_vxod,;
	trud_tovar with trud_sob+trud_vxod,trud_tovcx with trud_sob+trud_vxod,;
	posl_oper with a1.posl_oper

sele dist coddet,zaxlist,cex,nzax,trud_dsob,trud_dvxod,trud_dtov,;
		truddtovcx,trud_sob,trud_vxod,trud_tovar,trud_tovcx,date_izm,;
		posl_oper,npp_oper ;
	from &ad_norm.temp\spchar_0 into dbf &ad_norm.temp\spchar_dS ;
	grou by coddet,cex,nzax
COPY TO &ad_norm.temp\spchar_d TYPE FOX2X as 866
    USE &ad_norm.temp\spchar_d
  ERASE &ad_norm.temp\spchar_dS.dbf

	
inde on cex+coddet+allt(nzax) tag cexdetzax
inde on coddet+cex+allt(nzax) tag detcexzax
inde on coddet+str(zaxlist) tag detlist

**seek '01769062200'
**brow fiel coddet,cex,nzax:2,trud_sob,trud_vxod,trud_tovar,trud_tovcx

CLOSE TABLES 
WAIT CLEAR 
RETURN 

***********************************************************************************
proc spchar_u
** 21/09/18 Смирнова Н.А.
** Добавить в  clcopupt.prg   Последним действием

** spchar_d.dbf  показывает трудоемкость каждой конкретной точки маршрута, 
**  не таща накопительной трудоемкости других. Аналогично надо построить и базу
**  с трудоемкостями по участкам spcharUCH.dbf  - по каждому участку лично его трудоемкость 
** как своя прямая, так и своя входящая. 
** Т.е. в цехозаходе должны встретиться все участки, по которым прошла ДСЕ, 
** тогда сумма по цехозаходу по собственной трудоемкости и входящей 
** даст данные аналогичные spchar_d.dbf  . 
CLOSE TABLES 

wait 'шаг 6. Формируется таблица поучастковых трудоемкостей SPCHARUC.dbf'  WINDOW NOWAIT NOCLEAR 

SELECT opertrud.b3 as coddet, opertrud.nzax, opertrud.b1 as cex, opertrud.uch , 00 as maxlevel, ;
opertrud.zaxlist, opertrud.zaxlist as zaxall, ;
sum(t1/IIF(vich=0,1,vich)) as TRUD_DSOB, sum(t2/IIF(vich=0,1,vich)) as TRUD_SOB ;
FROM &ad_norm.oper\opertrud INTO dbf &ad_norm.temp\spch_uch ;
WHERE zaxlist<>0 ;
group by b3 ,b1,nzax,uch,zaxlist
** внутри одного товарного захода nzax могут быть несколько нетоварных zaxlist

** в  opertrud.dbf   поля:
**              nzax  - №захода в цех по товарному маршруту
**              nzax_all  - №захода в цех по ПОЛНОМУ маршруту
**		zaxlist - №захода по ПОЛНОМУ маршруту

 
Inde on coddet +cex +uch +str(val(nzax),2) tag detcexunz
Inde on coddet +cex +uch +str(val(nzax),2)+str(zaxlist) tag dtcexunzz

** opertrud.zaxlist - по полному маршр
** opertrud.nzax - по товарному маршр
**определяем максимальный уровень входимости для каждой сборки  и её первый цех по маршруту
**далее  надо для полноты информации в spcharuc!!
** здесь для первого цеха сразу можем поставит nzax и zaxlist, и дополнительно поле coddet, ;
**	 чтобы недостающие записи принести потом в spcarus/  

SELECT DISTINCT coddet as codizd,MAX(maxlevel) as maxlevel,'   ' as cex,  ;
'1' as nzax,1 as zaxlist,coddet ;
FROM &ad_norm.outizd_a into dbf &ad_norm.temp\sbor_ur ;
where maxlevel>0 GROUP BY coddet

inde on codizd tag codizd

** 07/06/2019 надо добавить сюда сами  изделия, которых нет в перечне деталей

SELECT DISTINCT codizd as codizd, 1 as maxlevel, '   ' as cex,  ;
'1' as nzax, 1 as zaxlist, codizd as coddet ;
FROM &ad_norm.outizd_a into dbf &ad_norm.temp\sbor_uri ;
group by codizd

set rela to codizd into sbor_ur
copy to &ad_norm.temp\sbor_dob  FOR !FOUND([sbor_ur]) TYPE FOX2X as 866
sele  sbor_ur
appen from &ad_norm.temp\sbor_dob
use in sbor_uri
use in outizd_a
inde on codizd+cex+str(val(nzax),2) tag detcexnz

** 07/06/2019

** заполним цех сборщик это далее потребуется при сборе затрат по входящим

USE &ad_norm.cexlista.dbf IN 0 ORDER DETLISTALL
Set rela to codizd+STR(zaxlist) into cexlista
REPLACE cex WITH cexlista.cexall FOR FOUND([cexlista])
set rela to

** определим для всех ДСЕ последний цех по маршруту в паре узел-деталь, и его №захода по полному маршруту.
** <cexlist1> - по товарному маршруту
** <cexlist0> - по полному маршруту

SELECT DISTINCT codizd,coddet,MAX(zaxlist)  as zaxall,cex, '  ' as nzax, ;
MAX(zaxlist)  as zaxlist,00 as maxlevel ;
FROM &ad_norm.cexlist0 INTO dbf &ad_norm.temp\vxdet_L ;
GROUP BY codizd,coddet
** в cexlist0 заходы совпадают с cexlista  !!! (В cexlst_a они другие!!)
Set rela to  coddet+STR(zaxall)+cex into cexlista
REPLACE nzax  WITH cexlista.Nzax  FOR FOUND([cexlista])
use in cexlista
use in cexlist0
** в spch_uch  заполним maxlevel, Он >0 для узловых ДСЕ.
SELECT spch_uch
SET RELATION TO coddet INTO sbor_ur
REPLACE maxlevel WITH sbor_ur.maxlevel FOR FOUND([sbor_ur])

**  определим, какие входящие ДСЕ в vxdet_L сами являются узлами
sele vxdet_L
SET RELATION TO coddet INTO sbor_ur
REPLACE maxlevel WITH sbor_ur.maxlevel FOR FOUND([sbor_ur])
** Здесь есть сборки для которых в opertrud НЕт трудоемкостей, 
** но у них есть трудоемкость других 
** - эти записи надо будет добавить в spcharUC

** а еще выберем из опертруда, какие участки есть в каждом цехе общества
SELECT distinct b1 as cex ,uch ;
FROM &ad_norm.oper\opertrud INTO dbf &ad_norm.temp\podr_uch ;
WHERE zaxlist<>0 and !empty(uch) group BY b1,uch


** сделаем заготовку для spcharUCH.dbf  
*!*		creat table spcharUCH ;
*!*		(coddet c(11),cex c(3),zaxlist n(2,0),uch c(2), nzax c(2),trud_dsob n(11,5),;
*!*		trud_dvxod n(11,5),trud_dtov n(11,5), truddtovcx n(11,5),;
*!*		trud_sob n(11,5),trud_vxod n(11,5),trud_tovar n(11,5),;
*!*		trud_tovcx n(11,5) )


Sele distinct s.coddet, s.cex, p.uch, s.nzax, s.zaxlist, s.zaxall, ;
0000000.00000 as  TRUD_DSOB,0000000.00000 as TRUD_Dvxod, ;
0000000.00000 as TRUD_Dtov,  ;
0000000.00000 as  TRUD_SOB, 0000000.00000 as TRUD_vxod, ;
0000000.00000 as TRUD_tovar  , 00 as maxlevel ;
from &ad_norm.temp\spch_uch s , &ad_norm.temp\podr_uch p  ;
where s.cex=p.cex  ;
into dbf &ad_norm.temp\spcharucS ;
group by s.coddet, s.cex, p.uch, s.nzax, s.zaxlist;
order by s.coddet, s.zaxlist, s.cex, p.uch, s.nzax

COPY TO &ad_norm.temp\spcharuc TYPE FOX2X as 866 
    USE &ad_norm.temp\spcharuc
  ERASE &ad_norm.temp\spcharucS.dbf


inde on coddet+cex+str(val(nzax),2) tag detcexnz
inde on coddet+cex+str(val(nzax),2)+str(zaxall) tag dtcexnzz

SET RELATION TO  coddet +cex +uch +str(val(nzax),2)+str(zaxall) INTO spch_uch
REPLACE trud_dsob WITH spch_uch.trud_dsob , trud_sob WITH spch_uch.trud_sob ;
		FOR FOUND([spch_uch]) 
	***  and zaxlist= spch_uch.zaxlist
set rela to

** сделаем выборку сборок цехов, ;
** в которых будет только труд. входящих и нет собственных труд. 
** и далее сборки исчезают в этих цехах (готовые узлы для сборок)
** в связи с чем этих позиций нет в выборке spcharuc
** при этом входящие собираются с Участками, поэтому для этих сборок, 
** надо сделать записи со всеми возможными участками!!!

sele sbor_ur
SET RELATION TO coddet+cex+str(val(nzax),2) INTO spcharuc
copy to &ad_norm.temp\dsur_sp for !found([spcharuc]) and !empty(sbor_ur.cex)
set rela to

sele dist d.codizd, d.maxlevel, d.cex, d.nzax, d.zaxlist, d.coddet, p.uch ;
from &ad_norm.temp\dsur_sp d,&ad_norm.temp\podr_uch p ;
into dbf &ad_norm.temp\dsur_spu ;
where d.cex=p.cex ;
group by  d.coddet,d.cex, p.uch

use in opertrud
use in dsur_sp
use in podr_uch
use in spch_uch

sele spcharuc
appen from &ad_norm.temp\dsur_spu 
use in dsur_spu

** т.к.последние заходы ДСЕ(сборок), то попробуем пока без них - важны первые заходы сборок, а их взяли выше!!
**	sele vxdet_L
**	SET RELATION TO coddet+cex+str(val(nzax),2) INTO spcharuc
**	copy to c:\normativ\TEMP\dsvx_ for !found([spcharuc])
** т.к. детали в выборке повторяются по количеству узлов, то выборку надо почистить от дублей
**	set rela to
**	sele coddet,cex,zaxall,zaxlist,nzax,maxlevel ;
**	from c:\normativ\TEMP\dsvx_ into dbf c:\normativ\TEMP\dsvx_spu;
**	group by coddet,cex,zaxlist,nzax,maxlevel 

**	sele spcharuc 
**	appen from c:\normativ\TEMP\dsvx_spu 
**	set rela to


** получили базу с избыточной информацией по участкам цеха для каждой детали, ;
** чтобы было куда положить информацию по входящим. 
** Все строки с нулевыми трудоемкостями после работы с узлами  УДАЛИМ!!!
*!* теперь надо поработать с узлами по уроням их входимости от мах к мин.
*!* опираясь на c:\normativ\uch\sbor_ur и c:\normativ\uch\vxdet_L выберем из specific состав сборок с информацией 
*!* о цехе сборщике узла (у него zaxlist=1 и nzax=1) 
*!* и последнем заходе входящей ДСЕ (цех сборщик = цеху и nzax  , нет СМЫСЛА брать  zaxlist и по нему делать сравнения!!! 
*!* См. деталь BROWSE FOR coddet='98196313400'	
*!* в opertrud по ней последние операции на  5 zaxlist (далее 104 и возврат в цех на сборку - это уже 7 zaxlist (на 7 нет операций, а в сборку уходит с него ), при этом nzax товатный у них 1!!) 

SELECT spcharuc
INDEX ON coddet+cex+str(val(nzax),2)+uch TAG detcexnzu


** подготовим состав узлов  
Sele s.codizd,u.maxlevel,u.cex as cex_sbor  , s.coddet, s.quant , c.zaxall, ;
 c.cex, c.nzax ;
From &ad_norm.temp\sbor_ur u, &ad_norm.specific s, &ad_norm.temp\vxdet_L  c ;
Into dbf  &ad_norm.temp\specif_   ;
Where u.codizd=s.codizd and s.codizd=c.codizd and s.coddet=c.coddet ;
Group by s.codizd, s.coddet order by u.maxlevel,s.codizd

INDEX ON LEFT(ALLTRIM(STR(maxlevel)),2)+codizd TAG urizd
sele max(maxlevel) from &ad_norm.temp\specif_ into arra MX
sele min(maxlevel) from &ad_norm.temp\specif_ into arra MN
 i=mx
use in specific
use in vxdet_L
use in sbor_ur

For i =mx to mn step -1
	WAIT  'шаг 6. Формируется таблица поучастковых трудоемкостей SPCHARUC.dbf'+CHR(13)+;
			'идет работа с уровнем сборок '+ALLTRIM(STR(i))  WINDOW NOWAIT NOCLEAR  

	vix_F='&ad_norm.temp\'+'prom_'+ALLTRIM(STR(i))
	imf='prom_'+ALLTRIM(STR(i))

	** это будем оставлять, чтобы проверить какие входящие взяли для узла
	** для детали (t.zaxlist as zaxlistd ) брать не будем, 
	** т.к. по последнему ТОВАРНОСМУ заходу м.б. несколько заходов по полному,
	** кроме того, здесь из-за этого надо суммировать внутри NZAXD

	SELECT s.codizd as coddet,'1 ' as nzax, s.maxlevel,s.cex_sbor , ;
	s.coddet as detvxod, t.cex,t.uch,t.nzax as nzaxd, ;
	sum(t.trud_dsob) as trud_dsob , sum(t.trud_dvxod) as trud_dvxod, ;
	sum(t.trud_sob) as trud_sob, sum(t.trud_vxod) as trud_vxod,  ;
	s.quant, sum((t.trud_dsob+t.trud_dvxod))*s.quant as dvxod, ;
	sum((t.trud_sob+t.trud_vxod))*s.quant as vxod ;
	from &ad_norm.temp\spcharuc t, &ad_norm.temp\specif_ s ;
	INTO dbf &vix_F;
	WHERE t.coddet=s.coddet AND t.cex=s.cex_sbor AND ;
		ALLTRIM(t.nzax)==ALLTRIM(s.nzax) AND s.maxlevel=i and ;
		t.trud_dsob+t.trud_dvxod+t.trud_sob+t.trud_vxod>0 ;
	group by s.codizd,t.cex,t.uch,s.maxlevel,s.coddet,t.nzax
	
	** теперь проссумируем, что надо добавить суммарно на ДСЕ во входящие
	SELECT coddet,cex,uch,nzax,maxlevel,sum(dvxod) as trud_dvxod,sum(vxod) as trud_vxod ;
	from &vix_F into dbf &ad_norm.temp\prom_ ;
	group by coddet,cex,nzax,uch,maxlevel
	** 	? _tally
	INDEX ON coddet+cex+str(val(nzax),2)+uch TAG detcexnzu
 	** сохраним для контроля
	promdd='&ad_norm.temp\prom_d'+ALLTRIM(STR(i))
	copy to &promdd 
	** теперь добавим собранные трудоемкости по входяшим в их узлы
	** НО ТОЛЬКО на 1 заход по полному маршруту, чтобы не дублилась информация
	SELECT spcharuc
	** индекс уже установлен и для реляции он не важен.
	** SET ORDER TO detcexnzu
	SET RELATION TO coddet+cex+str(val(nzax),2)+uch INTO prom_
	REPLACE trud_dvxod WITH prom_.trud_dvxod , ;
		trud_vxod WITH prom_.trud_vxod  FOR FOUND([prom_]) and zaxall==1 
	** если участок деталей входящих не совпадает с участком, а информация есть 
	SET RELATION TO coddet+cex+str(val(nzax),2) INTO prom_
	REPLACE trud_dvxod WITH prom_.trud_dvxod , ;
		trud_vxod WITH prom_.trud_vxod  ;
		FOR FOUND([prom_]) and ;
			spcharuc.trud_dvxod+spcharuc.trud_vxod=0 and ;
			empty(spcharuc.uch) and empty(prom_.uch)  and zaxall==1
        use in &imf
        use in prom_
Endfor 

use in specif_

** теперь удалим ненужные записи по участкам, на которых не велась работа
SELECT spcharuc

**DELETE FOR trud_dsob+trud_dvxod+trud_sob+trud_vxod=0
**PACK 
** пока все оставим

REPLACE ALL  trud_dtov WITH trud_dsob+trud_dvxod, trud_tovar WITH trud_sob+trud_vxod

** 07/06/2019  более правильно сделать и замену в поле zaxlist, 
	**  соответствуюшим значением ТОВАРНОГО захода относительно товарного NZAX , 
	**  так как там значения взятые из  opertrud.zaxlist - по полному маршр.
	** в поле zaxall останется значения взятые из  opertrud.zaxlist - по полному маршр.
	**  (opertrud.nzax - по товарному маршр)

USE &ad_norm.cexlist1.dbf IN 0 
sele cexlist1
inde on coddet+cex+str(val(nzax),2) tag detcexnz
SELECT spcharuc
SET RELATION TO coddet+cex+str(val(nzax),2) INTO cexlist1
REPLACE zaxlist WITH cexlist1.zaxlist FOR FOUND([cexlist1])
use in cexlist1

** часть точек маршрута, по которым нет собственной трудоемк и входящей сейчас 
** отсутствует в итоговом файле spchar_d, эту брешь можно восполнить 
** добавлением точек после сравнения с cexlist1, 
** но надо ли это, если там все равно 0??

** теперь принесем в spchar_d действующие трудоемкости, т.к. сейчас в полях стоят  УПТ (t2!!)

	WAIT  'шаг 6. Формируется таблица поучастковых трудоемкостей SPCHARUC.dbf'+CHR(13)+;
		'Заполняем в SPCHAR_D.dbf действующие трудоемкости' WINDOW NOWAIT NOCLEAR 
SELECT coddet,cex,nzax,zaxlist, ;
sum(trud_dsob) as trud_dsob, sum(trud_dvxod) as trud_dvxod, sum(trud_dtov) as trud_dtov,;
sum(trud_sob) as trud_sob, sum(trud_vxod) as trud_vxod, sum(trud_tovar) as trud_tovar, maxlevel ;
FROM &ad_norm.temp\spcharuc INTO dbf &ad_norm.temp\spchardd ;
GROUP BY coddet,cex,nzax

INDEX ON coddet+cex+STR(VAL(nzax),2) TAG detcexnz

use &ad_norm.temp\spchar_d in 0 
sele spchar_d
INDEX ON coddet+cex+STR(VAL(nzax),2) TAG detcexnz

** НО сначала, выберем из spchardd записи по деталям, которых нет в spchar_d
** а нет там (в spchar_d) финишных изделий!!
sele spchardd 
set rela to coddet+cex+STR(VAL(nzax),2) into spchar_d 
copy to &ad_norm.temp\dob_spch for !found([spchar_d]) and !empty(spchardd.cex) TYPE FOX2X as 866
set rela to

sele SPCHAR_D
SET RELATION TO  coddet+cex+STR(VAL(nzax),2) INTO spchardd
Repl trud_dsob with spchardd.trud_dsob, trud_dvxod with spchardd.trud_dvxod,  ;
	trud_dtov with spchardd.trud_dtov , ;
	truddtovcx with spchardd.trud_dsob+ spchardd.trud_dvxod ;
	trud_sob with spchardd.trud_sob, trud_vxod with spchardd.trud_vxod , ;
	trud_tovar with spchardd.trud_tovar, ;
	trud_tovcx with spchardd.trud_sob+ spchardd.trud_vxod ;
for found([spchardd])

** в spchar_d заменила и действующую,и  УПТ 

**trud_sob with spchardd.trud_sob, trud_vxod with spchardd.trud_vxod , ;
**trud_tovar with spchardd.trud_tovar, trud_tovcx with spchardd.trud_sob+ spchardd.trud_vxod ;
** в spchar_d заменила только действующую, УПТ не трогаем, хотя и она правильно собрана

** Добавим недостающие в spchar_d детали(изделия)

appen from &ad_norm.temp\dob_spch
** дозаполним появившиеся в записях поля 
repl all truddtovcx with trud_dsob+trud_dvxod, ;
	trud_tovcx with trud_sob+ trud_vxod 
COPY to &ad_norm.SPCHAR_D with cdx TYPE FOX2X as 866


** Проверка разницы в SPCHAR_D из ООТиЗ и текущим показала:
** В ООТиЗ в поля трудоемкости Входящиих попадает трудоеикость других (104ц),
** и это неправильно!!!
** здесь трудозатраты только цеха текущей строки 
** для подведения данных в отчетах по товару цеха!!!
** для полноты картины надо бы было сделать и поле трудоемкости ДРУГИХ

**07/06/2019
sele spcharuc
COPY to &ad_norm.spcharuc with cdx TYPE FOX2X as 866

CLOSE TABLES 
wait 'Сформированы SPCHARUS.dbf (поучастк.) и SPCHAR_D.dbf (цех.) труд. ' WINDOW NOWAIT NOCLEAR && time 2


RETURN 

**********************************************************
******** формирование справочника сборочных единиц *******
**********************************************************
proc f_sprsbor
wait wind nowa 'формирование справочника сборочных единиц' 
**справочник сборочных единиц содержит данные о цехе-сборщике и уровне входимости

sele dist a1.codizd,a2.cexall as cex,00 as maxlevel ;
	from specific a1,cexlista a2 ;
	into dbf spr_sbor ;
	where a1.codizd=a2.coddet and a2.zaxall=1

**определяем максимальный уровень входимости для каждой сборки
sele coddet as codizd,max(maxlevel) as maxlevel ;
	from outizd_a ;
	into dbf max_sbor ;
	grou by coddet ;
	where maxlevel>0
	
inde on codizd tag codizd

CLOSE TABLES

sele 1
use max_sbor alia a1 orde codizd
sele 2
use izdel alia a2 orde codizd
sele 3
use spr_sbor alia a3

** уровень входимости
set rela to codizd into a1
repl all maxlevel with a1.maxlevel

** у изделий уровень входимости = 1
set rela to codizd into a2
repl all maxlevel with 1 for found(2) and maxlevel=0

**записываем перечень сборок с нулевой входимостью в отдельный файл <0_maxlev>
copy to 0_maxlev for maxlevel=0

dele all for maxlevel=0
pack

inde on codizd+cex tag coduzla
inde on cex+codizd tag cexuzel
inde on str(maxlevel)+codizd+cex tag vxoduzel

CLOSE TABLES 

wait clear
RETURN 



