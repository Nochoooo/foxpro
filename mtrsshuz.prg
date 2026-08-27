** mtrsshuz.prg
** ** 2026г Смирнова
** Идет формирование таблиц  - их в конце формирования надо сохранить в fox2x as 866 !
CLOSE TABLES
*************************************************************
*********** расчет расшифровки материальных затрат по сборкам **************
****************************************************************************
WAIT 'Идет расчет расшифровки цеховых материальных затрат по сборкам...' +CHR(13)+;
	'Собираю вспомогательные материалы по составу узлов' WINDOW NOWAIT NOCLEAR 
**кроме групп 100 - 398
**    (val(left(a2.codmat,3))<100 or val(left(a2.codmat,3))>398) and ;
** c марта 2021 убрано ограничение групп с 100 по 398
**расчет с учетом применяемости на тех.нужды, КВИ и образцы:

sele a1.codizd,a2.cexpol,a2.codmat,a2.edizm_1,a3.obedizm,;
     round(a2.norma/a2.koef*a1.allquant,5) as norma,;
     a2.codedizm,'V' as typ ;
     from &ad_norm.out_uzel a1, &ad_norm.vspm_det a2, &ad_norm.sh_edizm a3 ;
     into table &ad_norm.prom2v ;
     where a1.coddet=a2.coddet.and.a2.norma>0.and.a2.koef>0;
     .and.alltrim(str(val(a2.codedizm)))=alltrim(a3.codedizm) 
     
** @ 23,0 say 'Собираю вспомогательные материалы как основные по составу узлов'
** группы 100 - 398

**    (val(left(a2.codmat,3))<100 or val(left(a2.codmat,3))>398) and ;
** c марта 2021 убрано ограничение групп с 100 по 398

**расчет с учетом применяемости на тех.нужды, КВИ и образцы:
** sele a1.codizd,a2.cexpol,a2.codmat,a2.edizm_1,a3.obedizm,;
**     round(a2.norma/a2.koef*a1.allquant,5) as norma,;
**   a2.codedizm,'M' as typ ;
**     from out_uzel a1,vspm_det a2,sh_edizm a3 ;
**     into table prom2o ;
**     where a1.coddet=a2.coddet.and.a2.norma>0.and.a2.koef>0;
**     .and.alltrim(str(val(a2.codedizm)))=alltrim(a3.codedizm).and.;
**     val(left(a2.codmat,3))>99.and.val(left(a2.codmat,3))<399
     
CLOSE TABLES 
WAIT 'Идет расчет расшифровки цеховых материальных затрат по сборкам...' +CHR(13)+;
	'Собираю материалы по сплавам, если сплав собственного производства' WINDOW NOWAIT NOCLEAR 
** определяем по цех-спискам поставщиков сплава:
sele 3
use &ad_norm.cexlist alia a3 orde detizd
sele 2
use &ad_norm.norm_mat alia a2 orde codmat
set rela to coddet into a3
set skip to a3
sele 1
use &ad_norm.splav
set rela to cod_splav into a2
repl all cex with left(allt(a3.cexlist),3)

** если поставщик - литейный цех, то расшихтовываем сплав:
sele a1.coddet,a2.cex,a2.cod_splav,a2.codmat,a1.codedizm,a1.obedizm,;
     a1.norma*a2.quant/100 as norma,'M' as typ ;
     from &ad_norm.norm_mat a1, &ad_norm.splav a2 ;
     into table &ad_norm.matsplav ;
     where a1.codmat=a2.cod_splav.and.a1.norma>0.and.left(a2.cex,1)='1'

WAIT 'Идет расчет расшифровки цеховых материальных затрат по сборкам...' +CHR(13)+;
	 'Собираю материалы в сплавах по составу узлов' WINDOW NOWAIT NOCLEAR 
    
