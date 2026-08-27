** _cextovp.prg
** 2026г Смирнова
** На Y: надо сохранить в fox2x as 866 и проиндексировать!!
CLOSE TABLES
*!*	CLEAR 
********************************************************************
*** Формирование таблицы соответствия товарных и полных маршрутов ***
*************** с привязкой ДСЕ к сборочным единицам ****************
*********************************************************************
** _cextovp.prg вместо _cextovn.prg
** изменения от 31.08.06 устранение проблем с пропуском заходов в ЦЗЛ (10125)
set path to c:\normativ\oper

** 09/02/2026 Смирнова  - добавлены : nop_min, nop_max   ,
**  поле NZAX_all  оставила со своим именем (ранее переименовывалось в NZAX)
WAIT 'Формируем список цеховых операций ДСЕ по заходам по ПОЛНОМУ маршруту из OPERTRUD opzaxtrd.dbf...' WINDOW NOWAIT NOCLEAR  

** запомним активную строку экрана , чтобы на неё вернуться
akt_str=_PLINENO
** =messagebox(akt_str)

sele dist b1 as cex,b3 as coddet,nzax_all ,zaxlist, ;
	min(str(val(n_oper))) as oper_min,;
	max(str(val(n_oper))) as oper_max, ;
	MIN(npp_oper) as nop_min, MAX(npp_oper) as nop_max ;
	from &ad_norm.oper\opertrud ;
	into dbf &ad_norm.opzaxtrdS ;
	grou by b1,b3,nzax_all orde by b3,nzax_all,b1

COPY TO &ad_norm.opzaxtrd TYPE FOX2X as 866
    USE &ad_norm.opzaxtrd
  ERASE &ad_norm.opzaxtrdS.dbf

inde on cex+coddet+allt(nzax_all) tag cexdetzax
inde on coddet+cex+allt(nzax_all) tag detcexzax
inde on coddet+str(zaxlist,2) tag detzaxli
inde on coddet+allt(nzax_all)+cex tag detzaxcex
CLOSE TABLES 

WAIT 'Формирую таблицу столбчатого цех-списка без повторяющихся заходов...' WINDOW NOWAIT NOCLEAR  
use &ad_norm.cexlst_a orde detlist
repl all cex with '125' for cex+group='10125'
go top

m.cex=' '
m.codizd=' '
m.coddet=' '
m.zaxcex=1

*!*	 если цех поставщик и получатель один и тот же - оставляем ;
*!*		только один цех, причем, если часто встречающийся маршрут ;
*!*		10125-101 - оставляем только 101 без ЦЗЛ (10125), ;
*!*		чтобы не потерять основной заход в 101 цех!!! ;
*!*		Поступаем проще: присваиваем код 125 вместо 10125
scan
	if codizd+coddet+cex=m.codizd++m.coddet+m.cex
		if cex='101'
			skip -1
			repl group with '  '
			skip
		endif		
		dele
    endif
    scat memvar
endscan    

copy to &ad_norm.prmcxlsa for !dele() TYPE FOX2X as 866
** 10.02.2026  - вернем назад 101
** repl cex with '101' for cex='125'
** в ООТиЗ остается 125 - менять нельзя!!!

reca all
CLOSE TABLES 

WAIT 'Формирую таблицу соответствия полных и товарных заходов cexa_dse.dbf...' WINDOW NOWAIT NOCLEAR
** предварительно 

@ 0,80
@ 0,80 say 'Формируем перечень цеховых ДСЕ по полным маршрутам cexa_dse.dbf...'

sele a2.codizd,a2.coddet,quant,zaxlist,cex,zaxcex,cex_post,cex_poluch,;
	group,'   ' as post_t,'   ' as cex_t,'   ' as poluch_t,;
	'  ' as nzax,00 as zaxlist_t,00 as zaxcex_t,'   ' as cex_prom ;
	from &ad_norm.prmcxlsa a1,&ad_norm.specific a2 ;
	into dbf &ad_norm.cexa_dseS ;
	where a1.codizd+a1.coddet=a2.codizd+a2.coddet and (a1.cex+a1.group)!='10125' ;
	grou by a2.codizd,a2.coddet,zaxlist,cex

