** _calcul  - 2026  вырезан из  formnorm.prg
** ** 2026г Смирнова
** Идет формирование таблиц  - их в конце формирования надо сохранить в fox2x as 866 !
CLOSE TABLES
*!*	CLEAR 
WAIT 'Подождите, обновляю базу данных <11.1. Общий расчет (det_calc.dbf)>' WINDOW NOWAIT NOCLEAR 

** запомним активную строку экрана, чтобы на неё вернуться
akt_str=_PLINENO

set cloc on
TM1=seco()

*!*	** 2026г Смирнова - формирование norm_mat выделяем в отдельный пункт в п. <9 Трудозатраты > - <9.5 Формирование norm_mat.dbf >
*!*	WAIT 'Формирую norm_mat и считаю подетальные затраты  ...'' WINDOW NOWAIT NOCLEAR 
*!*	do fdetzatr

*!*	*!*	@ 24,0
*!*	*!*	@ 24,0 say 'Определяю тип материалов...' color w+/n
*!*	WAIT 'Определяю тип материалов в norm_mat...'' WINDOW NOWAIT NOCLEAR 
*!*	do form_typ


*!*	@ 24,0
*!*	@ 24,0 say 'Считаю калькуляции по ДСЕ в det_calc...' color w+/n

WAIT 'Считаю калькуляции по всем ДСЕ в det_calc ...' WINDOW NOWAIT NOCLEAR 

creat table &ad_norm.det_calcS (CODDET C(11),TRUD N(11,5),ZARP N(11,5),prem N(11,5), ;
	SUM_MATER N(12,5),SUM_P_F N(14,5),SUM_GOT N(14,5),SUM_VSPM N(12,5),PRICE N(12,2),TYP_KOEFF C(1))
** Надо в DOS варианте
COPY TO &ad_norm.det_calc TYPE FOX2X as 866
    USE &ad_norm.det_calc
  ERASE &ad_norm.det_calcS.dbf

CLOSE TABLES 


MX=0
*!*	@ 24,0 say 'Считаю прямые затраты на узлы...' color rg+/n*
WAIT 'Собираю прямые затраты на узлы' WINDOW NOWAIT NOCLEAR             
sele dist coddet ;
  from &ad_norm.outizd ;
  into table &ad_norm.prom ;
  where maxlevel=0
          
sele dist codizd as coddet,00000.00000 as trud,0000000.000 as zarp, ;
     0000000.000 as prem, 0000000.00 as sum_mater, ;
     00000000.00 as sum_p_f,00000000.00 as sum_got, ;
     0000000.00 as sum_vspm ;
     from &ad_norm.specific ;
     into table &ad_norm.calcuzel ;
     grou by codizd
inde on coddet tag coddet

ERASE &ad_norm.det_calc.cdx
use &ad_norm.det_calc
*!*	dele tag all
zap			&& ?? удалили все записи, добавленные в процедуре - fdetzatr ????
appe from &ad_norm.prom			&& здесь только детали maxlevel=0
appe from &ad_norm.calcuzel		&& здесь все сборки , в т.ч. изделия
inde on coddet tag coddet
     
CLOSE TABLES 
erase &ad_norm.prom.dbf

sele 1
use &ad_norm.calcuzel alia a1 orde coddet
sele 2
use &ad_norm.det_trud alia a2 orde coddet
sele 3
use &ad_norm.norm_mat orde coddet_u alia a3
sele 5
use &ad_norm.outizd alia a5 orde izddet
sele 6
use &ad_norm.izdel alia a6 orde codizd
sele 7
use &ad_norm.det_calc alia a7 orde coddet
sele 8
use &ad_norm.vsp_mat alia a8 orde detmat
sele 9
use &ad_norm.vspm_det alia a9 orde detmat
sele 4
use &ad_norm.out_uzel alia a4 orde izddet
set rela to coddet into a2,coddet into a3,coddet into a9
set skip to a9
sele 1		&&	 calcuzel
set rela to coddet into a4
set skip to a4
*!*	@ 23,0
*!*	@ 23,0 say 'Считаю прямые затраты на узлы по их составу'
*!*	@ 22,0
*!*	@ 22,0 say 'Трудозатраты...' color w+/n
WAIT 'Считаю прямые затраты на узлы по их составу - '+CHR(13)+'Трудозатраты...' WINDOW NOWAIT NOCLEAR 
repl all trud with trud+a2.t1*a4.allquant, ;
		zarp with zarp+a2.r1*a4.allquant, ;
		prem with prem+a2.prem*a4.allquant
