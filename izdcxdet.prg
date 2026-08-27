** izdcxdet.prg
** 2026г Смирнова
**
** Создаётся izdcxdet.dbf - распределение деталей по цехам и изделиям -- табоица в VF 7 !!!!!!!!!!

CLOSE TABLES
*!*	CLEAR 

WAIT 'Подождите, обновляю базу данных <9.5. Состав изделий по цехам (распределение деталей по цехам и изделиям)>' WINDOW NOWAIT NOCLEAR 

sele dist a1.codizd,a1.coddet,a2.cex,str(a2.zaxcex,1,0) as nzax ;
     from &ad_norm.outizd_a a1,&ad_norm.cexlst_a a2,&ad_norm.specific a3,&ad_norm.cex_trud a4 ;
     into dbf izdcxdet ;
     where a1.coddet=a2.coddet.and.a1.coddet=a3.codizd;
     .and.a2.codizd+a2.coddet=a3.codizd+a3.coddet.and.a2.nmarsh=1;
     .and.a1.coddet=a4.coddet

*!*	**************!!!*******************************
*!*	 ??? cex_trud - появляется после 9.2 - пункт ставим после него в п.9.4
*!*	     !!! 

clos data

? '<9.5. Состав изделий по цехам ... > Создана izdcxdet.dbf - распределение деталей по цехам и изделиям...' 

wait 'Создана izdcxdet.dbf - распределение деталей по цехам и изделиям...' WINDOW NOWAIT NOCLEAR 
RETURN 






