** _korrlst.prg
** 2026г Смирнова
** На Y: надо сохранить в TYPE FOX2X as 866 и проиндексировать!!

CLOSE TABLES
*!*	CLEAR 
WAIT CLEAR 
WAIT 'Подождите, ищем нестыковки в строчном ВТМ' WINDOW NOWAIT NOCLEAR 
*****************************************************************************
** корректировка БД строчных ВТМ
*****************************************************************************
** 2026  это лишний блок, он стоит при формировании cexlist!!
*!*	use &ad_norm.cexlist

*!*	wait wind nowa "удаляем все маршруты кроме 1-го"
*!*	dele all for nmarsh>1
*!*	pack

*!*	wait wind nowa 'очищаем строку цех-списка от "грязи"'
*!*	repl all cexlist with allt(strtran(cexlist,'*',''))
*!*	repl all cexlist with allt(strtran(cexlist,'316','315'))

*!*	wait wind nowa "исправляем последние цеха ДСЕ на цеха-сборщики узлов"
**2026

** (пока формируем только таблицу нестыковок)
sele dist codizd ;
	from &ad_norm.cexlist ;
	into dbf &ad_norm.sborki

inde on codizd tag codizd

CLOSE TABLES 

use &ad_norm.sborki orde codizd
use &ad_norm.sprin IN 0 orde coddet
use &ad_norm.cexlist IN 0 
SELECT cexlist
on erro inde on coddet+codizd tag detizd
set orde to detizd
on erro
set rela to coddet into sborki
copy to &ad_norm.prom for found([sborki]) TYPE FOX2X as 866
set rela to

WAIT 'Формируем таблицу нестыковок в БД строчных ВТМ...' WINDOW NOWAIT NOCLEAR 
sele sborki
set rela to codizd into cexlist, codizd into sprin
copy to &ad_norm.errlstuz FIELDS sborki.codizd,sprin.chnom,sprin.naim for !found([cexlist]) TYPE FOX2X as 866
klz=_tally

IF klz>0
	? '    В Н И М А Н И Е    А Д М И Н И С Т Р А Т О Р !!!    '
	? 'Отправьте таблицу <ERRLSTUZ.dbf> в ОГТ для корректировки ВТМ'
	? ' Для самой сборки\изделия НЕ ОПРЕДЕЛЁН маршрут!!'
ENDIF 

** 2026 А для чего эта выборка??
sele dist codizd,iif(left(cexlist,1)!='1',subs(cexlist,at('-',;
	cexlist,1)+1,3),left(cexlist,3)) as cex ;
	from prom ;
	into dbf &ad_norm.listuzel

*!*	sele 3
*!*	use errlstuz
*!*	**brow
clos data

WAIT 'Проверка БД строчных ВТМ окончена '+IIF(klz>0,' - есть нестыковки в строчном ВТМ !', '') WINDOW NOWAIT NOCLEAR 
? '<4.3. Проверка БД  строчных ВТМ> - окончена '+IIF(klz>0,' - есть нестыковки в строчном ВТМ !', '')
**До запуска след пункта висит сообщение о результате обновления по текущему пункту!
RETURN 

