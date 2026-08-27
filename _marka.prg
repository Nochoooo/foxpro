** _marka.prg
** 2026г Смирнова
** надо сохранить в fox2x as 866 и проиндексировать!!
CLOSE TABLES
*!*	CLEAR 
WAIT 'Подождите, обновляю базу данных <8. Марки материалов> справочник марок материалов...' WINDOW NOWAIT NOCLEAR 

sele dist marka,codmat,naimmat from &ad_norm.shifrcen into dbf &ad_norm.markaS where !empty(marka)
** чтобы сохранить в DOS 
COPY TO &ad_norm.marka TYPE FOX2X as 866
USE &ad_norm.marka
ERASE &ad_norm.markaS.dbf

inde on marka tag marka
inde on codmat tag codmat
CLOSE TABLES 

if adir(dr,ad_normS,'d')>0		&& adir(dr,'y:\normativ','d')=1
	wait 'Обновляю marka.dbf в сети ... '+ad_normS WINDOW NOWAIT  
	USE &ad_norm.marka
	? '<8. Марки материалов> - В cети обновляем таблицу marka.dbf!'
	ON ERROR ? '<8. Марки материалов> - Проблема! В cети НЕ ОБНОВЛЕНА таблица marka.dbf!'
	copy to &ad_normS.marka with cdx TYPE FOX2X as 866
	ON ERROR 
	USE 
	WAIT 'База данных marka.dbf обновлена в сети!' WINDOW NOWAIT NOCLEAR &&  time 1
ELSE 
	wait 'Вы не подключены к сети! В cети НЕ ОБНОВЛЕНА таблица marka.dbf ...' WINDOW NOWAIT NOCLEAR 	&&  time 1
	? '<8. Марки материалов> - В cети НЕ ОБНОВЛЕНА таблица marka.dbf!'
ENDIF    

**До запуска след пункта висит сообщение о результате обновления по текущему пункту!
RETURN 