COPY TO &ad_norm.cexa_dse TYPE FOX2X as 866
  USE &ad_norm.cexa_dse
ERASE &ad_norm.cexa_dseS.dbf

inde on codizd+coddet tag izddet

@ 0,80
@ 0,80 say 'Формируем перечень цеховых изделий по полным маршрутам cexa_izd...'
sele dist a2.codizd,a1.coddet as coddet,1 as quant,zaxlist,cex,zaxcex,cex_post,;
	cex_poluch,group ;
	from &ad_norm.prmcxlsa a1,&ad_norm.izdel a2 ;
	into dbf &ad_norm.cexa_izd ;
	where a1.coddet=a2.codizd and (a1.cex+a1.group)!='10125' ;
	grou by a2.codizd,a1.coddet,zaxlist

set rela to codizd+coddet into cexa_dse
copy to prom for !found([cexa_dse]) TYPE FOX2X as 866

USE IN izdel
USE IN specific
USE IN cexa_izd

sele cexa_dse
appe from prom

@ 0,80
@ 0,80 say 'Индексирую cexa_dse.dbf...'
inde on codizd+coddet+str(zaxlist)+cex tag idetlistcx
inde on codizd+coddet+cex_t+str(zaxlist) tag idetcxtlst
inde on codizd+coddet+cex+str(zaxlist) tag idetcexlst
inde on coddet+cex+str(zaxlist)+codizd tag detcexzaxi
inde on coddet+codizd+cex+str(zaxlist) tag dtizcexlst

@ 0,80
@ 0,80 say 'В cexa_dse.dbf перенумеровываем заходы в цеха по полным маршрутам '
set orde to idetcexlst

go top

m.cex=' '
m.codizd=' '
m.coddet=' '
m.zaxcex=1

scan
	if codizd+coddet+cex=m.codizd++m.coddet+m.cex
		repl zaxcex with m.zaxcex+1
    else
       repl zaxcex with 1
    endif
    scat memvar
endscan    

@ 0,80
@ 0,80 say 'В cexa_dse.dbf переименовываем поставщиков и получателей по полным маршрутам'
set orde to idetlistcx		&& inde on codizd+coddet+str(zaxlist)+cex tag idetlistcx

go top
m.cex=' '
m.codizd=' '
m.coddet=' '

scan
    if codizd+coddet=m.codizd+m.coddet
       repl cex_post with m.cex,cex_poluch with space(3)
       CX=cex
       skip -1
       repl cex_poluch with CX
       skip +1
    else
       repl cex_post with space(3)
    endif
    scat memvar
endscan    

repl all cex_t with iif(cex+group='81336','136',cex)

@ 0,80
@ 0,80 say 'в cexa_dse.dbf проставляем товарные цеха поставщики и получатели...'
set orde to idetlistcx		&& inde on codizd+coddet+str(zaxlist)+cex tag idetlistcx

go top
m.cex_t=' '
m.codizd=' '
m.coddet=' '

scan
    if codizd+coddet=m.codizd+m.coddet
       repl post_t with m.cex_t,poluch_t with space(3)
       CX=cex_t
       skip -1
       repl poluch_t with CX
       skip +1
    else
       repl post_t with space(3)
    endif
    scat memvar
endscan    

@ 0,80
@ 0,80 say 'в cexa_dse.dbf проставляем товарные цеха...'
go top
m.cex_t=' '
m.coddet=' '
m.codizd=' '

** возможные варианты пропуска заходов в цеха для формирования товарных заходов
** <CEX №X>-104-10125-104-<CEX №X>
** <CEX №X>-10125-104-<CEX №X>
** <CEX №X>-104-10125-<CEX №X>
** <CEX №X>-10125-104-10125-<CEX №X>

** <CEX №X>-104-125-104-<CEX №X>
** <CEX №X>-125-104-<CEX №X>
** <CEX №X>-104-125-<CEX №X>
** <CEX №X>-125-104-125-<CEX №X>

