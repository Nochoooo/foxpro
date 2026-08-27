** frmnormm.prg
** ** 2026г Смирнова
** Идет формирование таблиц  - их в конце формирования надо сохранить в fox2x as 866 !
CLOSE TABLES
** запомним активную строку экрана, чтобы на неё вернуться
akt_str=_PLINENO
TM1n=seco()

WAIT 'Считаю подетальные затраты normmatm ...' WINDOW NOWAIT NOCLEAR 

do fdetztrm

WAIT 'Определяю тип материалов...' WINDOW NOWAIT NOCLEAR 

do formtypm

wait 'Считаю калькуляции по узлам detcalc3 ...'  WINDOW NOWAIT NOCLEAR 

do _calculm

CLOSE TABLES
WAIT 'Расчет таблиц с максимальными ценами закончен! Продолжительность '+str((seco()-TM1n)/60,5,1)+' мин.' WINDOW TIMEOUT 3 && NOWAIT NOCLEAR 

** @ akt_str+1,110 say SPACE(10)

if adir(dr,ad_normS,'d')>0		&& adir(dr,'y:\normativ','d')=1
	wait 'Обновляю в сети ... '+ad_normS WINDOW NOWAIT  
	USE &ad_norm.normmatm
	? '<11.3. Максимальные цены> - В cети обновляем таблицу normmatm.dbf!'
	ON ERROR ? '<11.3. Максимальные цены> - Проблема! В cети НЕ ОБНОВЛЕНА таблица normmatm.dbf!'
	copy to &ad_normS.normmatm with cdx TYPE FOX2X as 866
	ON ERROR 
	
	USE &ad_norm.detcalcm
	? '<11.3. Максимальные цены> - В cети обновляем таблицу detcalcm.dbf!'
	ON ERROR ? '<11.3. Максимальные цены> - Проблема! В cети НЕ ОБНОВЛЕНА таблица detcalcm.dbf!'
	copy to &ad_normS.detcalcm with cdx TYPE FOX2X as 866
	ON ERROR 
	USE 
	WAIT 'Базы данных normmatm.dbf , detcalcm.dbf обновлены в сети!' WINDOW NOWAIT NOCLEAR &&  time 1
ELSE 
	wait 'Вы не подключены к сети! В cети НЕ ОБНОВЛЕНЫ таблицы normmatm.dbf , detcalcm.dbf ...' WINDOW NOWAIT NOCLEAR 	&&  time 1
	? '<11.3. Максимальные цены> - В cети НЕ ОБНОВЛЕНЫ таблицы normmatm.dbf , detcalcm.dbf !'
ENDIF    

**До запуска след пункта висит сообщение о результате обновления по текущему пункту!

CLOSE TABLES 
RETURN 
*******************************************************************
PROCEDURE fdetztrm
CLOSE TABLES 

wait 'Считаю подетальные затраты normmatm - '+CHR(13)+;
	'Формирую подетальный состав затрат...'  WINDOW NOWAIT NOCLEAR 

creat table &ad_norm.normmatmS (CODDET C(11),CODMAT C(8),CEXPOL C(3),CODEDIZM C(4),;
	OBEDIZM C(6),CODZAGT C(3),NORMA N(10,5),KPRM N(14,6),PRICE N(12,2),;
	GOST_TU C(25),GOST_SORT C(25),NAIMMAT C(50),RASMER_OBR C(25),;
	PRICEKUR C(20),TRUD N(11,5),ZARP N(12,3),TYP C(1),CZM c(3))
COPY TO &ad_norm.normmatm TYPE FOX2X as 866
    USE &ad_norm.normmatm
  ERASE &ad_norm.normmatmS.dbf
  
sele dist coddet from &ad_norm.cexlist into table &ad_norm.det_u
sele dist codizd as coddet from &ad_norm.cexlist into table &ad_norm.uzel_u
appe from &ad_norm.det_u
 
sele dist coddet from &ad_norm.uzel_u into table &ad_norm.uzdet_u
CLOSE TABLES

use &ad_norm.detcalcm
appe from &ad_norm.uzdet_u
sele dist a1.coddet,a2.codmat,a2.cexpol ;
	from &ad_norm.uzdet_u a1,&ad_norm.normmat a2 ;
	into dbf &ad_norm.prom ;
	where a1.coddet=a2.coddet

CLOSE TABLES

erase &ad_norm.det_u.dbf
erase &ad_norm.uzel_u.dbf

