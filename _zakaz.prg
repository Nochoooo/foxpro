** _zakaz.prg
** 2026г Смирнова
** Выгруженный с SQL файл zakaz (? КУДА, ?dbf ) надо сохранить в fox2x as 866 и проиндексировать!!
CLOSE TABLES
*!*	CLEAR 
WAIT CLEAR 
WAIT 'Подождите, обновляю базу данных <3. Список заказов (zakaz)>' WINDOW NOWAIT NOCLEAR 

USE &ad_norm.zakaz
zap
** где будет и какой формат??
** пока как раньше - Но учтем кодировку 866 !!
appe from &ad_vig.zakaz.dat type sdf  as 866

inde on zakaz+naim_zakaz tag zakaz
inde on zakaz uniq tag zakaz_u
USE

if adir(dr,ad_normS,'d')>0		&& adir(dr,'y:\normativ','d')=1
	wait 'Обновляю ZAKAZ.dbf в сети ... '+ad_normS WINDOW NOWAIT  
*!*	   run copy c:\normativ\zakaz.dbf y:\normativ
*!*	   run copy c:\normativ\zakaz.cdx y:\normativ
	USE &ad_norm.zakaz
	? '<3. Список заказов> - В cети обновляем таблицу ZAKAZ!'
	ON ERROR ? '<3. Список заказов> - Проблема! В cети НЕ ОБНОВЛЕНА таблица ZAKAZ!'
	copy to &ad_normS.zakaz with cdx TYPE FOX2X as 866
	ON ERROR 
	USE 
	WAIT 'База данных ZAKAZ обновлена в сети!' WINDOW NOWAIT NOCLEAR &&  time 1
ELSE 
	wait 'Вы не подключены к сети! В cети НЕ ОБНОВЛЕНА таблица ZAKAZ ...' WINDOW NOWAIT NOCLEAR 	&&  time 1
	? '<3. Список заказов> - В cети НЕ ОБНОВЛЕНА таблица ZAKAZ!'
ENDIF    

**До запуска след пункта висит сообщение о результате обновления по текущему пункту!
RETURN 