repl all zarp with 0.001 for zarp<0.001 and trud>0
*!*	@ 22,0
*!*	@ 22,0 say 'Материалы...' color w+/n
WAIT 'Считаю прямые затраты на узлы по их составу - '+CHR(13)+'Материалы...' WINDOW NOWAIT NOCLEAR 
repl all sum_mater with sum_mater+iif(a3.price*a3.norma<0.01,0.01,a3.price*a3.norma)*a4.allquant for a3.typ='M'
*!*	@ 22,0
*!*	@ 22,0 say 'Полуфабрикаты...' color w+/n
WAIT 'Считаю прямые затраты на узлы по их составу - '+CHR(13)+'Полуфабрикаты...' WINDOW NOWAIT NOCLEAR 
repl all sum_p_f with sum_p_f+iif(a3.price*a3.norma<0.01,0.01,a3.price*a3.norma)*a4.allquant for a3.typ='F'
*!*	@ 22,0
*!*	@ 22,0 say 'Готовые...' color w+/n
WAIT 'Считаю прямые затраты на узлы по их составу - '+CHR(13)+'Готовые...' WINDOW NOWAIT NOCLEAR 
repl all sum_got with sum_got+iif(a3.price*a3.norma<0.01,0.01,a3.price*a3.norma)*a4.allquant for a3.typ='P'
*!*	@ 22,0
*!*	@ 22,0 say 'Вспомогательные...' color w+/n
WAIT 'Считаю прямые затраты на узлы по их составу - '+CHR(13)+'Вспомогательные...' WINDOW NOWAIT NOCLEAR 
repl all sum_vspm with sum_vspm+iif(a9.price*a9.norma<0.01,0.01,a9.price*a9.norma)*a4.allquant

*!*	@ 23,0
*!*	@ 23,0 say 'Считаю прямые затраты на изделия по их составу'
WAIT 'Считаю прямые затраты на изделия по их составу - ' WINDOW NOWAIT NOCLEAR 
sele 4
set rela to
sele 5
set rela to coddet into a2,coddet into a3,coddet into a9
set skip to a9
sele 1
set rela to coddet into a5
set skip to a5
*!*	@ 22,0
*!*	@ 22,0 say 'Трудозатраты...' color w+/n
WAIT 'Считаю прямые затраты на изделия по их составу - '+CHR(13)+'Трудозатраты...' WINDOW NOWAIT NOCLEAR 
repl all trud with trud+a2.t1*a5.allquant, ;
		zarp with zarp+a2.r1*a5.allquant, ;
		prem with prem+a2.prem*a5.allquant