sele 2
use &ad_norm.normmat alia a2
set orde to detmatizm
sele 3
use &ad_norm.shifrcen alia a3 orde codmat
sele 4
use &ad_norm.sh_edizm alia a4 orde codedizm
sele 5
use &ad_norm.cexlist1 alia a5 orde detizdlist
sele 1
use &ad_norm.normmatm alia a1
zap
appe from &ad_norm.prom
erase &ad_norm.prom.dbf

wait 'Считаю подетальные затраты normmatm - '+CHR(13)+;
	'Вставляю вспомогательные данные из нормативных карт...' WINDOW NOWAIT NOCLEAR 
set rela to coddet+codmat into a2
        
repl all codedizm with a2.codedizm,czm with a2.czm,cexpol with a2.cexpol,;
         codzagt with a2.codzagt,kprm with 1

**выбираем цеха-получатели материалов из первых цехов по цех-спискам 
set rela to coddet into a5		&& cexlist1 alia a5
set skip to a5

repl all cexpol with a5.cex for found(5) and a5.zaxlist=1 and a5.cex!=cexpol

wait 'Считаю подетальные затраты normmatm - '+CHR(13)+;
	'Проставляю действующие цены (с № 1 из ценника)' WINDOW NOWAIT NOCLEAR 
set rela to codmat+'1' into a3		&&  shifrcen alia a3
repl all codedizm with a3.codedizm,price with a3.price,;
         gost_tu with a3.gost_tu,gost_sort with a3.gost_sort,;
         naimmat with a3.naimmat,rasmer_obr with a3.rasmer_obr,;
         pricekur with a3.pricekur
         
wait 'Считаю подетальные затраты normmatm - '+CHR(13)+;
	'Проставляю максимальные цены (с № 3 из ценника)' WINDOW NOWAIT NOCLEAR 
set rela to codmat into a3
set skip to a3
repl all price with a3.price,pricekur with a3.pricekur for a3.price>price
         
set rela to

sele 2		&& normmat alia a2
set orde to detmatizm
sele 1
set rela to coddet+codmat+alltrim(str(val(codedizm))) into a2
wait 'Считаю подетальные затраты normmatm - '+CHR(13)+;
	'Проставляю первые нормы из нормативных карт...' WINDOW NOWAIT NOCLEAR 
repl all norma with a2.norma for alltrim(str(val(codedizm)))=alltrim(str(val(a2.codedizm)))
set rela to
wait 'Считаю подетальные затраты normmatm - '+CHR(13)+;
	'Проставляю вторые нормы из нормативных карт...' WINDOW NOWAIT NOCLEAR 
sele 2
set orde to detmatizm2
sele 1
set rela to coddet+codmat+alltrim(str(val(codedizm))) into a2
repl all norma with a2.nrcm_2 for alltrim(str(val(codedizm)))=alltrim(str(val(a2.izm_2))).and.norma=0
set rela to
wait 'Считаю подетальные затраты normmatm - '+CHR(13)+;
	'Проставляю единицы измерения норм...' WINDOW NOWAIT NOCLEAR 
set rela to alltrim(str(val(codedizm))) into a4
repl all obedizm with a4.obedizm
set rela to
wait 'Считаю подетальные затраты normmatm - '+CHR(13)+;
	'Индексирую...' WINDOW NOWAIT NOCLEAR 
inde on coddet tag coddet
inde on coddet tag coddet_u uniq
inde on codmat tag codmat
inde on coddet+cexpol tag detcex
inde on cexpol+coddet tag cexdet
inde on typ+coddet tag typdet
inde on codmat+alltrim(str(val(codedizm))) tag matedizm
CLOSE TABLES 

wait 'Считаю подетальные затраты normmatm - '+CHR(13)+;
	'Обновляю трудозатраты...' WINDOW NOWAIT NOCLEAR 

sele 1
use &ad_norm.normmatm alia a1 excl
sele 2
use &ad_norm.det_trud alia a2 orde coddet
sele 3
use &ad_norm.cexlist1 alia a3 orde detizdlist
sele 1
set rela to coddet into a2
repl all trud with a2.t1,zarp with a2.r1
set rela to

wait 'Считаю подетальные затраты normmatm - '+CHR(13)+;
	'Удаляю ДСЕ без затрат...'+CHR(13)+; 
	'Список ДСЕ без затрат записывается в файл <NO_ZATR.DBF>' WINDOW NOWAIT NOCLEAR
