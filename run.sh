#!/bin/bash
######
if  [[$# -ne 2 ]] #если количство пааремтров не равно двум
  then
    echo "use run.sh X Y where X - top IP, Y - top URI"
	exit 0
  elif [[ $1 -lt 0 ]] #если первый параметр меньше нуля
	then
		echo "X must be grate 0"
		exit 0
	elif  [[ $2 -lt 0 ]] #если второй параметр меньше нуля
	  then
		echo "Y must be grate 0"
		exit 0
fi

x=$1
y=$2


# Защита от повторного запуска
LOCKFILE="/var/log/httpd/run.sh.lock" #файл блокировки запуска
if test -f $LOCKFILE #если файл блокировки уже есть
  then
    pid=$(cat $LOCKFILE)
    echo "Script run.sh already runing!!! PID="$pid 1>&2 #прочитаю и выведу pid запущенного уже скрипта
    exit 1
  else
    touch $LOCKFILE #иначе создаю файл блокировки и записываю туда свой pid
	echo $$>>$LOCKFILE
fi

# Когда последний раз анализировался access.log
ACCLASTfile="/var/log/httpd/access-vm.log.last" #файл с информацией о последнем анализе файла access-vm.log

if test -f $ACCLASTfile #если файл есть то счиатем из него
  then
    ACCLAST=$(cat $ACCLASTfile)
	STARTACCPOS=$(grep -n "$ACCLAST" access-vm.log | awk -F':' '{print $1}'| head -1) #получаю позицию с котрой начинать анализировать файл
		if [ -z "$STARTACCPOS" ];then STARTACCPOS=1;fi #если не нашел, то начнем с начала файла 
	FINACCPOS=$(wc -l < access-vm.log) #и запомним на момент запуска конечную позицю, так как файл может дописываться, пока работает скрипт
	
  else
    touch $ACCLASTfile #иначе создаю файл,
	STARTACCPOS=1 # анализировать буду с первой строки
	FINACCPOS=$(wc -l < access-vm.log) #и до конца файла
fi

# Когда последний раз анализировался error-vm.log
ERRLASTfile="/var/log/httpd/error-vm.log.last"

if test -f $ERRLASTfile #если файл есть то счиатем из него
  then
    ERRLAST=$(cat $ERRLASTfile) 
	STARTERRPOS=$(grep -n "$ERRLAST" error-vm.log | awk -F':' '{print $1}'| head -1) #получаю позицию с котрой начинать анализировать файл
		if [ -z "$STARTERRPOS" ];then STARTERRPOS=1;fi #если не нашел, то начнем с начала файла
	FINERRPOS=$(wc -l < error-vm.log) #и запомним на момент запуска конечную позицю, так как файл может дописываться, пока работает скрипт
  else
    touch $ERRLASTfile #иначе создаю файл,
	STARTERRPOS=1 #анализировать буду с первой строки
	FINERRPOS=$(wc -l < error-vm.log) #и до конца файла
fi

#посчитаю, сколько строчек с конца файла будем анализировать.

ACCTAIL=$(($FINACCPOS-$STARTACCPOS));
ERRTAIL=$(($FINERRPOS-$STARTERRPOS));

#и запишу с чего начать в следующий раз

(sed -n $FINACCPOS,${FINACCPOS}p access-vm.log| sed 's/.*\[//;s/].*//;')>>${ACCLASTfile}

(sed -n $FINERRPOS,${FINERRPOS}p error-vm.log | sed 's/\[//;s/].*//;')>>${ERRLASTfile}

#вывод информации
printf "+TOP IP+++++++++++++++++++++++++\n\n"
cat access-vm.log | tail -n $ACCTAIL | awk '{ ipcount[$1]++ } END { for (i in ipcount) { printf "IP: %15s - %d times\n", i, ipcount[i] } }' |sort -rnk4 | head -${x}
printf "+TOP URI+++++++++++++++++++++++++\n\n"
cat access-vm.log | tail -n $ACCTAIL | grep -E 'GET|POST'| awk '{ uri[$7]++ } END { for (i in uri) { printf "URI : %s - %d times\n", i, uri[i] } }' | sort -rnk5 | head -${y}
printf "+ERROR+++++++++++++++++++++++++++\n\n"
cat error-vm.log | tail -n $ERRTAIL
printf "+TOP HTTP CODE++++++++++++++++++\n\n"
cat access-vm.log | tail -n $ACCTAIL | awk  '{ httpcode[$9]++ } END { for (i in httpcode) { printf "HTTP CODE : %3s - %d times\n", i, httpcode[i] } }' | sort -rnk6
printf "++++++++++++++++++++++++++++++++\n\n"

# удаляею лок файл
rm -f $LOCKFILE
exit 0
