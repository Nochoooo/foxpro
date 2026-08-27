** formnorm.prg
** ** 2026г Смирнова
** Идет формирование таблиц  - их в конце формирования надо сохранить в fox2x as 866 !
CLOSE TABLES
*!*	CLEAR 
WAIT 'Подождите, обновляю базу данных <9.3. Формирование norm_mat.dbf>' WINDOW NOWAIT NOCLEAR 

** запомним активную строку экрана, чтобы на неё вернуться
akt_str=_PLINENO

set cloc on
TM1=seco()

WAIT 'Формирую norm_mat и считаю подетальные затраты  ...' WINDOW NOWAIT NOCLEAR 
do fdetzatr

*!*	@ 24,0
*!*	@ 24,0 say 'Определяю тип материалов...' color w+/n
WAIT 'Определяю тип материалов в norm_mat...' WINDOW NOWAIT NOCLEAR 
do form_typ

CLOSE TABLES 
** @ akt_str+1,110 say SPACE(10)

if adir(dr,ad_normS,'d')>0		&& adir(dr,'y:\normativ','d')=1
	wait 'Обновляю norm_mat.dbf в сети ... '+ad_normS WINDOW NOWAIT  
	USE &ad_norm.norm_mat
	? '<9.3. Формирование norm_mat> - В cети обновляем таблицу norm_mat.dbf !'
	ON ERROR ? '<9.3. Формирование norm_mat> - Проблема! В cети НЕ ОБНОВЛЕНА таблица norm_mat.dbf !'
	copy to &ad_normS.norm_mat with cdx TYPE FOX2X as 866
	ON ERROR 
	USE 
ELSE 
	wait 'Вы не подключены к сети! В cети НЕ ОБНОВЛЕНЫ таблицы norm_mat.dbf , det_calc.dbf ...' WINDOW NOWAIT NOCLEAR 	&&  time 1
	? '<9.3. Формирование norm_mat> - В cети НЕ ОБНОВЛЕНЫ таблицы norm_mat.dbf , det_calc.dbf !'
ENDIF    

**До запуска след пункта висит сообщение о результате обновления по текущему пункту!
RETURN 

***************************************************************************************************************
PROCEDURE fdetzatr
clos data
*!*	@ 0,80
*!*	@ 0,80 say 'Формирую состав затрат...' color w+/n

creat table &ad_norm.norm_matS (codizd c(11),CODDET C(11),CODMAT C(8),CEXPOL C(3),;
	CODEDIZM C(4),OBEDIZM C(6),CODZAGT C(3),NORMA N(10,5),KPRM N(14,6),;
	PRICE N(12,2),GOST_TU C(25),GOST_SORT C(25),NAIMMAT C(50),;
	RASMER_OBR C(25),PRICEKUR C(20),TRUD N(11,5),ZARP N(12,3),TYP C(1),;
	CZM c(3))
COPY TO &ad_norm.norm_mat TYPE FOX2X as 866
    USE &ad_norm.norm_mat
  ERASE &ad_norm.norm_matS.dbf
	
**формируем таблицу детальных затрат <norm_mat> ;
**	с учетом разных цехов-получателей материалов по разным изделиям
			** cexlst_a  из  п. 4.4
sele dist coddet,cex,str(zaxcex,1,0) as nzax ;
	from &ad_norm.cexlst_a ;
	into table &ad_norm.cex_dse

**формируем перечень уникальных ДСЕ
sele dist coddet ;
	from &ad_norm.cex_dse ;
	into table &ad_norm.uzdet_u

**формируем перечень уникальных ДСЕ в цехах-получателях материала
sele dist coddet,cex as cexpol ;
	from &ad_norm.cex_dse ;
	into table &ad_norm.uzdtcx_u
	
CLOSE TABLES 

*!*	В процедуре _calcul все эти данные будут вычещены!! нет смысла заполнять !! 2026г
*!*	SELECT det_calc
*!*	appe from &ad_norm.uzdet_u

**формируем перечень уникальных ДСЕ и материалов в цехах-получателях материала
			** normmat из п.5
sele dist a1.coddet,a2.codmat,a2.cexpol ;
	from &ad_norm.uzdet_u a1,&ad_norm.normmat a2 ;
	into dbf &ad_norm.prom ;
	where a1.coddet=a2.coddet

CLOSE TABLES 

*!*	@ 23,0
*!*	@ 23,0 say 'Формирую промежуточную базу...' color w+/n
WAIT 'Добавляю в norm_mat вспомогательные данные из нормативных карт normmat, shifrcen , sh_edizm...' WINDOW NOWAIT NOCLEAR 
sele 2
use &ad_norm.normmat 
set orde to detmatizm
sele 3
use &ad_norm.shifrcen orde codmat			&& п. 7.
sele 4
use &ad_norm.sh_edizm orde codedizm
sele 1
use &ad_norm.norm_mat alia a1
zap
appe from &ad_norm.prom
erase &ad_norm.prom.dbf
*!*	@ 23,0
*!*	@ 23,0 say 'Вставляю вспомогательные данные из нормативных карт ...' color w+/n
set rela to coddet+codmat into normmat
        
repl all codedizm with normmat.codedizm, czm with normmat.czm, cexpol with normmat.cexpol,;
         codzagt with normmat.codzagt, kprm with 1

*!*	@ 23,0
*!*	@ 23,0 say 'Проставляю цены на материалы (с № 1 из ценника)' color w+/n
set rela to codmat+'1' into shifrcen 					&&for val(normmat.num_price)=1
repl all codedizm with shifrcen.codedizm, price with shifrcen.price,;
         gost_tu with shifrcen.gost_tu, gost_sort with shifrcen.gost_sort,;
         naimmat with shifrcen.naimmat, rasmer_obr with shifrcen.rasmer_obr,;
         pricekur with shifrcen.pricekur
         
