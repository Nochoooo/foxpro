** _vspmdet.prg
** 2026г Смирнова
** Выгруженный с SQL файлы  (? КУДА, ?dbf ) надо сохранить в fox2x as 866 и проиндексировать!!
CLOSE TABLES
*!*	CLEAR 

WAIT 'Подождите, обновляю базы данных вспомогательных <10.2. По деталям (основной)> ' WINDOW NOWAIT NOCLEAR 
***************************************************************************
***** вспомогательные материалы по деталям (лакокраска, спирты и т.д.) ****
***************************************************************************
if file('&ad_vig.VSPM_D.DAT')
WAIT 'Подождите, обновляю ВСПОМОГАТЕЛЬНЫЕ МАТЕРИАЛЫ ПО ДЕТАЛЯМ' WINDOW NOWAIT NOCLEAR 
   erase &ad_norm.vspm_det.cdx
	*************!!!!!!!!!!!!!!!!!!*************************************
	*** т.к. из текстового файла при зачитывании полей ЧИСЛОВЫХ в VF7 могут теряться значения,
	**  то сначала создадим таблицу со структурой, где ВСЕ поля СИМВОЛЬНЫЕ.
	** получим в неё данные из файла DAT, а затем их загрузим в правильную таблицу!!!
	creat table &ad_norm.VSPM_detS (coddet c(11), cexpol c(3),codmat c(8),edizm_1 c(4),norma c(12), ;
								price c(15),codedizm c(4),koef c(14))   
   APPEND FROM &ad_vig.VSPM_d.DAT TYPE SDF as 866
	USE 
	*********!!!!!!!!!!!!!!!!************************************************************
   
   sele 1
   USE &ad_norm.VSPM_det.DBF excl
   zap
   APPEND FROM &ad_norm.VSPM_detS		&&*********!!!!!!!!!!!!!!!!
   ERASE &ad_norm.VSPM_detS.dbf				&&*********!!!!!!!!!!!!!!!!
   
	WAIT 'Индексирую VSPM_det.dbf ...' WINDOW NOWAIT NOCLEAR 
   inde on coddet tag coddet
   inde on coddet+codedizm tag detedizm
   inde on cexpol+coddet+codmat tag cexdet
   inde on coddet+cexpol+codmat tag detcex
   inde on codmat+cexpol+coddet tag codmat
   inde on coddet+codmat+cexpol tag detmat
   CLOSE TABLES 
endif   
WAIT 'Обновляю цены в VSPM_det.dbf ...' WINDOW NOWAIT NOCLEAR
sele 1
USE &ad_norm.VSPM_det.DBF excl
sele 2
use &ad_norm.shifrcen orde codmat
sele 1
set rela to codmat+'1' into shifrcen
repl all codedizm with shifrcen.codedizm,price with shifrcen.price for val(shifrcen.num_price)=1
sele 3
use &ad_norm.sh_edizm orde codedizm
sele 1		&& VSPM_det
set rela to alltrim(str(val(codedizm))) into sh_edizm
repl all koef with sh_edizm.koef
set rela to alltrim(str(val(edizm_1))) into sh_edizm
repl all koef with koef/sh_edizm.koef for sh_edizm.koef>0
set rela to
CLOSE TABLES 

