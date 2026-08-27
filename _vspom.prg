** _vspom.prg
** 2026г Смирнова
** На Y: надо сохранить в TYPE FOX2X as 866 и проиндексировать!!
CLOSE TABLES
*!*	CLEAR 

WAIT 'Подождите, обновляю базы данных вспомогательных <10.1. По изделиям> ' WINDOW NOWAIT NOCLEAR 
************************************************
***** вспомогательные материалы по изделиям ****
************************************************

if file('&ad_vig.DRAGMET.LST')
	WAIT 'Подождите, обновляю ДРАГМЕТАЛЛЫ ПО ИЗДЕЛИЯМ DRAGMET.DBF' WINDOW NOWAIT NOCLEAR 
	*************!!!!!!!!!!!!!!!!!!*************************************
	*** т.к. из текстового файла при зачитывании полей ЧИСЛОВЫХ в VF7 могут теряться значения,
	**  то сначала создадим таблицу со структурой, где ВСЕ поля СИМВОЛЬНЫЕ.
	** получим в неё данные из файла DAT, а затем их загрузим в правильную таблицу!!!
	creat table &ad_norm.DRAGMETS (codizd c(11),coddet c(11), codmat C(8), norma c(12))   
	APPEND FROM &ad_vig.DRAGMET.LST TYPE SDF as 866
	*********!!!!!!!!!!!!!!!!************************************************************
	
   USE &ad_norm.DRAGMET.DBF
   zap
   APPEND FROM &ad_norm.DRAGMETS		&&*************!!!!!!!!!!!!!
   ERASE &ad_norm.DRAGMETS.dbf			&&*************!!!!!!!!!!!!!
   CLOSE TABLES 
ENDIF 

if file('&ad_vig.VSPM.DAT')
	WAIT 'Подождите, обновляю ВСПОМОГАТЕЛЬНЫЕ МАТЕРИАЛЫ ПО ИЗДЕЛИЯМ - VSP_MAT.DBF' WINDOW NOWAIT NOCLEAR 
   erase &ad_norm.vsp_mat.cdx
	*************!!!!!!!!!!!!!!!!!!*************************************
	*** т.к. из текстового файла при зачитывании полей ЧИСЛОВЫХ в VF7 могут теряться значения,
	**  то сначала создадим таблицу со структурой, где ВСЕ поля СИМВОЛЬНЫЕ.
	** получим в неё данные из файла DAT, а затем их загрузим в правильную таблицу!!!
	creat table &ad_norm.VSP_MATS (coddet c(11), cexpol c(3),codmat c(8),edizm_1 c(4),norma c(12), ;
								price c(15),codedizm c(4),koef c(14))   
	APPEND FROM &ad_vig.VSPM.DAT TYPE SDF as 866
	USE 
	*********!!!!!!!!!!!!!!!!************************************************************
   sele 1
   USE &ad_norm.VSP_MAT.DBF
   zap
   APPEND FROM &ad_norm.VSP_MATS 		&&*************!!!!!!!!!!!!!
   ERASE &ad_norm.VSP_MATS.dbf			&&*************!!!!!!!!!!!!!
   
   WAIT 'Индексирую - VSP_MAT.DBF ...' WINDOW NOWAIT NOCLEAR
   inde on coddet tag coddet
   inde on coddet+codedizm tag detedizm
   inde on cexpol+coddet+codmat tag cexdet
   inde on coddet+cexpol+codmat tag detcex
   inde on codmat+cexpol+coddet tag codmat
   inde on coddet+codmat+cexpol tag detmat
   clos data
ENDIF    
WAIT 'Обновляю цены в VSP_MAT.DBF ...' WINDOW NOWAIT NOCLEAR
sele 1
USE &ad_norm.VSP_MAT.DBF excl
sele 2
use &ad_norm.shifrcen orde codmat
sele 1
set rela to codmat+'1' into shifrcen
repl all codedizm with shifrcen.codedizm, price with shifrcen.price for val(shifrcen.num_price)=1
sele 3
use &ad_norm.sh_edizm orde codedizm
sele 1
set rela to alltrim(str(val(codedizm))) into sh_edizm
repl all koef with sh_edizm.koef
set rela to alltrim(str(val(edizm_1))) into sh_edizm
repl all koef with koef/sh_edizm.koef for sh_edizm.koef>0
set rela to

CLOSE TABLES 
***********************24/07/2014*************
*** c 07/2014 у сборщиков вспомогательные материалы разделены на сборку и на испытания
***  120 00 на сборку
***  120 01 на предъявительские испытания
***  120 02 на приемосдаточные испытания
*** в новую таблицу добавлено поле UCH

