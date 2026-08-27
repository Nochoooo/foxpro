** _specifn.prg
** 2026г Смирнова
** На Y: надо сохранить в fox2x as 866 и проиндексировать!!

CLOSE TABLES
**CLEAR 
WAIT 'Подождите, обновляю базу данных <Спецификации>' WINDOW NOWAIT NOCLEAR 

if !file(ad_norm+'cexlist.dbf')
	WAIT 'Не найден файл-источник <CEXLIST.DBF> для формирования Специфкаций !!' WINDOW NOWAIT NOCLEAR 
	retu
endif

sele dist codizd,coddet,quant ;
	from &ad_norm.cexlist ;
	into dbf &ad_norm.specificS ;
	where codizd!=coddet
COPY TO &ad_norm.specific TYPE FOX2X as 866
USE &ad_norm.specific
ERASE &ad_norm.specificS.dbf

wait 'Индексирую...' WINDOW NOWAIT  
inde on coddet tag coddet   
inde on coddet+codizd tag detizd
inde on codizd+coddet tag izddet   
inde on codizd tag codizd

use &ad_norm.sprin IN 0 orde coddet
sele specific
set rela to coddet into sprin
copy to &ad_norm.no_zakaz fiel coddet,sprin.chnom,sprin.naim for sprin.codizd=' ' TYPE FOX2X as 866
use &ad_norm.no_zakaz
inde on coddet tag coddet
if RECCOUNT()>0
	wait 'Эти ДСЕ не отнесены на изделия-первичной применяемости' wind NOWAIT NOCLEAR 
	brow fiel coddet,chnom,naim
	? 'Открыв таблицу No_zakaz.dbf , можо поработать с перечнем не отнесенных на изделия-первичной применяемости'
ENDIF 

CLOSE TABLES

** 2026 здесь его формировать рано, т.к. еще нет обновленных cexlista, outizd_a !!!
*!*	wait wind nowa 'Формирую справочник сборочных единиц'
*!*	do f_sprsbor
*!*	clear

if  adir(dr,ad_normS,'d')>0		&& adir(dr,'y:\normativ','d')=1
	WAIT 'Обновляю SPECIFIC в сети ... '+ad_normS WINDOW NOWAIT NOCLEAR 
	use &ad_norm.SPECIFIC
	? '<4.2. Спецификации> - В cети обновляем таблицу SPECIFIC!'
	ON ERROR ? '<4.2. Спецификации> - Проблема! В cети НЕ ОБНОВЛЕНА таблица SPECIFIC!'
	COPY to &ad_normS.SPECIFIC with CDX TYPE FOX2X as 866
	ON ERROR 
	USE
	WAIT 'Таблица SPECIFIC обновлена!' WINDOW NOWAIT NOCLEAR 	&& time 1
else
	WAIT 'Вы не подключены к сети! В сети НЕ ОБНОВЛЕНА таблицА SPECIFIC ...' WINDOW NOWAIT NOCLEAR &&  time 1 
	? '<4.2. Спецификации> - В cети НЕ ОБНОВЛЕНА таблица SPECIFIC!'
endif   

**До запуска след пункта висит сообщение о результате обновления по текущему пункту!
retu

***********************************************
proc f_sprsbor	
**справочник сборочных единиц содержит данные о цехе-сборщике и уровне входимости

use &ad_norm.outizd_a 
 ** use outizd_a alia a2 orde detizd
on erro inde on coddet+codizd tag detizd
  set order to detizd
on erro
**27.12.2024

use &ad_norm.izdel IN 0 orde codizd

sele dist a1.codizd,a2.cexall as cex,00 as maxlevel ;
	from specific a1,cexlista a2 ;
	into dbf spr_sbor ;
	where a1.codizd=a2.coddet and zaxall=1

** уровень входимости
set rela to codizd into outizd_a
repl all maxlevel with outizd_a.maxlevel

** у изделий уровень входимости = 1
set rela to codizd into izdel
repl all maxlevel with 1 for found([izdel]) and maxlevel=0

inde on codizd+cex tag coduzla
inde on cex+codizd tag cexuzel
inde on str(maxlevel)+codizd+cex tag vxoduzel

CLOSE TABLES 
RETURN 