scan
	if codizd+coddet=m.codizd+m.coddet
	*!*	 если цех=104 или 125 и  поставщик и получатель равны, ;
	*!*	 то вместо 104 или получатель = 125 (10125), ставим поставщика
		if cex_t='104' or cex_t='125'
			if m.cex_t=poluch_t
				repl cex_t with m.cex_t
			endif
			skip 1
				CG=cex+group
			skip -1
			if CG='125'
				repl cex_t with m.cex_t
			endif
		endif
		*!*	 если цех - ЦЗЛ (группа 25 цеха 101 ) и поставщик, и получатель ;
		*!*	 равны то вместо 101 ставим поставщика
		if cex='125'
			if m.cex_t=poluch_t
				repl cex_t with m.cex_t
			endif
			skip 1
				CX=cex_t
			skip -1
			if CX='104'
				repl cex_t with m.cex_t
			endif
		endif
    endif
    scat memvar
endscan    

**** изм. 18.04.08 возвращаем вместо 125 цеха правильный номер цеха 101(25):
** repl all cex with '101' for cex='125'
** в ООТиЗ остается 125 - менять нельзя!!!
** для завода замену выполняе перед раздачей новых НСИ и поднятием на SQL!!!
*********

************************************
@ 0,80
@ 0,80 say 'в cexa_dse.dbf проставляем второй раз товарные цеха поставщики и получатели...'
set orde to idetlistcx		&& inde on codizd+coddet+str(zaxlist)+cex tag idetlistcx

go top
m.cex_t=' '
m.coddet=' '
m.codizd=' '

scan
    if codizd+coddet=m.codizd+m.coddet
       repl post_t with m.cex_t,poluch_t with space(3)
       CX=cex_t
       skip -1
       repl poluch_t with CX
       skip +1
    else
       repl post_t with space(3)
    endif
    scat memvar
endscan    

****************************************************

@ 1,80
@ 1,80 say 'в cexa_dse.dbf нумеруем товарные цехо-заходы (nzax)...'
** изменение 17.11.04 начало
**inde on coddet+cex_t+str(zaxlist) tag detcextlst
set orde to idetcxtlst			&& inde on codizd+coddet+cex_t+str(zaxlist) tag idetcxtlst

** изменение 17.11.04 конец

go top

m.cex_t=' '
m.codizd=' '
m.coddet=' '
m.nzax=' 1'

scan
	if codizd+coddet+cex_t=m.codizd+m.coddet+m.cex_t
**		if cex_t=post_t or post_t='104'
		if cex_t=post_t
			repl nzax with m.nzax
		else
			repl nzax with str(val(m.nzax)+1,2,0)
		endif
    else
       repl nzax with ' 1'
    endif
    scat memvar
endscan    

@ 1,80
@ 1,80 say 'проставляем для Товарных цехов товарные цеха поставщики и получатели...'
set orde to idetlistcx			&& inde on codizd+coddet+str(zaxlist)+cex tag idetlistcx

go top
m.cex_t=' '
m.codizd=' '
m.coddet=' '

scan
    if codizd+coddet=m.codizd+m.coddet
       repl post_t with m.cex_t,poluch_t with space(3)
       CX=cex_t
       skip -1
       repl poluch_t with CX
       skip +1
    else
       repl post_t with space(3)
    endif
    scat memvar
endscan    

@ 1,90
@ 1,90 say 'в cexa_dse.dbf заменяем нетоварные заходы на 0'

go top

m.cex_t=' '
m.codizd=' '
m.coddet=' '
m.nzax='1'

scan
	if codizd+coddet=m.codizd+m.coddet
	    if post_t=cex_t and poluch_t=cex_t
			repl zaxcex_t with 0
		else
			repl zaxcex_t with val(nzax)
		endif
	else
		repl zaxcex_t with 1
    endif
    scat memvar
endscan    

@ 1,80
@ 1,80 say 'в cexa_dse.dbf упорядочиваем порядковые номера полных заходов (zaxlist) по маршруту'
set orde to idetlistcx		&& inde on codizd+coddet+str(zaxlist)+cex tag idetlistcx

go top

m.cex_t=' '
m.codizd=' '
m.coddet=' '
m.nzax='1'

scan
	if codizd+coddet=m.codizd+m.coddet
		repl zaxlist with m.zaxlist+1
	else
		repl zaxlist with 1
	endif
    scat memvar
endscan    

*** 27/06/2017 Смирнова
@ 1,80
@ 1,80 say 'в cexa_dse.dbf упорядочиваем порядковые номера Товарных заходов (zaxlist_t) по маршруту'

