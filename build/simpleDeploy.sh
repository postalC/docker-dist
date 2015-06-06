#!/bin/bash
# Author: Guo Jiachun<jiachun.guo@sap.com>

# -- configure mobiliser host and port for portal --
function portal_mobiliser_config {
    ANSWER=""
    echo -n "`date` : INFO : Change Mobiliser host and port for Portal? (default is localhost:8080) [Y/N] : "
    read ANSWER
    if [ "$ANSWER" == "Y" ]||[ "$ANSWER" == "y" ]; then
        ANSWER=""
        echo -n "INFO : Mobiliser Host: "
        read HOST
        echo -n "INFO : Mobiliser Port: "
        read PORT
        echo "INFO : About to set Mobiliser Host to $HOST and port to $PORT"
        echo "       Files to be modified are: "
        echo "       $DEST/web/conf/context.xml"
        echo "       $DEST/web/bin/setenv.sh"
        echo -n "INFO : Confirm the setting? [Y/N] : "
        read ANSWER
        if [ "$ANSWER" == "Y" ]||[ "$ANSWER" == "y" ]; then
            ANSWER='N'
            sed -i -r "s,(prefs://prefsread:notsosecret@).*(/mobiliser),\1$HOST:$PORT\2," $DEST/web/conf/context.xml
            sed -i -r "s,^(MOBILISER_HOST=).*,\1http://$HOST:$PORT," $DEST/web/bin/setenv.sh
            echo "INFO : Set Mobiliser Host to $HOST and port to $PORT in $DEST/web/conf/context.xml and $DEST/web/bin/setenv.sh" | tee -a $LOG
            echo ""
        else
            echo "INFO : abort setting for Mobiliser Host and Port."
            echo ""
            portal_mobiliser_config
        fi
    else
        echo "INFO : Keep Default Setting for Mobiliser Host(localhost) and Port(8080). Nothing changed." | tee -a $LOG 
        echo ""
    fi
}

# -- configure exposed port for portal --
function portal_port_config {
    ANSWER=""
    echo -n "`date` : INFO : Change exposed port for portal? (default is 8082) [Y/N] : "
    read ANSWER
    if [ "$ANSWER" == "Y" ]||[ "$ANSWER" == "y" ]; then
        ANSWER=""
        echo -n "INFO : port: "
        read PORT
        echo "INFO : About to set exposed port to $PORT. Files to be modified are: "
        echo "       $DEST/web/conf/server.xml"
        echo -n "INFO : Confirm the setting? [Y/N] : "
        read ANSWER
        if [ "$ANSWER" == "Y" ]||[ "$ANSWER" == "y" ]; then
            ANSWER=""
            sed -i -r "s,^(\s*<Connector port=).*(protocol=\"HTTP/1.1\"),\1\"$PORT\" \2," $DEST/web/conf/server.xml
            echo "INFO : Set exposed port to $PORT in $DEST/web/conf/server.xml" | tee -a $LOG
            echo ""
        else
            echo "INFO : abort port setting."
            echo ""
            portal_port_config
        fi
    else
        echo "INFO : Keep default port Setting (8082) for portal." | tee -a $LOG 
        echo ""
    fi
}

# -- configure port for money --
function money_port_config {
    ANSWER=""
    echo -n "`date` : INFO : Change port for money? (default is 8080) [Y/N] : "
    read ANSWER
    if [ "$ANSWER" == "Y" ]||[ "$ANSWER" == "y" ]; then
        ANSWER=""
        echo -n "INFO : port: "
        read PORT
        echo "INFO : About to set port to $PORT. Files to be modified are: "
        echo "       $DEST/money/conf/jetty.xml"
        echo "       $DEST/money/conf/cfgload/com.sybase365.mobiliser.framework.gateway.security.authentication.webconsole.properties"
        echo -n "INFO : Confirm the setting? [Y/N] : "
        read ANSWER
        if [ "$ANSWER" == "Y" ]||[ "$ANSWER" == "y" ]; then
            ANSWER=""
            sed -i -r "s,^(\s*<Set name=\"port\">).*,\1$PORT</Set>," $DEST/money/conf/jetty.xml
            sed -i -r "s,^(requiredPorts=).*,\1$PORT," $DEST/money/conf/cfgload/com.sybase365.mobiliser.framework.gateway.security.authentication.webconsole.properties
            echo "INFO : Set port to $PORT in $DEST/money/conf/jetty.xml and $DEST/money/conf/cfgload/com.sybase365.mobiliser.framework.gateway.security.authentication.webconsole.properties" | tee -a $LOG
            echo ""
            
            # -- configure mobiliser port for web portal --
            echo -n "INFO : Set portal to listen to mobiliser on port $PORT? [Y/N] : "
            read ANSWER
            if [ "$ANSWER" == "Y" ]||[ "$ANSWER" == "y" ]; then
                ANSWER=""
                sed -i -r "s,(prefs://prefsread:notsosecret@.*):\w*(/mobiliser),\1:$PORT\2," $DEST/web/conf/context.xml
                sed -i -r "s,^(MOBILISER_HOST=.*):\w*,\1:$PORT," $DEST/web/bin/setenv.sh
                echo "INFO : Set portal to listen to mobiliser on port $PORT in $DEST/web/conf/context.xml and $DEST/web/bin/setenv.sh" | tee -a $LOG
                echo ""
            else
                echo "INFO : Portal configuration not changed." | tee -a $LOG
                echo ""
            fi
        else
            echo "INFO : abort port setting."
            echo ""
            money_port_config
        fi
    else
        echo "INFO : Keep default port Setting (8080) for money." | tee -a $LOG 
        echo ""
    fi
}

