** calcopdt.prg	
** ** 2026г Смирнова
** Идет формирование calcoper и calcopal  - их в конце формирования SPCHAR_D выкладываем в сеь!!!
***************************************************************************
***** Формирование пооперационных калькуляций по товарным цехозаходам calcoper и calcopal *****
***************************************************************************
** calcopdt.prg
** последнее изменение 01.06.06
** с изменениями 06.12.12 и 19.12.12 , 24.12.2024
** 27.12.2012 устанавливаем этот модуль в проекте Администратора

** вызывается ТОЛЬКО из clcopupt.prg , а не как самостоятильная программа!!  

clos data 

do f_sprsbor	&&	1.формирование справочника сборочных единиц

do f_cxtopcal	&&	2.формирование структуры БД цеховых операционных калькуляций ;
**					на ДСЕ с перенумерованием уровней входимости и ;
**					выставлением сквозных номеров операций
**					с изменениями 6-8 декабря 2012г.
**		с изменениями 18.01.2013 Смирновой для учета поля npp_oper в sostclop.dbf 
**				и правильной связи opertrud  cexlist0

do f_calcvxod	&& 	3.формирование БД затрат последних операций последних по маршруту ДСЕ ;
					для включения этих затрат в первые операции сборок, ;
					в которые входят данные ДСЕ в качестве входящих затрат

do r_calcvxod	&& 	4.окончательный расчет затрат на сборки ;
					с учетом затрат на входящих в них ДСЕ

do r_sumzatr	&& 	5.расчет суммарных цеховых трудозатрат на ДСЕ

do form_calct	&&	6.формирование БД CALCOPER затрат уникальных деталеопераций

CLOSE TABLES 

RETURN 

**********************************************************
*1****** формирование справочника сборочных единиц *******
**********************************************************
proc f_sprsbor
WAIT 'формируем справочник сборочных единиц' WINDOW NOWAIT NOCLEAR  
**справочник сборочных единиц содержит данные о цехе-сборщике и уровне входимости

sele dist a1.codizd,a2.cexall as cex,00 as maxlevel ;
	from &ad_norm.specific a1,&ad_norm.cexlista a2 ;
	into dbf &ad_norm.temp\spr_sborS ;
	where a1.codizd=a2.coddet and a2.zaxall=1

COPY TO &ad_norm.temp\spr_sbor TYPE FOX2X as 866
    USE &ad_norm.temp\spr_sbor
  ERASE &ad_norm.temp\spr_sborS.dbf

**определяем максимальный уровень входимости для каждой сборки
sele coddet as codizd,max(maxlevel) as maxlevel ;
	from &ad_norm.outizd_a ;
	into dbf &ad_norm.temp\max_sbor ;
	grou by coddet ;
	where maxlevel>0
	
inde on codizd tag codizd

CLOSE TABLES 

sele 1
use &ad_norm.temp\max_sbor alia a1 orde codizd excl
sele 2
use &ad_norm.izdel alia a2 orde codizd excl
sele 3
use &ad_norm.temp\spr_sbor alia a3 excl

** уровень входимости
set rela to codizd into a1
repl all maxlevel with a1.maxlevel

** у изделий уровень входимости = 1
set rela to codizd into a2
repl all maxlevel with 1 for found(2) and maxlevel=0

**записываем перечень сборок с нулевой входимостью в отдельный файл <0_maxlev>
copy to &ad_norm.temp\0_maxlev for maxlevel=0  TYPE FOX2X as 866

dele all for maxlevel=0
pack

inde on codizd tag codizd
inde on codizd+cex tag coduzla
inde on cex+codizd tag cexuzel
inde on str(maxlevel)+codizd+cex tag vxoduzel

CLOSE TABLES 
*!*	 Получили в &ad_norm.temp\  справочник сборок - spr_sbor
RETURN 

*******************************************************
*2***** формирование цеховых калькуляций на ДСЕ *******
*******************************************************
proc f_cxtopcal

wait 'шаг 1. Формирую цеховые операционные калькуляции на ДСЕ - CALCOPER.DBF'+chr(13)+;
	'по полным цехозаходам по составам сборок по действующим нормам' WINDOW  NOWAIT NOCLEAR  