copy to &ad_norm.prom for trud=0.and.(norma=0.or.codmat=' ')
dele all for trud=0.and.(norma=0.or.codmat=' ')
pack
sele a1.codizd,a3.oboznizd,a2.coddet,a4.chnom,a4.naim, a1.allquant ;
     from &ad_norm.outizd a1, &ad_norm.prom a2, &ad_norm.izdel a3, &ad_norm.sprin a4 ;
     into table &ad_norm.no_zatr ;
     where a1.coddet=a2.coddet.and.a1.codizd=a3.codizd.and.a2.coddet=a4.coddet
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
sele 2
appe from &ad_norm.prom1
sele 3
use &ad_norm.sprin alia a3 orde coddet
sele 2
set rela to coddet into a3
repl all chnom with a3.chnom,naim with a3.naim
CLOSE TABLES 
erase &ad_norm.prom.dbf
erase &ad_norm.prom1.dbf
erase &ad_norm.uzdet_u.dbf

CLOSE TABLES
RETURN 
***************************************************************
PROCEDURE formtypm
CLOSE TABLES  

TM1=seco()
sele 1
use &ad_norm.normmatm alia a1
repl all typ with ' '
sele 2
use &ad_norm.cex_trud alia a2 orde detcexzax
sele 1

wait 'Определяю тип материалов normmatm - '+CHR(13)+;
 		' определяю готовые ...Время: '+alltrim(str(seco()-TM1))+' сек.' WINDOW NOWAIT NOCLEAR 

repl all typ with 'P' for codmat<>' '.and.(codzagt='010'.or.codzagt='013'.or.codzagt='014'.or.codzagt='019')

set rela to coddet into a2
set skip to a2
wait 'Определяю тип материалов normmatm - '+CHR(13)+;
 		' определяю полуфабрикаты ... Время: '+alltrim(str(seco()-TM1))+' сек.' WINDOW NOWAIT NOCLEAR 
**repl all typ with 'F' for codmat<>' '.and.typ='P'.and.trud>0
repl all typ with 'F' for codmat<>' '.and.typ='P' and ;
	a2.t1>0 and a2.cex!='104'
set rela to

wait 'Определяю тип материалов normmatm - '+CHR(13)+;
 		' определяю материалы ... Время: '+alltrim(str(seco()-TM1))+' сек.' WINDOW NOWAIT NOCLEAR 
repl all typ with 'M' for codmat<>' '.and.typ=' '

CLOSE TABLES 

sele 1
use &ad_norm.normmatm alia a1
sele 2
use &ad_norm.sh_poluf alia a2 orde coddet
sele 1
set rela to coddet into a2
repl all typ with a2.typ for coddet=a2.coddet and a2.typ!=' '
CLOSE TABLES 

WAIT 'Расчет normmatm.dbf закончен! Продолжительность '+str((seco()-TM1n)/60,5,1)+' мин.' WINDOW TIMEOUT 3 && NOWAIT NOCLEAR 

RETURN 
***************************************************
PROCEDURE _calculm

creat table detcalcmS (CODDET C(11),TRUD N(11,5),ZARP N(11,5),PREM N(11,5),;
	SUM_MATER N(12,5),SUM_P_F N(14,5),SUM_GOT N(14,5),SUM_VSPM N(12,5),PRICE N(12,2),TYP_KOEFF C(1))
COPY TO &ad_norm.detcalcm TYPE FOX2X as 866
    USE &ad_norm.detcalcm
  ERASE &ad_norm.detcalcmS

CLOSE TABLES 

MX=0
TM1=seco()
WAIT 'Считаю прямые затраты по узлам detcalcm ...' WINDOW NOWAIT NOCLEAR 

**формируем перечень деталей          
sele dist coddet ;
	from &ad_norm.outizd_a ;
	into table &ad_norm.prom ;
	where maxlevel=0

**формируем перечень сборочных единиц          
sele dist codizd as coddet,00000.00000 as trud,0000000.000 as zarp,;
     0000000.000 as prem,0000000.00 as sum_mater,00000000.00 as sum_p_f, ;
     00000000.00 as sum_got,;
     0000000.00 as sum_vspm ;
     from &ad_norm.specific ;
     into table &ad_norm.calcuzel ;
     grou by codizd
inde on coddet tag coddet

ERASE &ad_norm.detcalcm.cdx
use &ad_norm.detcalcm
*!*	dele tag all
zap
**собираем вместе детали и сборки
appe from &ad_norm.prom
appe from &ad_norm.calcuzel
inde on coddet tag coddet
     
