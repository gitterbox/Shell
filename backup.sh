#!/bin/bash
###################################################
###Sicherungsscript letzte Aenderung am 09.11.12###
###Darf im Rahmen der GPL verbreitet werden########
#####################renku#########################
#######################################################################
#Der letzte Stand ist immer Vollbackup + letztes differentielles Backup

. .settings

proof () {
        touch $1 2>/dev/null
        echo $?
}

before () {
        echo "do before Action"
        #/etc/init.d/psql stop
        sleep 5
}

after () {
        echo "do after action"
        #/etc/init.d/psql start
}

runSic () {
        before
        echo ""
        echo "Sicherungsbeginn---------`file`---------------$ZEIT" 
        echo -e "Sichere $DIR1 $DIR2 $DIR3 nach $GERAET"
        echo "$INFO" 
        echo ""
        # windows like 
        #/bin/tar vcf $GERAET -g $1 "${src_name}" $DIR2 $DIR3  
        # default 
        /bin/tar vcf $GERAET -g $1 $DIR1 $DIR2 $DIR3  
        if [ $? -ne 0 ]
        then 
                sendMail "Es ist ein Fehler aufgetreten"  
                echo "Fehler" >> $LOG
                $PTH/./bubble.py "Backup verschoben :/"
                after
                exit 1
        else 
                #Eintrag in /var/log/messages erstellen
                logger "Backup `file` erfolgreich erstellt"
                $PTH/./bubble.py "Backup erfolgreich :)"
                increaseCounter
                #Mail 
                #sendMail "Backup erfolgreich erstellt"
        fi    
        after
        #echo "$ZEIT----------------`file`----------Sicherungsende" >> $LOG
}

file () {
        if [ "$1" = "w" ]
        then 
                echo "$2" > $FILE  
        else 
                while read -r xx yy
                do  
                        printf "%s" "$yy" "$xx"
                done  < $FILE
        fi
}

increaseCounter(){
        let A=`file`
        let B=1
        let C=$A+$B
        echo "schreibe $C in $FILE"
        file w $C
}

sendMail() {
        (
        echo "Betreff: $1"
        echo " "
        echo " "
        tail -n 50 $LOG
        ) | mail -s "$0 $1" $MAIL1
        #-a anhang
}

createConf(){
        cd $TARGET        
        mkdir .backup
        echo "$CONF erstellt"
        #erstellen von counter und stempel 
        touch $FILE
        file w 0
        echo "$FILE erstellt"
        touch $STEMPEL    
        echo "$STEMPEL erstellt"
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#############MAIN###################
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
if [ `proof $TARGET/testfile` -gt 0 ] 
then
        echo "$TARGET nicht schreibbar"
        sendMail "$TARGET ist leider nicht schreibbar"
        logger "$TARGET ist leider nicht schreibbar"
        #echo `proof $TARGET/testfile`
else
        #test ob configurations Ordner existiert
        if [ `proof $CONF/testfile` -gt 0 ]
        then
                createConf
        fi
        #prüfe ob über Limit bzw. kein lesbares Vollbackup vorhanden
        if [ `file` -gt $LIMIT ] || [ ! -r $TARGET/$VBFILE ]
        then
                $LEERE > $STEMPEL
                echo "Vollbackup --> leere $STEMPEL"
                file w 
                rm $TARGET/$VBFILE
                rm $TARGET/bac*
                GERAET=$TARGET/$VBFILE
                runSic $STEMPEL > $LOG
        else
                echo "Differentielles Backup `file`..."
                GERAET=$TARGET/bac-`file`.tar
                cp $STEMPEL $STEMPELTMP
                runSic $STEMPELTMP > $DIFLOG
                # Pfade und leere Zeilen entfernen und ins Log schreiben
                sed 's/.*\/$//g' < $DIFLOG | egrep -v "#|^$" >>$LOG
        fi

        rm $TARGET/testfile
fi