**@ 23,0
**@ 23,0 say 'Создаем дополнительный перечень цеховых ДСЕ, которых нет в БД <OPERTRUD> (ПКИ)'
sele 5
use &ad_norm.norm_mat orde coddet excl		&& п. 9.3
sele 4
use &ad_norm.izdel orde codizd excl
sele 3
use &ad_norm.temp\spr_sbor orde coduzla excl
sele 2
use &ad_norm.oper\opertrud excl
on erro inde on b3+b1+allt(nzax)+str(val(n_oper)) tag detcxzxopt
set orde to detcxzxopt
on erro
** 19.12.2012  вместо <cexlist1> используем <cexlist0>
sele 1
**use c:\normativ\cexlist1 alia a1 excl
use &ad_norm.cexlist0 alia a1 excl
**set rela to coddet+cex+allt(nzax) into a2
set rela to coddet+cex+allt(STR(zaxcex,2,0)) into opertrud

wait 'шаг 1. Формирую цеховые операционные калькуляции на ДСЕ - CALCOPER.DBF'+chr(13)+;
	'по полным цехозаходам по составам сборок по действующим нормам'+chr(13)+;
	'Перечень цеховых ДСЕ, которых нет в БД <OPERTRUD>' WINDOW  NOWAIT NOCLEAR  

copy to &ad_norm.temp\dob_sos for !found(2)	&& дополнительный перечень цеховых ДСЕ, которых нет в БД <OPERTRUD>
**21/01/2013
***т.к. поля нет, то сделаем нужную структуру dob_sost
sele codizd,coddet,quant,zaxlist,cex, ;
		STR(zaxcex,2,0) as nzax,;
		cex_post,cex_poluch ;
    from &ad_norm.temp\dob_sos ;
into dbf &ad_norm.temp\dob_sost
***21/01/2013
** 06/12/12 меняем существующий запрос  
** 19.12.2012 в запросе вместо <cexlist1> используем <cexlist0>
	
** <cexlist1> - по товарному маршруту
** <cexlist0> - по полному маршруту
**  В данном случае собираем затраты Дейсвующие (t1) и УПТ (t2) по ПОЛНОМУ маршруту!!!
** begin. 08.12.12 выставляем проценты премии и считаем суммы премии по операциям:
** 28.12.2012 Смирнова поле npp_oper добавлено 
** изменено правило связи таблиц
** 24.12.2024 Смирнова - поставлено точное сравнение == , т.к. заходов в один цех бывают >10
wait 'шаг 1. Формирую цеховые операционные калькуляции на ДСЕ - CALCOPER.DBF'+chr(13)+;
	'по полным цехозаходам по составам сборок по действующим нормам'+chr(13)+;
	'Перечень цеховых ДСЕ с операциями из БД <OPERTRUD>' WINDOW  NOWAIT NOCLEAR  

sele dist a1.codizd,a1.coddet,a1.quant,a1.zaxlist,a1.cex, ;
		STR(a1.zaxcex,2,0) as nzax,;
		a1.cex_post,a1.cex_poluch,a2.n_oper,a2.npp_oper,a2.uch,a2.grup,;
		a2.t1/a2.vich as trud,a2.r1/a2.vich as zarp, ;
		a2.t2/a2.vich as trud_up,a2.r2/a2.vich as zarp_up,;
		000.0 as prem_proc,00000.00000 as prem ;
	from &ad_norm.cexlist0 a1,&ad_norm.oper\opertrud a2 ;
	into dbf &ad_norm.temp\sostclop ;
	where a1.cex+a1.coddet+allt(STR(a1.zaxcex,2,0))== ;
		a2.b1+a2.b3+allt(a2.nzax_all) ;
		grou by a1.codizd,a1.coddet,a1.cex,a1.zaxlist,a2.n_oper,a2.uch,a2.npp_oper

** СМИРНОВА

SELECT 6
** USE c:\normativ\proc_prem_cex_uch ALIAS a6
USE &ad_norm.procprem ALIAS a6
on erro index on cex+allt(uch) tag cexuch 
SET ORDER TO cexuch
on erro
SELECT sostclop
SET RELATION TO cex+ALLTRIM(uch) INTO a6
REPLACE ALL prem_proc WITH a6.prem_proc
SET RELATION TO cex INTO a6
REPLACE ALL prem_proc WITH a6.prem_proc FOR EMPTY(a6.uch) AND prem_proc=0
SET RELATION TO 
REPLACE ALL prem WITH zarp*prem_proc/100
** end 08.12.12 **********
	
