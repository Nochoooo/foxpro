** _norma.prg
** 2026г Смирнова
** Выгруженный с SQL файлы  (? КУДА, ?dbf ) надо сохранить в fox2x as 866 и проиндексировать!!
CLOSE TABLES
*!*	CLEAR 

WAIT 'Подождите, обновляю базы данных <5. НОРМАТИВНЫЕ КАРТЫ (normmat)> (лицевая сторона)' WINDOW NOWAIT NOCLEAR 
** чтобы быстрее работало обновление
erase &ad_norm.normmat.cdx

wait 'Определяем цеха-получатели материалов...' wind NOWAIT NOCLEAR  
sele dist coddet,cex as cexpol ;
	from &ad_norm.cexlist0 ;
	into dbf &ad_norm.cexprimm ;
	where zaxlist=1
inde on coddet tag coddet
CLOSE TABLES

*************!!!!!!!!!!!!!!!!!!*************************************
*** т.к. из текстового файла при зачитывании полей ЧИСЛОВЫХ в VF7 могут теряться значения,
**  то сначала создадим таблицу со структурой, где ВСЕ поля СИМВОЛЬНЫЕ.
** получим в неё данные из файла DAT, а затем их загрузим в правильную таблицу!!!
creat table &ad_norm.NORMMATS (coddet C(11), czm C(3), cexpol C(3), grcexpol c(2), cobdir c(3), ;
	 cmex C(3),grcmex C(2), codzagt c(3), codmat C(8), codedizm c(4),izm_2 c(4),vzob_1 c(10),;
	vzob_2 c(10),norma C(10),nrcm_2 C(10), cves C(10),vesht C(10),kpsht C(5),kpmex C(4), ;
	svema C(6),nizv C(6),chixta C(9),nrssplav C(5),kprm C(1))

APPEND FROM &ad_vig.NKL802.DAT TYPE SDF as 866
USE 
*********!!!!!!!!!!!!!!!!************************************************************
sele 2
use &ad_norm.cexprimm orde coddet

sele 1
USE &ad_norm.NORMMAT
zap

wait 'Загружаем в NORMMAT данные из Oracle...'wind NOWAIT NOCLEAR  
APPEND FROM &ad_norm.NORMMATS		&&*********!!!!!!!!!!!!!!!!
ERASE &ad_norm.NORMMATS.dbf				&&*********!!!!!!!!!!!!!!!!
repl all kprm with 1,codedizm with alltrim(str(val(codedizm))),;
         izm_2 with iif(val(izm_2)=0,' ',alltrim(str(val(izm_2))))
repl kpsht with 1-kpsht/100 for kpsht>1.and.kpsht<=25
repl kpsht with kpsht/100 for kpsht>25

wait wind nowa 'Проставляем цеха-получатели из ВТМ (первые в ВТМ)...'
set rela to coddet into cexprimm
repl all cexpol with cexprimm.cexpol for found(2)
set rela to

WAIT 'Индексирую NORMMAT...' WINDOW NOWAIT NOCLEAR   
inde on codmat+cexpol tag codmat
inde on coddet+cexpol tag coddet
inde on coddet+codedizm tag detedizm
inde on codmat+codedizm tag matedizm
inde on cexpol+coddet tag cexdet
inde on cexpol tag cex
inde on coddet+codmat+alltrim(str(val(codedizm))) tag detmatizm
inde on coddet+codmat+alltrim(str(val(izm_2))) tag detmatizm2
inde on cexpol+codmat+coddet tag cexmatdet
inde on cmex+codmat+coddet tag cexmmatdet

CLOSE TABLES

erase &ad_norm.normmat2.cdx
*************!!!!!!!!!!!!!!!!!!*************************************
*** т.к. из текстового файла при зачитывании полей ЧИСЛОВЫХ в VF7 могут теряться значения,
**  то сначала создадим таблицу со структурой, где ВСЕ поля СИМВОЛЬНЫЕ.
** получим в неё данные из файла DAT, а затем их загрузим в правильную таблицу!!!
creat table &ad_norm.NORMMAT2S (coddet C(11), czm C(3), cexpol C(3), grcexpol c(2), cobdir c(3), ;
	 cmex C(3),grcmex C(2), codzagt c(3), codmat C(8), codedizm c(4),izm_2 c(4),vzob_1 c(10),;
	vzob_2 c(10),norma C(10),nrcm_2 C(10), cves C(10),vesht C(10),kpsht C(5),kpmex C(4), ;
	svema C(6),nizv C(6),chixta C(10),kprm C(1))

APPEND FROM &ad_vig.NKL802_2.DAT TYPE SDF as 866
USE 
*********!!!!!!!!!!!!!!!!************************************************************

sele 2
use &ad_norm.cexprimm orde coddet
sele 1
USE &ad_norm.NORMMAT2
zap

wait 'Загружаем в NORMMAT2...' WINDOW NOWAIT NOCLEAR 
APPEND FROM &ad_norm.NORMMAT2S		&&*********!!!!!!!!!!!!!!!!**
ERASE &ad_norm.NORMMAT2S.dbf		&&*********!!!!!!!!!!!!!!!!**