# -- configure DB connection --
function db_config {
    ANSWER=""
    echo -n "`date` : INFO : Configure DB connection now? [Y/N] : "
    read ANSWER
    if [ "$ANSWER" == "Y" ]||[ "$ANSWER" == "y" ]; then
        ANSWER=""
        echo -n "INFO : JDBC_URL: "
        read URL
        echo -n "INFO : JDBC_USERNAME: "
        read USER
        echo -n "INFO : JDBC_PASSWORD: "
        read PASSWORD
        echo "INFO : Confirm the following setting:"
        echo "       JDBC_URL=jdbc:sap://$URL:30015"
        echo "       JDBC_USERNAME=$USER"
        echo "       JDBC_PASSWORD=$PASSWORD"
        echo -n "INFO : Confirm the setting? [Y/N] : "
        read ANSWER
        if [ "$ANSWER" == "Y" ]||[ "$ANSWER" == "y" ]; then
            ANSWER='N'
            sed -i "s,^JDBC_URL=.*,JDBC_URL=jdbc:sap://$URL:30015,;s,^JDBC_USERNAME=.*,JDBC_USERNAME=$USER,;s,^JDBC_PASSWORD=.*,JDBC_PASSWORD=$PASSWORD,"  $DEST/money/conf/system.properties 
            echo "INFO : set JDBC_URL=jdbc:sap://$URL:30015 " | tee -a $LOG
            echo "INFO : set JDBC_USERNAME=$USER " | tee -a $LOG
            echo "INFO : set JDBC_PASSWORD=$PASSWORD " | tee -a $LOG
            echo "INFO : Configured DB connection in $DEST/money/conf/system.properties" | tee -a $LOG
            echo ""
        else
            echo "INFO : abort DB connection setting."
            echo ""
            db_config
        fi
    else
        echo "INFO : Keep Original DB Connection Setting. Nothing changed." | tee -a $LOG 
        echo ""
    fi
}

function deploy_money {
    ANSWER=""
    if [ -d "$DEST/money" ]; then
        echo "ERROR : --------------------------------------------" | tee -a $LOG
        echo "ERROR : "$DEST/money" already exist..." | tee -a $LOG
        echo "ERROR : --------------------------------------------" | tee -a $LOG
        echo ""
        echo -n "`date` : INFO : Do you want to remove it? [Y/N] : "
        read ANSWER
        if [ "$ANSWER" == "Y" ]||[ "$ANSWER" == "y" ]; then
            ANSWER="N"
            tarFileName=money-full-backup-$(date +"%Y-%m-%d_%H-%M").tar.gz
            tar -cvzf $tarFileName $DEST/money
            rm -Rf $DEST/money
            mv $tarFileName /tmp
            echo "INFO : Move Original $DEST/money directory to temp" | tee -a $LOG
            echo "`date` : --------------------------------------------"
            mv $path/money $DEST/money
            chmod -R u+x $DEST/money
            echo "INFO : Move CityApp Backend to $DEST/money" | tee -a $LOG
            echo ""

            # -- configure DB connection --
            db_config
            # -- configure port for money --
            money_port_config
        else
            echo "INFO : Keep Original $DEST/money. Nothing changed." | tee -a $LOG
            echo ""
        fi
    else
        mv $path/money $DEST/money
        chmod -R u+x $DEST/money
        echo "INFO : Move CityApp Backend to $DEST/money" | tee -a $LOG
        echo ""

        # -- configure DB connection --
        db_config
        # -- configure port for money --
        money_port_config
    fi
}

