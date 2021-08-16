#!/bin/bash

outDirForFiles="/home/azureuser/testfolder"
fileTimeInterval=45
daemonTimeInterval=15

while getopts fdr o
do  case "$o" in
    f) $fileTimeInterval="$OPTARG" ;;
    d) $daemonTimeInterval="$OPTARG" ;;
    r) $outDirForFiles="$OPTARG" ;;
    esac
done

SoftwareChanges() { 
    wget 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'
    sudo apt-get install -y ./google-chrome-stable_current_amd64.deb
}

FileChanges() {

    echo "Executing FileChanges"

    fileTimeInterval="${1:-45}"
    currentdir="${2:-"/home/azureuser/testfolder"}"
    echo $currentdir
    #currentdir="${maindir}/testfolder"
    mkdir $currentdir
    files=('f1-linux.txt' 'f2-linux.txt' 'f3-linux.txt')

    #Creating files
    for file in "${files[@]}"
    do
        echo "File created at $(date +"%T")">>"$currentdir/$file"
    done
    sleep $((fileTimeInterval*60))

    #Modifying files round 1
    for file in "${files[@]}"
    do
        echo "File modified at $(date +"%T")">>"$currentdir/$file"
    done
    sleep $((fileTimeInterval*60))
    files+=('f4-linux.txt')
    echo "File created at $(date +"%T")">>"$currentdir/f4-linux.txt"
    

    #Modifying files round 2
    for file in "${files[@]}"
    do
        echo "File modified at $(date +"%T")">>"$currentdir/$file"
    done
    sleep $((fileTimeInterval*60))
    

    #Modifying files round 3
    for file in "${files[@]}"
    do
        echo "File modified at $(date +"%T")">>"$currentdir/$file"
    done
    sleep $((fileTimeInterval*60))

    #Deleting files
    for file in "${files[@]}"
    do
        rm -f "$currentdir/$file"
    done


}

DaemonChanges() { 
    daemonTimeInterval="$1"
    for i in 1 2 3 4 5
    do
        echo $i
        if (systemctl -q is-active accounts-daemon.service)
        then
            echo "daemon running"
            sudo systemctl stop accounts-daemon.service
        else
            echo "daemon stopped"
            sudo systemctl start accounts-daemon.service
        fi 
        sleep $((daemonTimeInterval*60))
    done
}

omsagentDir="/etc/opt/microsoft/omsagent/conf/omsagent.d"
confMofFiles=("change_tracking.conf" "change_tracking_inventory.mof" "service_change_tracking.conf" "service_change_tracking_inventory.mof" "LinuxFileChangeTracking.conf" "LinuxFileChangeTracking.mof")
for file in "${confMofFiles[@]}"
do
    fileToCheck="$omsagentDir/$file"
    while (sudo test ! -e $fileToCheck)
    do
        echo "$fileToCheck does not exist. Going back to sleep..."
        sleep 600
    done
        echo "$file exists.Proceeding..."
done

FileChanges $fileTimeInterval $outDirForFiles &
DaemonChanges $daemonTimeInterval &
SoftwareChanges &
