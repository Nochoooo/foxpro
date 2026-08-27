PUBLIC oldCaption
oldCaption=_SCREEN.Caption
_SCREEN.Caption = 'Задача Модуль АДМИНИСТРАТОРА баз'

_SCREEN.windowstate=2	&& Максимизированный экран
_SCREEN.closable = .T.   && Запрет выхода по Х
clear
Do Set_.prg
PUBLIC id_ar,k_podr
m.id_ar=20  && индекс АРМ "Администратора" в spr_arm.dbf
m.k_podr='000'
*
Do Param_.prg

* определение путей задачи
**************
* добавить возможные пути для баз
* для возможности работы локальных машин
***
DO PUTI_.prg

set defa to &ad_norm.		&& ad_norm='c:\normativ\'

** Права на работу с модулем:
*!*	 Если ЕСТЬ c:\normativ\tab_SQL.dbf , то задача стартует, даже если нет таблицы c:\cex\user_s.dbf ИЛИ в c:\cex\user_s.dbf нет этого пользователя. Задача будет БЕЗ указания ФИО 
*!*	 Если  НЕТ c:\normativ\tab_SQL.dbf , то задача стартует ТОЛЬКО если пользователь найден в c:\cex\user_s.dbf . Задача будет с указанием ФИО
*!*	Во всех остальных случаях задача не откроется! 
** сама таблица c:\normativ\tab_SQL.dbf определяет пользовательский допуск на работу с сервером SQL

Do dostyp_d.prg
WAIT WINDOW 'Ждите, идет загрузка' NOWAIT
*********
*-----------------------------

m.name_exe='Adminstr'
* DO FIX.prg && Признак запуска задачи
Do Menu_admin.mpr

_SCREEN.closable = .t. 
WAIT CLEAR
READ EVENT
CLOSE ALL
SET SYSMENU TO DEFAULT
