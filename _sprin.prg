** _sprin.prg
** 2026г Смирнова
** Выгруженный с SQL файл sprin (? КУДА, ?dbf ) надо сохранить в fox2x as 866 и проиндексировать!!
CLOSE TABLES
*!*	CLEAR 
WAIT CLEAR 
WAIT 'Подождите, обновляю базу данных <1. ТАБЛИЦА КОДОВ ДСЕ (sprin)>' WINDOW NOWAIT NOCLEAR 

creat table &ad_norm.sprinS (coddet c(11),chnom c(40),naim c(35),codmat c(8),;
					codizd c(11),codizd_prg c(11))
** Надо в DOS варианте
COPY TO &ad_norm.sprin type fox2x as 866
USE &ad_norm.sprin	
ERASE &ad_norm.sprinS.dbf
				
** где будет и какой формат??
** пока как раньше - Но учтем кодировку 866 !!
appe from &ad_vig.sprindb.dat type sdf as 866

repl all codizd_prg with codizd

wait  'Индексирую sprin...' WINDOW NOWAIT NOCLEAR 
inde on coddet tag coddet
inde on chnom tag chnom
inde on ALLT(chnom)+ALLT(naim) tag chnomnaim
inde on allt(chnom)+coddet tag chnomcod
INDE ON ALLT(NAIM)+ALLT(CHNOM) TAG NAIMCHNOM

USE 

IF adir(dr,ad_normS,'d')>0		&& adir(dr,'c:\normativ','d')=1
	wait 'Обновляю sprin в сети ... '+ad_normS WINDOW NOWAIT  
	use &ad_norm.sprin
	? '<1. Таблица кодов ДСЕ>  - В cети обновляем таблицу Sprin!'
	ON ERROR ? '<1. Таблица кодов ДСЕ>  - Проблема! В cети НЕ ОБНОВЛЕНА таблица Sprin!'
	copy to &ad_normS.sprin with cdx TYPE FOX2X as 866
	ON ERROR 
	USE 
	WAIT 'База данных sprin обновлена в сети!' WINDOW NOWAIT NOCLEAR &&  time 1
ELSE 
	wait 'Вы не подключены к сети! В cети НЕ ОБНОВЛЕНА таблица Sprin ...' WINDOW NOWAIT NOCLEAR &&  time 1
	? '<1. Таблица кодов ДСЕ>  - В cети НЕ ОБНОВЛЕНА таблица Sprin!'
ENDIF    

**До запуска след пункта висит сообщение о результате обновления по текущему пункту!
RETURN 
***********************