inde on coddet+codizd+STR(zaxlist) tag DETIZLIST 

GO top
m.codizd=''
m.coddet=''
m.cex_t=''
m.zaxlist_t=1

SCAN 
	** проверим что работаем с новой парой изд-дет
	IF codizd<>m.codizd or coddet<>m.coddet
		REPLACE zaxlist_t WITH 1
	ELSE 
	** проверяем изменился ли цех товарный
		IF cex_t<>m.cex_t 
		** если изменился увеличиваем счетчик
			REPLACE zaxlist_t WITH m.zaxlist_t+1
		ELSE
		** товарный заход остается тот же 
			REPLACE zaxlist_t WITH m.zaxlist_t
		ENDIF 
	ENDIF  
	SCATTER MEMVAR 
ENDSCAN

***  27.06.2017

@ 1,80
@ 0,80
@ 0,80 say 'формируем БД "столбчатых" цех-списков "полных" заходов - cexlist0.dbf'
sele dist codizd,coddet,1 as nmarsh,quant,zaxlist,;
	cex_post,cex,zaxcex,group,cex_poluch ;
	from &ad_norm.cexa_dse ;
	into dbf &ad_norm.cexlist0S ;
	grou by codizd,coddet,cex,zaxlist

COPY TO &ad_norm.cexlist0 TYPE FOX2X as 866
  USE &ad_norm.cexlist0
ERASE &ad_norm.cexlist0S.dbf

** ??10.02.2026 	grou by codizd,coddet,cex,zaxcex

*!*	** repl cex_post with '101' for cex_post='125'
*!*	** repl cex_poluch with '101' for cex_poluch='125'
*!*	** в ООТиЗ остается 125 - менять нельзя!!!
*!*	** для завода замену выполняе перед раздачей новых НСИ и поднятием на SQL!!!
*********

@ 1,80
@ 1,80 say 'Индексирую базу "полного" цех-списка - cexlist0.dbf...' color w+/n
inde on codizd+coddet+cex+str(zaxlist) tag izddtcxlst
inde on codizd+coddet+str(zaxlist) tag izddetlist for zaxlist>0
inde on cex+coddet+allt(str(zaxcex))+cex_poluch tag cexdetpol
inde on cex+coddet+allt(str(zaxcex)) tag cexdetzax
inde on coddet+codizd+str(zaxlist) tag detlist
inde on coddet+codizd+cex+allt(str(zaxcex)) tag detizdcxzx
inde on coddet+cex+allt(str(zaxcex))+codizd tag detcexzax

@ 1,80
@ 0,80
@ 0,80 say 'формируем БД "столбчатых" цех-списков товарных заходов - cexlist1.dbf'
sele dist codizd,coddet,quant,zaxlist,int(val(nzax)) as zaxcex,;
	cex_t as cex,nzax,post_t as cex_post,poluch_t as cex_poluch,group,;
	1 as nmarsh,space(6) as oper_min,space(90) as naimop_min,;
	space(6) as oper_max,space(90) as naimop_max ,0000 as nop_min,0000 as nop_max ;
	from &ad_norm.cexa_dse ;
	into dbf &ad_norm.cexlist1S ;
	grou by codizd,coddet,cex_t,nzax

COPY TO &ad_norm.cexlist1 TYPE FOX2X as 866
  USE &ad_norm.cexlist1
ERASE &ad_norm.cexlist1S.dbf

@ 1,80
@ 1,80 say 'В cexlist1.dbf упорядочиваем порядковые номера цехов по товарному маршруту...'
inde on codizd+coddet+str(zaxlist) tag izddetlist for zaxlist>0
go top

m.cex=' '
m.codizd=' '
m.coddet=' '
m.zaxlist=1

scan
	if codizd+coddet=m.codizd+m.coddet
		repl zaxlist with m.zaxlist+1
	else
		repl zaxlist with 1
    endif
    scat memvar
endscan    

@ 1,80
@ 1,80 say 'В cexlist1.dbf упорядочиваем цеха-поставщики и -получатели по товарному цех-списку...' 
	
repl all cex_post with ' ' for zaxlist=1