repl all kprm with 1,codedizm with alltrim(str(val(codedizm))),;
         izm_2 with iif(val(izm_2)=0,' ',alltrim(str(val(izm_2))))
repl kpsht with 1-kpsht/100 for kpsht>1.and.kpsht<=25
repl kpsht with kpsht/100 for kpsht>25

wait wind nowa 'Индексирую NORMMAT2...'
inde on codmat tag codmat
inde on coddet tag coddet
inde on coddet+codedizm tag detedizm
inde on codmat+codedizm tag matedizm
inde on cexpol+coddet tag cexdet
inde on cexpol tag cex
inde on coddet+codmat+alltrim(str(val(codedizm))) tag detmatizm
inde on coddet+codmat+alltrim(str(val(izm_2))) tag detmatizm2
inde on cexpol+codmat+coddet tag cexmatdet
inde on cmex+codmat+coddet tag cexmmatdet

wait wind nowa 'Проставляем цеха-получатели из ВТМ (первые в ВТМ):'
set rela to coddet into cexprimm
repl all cexpol with cexprimm.cexpol for found(2)
set rela to

CLOSE TABLES

wait wind nowa 'Загружаем данные в NORMMATO...'

ERASE &ad_norm.NORMMATO.CDX
*************!!!!!!!!!!!!!!!!!!*************************************
*** т.к. из текстового файла при зачитывании полей ЧИСЛОВЫХ в VF7 могут теряться значения,
**  то сначала создадим таблицу со структурой, где ВСЕ поля СИМВОЛЬНЫЕ.
** получим в неё данные из файла DAT, а затем их загрузим в правильную таблицу!!!
creat table &ad_norm.NORMMATOS (coddet C(11), codizd C(11), ob_tar c(4), allquant c(10),quant_m_k c(10), ;
		quant_kvi c(10),quant_teh c(10),quant_exp c(10),quant_obr c(10),num_izv c(5))

APPEND FROM &ad_vig.NKO803.DAT TYPE SDF as 866
USE 
*********!!!!!!!!!!!!!!!!************************************************************

USE &ad_norm.normmato
ZAP

APPEND FROM &ad_norm.NORMMATOS		&&*********!!!!!!!!!!!!!!!!**
ERASE &ad_norm.NORMMATOS.dbf		&&*********!!!!!!!!!!!!!!!!**
			
wait wind nowa 'Индексирую NORMMATO...'
inde on coddet+codizd tag detizd
inde on codizd+coddet tag izddet
CLOSE TABLES

if  adir(dr,ad_normS,'d')>0		&&  adir(dr,'y:\normativ','d')=1
		USE NORMMAT
		? '<5. НОРМАТИВНЫЕ КАРТЫ (normmat)> - В cети обновляем таблицу NORMMAT.dbf !'
		ON ERROR ? '<5. НОРМАТИВНЫЕ КАРТЫ (normmat)> - Проблема! В cети НЕ ОБНОВЛЕНА таблица NORMMAT.dbf !'
	   copy to &ad_normS.NORMMAT with cdx TYPE FOX2X as 866
	    ON ERROR 
	    
		USE NORMMATO
		? '<5. НОРМАТИВНЫЕ КАРТЫ (normmat)> - В cети обновляем таблицу NORMMATO.dbf !'
		ON ERROR ? '<5. НОРМАТИВНЫЕ КАРТЫ (normmat)> - Проблема! В cети НЕ ОБНОВЛЕНА таблица NORMMATO.dbf !'
	   copy to &ad_normS.NORMMATO with cdx TYPE FOX2X as 866
	    ON ERROR 
	    
		USE NORMMAT2
		? '<5. НОРМАТИВНЫЕ КАРТЫ (normmat)> - В cети обновляем таблицу NORMMAT2.dbf !'
		ON ERROR ? '<5. НОРМАТИВНЫЕ КАРТЫ (normmat)> - Проблема! В cети НЕ ОБНОВЛЕНА таблица NORMMAT2.dbf !'
	   copy to &ad_normS.NORMMAT2 with cdx TYPE FOX2X as 866
	    ON ERROR 
	    
		WAIT 'Базы данных NORMMAT.dbf , NORMMATO.dbf , NORMMAT2.dbf обновлены в сети!' WINDOW NOWAIT NOCLEAR 
		
		USE 
else
	WAIT 'Вы не подключены к сети! В cети НЕ ОБНОВЛЕНЫ таблицы NORMMAT, NORMMATO, NORMMAT2 ...' WINDOW NOWAIT NOCLEAR &&  time 1
	? '<5. НОРМАТИВНЫЕ КАРТЫ (normmat)> - В cети НЕ ОБНОВЛЕНЫ таблицы NORMMAT, NORMMATO, NORMMAT2!'
endif   
**До запуска след пункта висит сообщение wait о результате обновления по текущему пункту!

RETURN 



