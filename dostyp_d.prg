**************************************************************
* DOSTYP_d.prg - программа проверки доступа пользователя к АРМ-у
*                
* 26.12.2003г.
* Газизова И.М.
**************************************************************
CLOSE TABLE ALL
*!*	PUBLIC net_nam,fio_name,dopysk
*!*	m.dopysk=0
*!*	fio_name=''
*!*	m.net_nam=UPPER(ALLTRIM(SUBSTR(SYS(0),AT('#',SYS(0))+2)))
m.otdel=UPPER(LEFT(ALLTRIM(SYS(0)),4))
 ** m.f_OTIZ - флаг ОТиЗ для показа ОПЕРТРУД 
 ** по именам машин
 ** 2016г ОМИС закрыта работа + PZ Представители заказчика 
m.f_OTIZ=IIF(m.otdel='OMIS' or LEFT(m.otdel,2)='PZ',.t.,.f.)
** далее этот флаг используется в меню -Трудовые нормативы

IF FILE('&ad_start.user_s.dbf')
** есть файлы начальной регистрации и загрузки
	IF USED('user_s') = .F.
	*	USE z:\office\pdo_sys\user_s IN 0 SHARED
		USE &ad_start.user_s IN 0 SHARED 
	ENDIF
	SELECT *;
	 FROM user_s;
	 WHERE UPPER(ALLTRIM(User_s.nam_sys)) == UPPER(?m.net_nam) ;
	   AND User_s.id_arm = ?m.id_ar;
	INTO CURSOR dop;
		ORDER BY user_s.id_op

	* Для себя! Пользователям надо своё писать.
	SELECT dop
	COUNT TO kz

	GO BOTTOM
	*!*	m.fio_name=OEMTOANSI(dop.realname) - для DOS-таблиц
	m.fio_name=ALLT(dop.realname) 
	m.k_podr=ALLTRIM(dop.id_podr)
	m.dopysk=dop.id_op
	*!*	?m.dopysk
	USE IN dop
	USE IN User_s

	 _SCREEN.Caption = _SCREEN.Caption+'   '+'Работает : '+fio_name
	IF kz>0
	** Это пользователь SQL как WindowsNT
		ALIA_SQL='SQL_test'
		PAROL_US=''

		*---- Защита от изменения дня на своём ПК
		*!*		USE f:\SYSTEM\day.dbf in 0 SHARE	&& Дата на сервере
		*!*		select day
		*!*		IF date()>day.date
		*!*			m.dat_serv=DATE()
		*!*		ELSE		
		*!*			m.dat_serv=day.date
		*!*		ENDIF	
		*!*		USE

	ELSE
	** проверим пользователя для работы с SQL как Учетная группа
		IF FILE('c:\normativ\tab_sql.dbf')
			ALIA_SQL='DATA1'
			USE c:\normativ\tab_sql IN 0 SHARED
			SELECT tab_sql
			m.dopysk=0
			PAROL_US=ALLTRIM(tab_sql.pass)
			m.net_nam=ALLTRIM(tab_sql.naim)
			USE 
		ELSE 
			=MESSAGEBOX("Извини, друг, я тебя не знаю...",16,"Информация о доступе к программе")
			* DO fix_end.prg  && Признак завершения задачи в start.dbf
			CANCEL
		ENDIF 
	ENDIF
ELSE
** проверяем на право работы с сервером по групповому соединению
	IF FILE('c:\normativ\tab_sql.dbf')
		ALIA_SQL='DATA1'
		USE c:\normativ\tab_sql IN 0 SHARED
		SELECT tab_sql
		m.dopysk=0
		PAROL_US=ALLTRIM(tab_sql.pass)
		m.net_nam=ALLTRIM(tab_sql.naim)
		USE 
	ELSE 
		=MESSAGEBOX("Извини, друг, я тебя не знаю...",16,"Информация о доступе к программе")
		* DO fix_end.prg  && Признак завершения задачи в start.dbf
		CANCEL
	ENDIF 
ENDIF 
********************************************************************************