@ 1,80
@ 1,90 say "Индексирую базу цех-списка cexlist1.dbf ..." color w+/n*
inde on codizd+coddet+cex+str(zaxlist) tag izddtcxlst
inde on codizd+coddet+str(zaxlist) tag izddetlist for zaxlist>0
inde on cex+coddet+str(zaxcex,1,0)+cex_poluch tag cexdetpol
inde on cex+coddet+str(zaxcex,1,0) tag cexdetzax
inde on coddet+codizd+str(nmarsh)+str(zaxlist) tag detlist
inde on coddet+cex+allt(nzax)+codizd tag detcexzax
inde on coddet+codizd+str(zaxlist) uniq tag marsh_u
inde on coddet+codizd+str(zaxlist) uniq tag detizdlist for zaxlist>0
inde on coddet+str(zaxlist)+codizd uniq tag detlist_mn for zaxlist>0
inde on coddet+str(1/zaxlist)+codizd uniq tag detlist_mx for zaxlist>0
inde on coddet+codizd+str(zaxlist) uniq tag detizd_mn for zaxlist>0
inde on coddet+codizd+str(100/zaxlist) uniq tag detizd_mx for zaxlist>0

@ 0,80
@ 0,80 say 'формируем БД соответствия цех-списков по полным и товарным заходам c привязкой к сборкам <CEXLISTI.dbf>...'
@ 1,80

**изм.24.02.05 начало
sele codizd,coddet,quant,zaxlist,cex_post,cex,group,cex_poluch,;
		str(zaxcex,2,0) as nzax_all,zaxlist_t,post_t as cexpost_t,cex_t,;
		poluch_t as cexpol_t,zaxcex_t,nzax,zaxcex,;
		space(8) as oper_min,space(8) as oper_max,;
		space(90) as naimop_min,space(90) as naimop_max,1 as nmarsh, ;
		0000 as nop_min,0000 as nop_max ;
	from &ad_norm.cexa_dse ;
	into dbf &ad_norm.cexlistiS ;
	grou by codizd,coddet,zaxlist

COPY TO &ad_norm.cexlisti TYPE FOX2X as 866
  USE &ad_norm.cexlisti
ERASE &ad_norm.cexlistiS.dbf

@ 1,80
@ 1,90 say "Индексирую базу цех-списка cexlisti.dbf ..." color w+/n*
inde on coddet+codizd+str(zaxlist)+cex tag dtizlstall
inde on coddet+codizd+cex_t+allt(nzax) tag detizcxzxt
inde on coddet+codizd+str(zaxlist)+cex tag detlistall
inde on coddet+codizd+cex_t+allt(nzax) tag detcexzaxt
inde on coddet+cex+allt(nzax_all)+codizd tag dtcxzxalli
inde on codizd+coddet+cex+allt(nzax_all) tag izdtcxzxal

do f_minmaxop
**изм.24.02.05 конец

@ 1,80
@ 0,80
@ 0,80 say 'формируем БД по уникальным ДСЕ без привязки к сборкам <CEXLISTA.dbf>...'

sele codizd,coddet,quant,1 as nmarsh,cex_post,cex_t as cex,group,;
	cex_poluch,zaxlist_t as zaxlist,zaxcex_t as zaxcex,;
	cex as cexall,zaxlist as zaxall,zaxcex as zaxcexall,nzax,;
	oper_min,oper_max,naimop_min,naimop_max, nop_min, nop_max ;
	from &ad_norm.cexlisti ;
	into dbf &ad_norm.cexlistaS ;
	grou by coddet,zaxlist,cex

COPY TO &ad_norm.cexlista TYPE FOX2X as 866
  USE &ad_norm.cexlista
ERASE &ad_norm.cexlistaS.dbf

@ 1,80
@ 1,90 say 'Индексируем cexlista.dbf...' color w+/n*

inde on coddet+str(zaxall)+cexall tag detlistall
inde on cex+coddet+allt(nzax) tag cexdetzax
inde on coddet+cex+allt(nzax) tag detcexzax
inde on coddet+cexall+allt(str(zaxcexall)) tag detcxzxall

** 09/02/2026 Смирнова
@ 0,80
@ 1,80

