# homework07
Пришлось на работе для теста поднять аналог zoom - https://www.videomost.com/. Работает он на apache. Для анализа его логов и напишу скрипт.

-X IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
-Y запрашиваемых адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
-все ошибки c момента последнего запуска;
-список всех кодов возврата с указанием их кол-ва с момента последнего запуска. 
-защита от мультизапуска

Скрипт будет принимать два параметра запуска: 
  1ый - количество выводимых IP адресов с наибольшим количеством запросов. (по убыванию)
  2ой - количество выводимых URI с наибольшим количеством запросов. (по убыванию) 
  
Начну сскрипт с проверки на количество и корректность параметров запуска.