CLOSE TABLES 
erase &ad_norm.prom.dbf

sele 1
use &ad_norm.calcuzel alia a1 orde coddet
sele 2
use &ad_norm.det_trud alia a2 orde coddet
sele 3
use &ad_norm.normmatm orde coddet_u alia a3
sele 5
use &ad_norm.outizd alia a5 orde izddet
sele 6
use &ad_norm.izdel alia a6 orde codizd
sele 7
use &ad_norm.detcalcm alia a7 orde coddet
sele 8
use &ad_norm.vsp_mat alia a8 orde detmat
rein
sele 9
use &ad_norm.vspm_det alia a9 orde detmat
rein
sele 4
use &ad_norm.out_uzel alia a4 orde izddet
set rela to coddet into a2,coddet into a3
sele 1
set rela to coddet into a4
set skip to a4
WAIT 'Считаю калькуляции по узлам detcalcm ...'+CHR(13)+ ;
	'calcuzel Считаю прямые затраты на узлы по их составу' +CHR(13)+ ;
	'Трудозатраты...' WINDOW NOWAIT NOCLEAR 
repl all trud with trud+a2.t1*a4.allquant,zarp with zarp+a2.r1*a4.allquant ,;
		 prem with prem+a2.prem*a4.allquant
repl all zarp with 0.001 for zarp<0.001 and trud>0
WAIT 'Считаю калькуляции по узлам detcalcm ...'+CHR(13)+ ;
	'calcuzel Считаю прямые затраты на узлы по их составу' +CHR(13)+ ;
	'Материалы...' WINDOW NOWAIT NOCLEAR
repl all sum_mater with sum_mater+iif(a3.price*a3.norma<0.01,;
	0.01,a3.price*a3.norma)*a4.allquant for a3.typ='M'
WAIT 'Считаю калькуляции по узлам detcalcm ...'+CHR(13)+ ;
	'calcuzel Считаю прямые затраты на узлы по их составу' +CHR(13)+ ;
	'Полуфабрикаты...' WINDOW NOWAIT NOCLEAR
repl all sum_p_f with sum_p_f+iif(a3.price*a3.norma<0.01,0.01,;
	a3.price*a3.norma)*a4.allquant for a3.typ='F'
WAIT 'Считаю калькуляции по узлам detcalcm ...'+CHR(13)+ ;
	'calcuzel Считаю прямые затраты на узлы по их составу' +CHR(13)+ ;
	'Готовые...' WINDOW NOWAIT NOCLEAR
repl all sum_got with sum_got+iif(a3.price*a3.norma<0.01,0.01,;
	a3.price*a3.norma)*a4.allquant for a3.typ='P'
WAIT 'Считаю калькуляции по узлам detcalcm ...'+CHR(13)+ ;
	'calcuzel Считаю прямые затраты на узлы по их составу' +CHR(13)+ ;
	'Вспомогательные...' WINDOW NOWAIT NOCLEAR
sele b1.codizd,b1.coddet,b2.codmat,b1.allquant,b2.norma,max(b3.price) as price,b2.koef ;
from &ad_norm.calcuzel b4, &ad_norm.out_uzel b1, &ad_norm.vspm_det b2, &ad_norm.shifrcen b3 ;
into dbf &ad_norm.promvspm  ;
where b4.coddet=b1.codizd and b1.coddet=b2.coddet and b2.norma>0 and b2.codmat=b3.codmat grou by b1.codizd,b1.coddet,b2.codmat

sele codizd,round(sum(allquant*norma*price/koef),5) as sum_vspm ;
	from &ad_norm.promvspm ;
	into dbf &ad_norm.sumvspmu grou by codizd
inde on codizd tag codizd
sele 1
set rela to coddet into sumvspmu
repl all sum_vspm with sumvspmu.sum_vspm

WAIT 'Считаю калькуляции по узлам detcalc3 ...'+CHR(13)+ ;
	'calcuzel Считаю прямые затраты на изделия по их составу' WINDOW NOWAIT NOCLEAR 
sele 4
set rela to
sele 5
**set rela to coddet into a2,coddet into a3,coddet into a9
**set skip to a9
set rela to coddet into a2,coddet into a3
sele 1
set rela to coddet into a5
set skip to a5
WAIT 'Считаю калькуляции по узлам detcalc3 ...'+CHR(13)+ ;
	'calcuzel Считаю прямые затраты на изделия по их составу'+CHR(13)+ ;
	'Трудозатраты...' WINDOW NOWAIT NOCLEAR 
