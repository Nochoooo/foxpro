** podbor.prg
** 2026г Смирнова
** Выгруженный надо сохранить в fox2x as 866 и проиндексировать!!
CLOSE TABLES
*!*	CLEAR 
WAIT CLEAR 
WAIT 'Подождите, обновляю базу данных ПОДБОР - PODBOR.dbf ' WINDOW NOWAIT NOCLEAR 
*************!!!!!!!!!!!!!!!!!!*************************************
*** т.к. из текстового файла при зачитывании полей ЧИСЛОВЫХ в VF7 могут теряться значения,
**  то сначала создадим таблицу со структурой, где ВСЕ поля СИМВОЛЬНЫЕ.
** получим в неё данные из файла DAT, а затем их загрузим в правильную таблицу!!!
creat table &ad_norm.PODBORS (coddet_osn C(11),coddet C(11), prizn c(1),codizd C(11),allquant c(10))

appe from &ad_vig.PODBOR.dat type sdf  as 866
USE 
*********!!!!!!!!!!!!!!!!************************************************************

USE &ad_norm.PODBOR
zap
** где будет и какой формат??
** пока как раньше - Но учтем кодировку 866 !!
appe from &ad_norm.PODBORS		&&*********!!!!!!!!!!!!!!!!
USE

select  DISTINCT C.CODIZD ;
  from &ad_norm.CEXLIST C ;
  where C.NMARSH=1 AND C.QUANT=0 ;
  INTO  dbf &ad_norm.podbor2

CLOSE TABLES 

select  DISTINCT C.CODIZD,C.CODDET ;
  from &ad_norm.CEXLIST C,&ad_norm.PODBOR2 P ;
  where P.CODIZD=C.CODDET  ;
  INTo dbf &ad_norm.podbor3

CLOSE TABLES 

select distinct p.coddet_osn ,P.coddet,p.prizn, O.CODIZD,o.allquant ;
 from &ad_norm.OUTIZD o,&ad_norm.podbor p,&ad_norm.PODBOR3 D ;
 where o.coddet =p.coddet_osn ;  
  AND O.CODIZD =D.CODIZD ;
 INTo dbf &ad_norm.podbor1
	
INDEX ON CODIZD+coddet_OSN tag coddet_OSN
INDEX ON CODIZD+ CODDET FOR coddet_osn!= coddet TAG CODIZD 

CLOSE TABLES

 SELE 1
 USE &ad_norm.PODBOR1 ALIAS A1 ORDE CODIZD
 SELE 2
 USE &ad_norm.OUTIZD ORDE IZDDET
 SELE 1
 SET RELA TO CODIZD+CODDET INTO OUTIZD
 dele all for found(2)
 pack
 CLOSE TABLES 

 sele CODIZD,coddet_osn ,count(*) as kol ;
  from &ad_norm.podbor1;
  into dbf &ad_norm.pom_podbor group by CODIZD,coddet_osn
	
INDEX ON CODIZD+coddet_osn  tag coddet_osn
CLOSE TABLES 

sele 2
use &ad_norm.pom_podbor alias a2 orde coddet_osn 
sele 1
use &ad_norm.podbor1 alias a1 orde coddet_osn
sele 1
 set rela to CODIZD+coddet_osn into a2
          
 REPL all a1.allquant with a1.allquant/a2.kol

CLOSE TABLES 
ERASE &ad_norm.podbor.dbf
ERASE &ad_norm.podbor.cdx
ERASE &ad_norm.podbor2.dbf
ERASE &ad_norm.podbor1.cdx

USE &ad_norm.podbor1
COPY TO &ad_norm.podbor TYPE FOX2X as 866

use &ad_norm.podbor
INDEX ON coddet_OSN tag coddet_OSN
INDEX ON codizd+coddet_osn tag izddet_osn
INDEX ON codizd+coddet_OSN+coddet tag izdosndet
CLOSE TABLES  

**************** обновление подбор узла
WAIT 'Подождите, обновляю базу данных ПОДБОР ДЕТАЛЕЙ УЗЛА - podborUZ.dbf  ' WINDOW NOWAIT NOCLEAR 

USE PODBORUZ
zap
** эти же данные зачитывали при формировании PODBOR.dbf в искусственную таблицу PODBORS.dbf
** APPEND FROM &ad_vig.PODBOR.DAT TYPE SDF as 866