**@ 23,0
**@ 23,0 say 'создаем структуру таблицы цеховых операционных калькуляций...'     

** begin.06.12.12 дополняем структуру новыми полями о процентах премии - prem_proc, размере премии - prem, собственные затраты на премию - prem_sob,;
** затраты других цехов на премию - prem_drug,затрату на премию ДСЕ, входящих в сборку - prem_vxod,; 
** prem_sum n(11,5),prem_cex n(11,5)
creat table &ad_norm.temp\calcoperS ;
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

** end **
COPY TO &ad_norm.temp\calcoper TYPE FOX2X as 866

    USE &ad_norm.temp\calcoper
  ERASE &ad_norm.temp\calcoperS.dbf

wait 'шаг 1. Формирую цеховые операционные калькуляции на ДСЕ - CALCOPER.DBF'+chr(13)+;
	'по полным цехозаходам по составам сборок по действующим нормам'+chr(13)+;
	'Создаем таблицу цеховых операционных калькуляций по перечням.' WINDOW  NOWAIT NOCLEAR  

appe from &ad_norm.temp\sostclop
appe from &ad_norm.temp\dob_sost

**удаляем данные по сборкам, входящих сами в себя, кроме изделий
set rela to codizd into izdel
dele all for coddet=codizd and !found(4)
pack

inde on coddet+codizd+str(zaxlist)+str(val(n_oper)) tag detizlstop
inde on codizd+coddet+cex+allt(nzax)+str(val(n_oper)) tag izddtcxzxt
inde on codizd+coddet+str(zaxlist)+str(val(n_oper)) tag izddtlstop
** этот индекс последний, по нему будем переустанавливать npp_oper
**18/01/2013 Смирнова для переустановки индексного поля лучше оставим 
** предыдущий т.к. само изменяемое поле лучше не трогать, если в индексе 
**inde on codizd+coddet+str(zaxlist)+str(npp_oper) tag izddtlsto

set rela to codizd into spr_sbor
repl all cex_sbor with spr_sbor.cex
**set rela to coddet into a3
set rela to codizd into spr_sbor
repl all maxlevel with spr_sbor.maxlevel

** удаляем состав сборочных единиц с 0-ым уровнем входимости, ;
	не вошедших в сформированный справочник сборочных единиц SPR_SBOR, ;
	т.к. они не входят ни в одно финальное изделие ;
	или их нет в цех-списках

dele all for maxlevel=0
pack

**@ 23,0
**@ 23,0 say 'ставим сквозные номера операций по всем деталям'
wait 'шаг 1. формирую цеховые операционные калькуляции на ДСЕ - CALCOPER.DBF'+chr(13)+;
	'по товарным цехозаходам по составам сборок'+chr(13)+;
	'Ставим сквозные номера операций по всем деталям' WINDOW NOWAIT NOCLEAR  

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
	**	repl posl_oper with last_op  &&&& m.npp_oper  - Смирнова
		repl posl_oper with m.npp_oper 
		skip
	endif
	*** Смирнова: сначала запомним собранную до этого m.npp_oper,
	*** чтобы ее использовать для последней операции в ДСЕ
	last_op=m.npp_oper
	scat memv
endscan

inde on coddet+codizd+str(npp_oper) tag detizdnpp
inde on codizd+coddet+str(npp_oper) tag izddetnpp
inde on str(maxlevel)+codizd+coddet+str(npp_oper) tag levizdtnpp

** переводим финальные изделия, которые в CALCOPER входят сами в себя, ;
	в состав одного общего изделия с кодом "99999999999", ;
	вводим им 0-вой уровень входимости, и пересчитываем все уровни ;
	входимости начиная с 1-го (вместо 0-го) и, соответственно, ;
	увеличивая все последующие уровни на 1

repl all codizd with '99999999999', maxlevel with 0, quant with 1 ;
	for codizd=coddet
	
repl all maxlevel with maxlevel+1

wait 'шаг 1. формирую цеховые операционные калькуляции на ДСЕ - CALCOPER.DBF'+chr(13)+;
	'по товарным цехозаходам по составам сборок'+chr(13)+;
	'записываем материальные затраты на первую по порядку операцию ДСЕ' WINDOW NOWAIT NOCLEAR  