&& **********  ЗАМЕНЫ МАТЕРИАЛА 
if file('&ad_vig.VSPM_DD.DAT')
	WAIT 'Подождите, обновляю ВСПОМОГАТЕЛЬНЫЕ МАТЕРИАЛЫ ПО ДЕТАЛЯМ с МАТЕРИАЛАМИ ЗАМЕНЫ - vspm_dED.DBF' WINDOW NOWAIT NOCLEAR 
   erase &ad_norm.vspm_dED.cdx
	*************!!!!!!!!!!!!!!!!!!*************************************
	*** т.к. из текстового файла при зачитывании полей ЧИСЛОВЫХ в VF7 могут теряться значения,
	**  то сначала создадим таблицу со структурой, где ВСЕ поля СИМВОЛЬНЫЕ.
	** получим в неё данные из файла DAT, а затем их загрузим в правильную таблицу!!!
	creat table &ad_norm.VSPM_dEDS (coddet c(11), cexpol c(3),codmat c(8),dobmat c(8),edizm_1 c(4),norma c(12), ;
								price c(15),codedizm c(4),koef c(14))   
   APPEND FROM &ad_vig.VSPM_dD.DAT TYPE SDF as 866
	USE 
	*********!!!!!!!!!!!!!!!!************************************************************
   
   sele 1
   USE &ad_norm.VSPM_dED.DBF excl
   zap
   APPEND FROM &ad_norm.VSPM_dEDS		&&*********!!!!!!!!!!!!!!!!
   ERASE &ad_norm.VSPM_dEDS.dbf			&&*********!!!!!!!!!!!!!!!!
WAIT  'Индексирую VSPM_dED ...' WINDOW NOWAIT NOCLEAR
   inde on coddet tag coddet
   inde on coddet+codedizm tag detedizm
   inde on cexpol+coddet+codmat+DOPMAT tag cexdet
   inde on coddet+cexpol+codmat+DOPMAT tag detcex
   inde on codmat+DOPMAT+cexpol+coddet tag codmat
   inde on coddet+codmat+DOPMAT+cexpol tag detmat
   CLOSE TABLES 
endif   
WAIT 'Обновляю цены в VSPM_dED.DBF...' WINDOW NOWAIT NOCLEAR
sele 1
USE &ad_norm.VSPM_deD.DBF excl
sele 2
use &ad_norm.shifrcen orde codmat
sele 1
set rela to DOPmat+'1' into shifrcen
repl all codedizm with shifrcen.codedizm,price with shifrcen.price for val(shifrcen.num_price)=1
sele 3
use &ad_norm.sh_edizm orde codedizm
sele 1
set rela to alltrim(str(val(codedizm))) into sh_edizm
repl all koef with sh_edizm.koef
set rela to alltrim(str(val(edizm_1))) into sh_edizm
repl all koef with koef/sh_edizm.koef for sh_edizm.koef>0
set rela to
CLOSE TABLES

if adir(dr,ad_normS,'d')>0		&& adir(dr,'y:\normativ','d')=1
	? 'вспомогательных <10.2. По деталям (основной)> - В cети обновляем таблицу vspm_det.dbf !'
   use &ad_norm.vspm_det
	ON ERROR ? 'вспомогательных <10.2. По деталям (основной)> - Проблема! В cети НЕ ОБНОВЛЕНА таблица vspm_det.dbf !'
   copy to &ad_normS.vspm_det with cdx  TYPE FOX2X as 866
    ON ERROR 
   use
	? 'вспомогательных <10.2. По деталям (основной)> - В cети обновляем таблицу vspm_deD.dbf !'
	use &ad_norm.vspm_deD
	ON ERROR ? 'вспомогательных <10.2. По деталям (основной)> - Проблема! В cети НЕ ОБНОВЛЕНА таблица vspm_deD.dbf !'
   copy to &ad_normS.vspm_deD with cdx  TYPE FOX2X as 866
    ON ERROR 
   USE
	WAIT 'Таблицы vspm_det.dbf , vspm_deD.dbf обновлены в сети!' WINDOW NOWAIT NOCLEAR 	&& time 1
   
else
	WAIT 'Вы не подключены к сети! В cети НЕ ОБНОВЛЕНЫ таблицы vspm_det, vspm_deD ...' WINDOW NOWAIT NOCLEAR &&  time 1
	? 'вспомогательных <10.2. По деталям (основной)> - В cети НЕ ОБНОВЛЕНЫ таблицы vspm_det, vspm_deD !'
endif   

retu
