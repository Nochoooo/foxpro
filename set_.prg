***********************************
*** Очистка памяти (глобальная) ***
***********************************
*!*	CLEAR ALL
*!*	CLEAR PROGRAM
CLOSE ALL
*!*	SET DEFAULT TO CURDIR()
****************************
*** Установки оформления ***
****************************
SET TALK OFF
SET SAFETY OFF
SET DATE TO GERMAN
SET STATUS BAR ON  && Для работы надо ON
SET CLOCK STATUS
*SET ESCAPE OFF
SET CENTURY ON		&& Дата 1999
SET CENTURY TO 19 ROLLOVER 50	&& если вводят 01, то вводится 2001
ON SHUTDOWN QUIT
**********************************
*** Установки работы с данными ***
**********************************
SET EXCLUSIVE ON		&& чтобы базы открывались SHARE -OFF- если ничего не указано
SET DELETED ON
*!*	SET NEAR OFF
SET NULLDISPLAY TO ''
SET NEAR ON
*!*	SET NOTIFY OFF   && Отключает системные сообщения
SET KEYCOMP TO DOS  
*SET AUTOSAVE ON
*SET HEADINGS ON
*SET OPTIMIZE ON
*SET UNIQUE OFF
*SET COLLATE TO 'MACHINE'
*SET ODOMETER TO 100
*SET BLOCKSIZE TO 64
*SET REFRESH TO 5,5
*SET EXACT OFF
*SET ANSI ON
SET LOCK OFF
SET MULTILOCKS ON
*SET REPROCESS TO AUTOMATIC
