** cexdtcal
** ** 2026г Смирнова
** Идет формирование таблиц  - их в конце формирования надо сохранить в fox2x as 866 !
CLOSE TABLES
***************************************************************************
*** Формирование детальных цеховых калькуляций по полному и "товарному" ***
***************************   маршрутам   *********************************
***************************************************************************
** ред.25.12.2012 вместо _CEXDTCA.PRG

TM0=seco()

do f_formuzel
do formcxdtcl
do f_rasschet
do calcizdcex

CLOSE TABLES 

use &ad_norm.calc_all orde detcexzx_u
copy to &ad_norm.calc_dse fiel coddet,cex,nzax,zaxlist,;
	trud_sob,trud_vxod,trud_drug,;
	zarp_sob,zarp_vxod,zarp_drug,;
	prem_proc,prem_sob,prem_vxod,prem_drug,;
	mater_sob,mater_vxod,mater_drug,;
	p_f_sob,p_f_vxod,p_f_drug,;
	got_sob,got_vxod,got_drug,;
	vspm_sob,vspm_vxod,vspm_drug,typ TYPE FOX2X as 866

use &ad_norm.calc_dse
INDEX ON CEX+CODDET+NZAX TAG CEXDETZAX
INDEX ON CODDET+STR(ZAXLIST) TAG DETLIST
INDEX ON CODDET+CEX+NZAX TAG DETCEXZAX
INDEX ON CEX+CODDET+NZAX TAG CEXDETZXOP
INDEX ON CODDET+CEX+NZAX TAG DETCEXZXOP
INDEX ON CODDET+STR(ZAXLIST) TAG DETLISTOP

CLOSE TABLES 
if adir(dr,ad_normS,'d')>0		&& adir(dr,'y:\normativ','d')=1
	wait 'Обновляю в сети ... '+ad_normS WINDOW NOWAIT  

*!*	Её (calc_all) дорабатываем в пункте 11.5 и копируем в сеть !!!
*!*		USE &ad_norm.calc_all
*!*		? '<11.4. Цеховые детальные полные калькуляции (calc_dse.dbf)> - В cети обновляем таблицу calc_all.dbf!'
*!*		ON ERROR ? '<11.4. Цеховые детальные полные калькуляции (calc_dse.dbf)> - Проблема! В cети НЕ ОБНОВЛЕНА таблица calc_all.dbf!'
*!*		copy to &ad_normS.calc_all with cdx TYPE FOX2X as 866
*!*		ON ERROR 
	
	USE &ad_norm.calc_dse
	? '<11.4. Цеховые детальные полные калькуляции (calc_dse.dbf)> - В cети обновляем таблицу calc_dse.dbf!'
	ON ERROR ? '<11.4. Цеховые детальные полные калькуляции (calc_dse.dbf)> - Проблема! В cети НЕ ОБНОВЛЕНА таблица calc_dse.dbf!'
	copy to &ad_normS.calc_dse with cdx TYPE FOX2X as 866
	ON ERROR 
	USE 
	WAIT 'Базы данных calc_all.dbf , calc_dse.dbf обновлены в сети!' WINDOW NOWAIT NOCLEAR &&  time 1
ELSE 
	wait 'Вы не подключены к сети! В cети НЕ ОБНОВЛЕНЫ таблицы calc_all.dbf , calc_dse.dbf ...' WINDOW NOWAIT NOCLEAR 	&&  time 1
	? '<11.4. Цеховые детальные полные калькуляции (calc_dse.dbf)> - В cети НЕ ОБНОВЛЕНЫ таблицы calc_all.dbf , calc_dse.dbf !'
ENDIF    

CLOSE TABLES  

RETURN 
 
****************************************************
**************** формирование перечня цеховых узлов:
****************************************************
proc f_formuzel
WAIT 'формирую перечень цеховых узлов и изделий и расставляю уровни входимости' WINDOW NOWAIT NOCLEAR 
sele dist codizd,00 as maxlevel ;
	from &ad_norm.specific ;
	into dbf &ad_norm.uzel
inde on codizd tag codizd
copy to &ad_norm.prom_uz
use &ad_norm.prom_uz
inde on codizd tag codizd
**формирую перечень узлов, входящих в другие узлы...
sele dist a1.codizd,a1.coddet ;
     from &ad_norm.specific a1, &ad_norm.uzel a2 ;
     into dbf &ad_norm.uzel_uz ;
     where a1.coddet=a2.codizd.and.a1.quant>0
