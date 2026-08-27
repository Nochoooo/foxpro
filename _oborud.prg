** _oborud.prg
** 2026г Смирнова
** Выгруженные файлы в C:\normativ\ надо сохранить в fox2x as 866 и проиндексировать!!
CLOSE TABLES
*!*	CLEAR 
WAIT CLEAR 

WAIT 'Подождите, обновляю базу данных <0. Таблицы Оборудования и NORMA (выгрузки берем из C:\NORMATIV\)>' WINDOW NOWAIT NOCLEAR 
IF FILE('&ad_norm.oborud.dat')
	wait wind nowa 'Подождите, обновляю базу данных  - ОБОРУДОВАНИЕ '
	*************!!!!!!!!!!!!!!!!!!*************************************
	*** т.к. из текстового файла при зачитывании полей ЧИСЛОВЫХ в VF7 могут теряться значения,
	**  то сначала создадим таблицу со структурой, где ВСЕ поля СИМВОЛЬНЫЕ.
	** получим в неё данные из файла DAT, а затем их загрузим в правильную таблицу!!!
	creat table &ad_norm.oborud_S (cex c(3),invent C(6),naim c(30),model C(15),koef_smen C(10), ;
			kod C(14),stoim c(10),oststoim c(10),ustan_m c(1), hifr_z c(4),god C(4),rs_mexo C(5), ; 
			tex c(50),k C(11),kod_s C(3),d c(1),am_hifr c(5),pr_p C(1),dtvv_mm c(2),dtvv_gg c(4), ;
			gr c(9),znom C(15), naim_z c(15) )
		APPEND FROM &ad_norm.oborud.dat TYPE SDF as 866
	*********!!!!!!!!!!!!!!!!************************************************************
	
	USE &ad_norm.oborud_.DBF
	zap
	APPEND FROM &ad_norm.oborud_S	&&  ************!!!!!!!!!!!!!**********
	USE 
	ERASE &ad_norm.oborud_S.dbf		&&  ************!!!!!!!!!!!!!**********
ELSE
	WAIT 'Для обновления oborud_.DBF НЕТ выгрузки '+'&ad_norm.oborud.dat' WINDOW NOWAIT TIMEOUT 3	
ENDIF

IF FILE('&ad_norm.SPOBOR.DAT')
	*************!!!!!!!!!!!!!!!!!!*************************************
	*** т.к. из текстового файла при зачитывании полей ЧИСЛОВЫХ в VF7 могут теряться значения,
	**  то сначала создадим таблицу со структурой, где ВСЕ поля СИМВОЛЬНЫЕ.
	** получим в неё данные из файла DAT, а затем их загрузим в правильную таблицу!!!
	creat table &ad_norm.SPOBORS (cod c(14),naim c(30),model C(15), rs_mexo c(10) rs_mexg c(10) rs_elo C(10), ;
			 rs_elg c(10), rs_upr c(10), ves c(10), pow c(10), tex C(15), ploch C(10) )
		APPEND FROM &ad_norm.SPOBOR.dat TYPE SDF as 866
	*********!!!!!!!!!!!!!!!!************************************************************

	USE &ad_norm.SPOBOR.DBF
	zap
	APPEND FROM &ad_norm.SPOBORS	&&  ************!!!!!!!!!!!!!**********
	USE 
	ERASE &ad_norm.SPOBORS.dbf		&&  ************!!!!!!!!!!!!!**********
ELSE
	WAIT 'Для обновления SPOBOR.DBF НЕТ выгрузки '+'&ad_norm.oborud.dat' WINDOW NOWAIT TIMEOUT 3	
ENDIF

IF FILE('&ad_norm.NORMA.DAT')
** 
	*************!!!!!!!!!!!!!!!!!!*************************************
	*** т.к. из текстового файла при зачитывании полей ЧИСЛОВЫХ в VF7 могут теряться значения,
	**  то сначала создадим таблицу со структурой, где ВСЕ поля СИМВОЛЬНЫЕ.
	** получим в неё данные из файла DAT, а затем их загрузим в правильную таблицу!!!
	creat table &ad_norm.NORMAS (pr C(1), cex C(3), grcex C(2), codizd C(11),codmat C(8), ;
		 edizm_1 C(2), codedizm C(6), z C(1), pr2 c(1), norma C(11))
		APPEND FROM &ad_norm.NORMA.dat TYPE SDF as 866
	*********!!!!!!!!!!!!!!!!************************************************************

	USE &ad_norm.NORMA.DBF
	zap
	APPEND FROM &ad_norm.NORMAS		&&  ************!!!!!!!!!!!!!**********
	USE
	ERASE &ad_norm.NORMAS.dbf		&&  ************!!!!!!!!!!!!!**********
	? '<0. Таблицы Оборудования и NORMA (выгрузки из C:\NORMATIV\)>  - Обновлена на ПК таблица NORMA.DBF !'