APPEND FROM &ad_norm.PODBORS.dbf
** ERASE &ad_norm.PODBORS.dbf		&&*********!!!!!!!!!!!!!!!!
CLOSE TABLES 

select distinct p.coddet_osn ,P.coddet,p.prizn ,O.CODIZD,o.allquant AS QUANT ;
 from &ad_norm.OUT_UZEL o,&ad_norm.podborUZ p,&ad_norm.PODBOR3 D ;
 where o.coddet =p.coddet_osn AND O.CODIZD =D.CODIZD ;
 INTo dbf podbor1
 
INDEX ON CODIZD+coddet_OSN tag coddet_OSN
INDEX ON CODIZD+ CODDET FOR coddet_osn!= coddet TAG CODIZD 

CLOSE TABLES 

SELE 1
USE &ad_norm.PODBOR1 ALIAS A1 ORDE CODIZD
SELE 2
USE &ad_norm.OUT_UZEL ORDE IZDDET
SELE 1
SET RELA TO CODIZD+CODDET INTO OUT_UZEL
DELETE all for found(2)
PACK 
CLOSE TABLES 

SELECT CODIZD,coddet_osn ,count(*) as kol ;
  from &ad_norm.podbor1 ;
  into dbf &ad_norm.pom_podbor group by CODIZD,coddet_osn
	
INDEX ON CODIZD+coddet_osn  tag coddet_osn
CLOSE TABLES 

sele 2
use &ad_norm.pom_podbor alias a2 orde coddet_osn 
sele 1
use &ad_norm.podbor1 alias a1 orde coddet_osn
sele 1
set rela to CODIZD+coddet_osn into a2
          
REPL all a1.quant with a1.quant/a2.kol

CLOSE TABLES 

ERASE &ad_norm.podborUZ.dbf
ERASE &ad_norm.podborUZ.cdx
ERASE &ad_norm.podbor3.dbf
ERASE &ad_norm.podbor3.cdx
ERASE &ad_norm.podbor1.cdx

USE &ad_norm.podbor1
COPY TO &ad_norm.podborUZ TYPE FOX2X as 866

USE &ad_norm.podborUZ
INDEX ON coddet_OSN tag coddet_OSN
INDEX ON codizd+coddet_osn tag izddet_osn
INDEX ON codizd+coddet_OSN+coddet tag izdosndet
CLOSE TABLES 

if adir(dr,ad_normS,'d')>0		&& adir(dr,'y:\normativ','d')=1
	wait 'Обновляю PODBOR.dbf в сети ... '+ad_normS WINDOW NOWAIT  
	USE &ad_norm.PODBOR
	? '<6.4. Сформировать обновлённые ПОДБОРЫ и затем повторить 6,2 !> - В cети обновляем таблицу PODBOR.dbf !'
	ON ERROR ? '<6.4. Сформировать обновлённые ПОДБОРЫ и затем повторить 6,2 !> - Проблема! В cети НЕ ОБНОВЛЕНА таблица PODBOR.dbf !'
	copy to &ad_normS.PODBOR with cdx TYPE FOX2X as 866
	ON ERROR 

	wait 'Обновляю podborUZ.dbf в сети ... '+ad_normS WINDOW NOWAIT  
	USE &ad_norm.podborUZ
	? '<6.4. Сформировать обновлённые ПОДБОРЫ и затем повторить 6,2 !> - В cети обновляем таблицу podborUZ.dbf!'
	ON ERROR ? '<6.4. Сформировать обновлённые ПОДБОРЫ и затем повторить 6,2 !> - Проблема! В cети НЕ ОБНОВЛЕНА таблица podborUZ.dbf!'
	copy to &ad_normS.podborUZ with cdx TYPE FOX2X as 866
	ON ERROR 
	USE 
	WAIT 'Базы данных PODBOR.dbf , podborUZ.dbf обновлены в сети!' WINDOW NOWAIT NOCLEAR &&  time 1
ELSE 
	wait 'Вы не подключены к сети! В cети НЕ ОБНОВЛЕНЫ таблицы PODBOR.dbf , podborUZ.dbf ...' WINDOW NOWAIT NOCLEAR 	&&  time 1
	? '<6.4. Сформировать обновлённые ПОДБОРЫ и затем повторить 6,2 !> - В cети НЕ ОБНОВЛЕНЫ таблицы PODBOR.dbf , podborUZ.dbf !'
ENDIF    

**До запуска след пункта висит сообщение о результате обновления по текущему пункту!
RETURN 


