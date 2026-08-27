** _dettrud.prg
** 2026г Смирнова
** Выгруженный файл надо сохранить в fox2x as 866 и проиндексировать!!
CLOSE TABLES
*!*	CLEAR 
WAIT 'Подождите, обновляю базу данных <9.2. Формирование DET_TRUD' WINDOW NOWAIT NOCLEAR 

*********************************************************************************************************
** _dettrud.prg 25.12.2012
*********************************************************************************************************
** формирование БД цеховых детальных и суммарных детальных трудозатрат
** 

wait 'Формирую БД детальных трудозатрат det_trud' WINDOW NOWAIT NOCLEAR 

sele dist coddet,sum(t1) as t1,sum(r1) as r1,sum(t2) as t2,sum(prem) as prem ;
	from &ad_norm.cex_trud ;
	into dbf &ad_norm.det_trudS ;
	grou by coddet
** Надо в DOS варианте
COPY TO &ad_norm.det_trud type fox2x as 866
USE 
ERASE &ad_norm.det_trudS.dbf

sele 0
use &ad_norm.det_trud excl
inde on coddet tag coddet

wait 'Формирую БД детальных трудозатрат det_truda' WINDOW NOWAIT NOCLEAR 
sele dist coddet,sum(t1) as t1,sum(r1) as r1,sum(t2) as t2,sum(prem) as prem ;
	from &ad_norm.cex_trda ;
	into dbf &ad_norm.det_trdaS ;
	grou by coddet
** Надо в DOS варианте
COPY TO &ad_norm.det_trda type fox2x as 866
USE 
ERASE &ad_norm.det_trdaS.dbf 

sele 0
use &ad_norm.det_trda excl
inde on coddet tag coddet

CLOSE TABLES 

if  adir(dr,ad_normS,'d')>0		&& adir(dr,'y:\normativ','d')=1
	wait 'Обновляю det_trud.dbf в сети ... '+ad_normS WINDOW NOWAIT NOCLEAR  
	USE &ad_norm.det_trud
	? '<9.2. Формирование DET_TRUD> - В cети обновляем таблицу det_trud.dbf !'
	ON ERROR ? '<9.2. Формирование DET_TRUD> - Проблема! В cети НЕ ОБНОВЛЕНА таблица det_trud.dbf!'
		copy to &ad_normS.det_trud with cdx TYPE FOX2X as 866
	ON ERROR 
	
	USE &ad_norm.det_trda
	? '<9.2. Формирование DET_TRUD> - В cети обновляем таблицу det_trda.dbf !'
	ON ERROR ? '<9.2. Формирование DET_TRUD> - Проблема! В cети НЕ ОБНОВЛЕНА таблица det_trda.dbf!'
		copy to &ad_normS.cex_trda with cdx TYPE FOX2X as 866
	ON ERROR 
	USE 
	WAIT 'Базы данных det_trud.dbf , det_trda.dbf обновлены в сети!' WINDOW NOWAIT NOCLEAR 
ELSE 
	wait 'Вы не подключены к сети! В cети НЕ ОБНОВЛЕНЫ таблицы det_trud.dbf , det_trda.dbf ...' WINDOW NOWAIT NOCLEAR 	&&  time 1
	? '<9.2. Формирование DET_TRUD> - В cети НЕ ОБНОВЛЕНЫ таблицы det_trud.dbf , det_trda.dbf !'
ENDIF 

**До запуска след пункта висит сообщение о результате обновления по текущему пункту!

RETURN 