ELSE
	WAIT 'Для обновления NORMA.DBF НЕТ выгрузки '+'&ad_norm.NORMA.DAT' WINDOW NOWAIT TIMEOUT 3	
ENDIF

IF FILE('&ad_norm.NORMAd.DAT')
	*************!!!!!!!!!!!!!!!!!!*************************************
	*** т.к. из текстового файла при зачитывании полей ЧИСЛОВЫХ в VF7 могут теряться значения,
	**  то сначала создадим таблицу со структурой, где ВСЕ поля СИМВОЛЬНЫЕ.
	** получим в неё данные из файла DAT, а затем их загрузим в правильную таблицу!!!
	creat table &ad_norm.NORMAdS (pr C(1), cex C(3), grcex C(2), codizd C(11),codmat C(8), ;
		 dopmat C(8), edizm_1 C(2), codedizm C(6), z C(1), norma C(11))
	APPEND FROM &ad_norm.NORMAd.DAT TYPE SDF as 866
	*********!!!!!!!!!!!!!!!!************************************************************

	USE &ad_norm.NORMAd.DBF
	zap
	APPEND FROM &ad_norm.NORMAdS	&&  ************!!!!!!!!!!!!!**********
	? '<0. Таблицы Оборудования и NORMA (выгрузки из C:\NORMATIV\)>  - Обновлена на ПК таблица NORMAd.DBF !'
	USE 
	ERASE &ad_norm.NORMAdS.dbf		&&  ************!!!!!!!!!!!!!**********
ELSE
	WAIT 'Для обновления NORMAd.DBF НЕТ выгрузки '+'&ad_norm.NORMAd.DAT' WINDOW NOWAIT TIMEOUT 3	
ENDIF

CLOSE TABLES 
				
IF adir(dr,ad_normS,'d')>0		&& adir(dr,'c:\normativ','d')=1
	IF FILE('&ad_norm.oborud.dat')
		WAIT 'Обновляю oborud_.DBF в сети ... '+ad_normS WINDOW NOWAIT  
		use &ad_norm.oborud_
		? '<0. Таблицы Оборудования и NORMA (выгрузки из C:\NORMATIV\)>  - В cети обновляем таблицу oborud_.DBF !'
		ON ERROR ? '<0. Таблицы Оборудования и NORMA (выгрузки из C:\NORMATIV\)>  - Проблема! В cети НЕ ОБНОВЛЕНА таблица oborud_.DBF !'
		copy to &ad_normS.sprin with cdx TYPE FOX2X as 866
		ON ERROR 
	ELSE
		? 'Для обновления oborud_.DBF НЕТ выгрузки '+'&ad_norm.oborud.dat'
	ENDIF 
	
	IF FILE('&ad_norm.SPOBOR.DAT')
		wait '<0. Таблицы Оборудования и NORMA (выгрузки из C:\NORMATIV\)> Обновляю spobor.DBF в сети ... '+ad_normS WINDOW NOWAIT  
		use &ad_norm.spobor
		? '<0. Таблицы Оборудования и NORMA (выгрузки из C:\NORMATIV\)>  - В cети обновляем таблицу spobor.DBF !'
		ON ERROR ? '<0. Таблицы Оборудования и NORMA (выгрузки из C:\NORMATIV\)>  - Проблема! В cети НЕ ОБНОВЛЕНА таблица spobor.DBF !'
		copy to &ad_normS.spobor with cdx TYPE FOX2X as 866
		ON ERROR 
		USE 
	ELSE 
		? 'Для обновления SPOBOR.DBF НЕТ выгрузки '+'&ad_norm.oborud.dat' 	
	ENDIF 
	
	WAIT 'Базы данных oborud_.DBF , spobor.DBF обновлены в сети!' WINDOW NOWAIT NOCLEAR &&  time 1
ELSE 
	wait 'Вы не подключены к сети! В cети НЕ ОБНОВЛЕНЫ таблицы oborud_.DBF , spobor.DBF ...' WINDOW NOWAIT NOCLEAR &&  time 1
	? '<0. Таблицы Оборудования и NORMA (выгрузки из C:\NORMATIV\)>  - В cети НЕ ОБНОВЛЕНА таблица oborud_.DBF , spobor.DBF !'
ENDIF    

**До запуска след пункта висит сообщение о результате обновления по текущему пункту!
RETURN 
***********************