** заполним поле zaxlist - Информацией о № захода по товарному маршруту по данным из cexlist1
use &ad_norm.cexlist1 in 0 order DETCEXZAX   &&  inde on coddet+cex+allt(nzax)+codizd tag detcexzax
sele cexlista
SET RELATION TO coddet+cex++ALLTRIM(nzax) INTO cexlist1
REPLACE zaxlist WITH cexlist1.zaxlist FOR FOUND([cexlist1])
** sele cexlist1
** repl cex with '101' for cex='125'
** repl cex_post with '101' for cex_post='125'
** repl cex_poluch with '101' for cex_poluch='125'
*!*	** в ООТиЗ остается 125 - менять нельзя!!!
*!*	** для завода замену выполняе перед раздачей новых НСИ и поднятием на SQL!!!
*********

use in cexlist1

** сформируем таблицу по товарному маршруту с Операциями мин и мах
SELECT dist coddet,cex,nzax,zaxlist, ;
 MIN(STR(VAL(oper_min))) as oper_min, MAX(STR(VAL(oper_max))) as oper_max, ;
 min(nop_min) as nop_min, max(nop_max) as nop_max ;
 FROM &ad_norm.cexlista into dbf &ad_norm.opzaxtovS ;
 where cex=cexall ;
 grou by coddet,zaxlist,cex orde by coddet,zaxlist,cex

COPY TO &ad_norm.opzaxtov TYPE FOX2X as 866
  USE &ad_norm.opzaxtov
ERASE &ad_norm.opzaxtovS.dbf

 ** условие cex=cexall обязательно, т.к. выбираем собственные операции товарного цехозахода !!!

inde on cex+coddet+allt(nzax) tag cexdetzax
inde on coddet+cex+allt(nzax) tag detcexzax
inde on coddet+str(zaxlist,2) tag detzaxli
inde on coddet+allt(nzax)+cex tag detzaxcex

**sele cexlista
**repl cex with '101' for cex='125'
**repl cex_post with '101' for cex_post='125'
**repl cex_poluch with '101' for cex_poluch='125'

** все замены 125 на 101 убраны, т.к. в ООТиЗ в базе они остаются 125 и при работе там идут ошибки!!
*!*	** в ООТиЗ остается 125 - менять нельзя!!!
*!*	** для завода замену выполняе перед раздачей новых НСИ и поднятием на SQL!!!
*********
** 09/02/2026

do f_sprsbor && формирования справочника сборочных единиц с цехами-сборщиками 

CLOSE TABLES
*!*	** ad_norm='C:\normativ\'
*!*	** ad_normS='\\NWNT.SYS2.KO\INFORMATION\NORMATIV\'
** =messagebox(akt_str)
** вернемся на активную строку, чтобы продолжить вывод

** ON ERROR CLEAR 
@ akt_str,110 say SPACE(10)
** ON ERROR