function deploy_web {
    ANSWER=""
    if [ -d "$DEST/web" ]; then
        echo "ERROR : --------------------------------------------" | tee -a $LOG
        echo "ERROR : "$DEST/web" already exist..." | tee -a $LOG
        echo "ERROR : --------------------------------------------" | tee -a $LOG
        echo ""
        echo -n "`date` : INFO : Do you want to remove it? [Y/N] : "
        read ANSWER
        if [ "$ANSWER" == "Y" ]||[ "$ANSWER" == "y" ]; then
            ANSWER="N"
            tarFileName=web-full-backup-$(date +"%Y-%m-%d_%H-%M").tar.gz
            tar -cvzf $tarFileName $DEST/web
            rm -Rf $DEST/web
            mv $tarFileName /tmp
            echo "INFO : Move Original $DEST/web directory to temp" | tee -a $LOG
            echo "`date` : --------------------------------------------"
            mv $path/web $DEST/web
            chmod -R u+x $DEST/web
            echo "INFO : Move CityApp Portal/Backoffice to $DEST/web" | tee -a $LOG
            echo ""
                        
            # -- configure exposed port for portal --
            portal_port_config
            # -- configure mobiliser host and port for portal --
            portal_mobiliser_config
        else
            echo "INFO : Keep Original $DEST/web. Nothing changed." | tee -a $LOG
            echo ""
        fi
    else
        mv $path/web $DEST/web
        chmod -R u+x $DEST/web
        echo "INFO : Move CityApp Portal/Backoffice to $DEST/web" | tee -a $LOG
        echo ""
                
        # -- configure exposed port for portal --
        portal_port_config
        # -- configure mobiliser host and port for portal --
        portal_mobiliser_config
    fi
}

clear

if [[ -z "$1" || -z "$2" ]]; then
    echo "Please specify the source zip file and destination directory"
    echo "example: ./simpleDeploy.sh cityapp.dist.zip /opt/cityapp"
    exit
fi

if [[ ! "$1" =~ \.zip$ ]]; then
    echo "Error : Source file should be a zip compressed file."
    exit
fi

if [ ! -d "$2" ]; then
    echo "Error : Directory $2 does not exist."
    exit
fi

LOG="$HOME/deploy/deployment-$(date +"%Y-%m-%d-%H-%M").log"
echo "`date` : INFO : Running CityApp Simple Deployment Scripts" | tee -a $LOG
# -- offer to start deploy --
echo -n "`date` : INFO : Do you wish to start deployment now? [Y/N] : "
read ANSWER
if [ "$ANSWER" == "Y" ]||[ "$ANSWER" == "y" ]; then
    ANSWER="N"
    # -- settings --
    current_dir=$(pwd)
    echo "Dir:[$current_dir]"
    SCR="$1"
    DEST="$2"

    ## -- check diskspace usage --
    if [ `df -h | grep "/$" | grep -c "100%"` -gt 0 ]; then
        echo "ERROR : --------------------------------------------" | tee -a $LOG
        echo "ERROR : Disk Full! Please cleanup before proceeding." | tee -a $LOG
        echo "ERROR : --------------------------------------------" | tee -a $LOG
        exit
    fi

    ## -- Start Process --
    ## -- unzip source file --
    echo "INFO : Starting to unzip Input Source File is $SCR" | tee -a $LOG
    unzip $SCR -d temp
    echo "INFO : Unzip completed" | tee -a $LOG
    echo ""

    path="$(ls -d temp/*)"
    echo "INFO : List unzipped result" | tee -a $LOG
    ls -ltr $path
    echo ""

    # -- options to deploy --
    echo "`date` : INFO : Options to deploy"
    echo "Deployment options: for CityApp Core (money)"
    echo "[100] Clean Install - Remove/Replace entire 'money' directory"
    echo "------------------------------------------------------------"

    echo "Deployment options: for CityApp Portal/Backoffice (web)"
    echo "[200] Clean Install - Remove/Replace entire 'web' directory"
    echo "------------------------------------------------------------"

    echo "Deployment options: for Entire CityApp - CityApp Core (money) & Portal/Backoffice (web)"
    echo "[700] Clean Install - Remove/Replace entire 'money' and 'web' directory"
    echo "------------------------------------------------------------"
    echo ""
    echo -n "`date` : INFO : What Module you wish to deployment now?: "
    read ANSWER

    case $ANSWER in
        100 ) deploy_money
              ;;
        200 ) deploy_web
              ;;
        700 ) deploy_money
              deploy_web
              ;;
        * ) echo "ERROR : --------------------------------------------" | tee -a $LOG
            echo "ERROR : Invalid Deployment Option :p ..." | tee -a $LOG
            echo "ERROR : --------------------------------------------" | tee -a $LOG
            echo "INFO : Remove working file" | tee -a $LOG
            rm -Rf $path
            echo "INFO : Completed" | tee -a $LOG
            exit
    esac

    echo "INFO : List move result"
    echo ""
    cd $DEST
    ls -ltr
    # -- return to current dir --
    cd $current_dir

    echo "INFO : Remove working file" | tee -a $LOG
    rm -Rf $path
    echo "INFO : Completed" | tee -a $LOG
    echo ""
else
    echo "ERROR : --------------------------------------------" | tee -a $LOG
    echo "ERROR : Invalid Answer :p ..." | tee -a $LOG
    echo "ERROR : --------------------------------------------" | tee -a $LOG
    exit
fi

# -- Final Message --
echo "`date` : --------------------------------------------"
echo "`date` : INFO : Deployment log store in $LOG"
echo "`date` : INFO : Have a nice day!"
echo "`date` : --------------------------------------------"