set rela to
sele 2
set orde to detmatizm
sele 1
set rela to coddet+codmat+alltrim(str(val(codedizm))) into normmat
*!*	@ 23,0
*!*	@ 23,0 say 'Проставляю первые нормы из нормативных карт...' color w+/n
repl all norma with normmat.norma for alltrim(str(val(codedizm)))=alltrim(str(val(normmat.codedizm)))
set rela to
*!*	@ 23,0
*!*	@ 23,0 say 'Проставляю вторые нормы из нормативных карт...' color w+/n
sele 2			&& normmat
set orde to detmatizm2
sele 1
set rela to coddet+codmat+alltrim(str(val(codedizm))) into normmat
repl all norma with normmat.nrcm_2 for alltrim(str(val(codedizm)))=alltrim(str(val(normmat.izm_2))).and.norma=0
set rela to
*!*	@ 23,0
*!*	@ 23,0 say 'Проставляю единицы измерения норм...' color w+/n
set rela to alltrim(str(val(codedizm))) into sh_edizm
repl all obedizm with sh_edizm.obedizm
set rela to
*!*	@ 23,0
*!*	@ 23,0 say 'Индексирую...' color w+/n*
inde on coddet tag coddet
inde on coddet tag coddet_u uniq
inde on codmat tag codmat
inde on coddet+cexpol tag detcex
inde on cexpol+coddet tag cexdet
inde on typ+coddet tag typdet
inde on codmat+alltrim(str(val(codedizm))) tag matedizm
CLOSE TABLES 

*!*	@ 23,0
*!*	@ 23,0 say 'Обновляю трудозатраты...' color w+/n
WAIT 'Проставляю трудозатраты в norm_mat ' WINDOW NOWAIT NOCLEAR 
sele 1
use &ad_norm.norm_mat alia a1 excl
sele 2
use &ad_norm.det_trud orde coddet			&& п. 9.3

sele 1
set rela to coddet into det_trud
repl all trud with det_trud.t1,zarp with det_trud.r1
set rela to

*!*	@ 23,0
*!*	@ 23,0 say 'Удаляю ДСЕ без затрат...' color w+/n
*!*	@ 12,0
*!*	@ 12,12 say 'Список ДСЕ без затрат записывается в файл <NO_ZATR.DBF>' color w+/b

WAIT 'Список ДСЕ без затрат записывается в файл <NO_ZATR.DBF>' WINDOW NOWAIT NOCLEAR 

copy to &ad_norm.prom for trud=0.and.(norma=0.or.codmat=' ')

dele all for trud=0.and.(norma=0.or.codmat=' ')
PACK

sele a1.codizd,a3.oboznizd,a2.coddet,space(15) as chnom,space(30) as naim,a1.allquant ;
     from &ad_norm.outizd a1,&ad_norm.prom a2,&ad_norm.izdel a3,&ad_norm.sprin a4 ;
     into table &ad_norm.no_zatrS ;
     where a1.coddet=a2.coddet.and.a1.codizd=a3.codizd.and.a2.coddet=a4.coddet

COPY TO &ad_norm.no_zatr TYPE FOX2X as 866
    USE &ad_norm.no_zatr
  ERASE &ad_norm.no_zatrS.dbf
     
inde on coddet tag coddet     

CLOSE TABLES 

sele 1
use &ad_norm.prom
sele 2
use &ad_norm.no_zatr orde coddet alia a2
sele 1
set rela to coddet into a2
copy to &ad_norm.prom1 for coddet!=a2.coddet
set rela to 
sele 2			&& no_zatr
appe from &ad_norm.prom1
sele 3
use &ad_norm.sprin alia a3 orde coddet
sele 2			&& no_zatr
set rela to coddet into a3
repl all chnom with a3.chnom,naim with a3.naim

CLOSE TABLES 
erase &ad_norm.prom.dbf
erase &ad_norm.prom1.dbf
erase &ad_norm.uzdet_u.dbf

RETURN 

****************************************************************************
PROCEDURE form_typ 
CLOSE TABLES 
*!*	TM1=seco()

sele 1
use &ad_norm.norm_mat alia a1
repl all typ with ' '
sele 2
use &ad_norm.cex_trud alia a2 orde detcexzax			&&  п. 9.2

sele 1
**set rela to coddet into a3
**repl all czm with a3.cex for a3.zaxlist=1.and.a3.nmarsh=1.and.val(czm)=0
**set rela to

*!*	@ 12,12 say 'Время: '+alltrim(str(seco()-TM1))+' сек.'+' определяю готовые...'
repl all typ with 'P' for codmat<>' '.and.(codzagt='010'.or.codzagt='013'.or.codzagt='014'.or.codzagt='019')

set rela to coddet into a2
set skip to a2
*!*	@ 12,12 say 'Время: '+alltrim(str(seco()-TM1))+' сек.'+' определяю полуфабрикаты...'

**repl all typ with 'F' for codmat<>' '.and.typ='P'.and.trud>0
repl all typ with 'F' for codmat<>' '.and.typ='P' and ;
	a2.t1>0 and a2.cex!='104'
set rela to

*!*	@ 12,12 say 'Время: '+alltrim(str(seco()-TM1))+' сек.'+' определяю материалы ...'

repl all typ with 'M' for codmat<>' '.and.typ=' '

CLOSE TABLES 

wait 'Тип материала в norm_mat определён ' WINDOW time 2

RETURN 

