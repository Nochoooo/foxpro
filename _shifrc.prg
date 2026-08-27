** _shifrc.prg
** 2026г Смирнова
** Выгруженный с SQL файл (? КУДА, ?dbf ) надо сохранить в fox2x as 866 и проиндексировать!!
CLOSE TABLES
*!*	CLEAR 
WAIT 'Подождите, обновляю базу данных <7. Шифратор-ценник (shifrcen)>' WINDOW NOWAIT NOCLEAR 
** запомним активную строку экрана, чтобы на неё вернуться
akt_str=_PLINENO

ERASE &ad_norm.SHIFRCEN.CDX
*************!!!!!!!!!!!!!!!!!!*************************************
*** т.к. из текстового файла при зачитывании полей ЧИСЛОВЫХ в VF7 могут теряться значения,
**  то сначала создадим таблицу со структурой, где ВСЕ поля СИМВОЛЬНЫЕ.
** получим в неё данные из файла DAT, а затем их загрузим в правильную таблицу!!!

creat table &ad_norm.shifrcenS (codmat c(8),codedizm c(2),price c(12),gost_tu c(25),sklad c(3),gost_sort c(25), ;
		naimmat c(50),rasmer_obr c(25),pricekur c(20),data_price c(8),num_price c(3),marka c(25))

appe from &ad_vig.shifrc12.dat type sdf as 866
USE 
*********!!!!!!!!!!!!!!!!************************************************************

sele 1
USE &ad_norm.shifrcen
ZAP

appe from &ad_norm.shifrcenS		&&*********!!!!!!!!!!!!!!!
ERASE &ad_norm.shifrcenS.dbf			&&*********!!!!!!!!!!!!!!!

repl all price with price/100

WAIT 'Индексирую shifrcen...' WINDOW NOWAIT NOCLEAR 
inde on codmat+alltrim(str(val(codedizm)))+allt(num_price) tag codmated
inde on codmat+allt(num_price) tag codmat
inde on naimmat+allt(num_price) tag naimmat
inde on marka+codmat+allt(num_price) tag marka

CLOSE TABLES 

WAIT 'Формирую справочник марок материалов...' WINDOW NOWAIT NOCLEAR

sele dist marka,codmat,naimmat from &ad_norm.shifrcen into dbf &ad_norm.markaS where !empty(marka)
** чтобы сохранить в DOS 
COPY TO &ad_norm.marka TYPE FOX2X as 866
USE &ad_norm.marka
ERASE &ad_norm.markaS.dbf

inde on marka tag marka
inde on codmat tag codmat
CLOSE TABLES 

** ?? странный блок... Меняем поля ( norma!!) в сетевой базe normmat  - зачем???
if  adir(dr,ad_normS,'d')>0		&&adir(dr,'y:\normativ','d')=1
	sele 1
	use &ad_norm.shifrcen  orde codmat		&&a1
	sele 2
	use &ad_normS.normmat alia a2 orde codmat 
	set rela to codmat into shifrcen
	copy to &ad_norm.prom for codedizm!=shifrcen.codedizm and izm_2=shifrcen.codedizm
	sele 3
	use &ad_norm.prom alia a3
	inde on coddet tag coddet
	sele 2
	set rela to coddet into a3
	COUNT TO klf for found(3)
	IF klf>0
		** в сетевой базе на Y меняем в полях
		? ' В сети вносим исправления в normmat.dbf в поля ( izm_2, nrcm_2, codedizm, norma !!)  у - '+ALLTRIM(STR(klf))+'записей.'
		ON ERROR ? ' ВНИМАНИЕ!! В сети не внесли исправления в normmat.dbf ! НЕТ СЕТИ или ПРАВ на запись в сеть !!'
		repl all izm_2 with a3.codedizm, nrcm_2 with a3.norma, codedizm with a3.izm_2, norma with a3.nrcm_2 for found(3)
		ON ERROR 
	ENDIF 
	CLOSE TABLES 
	ERASE &ad_norm.prom.dbf
	erase &ad_norm.prom.cdx
endif

if  adir(dr,ad_normS,'d')>0		&& adir(dr,'y:\normativ','d')=1
	wait 'Обновляю SHIFRCEN.dbf в сети ... '+ad_normS WINDOW NOWAIT  
	USE &ad_norm.SHIFRCEN
	? '<7. Шифратор-ценник (shifrcen)> - В cети обновляем таблицу SHIFRCEN.dbf!'
	ON ERROR ? '<7. Шифратор-ценник (shifrcen)> - Проблема! В cети НЕ ОБНОВЛЕНА таблица SHIFRCEN.dbf!'
	copy to &ad_normS.SHIFRCEN with cdx TYPE FOX2X as 866
	ON ERROR 

	wait 'Обновляю marka.dbf в сети ... '+ad_normS WINDOW NOWAIT  
	USE &ad_norm.marka
	? '<7. Шифратор-ценник (shifrcen)> - В cети обновляем таблицу marka.dbf!'
	ON ERROR ? '<7. Шифратор-ценник (shifrcen)> - Проблема! В cети НЕ ОБНОВЛЕНА таблица marka.dbf!'
	copy to &ad_normS.marka with cdx TYPE FOX2X as 866
	ON ERROR 
	USE 
	WAIT 'Базы данных SHIFRCEN.dbf , MARKA.dbf обновлена в сети!' WINDOW NOWAIT NOCLEAR &&  time 1
ELSE 
	wait 'Вы не подключены к сети! В cети НЕ ОБНОВЛЕНЫ таблицы SHIFRCEN.dbf , marka.dbf ...' WINDOW NOWAIT NOCLEAR 	&&  time 1
	? '<7. Шифратор-ценник (shifrcen)> - В cети НЕ ОБНОВЛЕНЫ таблицы SHIFRCEN.dbf ,marka.dbf!'
ENDIF     

**До запуска след пункта висит сообщение о результате обновления по текущему пункту!
RETURN 
