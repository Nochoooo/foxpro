** _vspomd.prg
** 2026г Смирнова
** Выгруженный с SQL файлы  (? КУДА, ?dbf ) надо сохранить в fox2x as 866 и проиндексировать!!
CLOSE TABLES
*!*	CLEAR 

***************************************************************************
**вспомогательные материалы по деталям (эксперимент (перевод из норм по изделиям))
***************************************************************************
if file('&ad_vig.VSPM_D2.DAT')
WAIT 'Подождите, обновляю базы данных вспомогательных <10.3. По деталям (дополнит.)> ' WINDOW NOWAIT NOCLEAR 
   erase &ad_norm.vspm_dt2.cdx
	*************!!!!!!!!!!!!!!!!!!*************************************
	*** т.к. из текстового файла при зачитывании полей ЧИСЛОВЫХ в VF7 могут теряться значения,
	**  то сначала создадим таблицу со структурой, где ВСЕ поля СИМВОЛЬНЫЕ.
	** получим в неё данные из файла DAT, а затем их загрузим в правильную таблицу!!!
	creat table &ad_norm.VSPM_dt2S (coddet c(11), cexpol c(3),codmat c(8),edizm_1 c(4),norma c(12), ;
								price c(15),codedizm c(4),koef c(14))   
   APPEND FROM &ad_vig.VSPM_d2.DAT TYPE SDF as 866
	USE 
	*********!!!!!!!!!!!!!!!!************************************************************
   
   sele 1
   USE &ad_norm.VSPM_dt2.DBF
   zap
   APPEND FROM &ad_norm.VSPM_dt2S		&&*********!!!!!!!!!!!!!!!
   ERASE &ad_norm.VSPM_dt2S.dbf			&&*********!!!!!!!!!!!!!!!
   
 	WAIT 'Индексирую VSPM_dt2.DBF ...' WINDOW NOWAIT NOCLEAR
   inde on coddet tag coddet
   inde on coddet+codedizm tag detedizm
   inde on cexpol+coddet+codmat tag cexdet
   inde on coddet+cexpol+codmat tag detcex
   inde on codmat+cexpol+coddet tag codmat
   inde on coddet+codmat+cexpol tag detmat
   CLOSE TABLES 
endif   
WAIT 'Обновляю цены в VSPM_dt2.DBF...' WINDOW NOWAIT NOCLEAR
sele 1
USE &ad_norm.VSPM_dt2.DBF
sele 2
use &ad_norm.shifrcen orde codmat
sele 1
set rela to codmat+'1' into shifrcen
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
&& ***************** МАТЕРИАЛ ЗАМЕНЫ
if file('&ad_vig.VSPM_D2D.DAT')
	WAIT 'Подождите, обновляю ВСПОМОГАТЕЛЬНЫЕ МАТЕРИАЛЫ по деталям с МАТЕРИАЛАМИ ЗАМЕНЫ - vspm_dtD.DBF' WINDOW NOWAIT NOCLEAR 
   erase &ad_norm.vspm_dtD.cdx
	*************!!!!!!!!!!!!!!!!!!*************************************
	*** т.к. из текстового файла при зачитывании полей ЧИСЛОВЫХ в VF7 могут теряться значения,
	**  то сначала создадим таблицу со структурой, где ВСЕ поля СИМВОЛЬНЫЕ.
	** получим в неё данные из файла DAT, а затем их загрузим в правильную таблицу!!!
	creat table &ad_norm.VSPM_dtDS (coddet c(11), cexpol c(3),codmat c(8),dobmat c(8),edizm_1 c(4),norma c(12), ;
								price c(15),codedizm c(4),koef c(14))   
   APPEND FROM &ad_vig.VSPM_d2D.DAT TYPE SDF as 866
	USE 
	*********!!!!!!!!!!!!!!!!************************************************************
   
   sele 1
   USE &ad_norm.VSPM_dtD.DBF
   zap
   APPEND FROM &ad_norm.VSPM_dtDS			&&*********!!!!!!!!!!!!!!!!
         ERASE &ad_norm.VSPM_dtDS.dbf		&&*********!!!!!!!!!!!!!!!!
 	WAIT 'Индексирую vspm_dtD.DBF ...' WINDOW NOWAIT NOCLEAR
   inde on coddet tag coddet
   inde on coddet+codedizm tag detedizm
   inde on cexpol+coddet+codmat+DOPMAT tag cexdet
   inde on coddet+cexpol+codmat+DOPMAT tag detcex
   inde on codmat+DOPMAT+cexpol+coddet tag codmat
   inde on coddet+codmat+DOPMAT+cexpol tag detmat
   clos data
endif   
WAIT 'Обновляю цены в vspm_dtD.DBF...' WINDOW NOWAIT NOCLEAR
sele 1
USE &ad_norm.VSPM_dtD.DBF
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
&& ************************************************

if adir(dr,ad_normS,'d')>0		&& adir(dr,'y:\normativ','d')=1
	? 'вспомогательных <10.3. По деталям (дополнит.)> - В cети обновляем таблицу vspm_dt2.dbf !'
   use &ad_norm.vspm_dt2
	ON ERROR ? 'вспомогательных <10.3. По деталям (дополнит.)> - Проблема! В cети НЕ ОБНОВЛЕНА таблица vspm_dt2.dbf !'
   copy to &ad_normS.vspm_dt2 with cdx  TYPE FOX2X as 866
    ON ERROR 
   USE
   
	? 'вспомогательных <10.3. По деталям (дополнит.)> - В cети обновляем таблицу vspm_dtD.dbf !'
	use &ad_norm.VSPM_dtD
	ON ERROR ? 'вспомогательных <10.3. По деталям (дополнит.)> - Проблема! В cети НЕ ОБНОВЛЕНА таблица vspm_dtD.dbf !'
   copy to &ad_normS.vspm_dtD with cdx  TYPE FOX2X as 866
    ON ERROR 
   USE
	WAIT 'В cети ОБНОВЛЕНЫ таблицы vspm_dt2, vspm_dtD ...' WINDOW NOWAIT NOCLEAR &&  time 1
else
	WAIT 'Вы не подключены к сети! В cети НЕ ОБНОВЛЕНЫ таблицы vspm_dt2, vspm_dtD ...' WINDOW NOWAIT NOCLEAR &&  time 1
	? 'вспомогательных <10.3. По деталям (дополнит.)> - В cети НЕ ОБНОВЛЕНЫ таблицы vspm_dt2, vspm_dtD !'
endif   

RETURN 







