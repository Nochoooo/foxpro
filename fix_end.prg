*********************************************************************
* FIX_end.dbf - Программа для обеспечения не более одного запуска задачи
* Газизова И.М.
* 16.09.99
*********************************************************************
IF .NOT.USED("start")
*	USE c:\cex\start.dbf IN 0 SHARE
	USE &ad_start.start.dbf IN 0 SHARE
ENDIF

Select start
SET ORDER TO start
GO TOP
SEEK m.name_exe
IF FOUND()
	UPDATE start SET start.pr_zap='0' WHERE start.name_exe=m.name_exe
ENDIF   
USE