sele a1.codizd,a2.cex as cexpol,a2.codmat,a2.codedizm,a2.obedizm,;
     '    ' as edizm_1,round(a2.norma*a1.allquant,5) as norma,;
     0000000000.00 as price,0000000000.00 as stoim,a2.typ ;
     from &ad_norm.out_uzel a1, &ad_norm.matsplav a2 ;
     into table &ad_norm.matspluz ;
     where a1.coddet=a2.coddet.and.a2.norma>0
     
WAIT 'Идет расчет расшифровки цеховых материальных затрат по сборкам...' +CHR(13)+;
	 'Oсновные материалы, п/фабрикаты и готовые по составу сборок' WINDOW NOWAIT NOCLEAR 

**расчет с учетом применяемости на тех.нужды, КВИ и образцы:
sele a1.codizd,a2.cexpol,a2.codmat,a2.codedizm,a2.obedizm,;
     '    ' as edizm_1,round(a2.norma*a1.allquant,5) as norma,;
     0000000000.00 as price,0000000000.00 as stoim,a2.typ ;
     from &ad_norm.out_uzel a1, &ad_norm.norm_mat a2 ;
     into table &ad_norm.prom ;
     where a1.coddet=a2.coddet.and.a2.norma>0
     
WAIT 'Идет расчет расшифровки цеховых материальных затрат по сборкам...' +CHR(13)+;
  'Собираю все материалы вместе' WINDOW NOWAIT NOCLEAR 

**    (val(left(a2.codmat,3))<100 or val(left(a2.codmat,3))>398) and ;
** c марта 2021 убрано ограничение групп с 100 по 398

appe from &ad_norm.prom2v
** appe from prom2o
     
CLOSE TABLES  
erase &ad_norm.prom1v.dbf
** erase prom1o.dbf
erase &ad_norm.prom2v.dbf
** erase prom2o.dbf
erase &ad_norm.prom4.dbf

sele dist codizd,codmat,cexpol,edizm_1,codedizm,obedizm,;
          00000.000000 as norma,00000.000000 as norma_tex,;
          000000000.00 as price,0000000000.00 as stoim,;
          0000000000.00 as stoim_tex,typ ;
          from &ad_norm.prom ;
          into table &ad_norm.rsmtcxuzS ;
          where norma!=0
          
COPY TO &ad_norm.rsmtcxuz TYPE FOX2X as 866
    USE &ad_norm.rsmtcxuz
  ERASE &ad_norm.rsmtcxuzS.dbf

repl all edizm_1 with codedizm for val(edizm_1)=0

CLOSE TABLES  

WAIT 'Идет расчет расшифровки цеховых материальных затрат по сборкам...' +CHR(13)+;
 'Считаю суммарные нормы'  WINDOW NOWAIT NOCLEAR 
sele 1
use &ad_norm.prom alia a1
sele 2
use &ad_norm.rsmtcxuz alia a2
inde on codmat+obedizm tag matedizm
inde on cexpol+codmat+codizd+obedizm+typ tag cexmatizd
inde on cexpol+codizd+codmat+obedizm+typ tag cexizdmat
inde on codizd+codmat+cexpol+obedizm+typ tag izdmatcex
inde on codizd+cexpol+codmat+obedizm+typ tag izdcexmat
sele 3
use &ad_norm.shifrcen alia a3 orde codmated
sele 4
use &ad_norm.sh_edizm alia a4 orde codedizm
sele 1
set rela to codizd+cexpol+codmat+obedizm+typ into a2
repl all a2.norma with a2.norma+norma
set rela to
WAIT 'Идет расчет расшифровки цеховых материальных затрат по сборкам...' +CHR(13)+;
 'Проставляю цены с номером 1'  WINDOW NOWAIT NOCLEAR 
sele 2    
set rela to codmat+alltrim(str(val(codedizm)))+'1' into a3
repl all price with a3.price for val(a3.num_price)=1
WAIT 'Идет расчет расшифровки цеховых материальных затрат по сборкам...' +CHR(13)+;
 'Считаю стоимость материалов'  WINDOW NOWAIT NOCLEAR 