repl all trud with trud+a2.t1*a5.allquant,zarp with zarp+a2.r1*a5.allquant,;
		 prem with prem+a2.prem*a5.allquant
repl all zarp with 0.001 for zarp<0.001 and trud>0
WAIT 'Считаю калькуляции по узлам detcalc3 ...'+CHR(13)+ ;
	'calcuzel Считаю прямые затраты на изделия по их составу'+CHR(13)+ ;
	'Материалы...' WINDOW NOWAIT NOCLEAR 
repl all sum_mater with sum_mater+iif(a3.price*a3.norma<0.01,0.01,a3.price*a3.norma)*a5.allquant for a3.typ='M'
WAIT 'Считаю калькуляции по узлам detcalc3 ...'+CHR(13)+ ;
	'calcuzel Считаю прямые затраты на изделия по их составу'+CHR(13)+ ;
	'Полуфабрикаты...' WINDOW NOWAIT NOCLEAR 
repl all sum_p_f with sum_p_f+iif(a3.price*a3.norma<0.01,0.01,a3.price*a3.norma)*a5.allquant for a3.typ='F'
WAIT 'Считаю калькуляции по узлам detcalc3 ...'+CHR(13)+ ;
	'calcuzel Считаю прямые затраты на изделия по их составу'+CHR(13)+ ;
	'Готовые...' WINDOW NOWAIT NOCLEAR 
repl all sum_got with sum_got+iif(a3.price*a3.norma<0.01,0.01,a3.price*a3.norma)*a5.allquant for a3.typ='P'
WAIT 'Считаю калькуляции по узлам detcalc3 ...'+CHR(13)+ ;
	'calcuzel Считаю прямые затраты на изделия по их составу'+CHR(13)+ ;
	'Вспомогательные...' WINDOW NOWAIT NOCLEAR 
**repl all sum_vspm with sum_vspm+iif(a9.price*a9.norma<0.01,0.01,a9.price*a9.norma)*a5.allquant  for found(9)
sele b1.codizd,b1.coddet,b2.codmat,b1.allquant,b2.norma,;
	max(b3.price) as price,b2.koef ;
	from &ad_norm.calcuzel b4, &ad_norm.outizd_a b1, &ad_norm.vspm_det b2, &ad_norm.shifrcen b3 ;
	into dbf &ad_norm.promvspm  ;
	where b4.coddet=b1.codizd and b1.coddet=b2.coddet and b2.norma>0 and b2.codmat=b3.codmat ;
	grou by b1.codizd,b1.coddet,b2.codmat
sele codizd,round(sum(allquant*norma*price/koef),5) as sum_vspm ;
	from &ad_norm.promvspm ;
	into dbf &ad_norm.sumvspmi grou by codizd
inde on codizd tag codizd
sele 1
set rela to coddet into sumvspmu
repl all sum_vspm with sumvspmu.sum_vspm

WAIT 'Считаю калькуляции по узлам detcalc3 ...'+CHR(13)+ ;
	'calcuzel Добавляем собственные затраты на сборку узлов и изделий...' WINDOW NOWAIT NOCLEAR 

set rela to
sele 1
WAIT 'Считаю калькуляции по узлам detcalc3 ...'+CHR(13)+ ;
	'calcuzel Добавляем собственные затраты на сборку узлов и изделий...'+CHR(13)+ ;
	'Трудозатраты...' WINDOW NOWAIT NOCLEAR 
set rela to coddet into a2
repl all trud with trud+a2.t1,zarp with zarp+a2.r1, ;
		 prem with prem+a2.prem for coddet=a2.coddet
repl all zarp with 0.001 for zarp<0.001 and trud>0

set rela to coddet into a3
WAIT 'Считаю калькуляции по узлам detcalc3 ...'+CHR(13)+ ;
	'calcuzel Добавляем собственные затраты на сборку узлов и изделий...'+CHR(13)+ ;
	'Материалы...' WINDOW NOWAIT NOCLEAR 
repl all sum_mater with sum_mater+iif(a3.price*a3.norma<0.01,0.01,a3.price*a3.norma) for coddet=a3.coddet and a3.typ='M'
WAIT 'Считаю калькуляции по узлам detcalc3 ...'+CHR(13)+ ;
	'calcuzel Добавляем собственные затраты на сборку узлов и изделий...'+CHR(13)+ ;
	'Полуфабрикаты...' WINDOW NOWAIT NOCLEAR 