if file('&ad_vig.VSPMU.DAT')
	WAIT 'Подождите, обновляю ВСПОМОГАТЕЛЬНЫЕ МАТЕРИАЛЫ ПО ИЗДЕЛИЯМ на ИСПЫТАНИЯ и СБОРКУ'  WINDOW NOWAIT NOCLEAR
   erase &ad_norm.vsp_matU.cdx
	*************!!!!!!!!!!!!!!!!!!*************************************
	*** т.к. из текстового файла при зачитывании полей ЧИСЛОВЫХ в VF7 могут теряться значения,
	**  то сначала создадим таблицу со структурой, где ВСЕ поля СИМВОЛЬНЫЕ.
	** получим в неё данные из файла DAT, а затем их загрузим в правильную таблицу!!!
	creat table &ad_norm.VSP_MATUS (coddet c(11), cexpol c(3),uch C(2),codmat c(8),edizm_1 c(4),norma c(12), ;
								price c(15),codedizm c(4),koef c(14))   
   APPEND FROM &ad_vig.VSPMU.DAT TYPE SDF as 866
	USE 
	*********!!!!!!!!!!!!!!!!************************************************************
   sele 1
   USE &ad_norm.VSP_MATU.DBF
   zap
   APPEND FROM &ad_norm.VSP_MATUS		&&*************!!!!!!!!!!!!!
   ERASE &ad_norm.VSP_MATUS.dbf			&&*************!!!!!!!!!!!!!
   
 **  repl all norma with norma0000000
	WAIT 'Индексирую VSP_MATU.DBF ...' WINDOW NOWAIT NOCLEAR
   inde on coddet tag coddet
   inde on coddet+codedizm tag detedizm
   inde on cexpol+uch+coddet+codmat tag cexuchdet
   inde on coddet+cexpol+uch+codmat tag detcexuch
   inde on codmat+cexpol+uch+coddet tag codmat
   inde on coddet+codmat+cexpol+uch tag detmatcu
   CLOSE TABLES 
endif   
WAIT 'Обновляю цены в VSP_MATU.DBF...' WINDOW NOWAIT NOCLEAR
sele 1
USE &ad_norm.VSP_MATU.DBF excl
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
***********************конец 24/07/2014****
******************* с МАТЕРИАЛом ЗАМЕНЫ
if file('&ad_vig.VSPMd.DAT')
	WAIT 'Подождите, обновляю ВСПОМОГАТЕЛЬНЫЕ МАТЕРИАЛЫ ПО ИЗДЕЛИЯМ с МАТЕРИАЛАМИ ЗАМЕНЫ - VSP_MATd.DBF' WINDOW NOWAIT NOCLEAR 
   erase &ad_vig.vsp_matd.cdx
	*************!!!!!!!!!!!!!!!!!!*************************************
	*** т.к. из текстового файла при зачитывании полей ЧИСЛОВЫХ в VF7 могут теряться значения,
	**  то сначала создадим таблицу со структурой, где ВСЕ поля СИМВОЛЬНЫЕ.
	** получим в неё данные из файла DAT, а затем их загрузим в правильную таблицу!!!
	creat table &ad_norm.VSP_MATdS (coddet c(11), cexpol c(3),codmat c(8),dopmat c(8),edizm_1 c(4),norma c(12), ;
								price c(15),codedizm c(4),koef c(14))   
	APPEND FROM &ad_vig.VSPMd.DAT TYPE SDF as 866
	USE 
	*********!!!!!!!!!!!!!!!!************************************************************
   
   sele 1
   USE &ad_norm.VSP_MATd.DBF
   zap
	APPEND FROM &ad_norm.VSP_MATdS	&&*************!!!!!!!!!!!!!
	ERASE &ad_norm.VSP_MATdS.dbf	&&*************!!!!!!!!!!!!!
	
   WAIT 'Индексирую VSP_MATd.DBF...' WINDOW NOWAIT NOCLEAR
   inde on coddet tag coddet
   inde on coddet+codedizm tag detedizm
   inde on cexpol+coddet+codmat+DOPmat tag cexdet
   inde on coddet+cexpol+codmat+DOPmat tag detcex
   inde on codmat+DOPMAT+cexpol+coddet tag codmat
   inde on coddet+codmat+DOPmat+cexpol tag detmat
   CLOSE TABLES 