repl all stoim with price*norma   &&/a4.koef for a4.koef>0
set rela to
CLOSE TABLES  

erase &ad_norm.prom.cdx
erase &ad_norm.prom.dbf

WAIT 'Идет расчет расшифровки материальных затрат по сборкам...'  WINDOW NOWAIT NOCLEAR 

sele dist codizd,codmat,edizm_1,codedizm,obedizm,price,;
          00000.00000 as norma,00000.00000 as norma_tex,;
          000000000.00 as stoim,000000000.00 as stoim_tex,typ ;
          from &ad_norm.rsmtcxuz into table &ad_norm.rsshmtuzS 

COPY TO &ad_norm.rsshmtuz TYPE FOX2X as 866
    USE &ad_norm.rsshmtuz
  ERASE &ad_norm.rsshmtuzS.dbf
 
CLOSE TABLES  

sele 1
use &ad_norm.rsmtcxuz alia a1
sele 2
use &ad_norm.rsshmtuz alia a2 excl
inde on codmat+obedizm tag matedizm
inde on codmat+codizd+obedizm tag matizdediz
inde on codizd+codmat+obedizm tag izdmatediz
inde on codizd+codmat+typ tag izdmattyp
sele 1
set rela to codizd+codmat+typ into a2
WAIT 'Идет расчет расшифровки материальных затрат по сборкам...'+CHR(13)+ ; 
	'Считаю суммарные нормы и стоимость материалов' WINDOW NOWAIT NOCLEAR 
repl all a2.norma with a2.norma+norma
set rela to
sele 2
repl all stoim with price*norma
set rela to

CLOSE TABLES 

if adir(dr,ad_normS,'d')>0		&& adir(dr,'y:\normativ','d')=1
	wait 'Обновляю в сети ... '+ad_normS WINDOW NOWAIT  

	USE &ad_norm.RSMTCXUZ
	? '<13.3. По сборкам> - В cети обновляем таблицу RSMTCXUZ.dbf!'
	ON ERROR ? '<13.3. По сборкам> - Проблема! В cети НЕ ОБНОВЛЕНА таблица RSMTCXUZ.dbf!'
	copy to &ad_normS.RSMTCXUZ with cdx TYPE FOX2X as 866
	ON ERROR 
	
	USE &ad_norm.RSSHMTUZ
	? '<13.3. По сборкам > - В cети обновляем таблицу RSSHMTUZ.dbf!'
	ON ERROR ? '<13.3. По сборкам > - Проблема! В cети НЕ ОБНОВЛЕНА таблица RSSHMTUZ.dbf!'
	copy to &ad_normS.RSSHMTUZ with cdx TYPE FOX2X as 866
	ON ERROR 

*!*		USE &ad_norm.calc_uz
*!*		? '<13.3. По сборкам > - В cети обновляем таблицу calc_uz.dbf!'
*!*		ON ERROR ? '<13.3. По сборкам > - Проблема! В cети НЕ ОБНОВЛЕНА таблица calc_uz.dbf!'
*!*		copy to &ad_normS.RSSHMTUZ with cdx TYPE FOX2X as 866
*!*		ON ERROR 
	
	USE 
	WAIT 'Базы данных RSMTCXUZ.dbf , RSSHMTUZ.dbf , обновлены в сети!' WINDOW NOWAIT NOCLEAR &&  time 1
ELSE 
	wait 'Вы не подключены к сети! В cети НЕ ОБНОВЛЕНЫ таблицы  RSMTCXUZ.dbf , RSSHMTUZ.dbf ...' WINDOW NOWAIT NOCLEAR 	&&  time 1
	? '<13.3. По сборкам > - В cети НЕ ОБНОВЛЕНЫ таблицы  RSMTCXUZ.dbf , RSSHMTUZ.dbf  !'
ENDIF    

CLOSE TABLES  

RETURN 