inde on codizd+coddet tag izddet
inde on coddet+codizd tag detizd     
CLOSE TABLES
sele 1
use &ad_norm.uzel_uz alia a1 orde izddet
sele 2
use &ad_norm.uzel alia a2 orde codizd
sele 3
use &ad_norm.prom_uz alia a3 orde codizd
sele 2
set rela to codizd into a1
repl all maxlevel with 1 for codizd!=a1.codizd
set rela to codizd into a3
repl all a3.maxlevel with maxlevel
set rela to

for i=1 to 20
    sele 1
    set orde to detizd
    set rela to codizd into a3
    sele 2
    set rela to codizd into a1
    set skip to a1
    count to CN for codizd=a1.coddet.and.maxlevel=i
    if CN=0
       exit
    else
       repl all a3.maxlevel with i+1 for codizd=a1.coddet.and.maxlevel=i
       set rela to 
       sele 1
       set rela to
       sele 2
       set rela to codizd into a3
       repl all maxlevel with a3.maxlevel for a3.maxlevel=i+1
       set rela to
    endif
endfor
CLOSE TABLES 

erase &ad_norm.prom.dbf
erase &ad_norm.prom.cdx
erase &ad_norm.prom_uz.dbf
erase &ad_norm.prom_uz.cdx

RETURN 

*******************************************************
******* формирование цеховых калькуляций на ДСЕ *******
*******************************************************
proc formcxdtcl
CLOSE TABLES 
WAIT 'формирую цеховые калькуляции на ДСЕ - calc_all' WINDOW NOWAIT NOCLEAR 

**создаем структуру таблицы цеховых калькуляций:     
** 20.12.2012 
      
creat table &ad_norm.calc_allS (codizd c(11),coddet c(11),quant n(7,2),cex c(3),;
	nzax c(2),zaxlist n(2,0),zaxlist_t n(2,0),cex_t c(3),nzax_t c(2),;
	trud_sob n(15,5),trud_vxod n(15,5),trud_drug n(15,5),;
	zarp_sob n(15,5),zarp_vxod n(15,5),zarp_drug n(15,5),;
	prem_proc n(5,1),prem_sob n(15,5),prem_vxod n(15,5),prem_drug n(15,5),;
	mater_sob n(15,5),mater_vxod n(15,5),mater_drug n(15,5),;
	p_f_sob n(15,5),p_f_vxod n(15,5),p_f_drug n(15,5),;
	got_sob n(15,5),got_vxod n(15,5),got_drug n(15,5),;
	vspm_sob n(15,5),vspm_vxod n(15,5),vspm_drug n(15,5),;
	maxlevel n(2,0),typ c(1))
COPY TO &ad_norm.calc_all TYPE FOX2X as 866
    USE &ad_norm.calc_all
  ERASE &ad_norm.calc_allS.dbf
	
sele a1.codizd,a1.codizd as coddet,a2.cex,allt(str(zaxcex,2,0)) as nzax,;
	a2.zaxlist ;
	from &ad_norm.izdel a1, &ad_norm.cexlist0 a2 ;
	into dbf &ad_norm.vtms_izd ;
	where a1.codizd=a2.coddet ;
	grou by a1.codizd,a2.cex,a2.zaxcex

sele a1.codizd,a1.coddet,a2.cex,allt(str(zaxcex,2,0)) as nzax,;
	a2.zaxlist ;
	from &ad_norm.specific a1, &ad_norm.cexlist0 a2 ;
	into dbf vtms_dse ;
	where a1.codizd+a1.coddet=a2.codizd+a2.coddet ;
	grou by a1.codizd,a1.coddet,a2.cex,a2.zaxcex

sele calc_all
**добавляем перечень в таблицу цеховых калькуляций данные из ВТМ:
appe from &ad_norm.vtms_dse

CLOSE TABLES 

sele 1
use &ad_norm.calc_all alia a1
WAIT 'Индексирую таблицу цеховых калькуляций по полным маршрутам calc_all ...' WINDOW  NOWAIT NOCLEAR  
inde on cex+coddet+allt(nzax)+codizd tag cexdetzaxi
inde on cex+codizd+coddet+allt(nzax) tag cexizddtzx
inde on coddet+cex+allt(nzax)+codizd tag detcexzaxi
inde on codizd+cex+allt(nzax)+coddet tag izdcexzxdt
inde on CODIZD+CODDET+STR(ZAXLIST) tag izddetlist
inde on CODDET+CODIZD+STR(ZAXLIST) tag detizlist
inde on codizd+coddet+cex+allt(nzax) tag izddtcexzx