IF  MESSAGEBOX('Обновлять сетевые БД ?',36,'Внимание!!')=6 	&& 6 - ДА (36 - выделена по умолчанию ДА,если 292 -выделена НЕТ ) 
	&& 6 - ДА
	if adir(dr,ad_normS,'d')>0		&& adir(dr,'y:\normativ','d')=1 and uppe(YN)='Y'
		wait 'Обновляю cexlista в сети ... '+ad_normS WINDOW NOWAIT  
		use &ad_norm.cexlista
		? '<4.5. Таблица соответствия товарных и полных заходов> - В cети обновляем таблицу cexlista!'
		ON ERROR ? '<4.5. Таблица соответствия товарных и полных заходов> - Проблема! В cети НЕ ОБНОВЛЕНА таблица cexlista!'
			COPY to &ad_normS.cexlista with cdx TYPE FOX2X as 866
		ON ERROR 

		wait 'Обновляю cexlisti в сети ... '+ad_normS WINDOW NOWAIT  
		use &ad_norm.cexlisti
		? '<4.5. Таблица соответствия товарных и полных заходов> - В cети обновляем таблицу cexlisti!'
		ON ERROR ? '<4.5. Таблица соответствия товарных и полных заходов> - Проблема! В cети НЕ ОБНОВЛЕНА таблица cexlisti!'
	   		COPY to &ad_normS.cexlisti with cdx TYPE FOX2X as 866
		ON ERROR 
		
		wait 'Обновляю cexlist1 в сети ... '+ad_normS WINDOW NOWAIT  
		use &ad_norm.cexlist1
		? '<4.5. Таблица соответствия товарных и полных заходов> - В cети обновляем таблицу cexlist1 !'
		ON ERROR ? '<4.5. Таблица соответствия товарных и полных заходов> - Проблема! В cети НЕ ОБНОВЛЕНА таблица cexlist1 !'
		   COPY to &ad_normS.cexlist1 with cdx TYPE FOX2X as 866
		ON ERROR 
		
		wait 'Обновляю cexlist0 в сети ... '+ad_normS WINDOW NOWAIT  
		use &ad_norm.cexlist0
		? '<4.5. Таблица соответствия товарных и полных заходов> - В cети обновляем таблицу cexlist0 !'
		ON ERROR ? '<4.5. Таблица соответствия товарных и полных заходов> - Проблема! В cети НЕ ОБНОВЛЕНА таблица cexlist0 !'
	   		COPY to &ad_normS.cexlist0 with cdx TYPE FOX2X as 866
		ON ERROR 

		wait 'Обновляю cexa_dse в сети ... '+ad_normS WINDOW NOWAIT  
		use &ad_norm.cexa_dse
		? '<4.5. Таблица соответствия товарных и полных заходов> - В cети обновляем таблицу cexa_dse !'
		ON ERROR ? '<4.5. Таблица соответствия товарных и полных заходов> - Проблема! В cети НЕ ОБНОВЛЕНА таблица cexa_dse !'
	   		COPY to &ad_normS.cexa_dse with cdx TYPE FOX2X as 866
		ON ERROR 

		wait 'Обновляю spr_sbor в сети ... '+ad_normS WINDOW NOWAIT  
		use &ad_norm.spr_sbor
		? '<4.5. Таблица соответствия товарных и полных заходов> - В cети обновляем таблицу spr_sbor !'
		ON ERROR ? '<4.5. Таблица соответствия товарных и полных заходов> - Проблема! В cети НЕ ОБНОВЛЕНА таблица spr_sbor !'
			COPY to &ad_normS.spr_sbor with cdx TYPE FOX2X as 866
		ON ERROR 
	   
		wait 'Обновляю opzaxtrd в сети ... '+ad_normS WINDOW NOWAIT  
		use &ad_norm.opzaxtrd 
		? '<4.5. Таблица соответствия товарных и полных заходов> - В cети обновляем таблицу opzaxtrd !'
		ON ERROR ? '<4.5. Таблица соответствия товарных и полных заходов> - Проблема! В cети НЕ ОБНОВЛЕНА таблица opzaxtrd !'
	   		COPY to &ad_normS.opzaxtrd with cdx TYPE FOX2X as 866
		ON ERROR 

		wait 'Обновляю opzaxtov в сети ... '+ad_normS WINDOW NOWAIT  
		use &ad_norm.opzaxtov 
		? '<4.5. Таблица соответствия товарных и полных заходов> - В cети обновляем таблицу opzaxtov !'
		ON ERROR ? '<4.5. Таблица соответствия товарных и полных заходов> - Проблема! В cети НЕ ОБНОВЛЕНА таблица opzaxtov !'
	   		COPY to &ad_normS.opzaxtov with cdx TYPE FOX2X as 866
		ON ERROR 
		USE 
	**   use c:\normativ\opzaxall
	**   COPY to y:\normativ\opzaxall with cdx
	ELSE 
		WAIT 'Вы не подключены к сети! В сети НЕ ОБНОВЛЕНЫ таблицы столбчатых маршрутов:'+CHR(13)+;
		 ' cexlista.dbf , cexlisti.dbf , cexlist1.dbf , cexlist0.dbf , cexa_dse.dbf , spr_sbor.dbf , opzaxtrd.dbf , opzaxtov.dbf '  WINDOW NOWAIT NOCLEAR 
		? '<4.5. Таблица соответствия товарных и полных заходов> - В cети НЕ ОБНОВЛЕНЫ столбчатые таблицы маршрутов:'
		? '	cexlista.dbf , cexlisti.dbf , cexlist1.dbf , cexlist0.dbf , cexa_dse.dbf , spr_sbor.dbf , opzaxtrd.dbf , opzaxtov.dbf '
	ENDIF 	   
