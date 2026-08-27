CLOSE TABLE ALL
SET SAFETY OFF
SET TALK OFF
SET NULLDISPLAY TO ''	&& чтобы вместо .NULL было пусто

PUBLIC editing
m.editing=.F.	&& Для меню

PUBLIC name_exe
m.name_exe=''  && наименование экзешника

PUBLIC net_nam,fio_name,dopysk,k_podr,W_user,W_userPro,f_OTIZ,otdel, akt_str
** otdel - первые 4 знака из имени ПК
 ** m.f_OTIZ - флаг ОТиЗ для показа ОПЕРТРУД , 2016г ОМИС закрыта работа 
m.net_nam=UPPER(ALLTRIM(SUBSTR(SYS(0),AT('#',SYS(0))+2)))
fio_name=''
m.dopysk=0
m.k_podr=''
** запоминаем имя пользователя в WINDOW
**m.W_user=GETENV("USERNAME")
m.W_user=m.net_nam
akt_str=_PLINENO		&& активная строка экрана 

PUBLIC mes(12)
mes(1) =" Январь "
mes(2) ="Февраль "
mes(3) ="  Март  "
mes(4) =" Апрель "
mes(5) ="  Май   "
mes(6) ="  Июнь  "
mes(7) ="  Июль  "
mes(8) =" Август "
mes(9) ="Сентябрь"
mes(10)="Октябрь "
mes(11)=" Ноябрь "
mes(12)="Декабрь "

PUBLIC nrep,m.dat1,m.dat2,n_mes,n_god
m.nrep=''
m.dat1=DATE()
m.dat2=DATE()
m.n_mes=MONTH(m.dat1)  				&& Месяц - число
m.n_god=YEAR(m.dat1)					&& Год  		

PUBLIC tim,tim1,tim2
m.tim=0
m.tim1=0
m.tim2=0

*!*	PUBLIC GGGG, GGGGP, GG, GGP
*!*	GGGG=str(year(date()),4,0)
*!*	GGGGP=str(year(date())-1,4,0)
*!*	GG=right(GGGG,2)
*!*	GGP=right(GGGGP,2)