sele 2
use &ad_norm.vtms_izd alia a2
set rela to codizd+coddet into a1
copy to &ad_norm.dobvtmiz for !found(1)
set rela to
sele 1
appe from &ad_norm.dobvtmiz

WAIT 'Проставляем в calc_all применяемость из specific' WINDOW NOWAIT NOCLEAR 
**проставляем собственные затраты
sele 2
use &ad_norm.specific alia a2 orde izddet
sele 1
set rela to codizd+coddet into a2
repl all quant with a2.quant
set rela to
repl all quant with 1 for coddet=codizd

WAIT 'Проставляем в calc_all собственные затраты' WINDOW NOWAIT NOCLEAR 
sele 2
use &ad_norm.cex_trda alia a2

** 24.12.2024 Смирнова проиндексируем по zaxlist, и по нему же свяжем для реляции в calc_all
** on erro inde on coddet+cex+allt(nzax) tag detcexzax
** set orde to detcexzax 	&& этот индекс в реальности был : coddet+cex+ALLTRIM(nzax_all) , где nzax_all м.б. и >10 
** on erro

inde on coddet+cex+str(zaxlist,2) tag detcexzxL
sele 1

set rela to coddet+cex+str(zaxlist,2) into a2
**24.12.2024 

repl all trud_sob with trud_sob+a2.t1,zarp_sob with zarp_sob+a2.r1,;
	prem_sob with prem_sob+a2.prem
set rela to

sele 2
use &ad_norm.norm_mat alia a2 orde detcex
sele 1
set rela to coddet+cex into a2
repl all mater_sob with a2.norma*a2.price for allt(nzax)=='1' and a2.typ='M'
repl all p_f_sob with a2.norma*a2.price for allt(nzax)=='1' and a2.typ='F'

*!*	** чтобы не привязываться к конкретному цеху-получателю ПКИ ;
*!*		из-за возможных ошибок в нормативных картах, ;
*!*		ПКИ привязываем к первому цеху по ВТМ...
set rela to coddet into a2

repl all got_sob with a2.norma*a2.price for zaxlist=1 and a2.typ='P'

sele 2
use &ad_norm.vspm_sum alia a2 orde detcex  && проверить формирование vspm_sum
sele 1
set rela to coddet+cex into a2
repl all vspm_sob with a2.sum_vspm for zaxlist=1 
set rela to

WAIT 'Проставляем в calc_all затраты других цехов' WINDOW NOWAIT NOCLEAR 
**проставляем затраты других цехов
inde on codizd+coddet+str(zaxlist) tag izddetlist

go top
m.codizd=' '
m.coddet=' '
scan
	if codizd+coddet=m.codizd+m.coddet
		repl trud_drug with m.trud_sob+m.trud_drug,;
			zarp_drug with m.zarp_sob+m.zarp_drug,;
			prem_drug with m.prem_sob+m.prem_drug,;
			mater_drug with m.mater_sob+m.mater_drug,;
			p_f_drug with m.p_f_sob+m.p_f_drug,;
			got_drug with m.got_sob+m.got_drug,;
			vspm_drug with m.vspm_sob+m.vspm_drug
	else      
		repl trud_drug with 0,zarp_drug with 0,prem_drug with 0,;
			mater_drug with 0,p_f_drug with 0,got_drug with 0,vspm_drug with 0
	endif
	scat memv
endscan
 
CLOSE TABLES 

WAIT 'формирую промежуточный файл узловых затрат UZL_ZATR' WINDOW NOWAIT NOCLEAR 
sele 1
use &ad_norm.calc_all alia a1 excl
sele 2
use &ad_norm.uzel alia a2 orde codizd
sele 1
set rela to codizd into a2
repl all maxlevel with a2.maxlevel
inde on coddet+cex+allt(nzax) tag detcexzx_u uniq
set rela to coddet into a2

** формирую промежуточный файл узловых затрат UZL_ZATR
copy to &ad_norm.uzl_zatr for coddet=a2.codizd TYPE FOX2X as 866 
use &ad_norm.uzl_zatr
repl all codizd with coddet
inde on coddet+str(zaxlist) tag detlist

**
go top
m.coddet=' '
scan
	if coddet!=m.coddet
		repl zaxlist with 1
	else
		repl zaxlist with m.zaxlist+1	
	endif
	scat memv
endscan

inde on coddet+cex+allt(nzax) tag detcexzax1 for zaxlist=1
inde on coddet+cex+allt(nzax) tag detcexzax

set rela to coddet into a2
repl all maxlevel with a2.maxlevel
CLOSE TABLES 

** ?? 2026 зачем, они уже убиты в f_formuzel ...
erase &ad_norm.prom.dbf
erase &ad_norm.prom.cdx

