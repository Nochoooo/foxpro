
*********************************************************************
* puti_.prg - ѕрограмма дл€ установки путей к таблицам задачи
* —мирнова Ќ.ј.
* 10.01.2004
*********************************************************************
* переменные описывающие пути к таблицам начального запуска
* список путей может мен€тьс€ (дополн€тьс€) дл€ разных задач, Ќќ
* об€зательно определены до работы или должны быть в списке : ad_puti, ad_start , ad_norm
PUBLIC ad_puti, ad_start, ad_norm, ad_normS,ad_vig, ad_netR 
m.ad_puti='C:\cex\'	&& путь к таблице PUTI -Ё“ќ ќЅя«ј“≈Ћ№Ќќ!
m.ad_start='c:\cex\'	&& путь к таблицам начальной регистрации пользователей -Ё“ќ ќЅя«ј“≈Ћ№Ќќ!!
inorm=1			&& это индекс адреса в таблице PUTI !! информ дл€ разработчика
m.ad_norm=''	&& путь к базам нормативным -Ё“ќ ќЅя«ј“≈Ћ№Ќќ, где лежит на ѕ  Ќ—»!!
inormS=2
m.ad_normS=''	&& путь к базам нормативным сетевым
inetR=3
m.ad_vig=''
inetR=4
m.ad_netR=''	&& ѕуть к  общедоступной архивной области сети с »нструкци€ми  

IF FILE('c:\cex\puti.dbf')=.t.
	IF .NOT.USED("puti")
		USE c:\cex\puti.dbf IN 0 SHARE
	ENDIF
ELSE
	=MESSAGEBOX("ƒл€ запуска нужна таблица PUTI в C:\CEX\...",16,"ќшибка загрузки задачи")
	cancel
ENDIF

Select PUTI

**********************************ind_adr
baz_t='c:\cex\puti.dbf'
STR_indB='ind_adr'
im_ind='IND_ADR'
** по im_ind провер€ем создание индекса ('NOT' нет)
ON ERROR do IndexEr with baz_t,STR_indB,im_ind
SET ORDER TO IND_ADR
ON ERROR 

STR_indB='ALLTRIM(STR(ind_arm,5,0))+ALLTRIM(im_adr)'
im_ind='armadr'
** по im_ind провер€ем создание индекса ('NOT' нет)
ON ERROR do IndexEr with baz_t,STR_indB,im_ind
SET ORDER TO armadr
ON ERROR 
*************************************
GO TOP
* ограничение по индексу ј–ћа (id_ar)
COPY TO ARRAY pb FIELDS PUTI.Im_adr FOR ind_arm=m.id_ar
GO top
COPY TO ARRAY pb FIELDS PUTI.Im_adr FOR ind_arm=m.id_ar
FOR i=1 TO alen(pb)
 SEEK ALLTRIM(STR(m.id_ar,5,0))+ALLTRIM(pb(i))
 IF FOUND()
	&pb(i).=ALLTRIM(puti.ADRES)
 ENDIF 
endfor  

USE