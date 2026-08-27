** _calcizd
** ** 2026г Смирнова
** Идет формирование таблиц  - их в конце формирования надо сохранить в fox2x as 866 !
CLOSE TABLES

***************************
** редакция с изменениями 25.12.2012
***************************
WAIT 'Идет расчет статей калькуляции по изделиям zatr_izd.dbf ...' WINDOW NOWAIT NOCLEAR 

** расчет прямых затрат 
** 20.12.2012 добавляем в запрос поля с премиями: 
sele dist codizd,oboznizd,grup,podgrup,000000.0000 as trud,;
          000000000.00 as zarp,000000000.00 as prem,;
          000000000.00 as stoim_mat,;
          000000000.00 as stoim_pfp,000000000.00 as stoim_sht,;
          000000000.00 as stoim_gotp,000000000.00 as stoim_agr,;
          000000000.00 as stoim_vspm ;
    from &ad_norm.izdel ;
into table &ad_norm.zatr_izdS 

COPY TO &ad_norm.zatr_izd TYPE FOX2X as 866
    USE &ad_norm.zatr_izd
  ERASE &ad_norm.zatr_izdS.dbf
	
inde on grup+podgrup+oboznizd tag grupobozn
inde on codizd tag codizd
          
****************	в сеть выкладываем calc_izd.dbf , полученную в п.13.1 !!! *****************************
****************  там имена полей другие здесь формирование блокируем !!! ****************************
*!*	sele dist codizd,oboznizd,grup,podgrup,000000.0000 as trud,;
*!*			000000000.00 as zarp,000000000.00 as prem,;
*!*	    	000000000.00 as stoim_mat,000000000.00 as stoim_p_f,;
*!*	    	000000000.00 as stoim_got,000000000.00 as stoim_vspm ;
*!*	    from &ad_norm.izdel ;
*!*	    into table &ad_norm.calc_izdS 

*!*	COPY TO &ad_norm.calc_izd TYPE FOX2X as 866
*!*	    USE &ad_norm.calc_izd
*!*	  ERASE &ad_norm.calc_izdS.dbf

*!*	inde on grup+podgrup+oboznizd tag grupobozn
*!*	inde on codizd tag codizd
CLOSE TABLES 

sele 1
use &ad_norm.rasshmat alia a1
*!*	sele 2
*!*	use &ad_norm.calc_izd alia a2 orde codizd
sele 3
use &ad_norm.outizd alia a3 orde izddet
sele 4
use &ad_norm.det_trud alia a4 orde coddet
*!*	sele 3
*!*	set rela to coddet into a4,codizd into a2
*!*	repl all a2.trud with a2.trud+a4.t1*a3.allquant,;
*!*	         a2.zarp with a2.zarp+a4.r1*a3.allquant

*!*	** 21.12.2012 добавляем премию:
*!*	repl all a2.prem with a2.prem+a4.prem*a3.allquant

*!*	set rela to

*!*	sele 1			&& rasshmat 
*!*	set rela to codizd into a2		&& calc_izd
*!*	repl all a2.stoim_mat with a2.stoim_mat+a1.stoim for a1.typ='M'
*!*	repl all a2.stoim_p_f with a2.stoim_p_f+a1.stoim for a1.typ='F'
*!*	repl all a2.stoim_got with a2.stoim_got+a1.stoim for a1.typ='P'
*!*	repl all a2.stoim_vspm with a2.stoim_vspm+a1.stoim for a1.typ='V'
*!*	set rela to

** расчет прямых затрат с разбивкой по группам в  zatr_izd.dbf
sele 2
use zatr_izd alia a2 orde codizd
sele 3
set rela to coddet into a4,codizd into a2
repl all a2.trud with a2.trud+a4.t1*a3.allquant,;
         a2.zarp with a2.zarp+a4.r1*a3.allquant

** 21.12.2012 добавляем премию:
repl all a2.prem with a2.prem+a4.prem*a3.allquant

set rela to

sele 1
set rela to codizd into a2			&&  zatr_izd
repl all a2.stoim_mat with a2.stoim_mat+a1.stoim for a1.typ='M'
repl all a2.stoim_pfp with a2.stoim_pfp+a1.stoim for a1.typ='F'	&& полуфабрикаты прочие
repl all a2.stoim_sht with a2.stoim_sht+a1.stoim for a1.typ='P'	
repl all a2.stoim_gotp with a2.stoim_gotp+a1.stoim for a1.typ='P'
repl all a2.stoim_agr with a2.stoim_agr+a1.stoim for a1.typ='P'
repl all a2.stoim_vspm with a2.stoim_vspm+a1.stoim for a1.typ='V'

CLOSE TABLES 

if adir(dr,ad_normS,'d')>0		&& adir(dr,'y:\normativ','d')=1
	wait 'Обновляю в сети ... '+ad_normS WINDOW NOWAIT  

******** в сеть выкладываем таблицу из п.13.1  , здесь даже имена полей другие!!! *******************
*!*		USE &ad_norm.calc_izd
*!*		? '<13.2 Калькуляции по изделиям> - В cети обновляем таблицу calc_izd.dbf!'
*!*		ON ERROR ? '<13.2 Калькуляции по изделиям)> - Проблема! В cети НЕ ОБНОВЛЕНА таблица calc_izd.dbf!'
*!*		copy to &ad_normS.calc_izd with cdx TYPE FOX2X as 866
*!*		ON ERROR 
	
	USE &ad_norm.zatr_izd
	? '<13.2 Калькуляции по изделиям zatr_izd.dbf > - В cети обновляем таблицу zatr_izd.dbf!'
	ON ERROR ? '<13.2 Калькуляции по изделиям zatr_izd.dbf > - Проблема! В cети НЕ ОБНОВЛЕНА таблица zatr_izd.dbf!'
	copy to &ad_normS.zatr_izd with cdx TYPE FOX2X as 866
	ON ERROR 
	USE 
	WAIT 'Базы данных zatr_izd.dbf обновлены в сети!' WINDOW NOWAIT NOCLEAR &&  time 1
ELSE 
	wait 'Вы не подключены к сети! В cети НЕ ОБНОВЛЕНЫ таблицы  zatr_izd.dbf ...' WINDOW NOWAIT NOCLEAR 	&&  time 1
	? '<13.2 Калькуляции по изделиям zatr_izd.dbf > - В cети НЕ ОБНОВЛЕНЫ таблицы  zatr_izd.dbf !'
ENDIF    

CLOSE TABLES  

RETURN 