ELSE 
	WAIT 'Вы ОТКАЗАЛИСЬ обновлять в сети! В сети НЕ ОБНОВЛЕНЫ таблицы столбчатых маршрутов:'+CHR(13)+;
		' cexlista.dbf , cexlisti.dbf , cexlist1.dbf , cexlist0.dbf , cexa_dse.dbf , spr_sbor.dbf , opzaxtrd.dbf , opzaxtov.dbf '  WINDOW NOWAIT NOCLEAR 
	? '<4.5. Таблица соответствия товарных и полных заходов> - ОТКАЗАЛИСЬ обновлять в сети столбчатые таблицы маршрутов:'
	? '	cexlista.dbf , cexlisti.dbf , cexlist1.dbf , cexlist0.dbf , cexa_dse.dbf , spr_sbor.dbf , opzaxtrd.dbf , opzaxtov.dbf '
	? '	В cети НЕ ОБНОВЛЕНЫ столбчатые таблицы маршрутов !!'
ENDIF 
**До запуска след пункта висит сообщение о результате обновления по текущему пункту!
CLOSE TABLES 

RETURN 

***********************************************
proc f_sprsbor	&& формирования справочника сборочных единиц с цехами-сборщиками 
WAIT 'формирования справочника сборочных единиц с цехами-сборщиками SPR_SBOR.dbf...' WINDOW NOWAIT NOCLEAR  
sele 2
use &ad_norm.outizd_a alia a2 orde detizd
sele 3
use &ad_norm.izdel alia a3 orde codizd

sele dist a1.codizd,a2.cexall as cex,00 as maxlevel ;
	from &ad_norm.specific a1,&ad_norm.cexlista a2 ;
	into dbf &ad_norm.spr_sborS ;
	where a1.codizd=a2.coddet and zaxall=1 ;
	grou by a1.codizd

COPY TO &ad_norm.spr_sbor TYPE FOX2X as 866
USE &ad_norm.spr_sbor
ERASE &ad_norm.spr_sborS.dbf

** уровень входимости
set rela to codizd into a2
repl all maxlevel with a2.maxlevel

** у изделий уровень входимости = 1
set rela to codizd into a3
repl all maxlevel with 1 for found(3) and maxlevel=0

@ 0,80
@ 0,80 say 'Индексируем SPR_SBOR.dbf...' 
inde on codizd tag codizd
inde on codizd+cex tag coduzla
inde on cex+codizd tag cexuzel
inde on str(maxlevel)+codizd+cex tag vxoduzel

CLOSE TABLES
@ 0,80

RETURN 

****************************************************
proc f_minmaxop
WAIT 'В cexlisti.dbf ставим первые и последние операции по заходам...' WINDOW NOWAIT NOCLEAR  
CLOSE TABLES 
sele 1
use &ad_norm.cexlisti alia a1 orde detlistall
sele 2
use &ad_norm.opzaxtrd alia a2 orde detcexzax

sele 3
use &ad_norm.oper\opertrud alia a3 orde cexdetop
sele 1
** т.к. в opzaxtrd из opertrud лаборатория 125, то для связи надо
set rela to coddet+IIF(cex+group='10125','125',cex)+allt(nzax_all) into a2
@ 0,80
@ 0,80 say 'Проставляем №№ минимальных-максимальных операций из opzaxtrd.dbf'
repl all oper_min with allt(a2.oper_min),oper_max with allt(a2.oper_max), ;
		nop_min with a2.nop_min ,nop_max with a2.nop_max

@ 0,80
@ 0,80 say 'Заполняем Наименование минимальных операций из opertrud.dbf'
set rela to IIF(cex+group='10125','125',cex)+coddet+str(val(oper_min)) into a3
repl all naimop_min with a3.n2

@ 0,80
@ 0,80 say 'Заполняем Наименование максимальных операций из opertrud.dbf'
set rela to IIF(cex+group='10125','125',cex)+coddet+str(val(oper_max)) into a3
repl all naimop_max with a3.n2
CLOSE TABLES 
@ 0,80
@ 1,80

RETURN 

