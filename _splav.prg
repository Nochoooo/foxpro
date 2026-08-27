** _splav.prg
** 2026г Смирнова
** Выгруженный с SQL файл (? КУДА, ?dbf ) надо сохранить в fox2x as 866 и проиндексировать!!
CLOSE TABLES
*!*	CLEAR 
WAIT 'Подождите, обновляю базу данных <12. Состав сплавов>' WINDOW NOWAIT NOCLEAR 
****************************************************************
***** обновление БД составов сплавов из БД ORACLE-сервера ******
****************************************************************
** _splav.prg
** созданоно 09.10.06

*************!!!!!!!!!!!!!!!!!!*************************************
*** т.к. из текстового файла при зачитывании полей ЧИСЛОВЫХ в VF7 могут теряться значения,
**  то сначала создадим таблицу со структурой, где ВСЕ поля СИМВОЛЬНЫЕ.
** получим в неё данные из файла DAT, а затем их загрузим в правильную таблицу!!!

*!*	creat table &ad_norm.splavS (cod_splav c(8),codmat c(8),quant n(11,5),codedizm c(2),;
*!*			cex c(3),price n(11,2),typ c(1))
*!*	** Надо в DOS варианте
*!*	COPY TO &ad_norm.splav type fox2x as 866

creat table &ad_norm.splavS (cod_splav c(8),codmat c(8),quant C(11),codedizm c(2),;
		cex c(3),price C(11),typ c(1))

appe from &ad_vig.splav.dat type sdf as 866

USE &ad_norm.splav
**** 2026
ZAP
APPEND FROM &ad_norm.splavS
*****	
ERASE &ad_norm.splavS.dbf

inde on cod_splav+codmat tag codsplav
inde on cod_splav uniq tag codspl_u
inde on codmat tag codmat

CLOSE TABLES 

sele dist cod_splav,00000000.00 as stoim_got,00000000.00 as stoim_sob ;
     from &ad_norm.splav into dbf &ad_norm.spl_pric
     
** формируем перечень деталей, изготовляемых из сплавов...
sele dist a2.cod_splav,a1.coddet,a1.norma as norma_spl,a1.codedizm,a2.codmat,;
	iif(a2.quant=0,0,a1.norma*a2.quant/100) as norma_mat ;
	from &ad_norm.norm_mat a1,&ad_norm.splav a2 ;
	into dbf &ad_norm.splav_d ;
	where a1.codmat=a2.cod_splav ;
	grou by a2.cod_splav,a2.codmat,a1.coddet
inde on coddet+cod_splav+codmat tag detsplmat
inde on codmat+coddet+cod_splav tag matdetspl
inde on cod_splav+codmat+coddet tag splmatdet
inde on cod_splav+coddet+codmat tag spldetmat
CLOSE TABLES
sele 1
use &ad_norm.spl_pric alia a1
inde on cod_splav tag codsplav
sele 2
use &ad_norm.splav alia a2 orde codsplav
sele 3
use &ad_norm.shifrcen orde codmat
sele 4
use &ad_norm.norm_mat orde codmat
sele 2
set rela to cod_splav into a1, codmat+'1' into shifrcen,codmat into norm_mat
** для чего это заполнение  ?? В  splav.dbf (alia a2) поля: cex, price  - остаются ПУСТЫМИ!!! 
repl all a1.stoim_sob with a1.stoim_sob+shifrcen.price*quant/100, cex with norm_mat.cexpol
**01.07.2026  Заполним в splav цену материала
REPLACE ALL price WITH shifrcen.price*quant/100
**01.07.2026
set rela to
sele 1		&& для чего эта база ??
*!*	 М.б. это проверка стоимости сплава в шифраторе , 
*!*	т.к. сначалас собираем стоимость по компонентам,а потом приносим стоимость из шифратора???
set rela to cod_splav+'1' into shifrcen
repl all stoim_got with shifrcen.price

CLOSE TABLES 

if adir(dr,ad_normS,'d')>0		&& adir(dr,'y:\normativ','d')=1
	wait wind nowa 'Обновляю сетевые БД...'
	use &ad_norm.splav
	? '<12. Состав сплавов> - В cети обновляем таблицу splav.dbf !'
	ON ERROR ? '<12. Состав сплавов> - Проблема! В cети НЕ ОБНОВЛЕНА таблица splav.dbf !'
	copy to &ad_normS.splav with cdx TYPE FOX2X as 866
	ON ERROR 
	USE 
	WAIT 'База данных splav.dbf обновлена в сети!' WINDOW NOWAIT NOCLEAR &&  time 1
else
	wait 'Вы не подключены к сети! В cети НЕ ОБНОВЛЕНА таблица splav ...' WINDOW NOWAIT NOCLEAR &&  time 1
	? '<12. Состав сплавов> - В cети НЕ ОБНОВЛЕНА таблица splav.dbf!'
endif   
retu