repl all zarp with 0.001 for zarp<0.001 and trud>0
*!*	@ 22,0
*!*	@ 22,0 say 'Материалы...' color w+/n
WAIT 'Считаю прямые затраты на изделия по их составу - '+CHR(13)+'Материалы...' WINDOW NOWAIT NOCLEAR 
repl all sum_mater with sum_mater+iif(a3.price*a3.norma<0.01,0.01,a3.price*a3.norma)*a5.allquant for a3.typ='M'
*!*	@ 22,0
*!*	@ 22,0 say 'Полуфабрикаты...' color w+/n
WAIT 'Считаю прямые затраты на изделия по их составу - '+CHR(13)+'Полуфабрикаты...' WINDOW NOWAIT NOCLEAR 
repl all sum_p_f with sum_p_f+iif(a3.price*a3.norma<0.01,0.01,a3.price*a3.norma)*a5.allquant for a3.typ='F'
*!*	@ 22,0
*!*	@ 22,0 say 'Готовые...' color w+/n
WAIT 'Считаю прямые затраты на изделия по их составу - '+CHR(13)+'Готовые...' WINDOW NOWAIT NOCLEAR 
repl all sum_got with sum_got+iif(a3.price*a3.norma<0.01,0.01,a3.price*a3.norma)*a5.allquant for a3.typ='P'
*!*	@ 22,0
*!*	@ 22,0 say 'Вспомогательные...' color w+/n
WAIT 'Считаю прямые затраты на изделия по их составу - '+CHR(13)+'' WINDOW NOWAIT NOCLEAR 
repl all sum_vspm with sum_vspm+iif(a9.price*a9.norma<0.01,0.01,a9.price*a9.norma)*a5.allquant

*!*	@ 22,0 say 'Добавляем собственные затраты на узлы...' color w+/n
*!*	@ 22,0    
set rela to
sele 1
*!*	@ 22,0
*!*	@ 22,0 say 'Трудозатраты...' color w+/n
WAIT 'Добавляем собственные затраты на узлы... - '+CHR(13)+'Трудозатраты...' WINDOW NOWAIT NOCLEAR 
set rela to coddet into a2
repl all trud with trud+a2.t1, ;
		zarp with zarp+a2.r1, prem with prem+a2.prem for coddet=a2.coddet
repl all zarp with 0.001 for zarp<0.001 and trud>0

set rela to coddet into a3
*!*	@ 22,0
*!*	@ 22,0 say 'Материалы...' color w+/n
WAIT 'Добавляем собственные затраты на узлы... - '+CHR(13)+'Материалы...' WINDOW NOWAIT NOCLEAR 
repl all sum_mater with sum_mater+iif(a3.price*a3.norma<0.01,0.01,a3.price*a3.norma) for coddet=a3.coddet and a3.typ='M'
*!*	@ 22,0
*!*	@ 22,0 say 'Полуфабрикаты...' color w+/n
WAIT 'Добавляем собственные затраты на узлы... - '+CHR(13)+'Полуфабрикаты...' WINDOW NOWAIT NOCLEAR 
repl all sum_p_f with sum_p_f+iif(a3.price*a3.norma<0.01,0.01,a3.price*a3.norma) for coddet=a3.coddet and a3.typ='F'
*!*	@ 22,0
*!*	@ 22,0 say 'Готовые...' color w+/n
WAIT 'Добавляем собственные затраты на узлы... - '+CHR(13)+'Готовые...' WINDOW NOWAIT NOCLEAR 
repl all sum_got with sum_got+iif(a3.price*a3.norma<0.01,0.01,a3.price*a3.norma) for coddet=a3.coddet and a3.typ='P'
*!*	@ 22,0
*!*	@ 22,0 say 'Вспомогательные...' color w+/n
WAIT 'Добавляем собственные затраты на узлы... - '+CHR(13)+'Вспомогательные...' WINDOW NOWAIT NOCLEAR 
set rela to coddet into a8
set skip to a8
repl all sum_vspm with sum_vspm+iif(a8.price*a8.norma<0.01,0.01,a8.price*a8.norma)
set rela to

*!*	@ 22,0 say 'Копируем суммарные затраты по узлам в файл det_calc...'
WAIT 'Копируем суммарные затраты по узлам в файл det_calc...' WINDOW NOWAIT NOCLEAR 

sele 7
set rela to coddet into a1
repl all trud with a1.trud,zarp with a1.zarp, prem with a1.prem , ;
		 sum_mater with a1.sum_mater,;
         sum_p_f with a1.sum_p_f,sum_got with a1.sum_got,;
         sum_vspm with a1.sum_vspm
set rela to