** формируем вспомогательный файл последних заходов ДСЕ  
**при формировании последних заходов ДСЕ необходимо учитывать ;
	в какую сборку входит ДСЕ,...
** поэтому...
sele codizd,coddet,cex,nzax,max(zaxlist) as zaxlist_mx ;
	from &ad_norm.calc_all ;
	into dbf &ad_norm.posl_zax ;
	grou by codizd,coddet,cex
inde on codizd+coddet+cex+allt(nzax) tag idetcexzax

CLOSE TABLES 

RETURN 

***********************************************
*********** Расчет узловых затрат *************
***********************************************
PROCEDURE f_rasschet

WAIT 'Считаю затраты узлов и записываем затраты на узел в основную таблицу CALC_ALL' WINDOW NOWAIT NOCLEAR 

sele 1
use &ad_norm.calc_all alia a1 orde detcexzaxi excl
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
	WAIT 'Считаю затраты узлов и записываем затраты на узел в основную таблицу CALC_ALL'+CHR(13)+ ; 
   		'Уровень '+str(i,2,0) WINDOW NOWAIT NOCLEAR 
   
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
   
*!*	**   repl all a2.trud_vxod with iif(zaxlist=1,a2.trud_vxod+(trud_sob+trud_vxod)*quant,0),;
*!*	            a2.zarp_vxod with iif(zaxlist=1,a2.zarp_vxod+(zarp_sob+zarp_vxod)*quant,0),;
*!*	            a2.mater_vxod with iif(zaxlist=1,a2.mater_vxod+(mater_sob+mater_vxod)*quant,0),;
*!*	            a2.p_f_vxod with iif(zaxlist=1,a2.p_f_vxod+(p_f_sob+p_f_vxod)*quant,0),;
*!*	            a2.got_vxod with iif(zaxlist=1,a2.got_vxod+(got_sob+got_vxod)*quant,0),;
*!*	            a2.vspm_vxod with iif(zaxlist=1,a2.vspm_vxod+(vspm_sob+vspm_vxod)*quant,0),;
*!*	            a2.trud_drug with a2.trud_drug+trud_drug*quant,;
*!*	            a2.zarp_drug with a2.zarp_drug+zarp_drug*quant,;
*!*	            a2.mater_drug with a2.mater_drug+mater_drug*quant,;
*!*	            a2.p_f_drug with a2.p_f_drug+p_f_drug*quant,;
*!*	            a2.got_drug with a2.got_drug+got_drug*quant,;
*!*	            a2.vspm_drug with a2.vspm_drug+vspm_drug*quant ;
*!*	            for maxlevel=i and codizd=a2.coddet and found(3) ;
*!*	            and codizd!=coddet
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
   
   ** записываем затраты на узел в основную таблицу CALC_ALL
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

*****************************************
** Расчет цеховых калькуляций по изделиям
*****************************************
proc calcizdcex

WAIT 'Считаю цеховые калькуляции по изделиям...' WINDOW NOWAIT NOCLEAR 
sele dist codizd,cex,00000000.00000 as trud_sob,000000000.00000 as zarp_sob,;
     000000000.00000 as prem_sob,000000000.00000 as mater_sob,;
     000000000.00000 as p_f_sob,000000000.00000 as got_sob,;
     000000000.00000 as vspm_sob ;
     from &ad_norm.izddetcx ;
     into dbf &ad_norm.izdcxclc
inde on codizd+cex tag izdcex

CLOSE TABLES 

sele 2
use &ad_norm.calc_all alia a2 orde detcexzx_u excl
sele 3
use &ad_norm.izdcxclc alia a3 orde izdcex excl
sele 1
use &ad_norm.izddetcx alia a1
set rela to coddet+cex+allt(nzax) into a2,codizd+cex into a3
repl all a3.mater_sob with a3.mater_sob+a2.mater_sob*allquant,;
         a3.p_f_sob with a3.p_f_sob+a2.p_f_sob*allquant,;
         a3.got_sob with a3.got_sob+a2.got_sob*allquant,;
         a3.vspm_sob with a3.vspm_sob+a2.vspm_sob*allquant,;
         a3.trud_sob with a3.trud_sob+a2.trud_sob*allquant,;
         a3.zarp_sob with a3.zarp_sob+a2.zarp_sob*allquant,;
         a3.prem_sob with a3.prem_sob+a2.prem_sob*allquant
sele 3
dele all for mater_sob+p_f_sob+got_sob+vspm_sob+zarp_sob=0
pack
inde on cex+codizd tag cexizd

RETURN 