ENDIF    
WAIT 'Обновляю цены в VSP_MATd.DBF...' WINDOW NOWAIT NOCLEAR
sele 1
USE &ad_norm.VSP_MATd.DBF excl
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
&& ***********************************************************
if adir(dr,ad_normS,'d')>0		&& adir(dr,'y:\normativ','d')=1
	? 'вспомогательных <10.1. По изделиям> - В cети обновляем таблицу vsp_mat.dbf !'
   use &ad_norm.vsp_mat
	ON ERROR ? 'вспомогательных <10.1. По изделиям> - Проблема! В cети НЕ ОБНОВЛЕНА таблица vsp_mat.dbf !'
   copy to &ad_normS.vsp_mat with cdx TYPE FOX2X as 866
    ON ERROR 
   use
***************24/07/2014
 	? 'вспомогательных <10.1. По изделиям> - В cети обновляем таблицу vsp_matU.dbf !'
  use &ad_norm.vsp_matU
	ON ERROR ? 'вспомогательных <10.1. По изделиям> - Проблема! В cети НЕ ОБНОВЛЕНА таблица vsp_matU.dbf !'
   copy to &ad_normS.vsp_matU with cdx TYPE FOX2X as 866
    ON ERROR 
   use
***************24/07/2014
 	? 'вспомогательных <10.1. По изделиям> - В cети обновляем таблицу vsp_matd.dbf !'
   use &ad_norm.vsp_matd
	ON ERROR ? 'вспомогательных <10.1. По изделиям> - Проблема! В cети НЕ ОБНОВЛЕНА таблица vsp_matd.dbf !'
   copy to &ad_normS.vsp_matd with cdx TYPE FOX2X as 866
    ON ERROR 
   USE
   
 	? 'вспомогательных <10.1. По изделиям> - В cети обновляем таблицу DRAGMET.dbf !'
   use &ad_norm.DRAGMET
	ON ERROR ? 'вспомогательных <10.1. По изделиям> - Проблема! В cети НЕ ОБНОВЛЕНА таблица DRAGMET.dbf !'
   copy to &ad_normS.DRAGMET with cdx TYPE FOX2X as 866
    ON ERROR 
   USE 
	WAIT 'Базы данных vsp_mat.dbf , vsp_matU.dbf , vsp_matd.dbf , DRAGMET.dbf обновлены в сети!' WINDOW NOWAIT NOCLEAR 
else
	WAIT 'Вы не подключены к сети! В cети НЕ ОБНОВЛЕНЫ таблицы vsp_mat, vsp_matU, vsp_matd, DRAGMET ...' WINDOW NOWAIT NOCLEAR &&  time 1
	? 'вспомогательных <10.1. По изделиям> - В cети НЕ ОБНОВЛЕНЫ таблицы vsp_mat, vsp_matU, vsp_matd, DRAGMET !'
ENDIF 

do _vspmdet

CLOSE TABLES
USE &ad_norm.VSP_MAT.DBF
copy to &ad_norm.prom TYPE FOX2X as 866
use &ad_norm.prom
appe from &ad_norm.VSPM_DET.DBF
sele dist coddet,cexpol as cex,sum(round(price*norma/koef,3)) as sum_vspm ;
     from &ad_norm.prom into dbf &ad_norm.vspm_sumS where koef>0 grou by coddet,cexpol
   ** чтобы на исходном ПК база была версии DOS
COPY TO &ad_norm.vspm_sum TYPE FOX2X as 866
USE &ad_norm.vspm_sum
ERASE &ad_norm.vspm_sumS.dbf

inde on coddet+cex tag detcex
inde on cex+coddet tag cexdet

CLOSE TABLES 

if adir(dr,ad_normS,'d')>0		&&  adir(dr,'y:\normativ','d')=1
 	? 'вспомогательных <10.1. По изделиям> - В cети обновляем таблицу vspm_sum.dbf !'
   USE &ad_norm.vspm_sum
	ON ERROR ? 'вспомогательных <10.1. По изделиям> - Проблема! В cети НЕ ОБНОВЛЕНА таблица vsp_sum.dbf !'
   copy to &ad_normS.vsp_sum with cdx TYPE FOX2X as 866
    ON ERROR 
   USE
	WAIT 'В cети ОБНОВЛЕНА таблица vsp_sum ...' WINDOW NOWAIT NOCLEAR &&  time 1
else
	WAIT 'Вы не подключены к сети! В cети НЕ ОБНОВЛЕНА таблицА vsp_sum ...' WINDOW NOWAIT NOCLEAR &&  time 1
	? 'вспомогательных <10.1. По изделиям> - В cети НЕ ОБНОВЛЕНА таблица vsp_sum !'
endif   

RETURN 