** записываем материальные затраты на первую по порядку операцию ДСЕ
SET relation to coddet into norm_mat && for npp_oper=1
Repl all mater_sob with iif(norm_mat.typ='M',norm_mat.norma*norm_mat.price,0),;
	p_f_sob with iif(norm_mat.typ='F',norm_mat.norma*norm_mat.price,0),;
	got_sob with iif(norm_mat.typ='P',norm_mat.norma*norm_mat.price,0),;
	vspm_sob with iif(norm_mat.typ='V',norm_mat.norma*norm_mat.price,0) ;
	for npp_oper=1

CLOSE TABLES
RETURN 

***************************************************************************
*3***** формирование БД цеховых калькуляций последних операций ДСЕ ********
***************************************************************************
proc f_calcvxod		&& создаем БД калькуляций на сборки...

WAIT 'шаг 2. Формируем БД затрат последних операций последних по маршруту ДСЕ'+chr(13)+;
	'для включения этих затрат в первые операции сборок, '+chr(13)+;
	'в которые входят данные ДСЕ в качестве входящих затрат' WINDOW NOWAIT NOCLEAR 

use &ad_norm.temp\calcoper excl
copy to &ad_norm.temp\clc_vxod for posl_oper!=0
use &ad_norm.temp\clc_vxod excl
inde on coddet+codizd tag detizd
inde on codizd+coddet tag izddet

CLOSE TABLES 
RETURN 

***************************************************************************
*4***** расчет затрат входящих в сборки ДСЕ (окончательный расчет) ********
***************************************************************************
proc r_calcvxod		&& расчет затрат входящих в сборки ДСЕ

wait 'шаг 3. формирую цеховые операционные калькуляции на ДСЕ'+chr(13)+;
	'по товарным цехозаходам по составам сборок в CALCOPER.DBF'+chr(13)+;
	'Считаем затраты входящих в сборки ДСЕ' WINDOW NOWAIT NOCLEAR 

sele 2
use &ad_norm.temp\clc_vxod alia a2 orde izddet excl	&& затраты на ДСЕ по последней операцией ;
														последнего захода перед передачей ;
														ее на сборку
**определяем максимальный уровень входимости сборки (первичные сборки):
**calc max(maxlevel) to MX
**calc min(maxlevel) to MN
sele max(maxlevel) from &ad_norm.temp\calcoper into arra MX
sele min(maxlevel) from &ad_norm.temp\calcoper into arra MN
i=MX

** ПРИМЕЧАНИЕ:
**	1. Эти затраты необходимо перенести на первую операцию первого захода ;
	сборки, куда входит конкретная ДСЕ, причем, если цех-сборщик узла ;
	и цех-изготовитель входящей ДСЕ один и тот же, то trud_vxod ДСЕ ;
	и trud_sob прибавляется к trud_vxod сборки, а если нет, ;
	то trud_vxod и trud_sob ДСЕ прибавляется к trud_drug сборки ;
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
	перед расчетом необходимо выверить все БД, в частности, ;
	чтобы цех-изготовитель ДСЕ, входящий в сборку по последнему порядковому ;
	номеру захода по цех-списку был один и тотже, что и цех-сборщик узла, ;
	куда входит конкретная ДСЕ, ;
	Тогда вся трудоемкость других цехов trud_drug этой ДСЕ должна ;
	прибавляться к трудоемкости trud_drug самого узла

sele 1
use &ad_norm.temp\calcoper alia a1 excl
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
wait 'шаг 3. формирую цеховые операционные калькуляции на ДСЕ'+chr(13)+;
	'по товарным цехозаходам по составам сборок в CALCOPER.DBF'+chr(13)+;
	'Работаем с уровнем входимости '+ALLTRIM(str(i)) WINDOW NOWAIT NOCLEAR  

