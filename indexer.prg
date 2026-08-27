*** Индексирование таблицы  по заданному имени таблицы, строке и имени индекса
*** Смирнова Н А   04.04.2005

PROCEDURE indexEr 
PARAMETERS baz_t,str_indb,im_ind
** baz_t 	запрашиваемая таблица
** str_indb строка для индекса
** im_ind	имя индекса
USE
*** если файл занят, то выходит системная ошибка,
*** выбрать <IGNORE> для продолжения работы
USE &baz_t EXCLUSIVE  IN 0 ALIAS baz1
IF USED('baz1')
	SELECT baz1
	 ** если таблицу взяли в эксклюзив
	INDEX ON &str_indb TAG &im_ind
	USE
	USE &baz_t SHARED IN 0 ORDER &im_ind
ELSE 
	=messageb('Индексация не проведена')
	=messagebox('Таблица '+baz_t+CHR(13)+'        ЗАНЯТА'+CHR(13)+'Закройте задачи с обращением к ней!')
	im_ind='NOT'	
*** база открывается без индексов
	USE &baz_t SHARED IN 0
ENDIF  
RETURN
