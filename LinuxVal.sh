#!/bin/bash

fileTimeInterval=45
daemonTimeInterval=15

while getopts f:d o
do  case "$o" in
    f) $fileTimeInterval="$OPTARG" ;;
    d) $daemonTimeInterval="$OPTARG" ;;
    esac
done

SoftwareChanges() { 
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install -y ./google-chrome-stable_current_amd64.deb
}

FileChanges() {

    fileTimeInterval="${1:-45}"
    pwd=$(pwd)
    currentdir="${pwd}/testfolder"
    mkdir $currentdir
    files=("f1-linux.txt" "f2-linux.txt" "f3-linux.txt")

    #Creating files
    for file in ${files}
    do
        echo "File created at $(date +"%T")">>"$currentdir/$file"
    done
    sleep $((fileTimeInterval*60))

    #Modifying files round 1
    echo "File modified at $(date +"%T")">>"$currentdir/f1-linux.txt"
    echo "File modified at $(date +"%T")">>"$currentdir/f2-linux.txt"
    echo "File modified at $(date +"%T")">>"$currentdir/f3-linux.txt"
    sleep $((fileTimeInterval*60))

    #Modifying files round 2
    echo "File modified at $(date +"%T")">>"$currentdir/f1-linux.txt"
    echo "File modified at $(date +"%T")">>"$currentdir/f2-linux.txt"
    echo "File modified at $(date +"%T")">>"$currentdir/f3-linux.txt"
    sleep $((fileTimeInterval*60))

    #Modifying files round 3
    echo "File modified at $(date +"%T")">>"$currentdir/f1-linux.txt"
    echo "File modified at $(date +"%T")">>"$currentdir/f2-linux.txt"
    rm "$currentdir/f3-linux.txt"
    echo "File created at $(date +"%T")">>"$currentdir/f4-linux.txt"
    sleep $((fileTimeInterval*60))

    #Modifying files round 4
    echo "File modified at $(date +"%T")">>"$currentdir/f1-linux.txt"
    echo "File modified at $(date +"%T")">>"$currentdir/f2-linux.txt"
    echo "File modified at $(date +"%T")">>"$currentdir/f4-linux.txt"

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

SoftwareChanges &
FileChanges $fileTimeInterval &
DaemonChanges $daemonTimeInterval &
