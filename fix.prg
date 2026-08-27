*********************************************************************
* FIX.prg - Программа для обеспечения не более одного запуска задачи
* Газизова И.М.
* 16.09.99
*********************************************************************
*SET DEFAULT TO c:\CEX\
fl=ad_start+'start.dbf'
IF FILE(fl)=.t.
	IF .NOT.USED("start")
		USE &ad_start.start.dbf IN 0 SHARE
	ENDIF
ELSE
	CREATE DBF &ad_start.start.dbf FREE (name_exe c(8),pr_zap c(1)) 
	INDEX ON name_exe TAG start
ENDIF

Select start
SET ORDER TO start
GO TOP
SEEK m.name_exe
IF FOUND()
	IF start.pr_zap='1' 
		=MESSAGEBOX("Извините,но у Вас уже запущена задача...",16,"Ошибка загрузки задачи")
		CANCEL
	ELSE
		UPDATE start SET start.pr_zap='1' WHERE start.name_exe=m.name_exe
	ENDIF
ELSE
		INSERT INTO start (name_exe,pr_zap) VALUES (m.name_exe,'1')
ENDIF   

Select start
USE