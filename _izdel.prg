** _izdel.prg
** 2026г Смирнова
** Выгруженный с SQL файл IZDEL (? КУДА, ?dbf ) надо сохранить в fox2x as 866 и проиндексировать!!

CLOSE TABLES
*!*	CLEAR 
WAIT 'Подождите, обновляю базу данных <2. Список изделий (izdel)>' WINDOW NOWAIT NOCLEAR 

creat table &ad_norm.izd_alls (oboznizd c(15),codizd c(11),chnom c(40),naim c(35),;
	catalog c(8),grup c(1),podgrup c(2),zakaz c(7),npp_1 c(2),npp_2 c(2),;
	npp_3 c(2),npp c(3))
** Надо в DOS варианте TYPE FOX2X as 866 
COPY TO &ad_norm.izd_all type fox2x as 866
USE &ad_norm.IZD_all 
ERASE &ad_norm.izd_alls.dbf
** где будет и какой формат??
** пока как раньше - Но учтем кодировку 866 !!
appe from &ad_vig.izdel.dat type sdf as 866

inde on zakaz+oboznizd tag zakaz
inde on zakaz uniq tag zakaz_u
inde on naim tag naim
inde on grup+podgrup+oboznizd tag grupobozn
inde on oboznizd+grup+podgrup tag oboznizd
inde on oboznizd+grup+podgrup tag obozn
inde on codizd tag codizd
SET ORDER TO codizd

use &ad_norm.sprin IN 0 orde coddet
sele IZD_all
set rela to codizd into sprin
repl all chnom with sprin.chnom, naim with sprin.naim
dele all for EMPTY(chnom)
pack
copy to &ad_norm.izdel for !EMPTY(catalog) TYPE FOX2X as 866		&& catalog!=' '
** в IZD_all.dbf могут быть изделия БЕЗ каталога!!

** теперь вместо IZD_all в этой области открываем izdel
use &ad_norm.izdel 
inde on zakaz+oboznizd tag zakaz
inde on zakaz uniq tag zakaz_u
inde on naim tag naim
inde on codizd tag codizd
inde on grup+podgrup+oboznizd tag grupobozn
inde on oboznizd+grup+podgrup tag oboznizd
inde on oboznizd+grup+podgrup tag obozn
inde on npp tag npp

CLOSE TABLES 
if adir(dr,ad_normS,'d')>0		&& adir(dr,'y:\normativ','d')=1
	wait 'Обновляю izdel в сети ... '+ad_normS WINDOW NOWAIT NOCLEAR 
	use &ad_norm.izdel 
	? '<2. Список изделий (izdel)> - В cети обновляем таблицу izdel.dbf !'
	ON ERROR ? '<2. Список изделий (izdel)> - Проблема! В cети НЕ ОБНОВЛЕНА таблица izdel!'
	copy to &ad_normS.izdel with cdx TYPE FOX2X as 866 
	ON ERROR 
*!*		run copy c:\normativ\izdel.dbf y:\normativ
*!*		run copy c:\normativ\izdel.cdx y:\normativ
	use &ad_norm.izd_all 
	? '<2. Список изделий (izdel)> -В cети обновляем таблицу таблицу izd_all.dbf !'
	ON ERROR ? '<2. Список изделий (izdel)> -  Проблема! В cети НЕ ОБНОВЛЕНА таблица izd_all.dbf !'
	copy to &ad_normS.izd_all with cdx TYPE FOX2X as 866 
	ON ERROR 
	
*!*		run copy c:\normativ\izd_all.dbf y:\normativ
*!*		run copy c:\normativ\izd_all.cdx y:\normativ
	USE 
	WAIT 'Таблицы Изделий izdel.dbf , izd_all.dbf обновлены в сети!' WINDOW NOWAIT NOCLEAR 	&& time 1
else
	WAIT 'Вы не подключены к сети! В сети НЕ ОБНОВЛЕНЫ таблицы Изделий izdel.dbf , izd_all.dbf ...' WINDOW NOWAIT NOCLEAR &&  time 1 
	? '<2. Список изделий (izdel)> - В cети НЕ ОБНОВЛЕНЫ таблицы izdel.dbf , izd_all.dbf !'
ENDIF    

**До запуска след пункта висит сообщение о результате обновления по текущему пункту!
RETURN 

***********************