** для сбора трудозатрат действующих - добавлена к основе буква d
	calcsbor='&ad_norm.temp\clcsbd_'+allt(str(i))
	sost_sbor='&ad_norm.temp\sostsbd'+allt(str(i))
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
			** begin.06.12.12 добавляем проценты премии:
				REPLACE	prem_sob with prem+m.prem_sob,prem_drug with m.prem_drug,prem_vxod with m.prem_vxod
			** end **
			else
			** собственные материальные затраты при передаче ДСЕ в другой цех ;
			** должны обнуляться
				repl trud_vxod with 0,trud_sob with trud,trud_drug with m.trud_drug+m.trud_sob+m.trud_vxod,;
					zarp_vxod with 0,zarp_sob with zarp,zarp_drug with m.zarp_drug+m.zarp_sob+m.zarp_vxod,;
					mater_vxod with 0,mater_sob with 0,mater_drug with m.mater_drug+m.mater_sob+m.mater_vxod,;
					p_f_vxod with 0,p_f_sob with 0,p_f_drug with m.p_f_drug+m.p_f_sob+m.p_f_vxod,;
					got_vxod with 0,got_sob with 0,got_drug with m.got_drug+m.got_sob+m.got_vxod,;
					vspm_vxod with 0,vspm_sob with 0,vspm_drug with m.vspm_drug+m.vspm_sob+m.vspm_vxod
			** begin.06.12.12 добавляем проценты премии:
				repl prem_vxod with 0,prem_sob with prem,prem_drug with m.prem_drug+m.prem_sob+m.prem_vxod
			** end **
			endif
		else
			repl trud_sob with trud,zarp_sob with zarp
			** begin.06.12.12 ******
			repl prem_sob with prem
			** end ***
		endif
		scat memv
	endscan

** 2 шаг.
**	set rela to codizd+coddet into a2	&& 17.10.05 попробуем не связывать ;
		и не копировать собственные затраты во входящие в последних ;
		по порядку операциях CALCOPER, а сразу копировать их в CLC_VXOD 

** 3 шаг.
**	repl all trud_vxod with trud_sob,zarp_vxod with zarp_sob,;
*!*			mater_vxod with mater_sob,p_f_vxod with p_f_sob,;
*!*			got_vxod with got_sob,vspm_vxod with vspm_sob ;
*!*			for npp_oper=a2.npp_oper and maxlevel=i			&& 17.10.05 попробуем не связывать ;
*!*			и не копировать собственные затраты во входящие в последних ;
*!*			по порядку операциях CALCOPER, а сразу копировать их в CLC_VXOD 

** примечание по шагу 3: ;
	можно применить второй способ переноса собственных затрат ;
	во входящие затраты по последней операции входящих в сборку ДСЕ: ;
	шаг 2 выполнить перед шагом 4, а шаг 3 выполнять без связывания ;
	двух БД, т.к. связывание нужно только, чтобы определить последнюю ;
	сквозную операцию входящей ДСЕ, но эта операция уже определена ;
	в CALCOPER, тогда 3 шаг:

**	repl all trud_vxod with trud_sob,zarp_vxod with zarp_sob,;
*!*			mater_vxod with mater_sob,p_f_vxod with p_f_sob,;
*!*			got_vxod with got_sob,vspm_vxod with vspm_sob ;
*!*			for npp_oper=posl_npp and maxlevel=i	

** 					2 шаг.		   a2 == clc_vxod
	set rela to codizd+coddet into a2	&& 17.10.05 попробуем не копировать ;
										собственные затраты во входящие в последних ;
										по порядку операциях CALCOPER, а сразу копировать их в CLC_VXOD ;
										как сумму собственных и входящих затрат из CALCOPER

** 4 шаг.
	** begin.09.12.12 **
	repl all a2.trud_drug with trud_drug,a2.trud_vxod with trud_sob+trud_vxod,;
		a2.zarp_drug with zarp_drug,a2.zarp_vxod with zarp_sob+zarp_vxod,;
		a2.prem_drug with prem_drug,a2.prem_vxod with prem_sob+prem_vxod,;
		a2.mater_drug with mater_drug,a2.mater_vxod with mater_sob+mater_vxod,;
		a2.p_f_drug with p_f_drug,a2.p_f_vxod with p_f_sob+p_f_vxod,;
		a2.got_drug with got_drug,a2.got_vxod with got_sob+got_vxod,;
		a2.vspm_drug with vspm_drug,a2.vspm_vxod with vspm_sob+vspm_vxod ;
		for npp_oper=a2.npp_oper and maxlevel=i	
	** end ***
	
** 5 шаг.	измененный 
	sele 1
	set orde to detizdnpp