*!*	@ 24,0 say 'Собираем прямые затраты на ДСЕ в файле det_calc...' color rg+/n*
*!*	@ 23,0
*!*	@ 23,0 say 'Трудозатраты...' color w+/n
WAIT 'Собираем прямые затраты на ДСЕ в файле det_calc...'+CHR(13)+'Трудозатраты...' WINDOW NOWAIT NOCLEAR 
set rela to coddet into a1,coddet into a2
repl all trud with a2.t1,zarp with a2.r1, ;
		 prem with a2.prem for coddet=a2.coddet.and.coddet!=a1.coddet
repl all zarp with 0.001 for zarp<0.001 and trud>0
*!*	@ 23,0
*!*	@ 23,0 say 'Материалы...' color w+/n
WAIT 'Собираем прямые затраты на ДСЕ в файле det_calc...'+CHR(13)+'Материалы...' WINDOW NOWAIT NOCLEAR 
set rela to coddet into a1,coddet into a3
repl all sum_mater with iif(a3.price*a3.norma<0.01,0.01,a3.price*a3.norma) for a3.typ='M'.and.coddet=a3.coddet.and.coddet!=a1.coddet
*!*	@ 23,0
*!*	@ 23,0 say 'Полуфабрикаты...' color w+/n
WAIT 'Собираем прямые затраты на ДСЕ в файле det_calc...'+CHR(13)+'Полуфабрикаты...' WINDOW NOWAIT NOCLEAR 
repl all sum_p_f with iif(a3.price*a3.norma<0.01,0.01,a3.price*a3.norma) for a3.typ='F'.and.coddet=a3.coddet.and.coddet!=a1.coddet
*!*	@ 23,0
*!*	@ 23,0 say 'Готовые...' color w+/n
WAIT 'Собираем прямые затраты на ДСЕ в файле det_calc...'+CHR(13)+'Готовые...' WINDOW NOWAIT NOCLEAR 
repl all sum_got with iif(a3.price*a3.norma<0.01,0.01,a3.price*a3.norma) for a3.typ='P'.and.coddet=a3.coddet.and.coddet!=a1.coddet
*!*	@ 23,0
*!*	@ 23,0 say 'Вспомогательные...' color w+/n
WAIT 'Собираем прямые затраты на ДСЕ в файле det_calc...'+CHR(13)+'Вспомогательные...' WINDOW NOWAIT NOCLEAR 
set rela to coddet into a1,coddet into a9
set skip to a9
repl all sum_vspm with iif(a9.price*a9.norma<0.01,0.01,a9.price*a9.norma) for coddet=a9.coddet and coddet!=a1.coddet

set rela to

clos data

CLOSE TABLES 
** @ akt_str+1,110 say SPACE(10)

if adir(dr,ad_normS,'d')>0		&& adir(dr,'y:\normativ','d')=1
	wait 'Обновляю det_calc.dbf в сети ... '+ad_normS WINDOW NOWAIT  
	USE &ad_norm.det_calc
	? '<11.1. Общий расчет (det_calc.dbf)> - В cети обновляем таблицу det_calc.dbf!'
	ON ERROR ? '<11.1. Общий расчет (det_calc.dbf)> - Проблема! В cети НЕ ОБНОВЛЕНА таблица det_calc.dbf!'
	copy to &ad_normS.det_calc with cdx TYPE FOX2X as 866
	ON ERROR 
	USE 
	WAIT 'Базы данных det_calc.dbf обновлены в сети!' WINDOW NOWAIT NOCLEAR &&  time 1
ELSE 
	wait 'Вы не подключены к сети! В cети НЕ ОБНОВЛЕНЫ таблицы  det_calc.dbf ...' WINDOW NOWAIT NOCLEAR 	&&  time 1
	? '<11.1. Общий расчет (det_calc.dbf)> - В cети НЕ ОБНОВЛЕНЫ таблицы  det_calc.dbf !'
ENDIF    

**До запуска след пункта висит сообщение о результате обновления по текущему пункту!

RETURN 