repl all sum_p_f with sum_p_f+iif(a3.price*a3.norma<0.01,0.01,a3.price*a3.norma) for coddet=a3.coddet and a3.typ='F'
WAIT 'Считаю калькуляции по узлам detcalc3 ...'+CHR(13)+ ;
	'calcuzel Добавляем собственные затраты на сборку узлов и изделий...'+CHR(13)+ ;
	'Готовые...' WINDOW NOWAIT NOCLEAR 
repl all sum_got with sum_got+iif(a3.price*a3.norma<0.01,0.01,a3.price*a3.norma) for coddet=a3.coddet and a3.typ='P'
WAIT 'Считаю калькуляции по узлам detcalc3 ...'+CHR(13)+ ;
	'calcuzel Добавляем собственные затраты на сборку узлов и изделий...'+CHR(13)+ ;
	'Вспомогательные...' WINDOW NOWAIT NOCLEAR 
set rela to coddet into a8
set skip to a8
repl all sum_vspm with sum_vspm+iif(a8.price*a8.norma<0.01,0.01,a8.price*a8.norma) for found(8)
set rela to

WAIT 'Считаю калькуляции по узлам detcalcm ...'+CHR(13)+ ;
	'Копируем из calcuzel суммарные затраты по узлам в файл detcalcm...'  WINDOW NOWAIT NOCLEAR

sele 7
set rela to coddet into a1
repl all trud with a1.trud,zarp with a1.zarp,prem with a1.prem, ;
		 sum_mater with a1.sum_mater,;
         sum_p_f with a1.sum_p_f,sum_got with a1.sum_got,;
         sum_vspm with a1.sum_vspm
set rela to

WAIT 'Считаю калькуляции по узлам detcalc3 ...'+CHR(13)+ ;
	'Собираем прямые затраты на ДСЕ в файле detcalcm...'+CHR(13)+ ;
	'Трудозатраты...' WINDOW NOWAIT NOCLEAR 
set rela to coddet into a1,coddet into a2
repl all trud with a2.t1,zarp with a2.r1, ;
		 prem with a2.prem for coddet=a2.coddet.and.coddet!=a1.coddet
repl all zarp with 0.001 for zarp<0.001 and trud>0
WAIT 'Считаю калькуляции по узлам detcalc3 ...'+CHR(13)+ ;
	'Собираем прямые затраты на ДСЕ в файле detcalc3...'+CHR(13)+ ;
	'Материалы...' WINDOW NOWAIT NOCLEAR 
set rela to coddet into a1,coddet into a3
repl all sum_mater with iif(a3.price*a3.norma<0.01,0.01,a3.price*a3.norma) for a3.typ='M'.and.coddet=a3.coddet.and.coddet!=a1.coddet
WAIT 'Считаю калькуляции по узлам detcalc3 ...'+CHR(13)+ ;
	'Собираем прямые затраты на ДСЕ в файле detcalc3...'+CHR(13)+ ;
	'Полуфабрикаты...' WINDOW NOWAIT NOCLEAR 
repl all sum_p_f with iif(a3.price*a3.norma<0.01,0.01,a3.price*a3.norma) for a3.typ='F'.and.coddet=a3.coddet.and.coddet!=a1.coddet
WAIT 'Считаю калькуляции по узлам detcalc3 ...'+CHR(13)+ ;
	'Собираем прямые затраты на ДСЕ в файле detcalc3...'+CHR(13)+ ;
	'Готовые...' WINDOW NOWAIT NOCLEAR 
repl all sum_got with iif(a3.price*a3.norma<0.01,0.01,a3.price*a3.norma) for a3.typ='P'.and.coddet=a3.coddet.and.coddet!=a1.coddet
WAIT 'Считаю калькуляции по узлам detcalc3 ...'+CHR(13)+ ;
	'Собираем прямые затраты на ДСЕ в файле detcalc3...'+CHR(13)+ ;
	'Вспомогательные...' WINDOW NOWAIT NOCLEAR 
set rela to coddet into a1,coddet into a9
set skip to a9
repl all sum_vspm with iif(a9.price*a9.norma<0.01,0.01,a9.price*a9.norma) for coddet=a9.coddet and coddet!=a1.coddet and found(9)

set rela to
WAIT 'Расчет detcalcm.dbf закончен! Продолжительность '+str((seco()-TM1)/60,5,1)+' мин.' WINDOW TIMEOUT 3 && NOWAIT NOCLEAR 

CLOSE TABLES 

RETURN 