** файл состава сборок i-го уровня для проверки
** 09.12.12 заменяем запрос:
	
	** begin.09.12.12 на новый **
	sele dist maxlevel,codizd,coddet,quant,;
		trud_drug,trud_vxod,zarp_drug,zarp_vxod,;
		prem_drug,prem_vxod,;
		mater_drug,mater_vxod,p_f_drug,p_f_vxod,;
		got_drug,got_vxod,vspm_drug,vspm_vxod ;
	from &ad_norm.temp\clc_vxod ;
	into dbf &sost_sbor ;
	where maxlevel=i ;
	grou by codizd,coddet
	** end **

** файл суммарных затрат по составу сборок i-го уровня
** 09.12.12 заменяем запрос

** 09.12.12 на новый:
	sele dist maxlevel,codizd,;
		sum(trud_drug*quant) as trud_drug,sum(trud_vxod*quant) as trud_vxod,;
		sum(zarp_drug*quant) as zarp_drug,sum(zarp_vxod*quant) as zarp_vxod,;
		sum(prem_drug*quant) as prem_drug,sum(prem_vxod*quant) as prem_vxod,;
		sum(mater_drug*quant) as mater_drug,sum(mater_vxod*quant) as mater_vxod,;
		sum(p_f_drug*quant) as p_f_drug,sum(p_f_vxod*quant) as p_f_vxod,;
		sum(got_drug*quant) as got_drug,sum(got_vxod*quant) as got_vxod,;
		sum(vspm_drug*quant) as vspm_drug,sum(vspm_vxod*quant) as vspm_vxod ;
	from &ad_norm.temp\clc_vxod ;
	into dbf &calcsbor ;
	where maxlevel=i ;
	grou by codizd
** end **

	set rela to codizd into a1
	set skip to a1

** 6 шаг. измененный 
** 09.12.12 расчет:
** заменяем на 
		repl all a1.trud_drug with trud_drug,a1.trud_vxod with trud_vxod,;
			a1.zarp_drug with zarp_drug,a1.zarp_vxod with zarp_vxod,;
			a1.prem_drug with prem_drug,a1.prem_vxod with prem_vxod,;
			a1.mater_drug with mater_drug,a1.mater_vxod with mater_vxod,;
			a1.p_f_drug with p_f_drug,a1.p_f_vxod with p_f_vxod,;
			a1.got_drug with got_drug,a1.got_vxod with got_vxod,;
			a1.vspm_drug with vspm_drug,a1.vspm_vxod with vspm_vxod ;
			for a1.npp_oper=1 and codizd=a1.coddet
** end 09.12.12 88

	set rela to
	sele 1
**	brow nome for maxlevel=i-1

endfor

**ПОЯСНЕНИЯ к алгоритму работы модуля расчета затрат на изготовление сборок:;
	после формирования БД (CLC_VXOD) затрат по составам сборок, ;
	отнесенных на последнюю операцию (по сквозной нумерации), ;
	начинается расчет суммарных затрат на ДСЕ, входящих в сборки i-го уровня ;
	входимости (с самого нижнего);
	1 шаг. по известному алгоритму в БД (CALCOPER) для сборок i-го уровня ;
		входимости производится расчет суммарных (накопительных) затрат ;
		(TRUD_SOB) и (TRUD_DRUG) по операциям входящих в узел ДСЕ;
	2 шаг. связываем БД (CALCOPER) и (CLC_VXOD) по полям ;
		<CODIZD> <CODDET> и <NPP_OPER> и при их равенстве в обеих БД ;
	3 шаг. в БД (CALCOPER) i-го уровня собственные суммарные затраты ;
		(TRUD_SOB) по каждой входящей в сборку ДСЕ копируются в поле ;
		(TRUD_VXOD), при этом следует обратить внимание, что если последняя ;
		операция входящей в сборку ДСЕ делается в цехе, который производит ;
		сборку самого узла, то суммарная трудоемкость этого последнего ;
		захода имеет не нулевое значение и переносится в поле (TRUD_VXOD),;
		а если цех-сборщик узла и последний цех-изготовитель не один, ;
		то (TRUD_SOB) и (TRUD_VXOD) соответственно равны 0; 
		(повторно напоминаю: последний заход ДСЕ перед установкой ;
		в узел всегда идет в цех-сборщик) (примеры.....) ;
	4 шаг. переносим в БД (CLC_VXOD) из БД (CALCOPER) суммарные затраты ;
		(TRUD_DRUG) и (TRUD_VXOD) по каждой входящей в сборку ДСЕ i-го уровня;
	5 шаг. связываем поле <CODDET> БД (CALCOPER) и <CODIZD> (CLC_VXOD) ;
		  в отношении один ко многим и при их равенстве в обеих БД ;
		  (пример связывания...) ;
	6 шаг. суммаруем из БД (CLC_VXOD) трудоемкость (TRUD_DRUG) и (TRUD_VXOD) ;
		входящих в сборку ДСЕ i-го уровня входимости с учетом их ;
		применяимости, в первой по сквозному порядку операции ДСЕ ;
		в БД (CALCOPER) (код ДСЕ (CALCOPER) = коду сборки (CLC_VXOD)) ;
	7 шаг. переходим на более высокий уровень входимости и ;
		все начинаем с шага 1

CLOSE TABLES 

RETURN 

***************************************************************************
*5************ расчет суммарных цеховых трудозатрат на ДСЕ ****************
***************************************************************************
proc r_sumzatr		&& расчет суммарных цеховых трудозатрат на ДСЕ

wait 'шаг 4. Считаем суммарные цеховые трудозатраты по детале-операции в CALCOPER' WINDOW NOWAIT NOCLEAR  

use &ad_norm.temp\calcoper excl
on erro inde on coddet+codizd+cex+str(zaxlist)+str(npp_oper) tag dtizcxzxop
set orde to dtizcxzxop
on erro

go top

scat memv

** 09.12.12 заменяем расчет суммарных затрат, добавляя расчет премии 	

** и исправляем ошибку в расчете: было zarp_sum with zarp+m.trud_sum, стало zarp_sum with zarp+m.zarp_sum 
scan
	if coddet+codizd+cex=m.coddet+m.codizd+m.cex
		repl trud_sum with trud+m.trud_sum,;
			zarp_sum with zarp+m.zarp_sum,;
			prem_sum with prem+m.prem_sum
	else
		repl trud_sum with trud,zarp_sum with zarp,prem_sum with prem
	endif
	scat memv
ENDSCAN
** end **

CLOSE TABLES 

RETURN 

***************************************************************************
*6***** формирование БД CALCOPER затрат уникальных деталеопераций ********
***************************************************************************
proc form_calct

** begin.09.12.12 заменяем запрос:
wait 'шаг 5. формирование БД CALCOPER затрат уникальных деталеопераций'+chr(13)+;
	'и формирование БД CALCOPAL с составами сборок' WINDOW NOWAIT NOCLEAR  

** на новый с премией:
sele dist coddet,cex,zaxlist,nzax,n_oper,npp_oper,posl_oper, ;
	uch,grup,trud,trud_sob,trud_drug,trud_vxod,trud_sum,;
	zarp,zarp_sob,zarp_drug,zarp_vxod,zarp_sum,;
	prem_proc,prem,prem_sob,prem_drug,prem_vxod,prem_sum,;
	mater_sob,mater_vxod,mater_drug,p_f_sob,p_f_vxod,p_f_drug,;
	got_sob,got_vxod,got_drug,vspm_sob,vspm_vxod,vspm_drug ;
	from &ad_norm.temp\calcoper ;
	into dbf prom ;
	grou by coddet,npp_oper
** end **

**inde on coddet+str(npp_oper) tag detnpp
**inde on coddet+str(zaxlist)+str(val(n_oper)) tag detlistop
**inde on coddet+cex+allt(nzax)+str(val(n_oper)) tag detcexzxop

sele calcoper
** копируем БД CALCOPER с составами сборок в CALCOPAL
copy to &ad_norm.calcopal with cdx TYPE FOX2X as 866

** формируем БД CALCOPER уникальных деталеопераций
ZAP
*!*	после этого в обновленной CALCOPER поля cex_sbor и maxlevel останутся ПУСТЫМИ!!!!
appe from prom
**repl all trud_cex with trud_sum,zarp_cex with zarp_sum
** 09.12.12 Заменяем на 
repl all trud_cex with trud_sum,zarp_cex with zarp_sum,prem_cex with prem_sum
** end **
copy to &ad_norm.calcoper with cdx TYPE FOX2X as 866

CLOSE TABLES
RETURN 
