#!/bin/bash

#check the user that runs the script
if [[ $(id -u) -eq 0 ]] || [[ $(id -g) -eq 0 ]] ; then
    echo "You can't be root. root has too much power."
    echo -e "\e[31mFATAL ERROR\e[0m"
    exit 1
fi

. /load-libs.sh

#General Overview Of the consequences
echo "This script will erase EVERYTHING related to docker on your machine."
echo -n "It is intended as 'OMG, something is wrong with some docker, "
echo "I do not know what, i do not want to investigate further'"

#Detailed Overview Of the Consequences
if [[ $WTL_PRODUCTION == "1" ]] ; then
    echo "WAAAAAT?!"
    echo "You are triyng to delete all the dockers on a production environment?!"
    echo -n "I mean, you should know how to use docker to solve your problems"
    echo "without this script. Sorry man, I have to abort."
    echo -e "\e[31mFATAL ERROR\e[0m"
    exit 1
else
    echo
    echo "In particular, this will run:"
    echo "1. 'docker stop' on every docker container listed by 'docker ps'"
    echo "     this will stop every active docker container"
    echo "2. 'docker rm' on every docker container listed by 'docker ps'"
    echo "     this will remove every docker container"
    echo "3. 'docker rmi' on every docker image listed by 'docker images'"
    echo "     this will remove every docker image."
    echo -e "     \e[31mTHIS CUOLD WASTE YOUR TIME!\e[0m"
    echo "     reverting this command means downloading again the docker images"
    echo "     from the internet, and it could take a LOOOOOONG time"
    echo "4. 'docker volume rm' on every docker volume listed by 'docker volume ls'"
    echo "     this will remove every docker volume present on your computer"
    echo -e "     \e[31mTHIS IS DANGEROUS!\e[0m"
    echo "     You could lose data, in particular all the data"
    echo "     generated inside the docker containers and not safely backed up"
    echo "     will be gone.Forever"

    echo "Further information about docker containers can be found here:"
    echo "https://docs.docker.com/"
    echo
fi

#Interavtive part: we do not want this to go badly/automatically
echo "I, stupid script, have to be sure you know what you are doing."
echo "I will ask you few things, I have to."
echo

echo "Have you understood what you are doing?"
echo -n "('Yes' or 'no'): "
read understood
I_have_understood="0"
if [[ "$understood" == "Yes" ]]; then
    I_have_understood="1"
else
    echo "Wrong answer. Aborting. "
    echo "You should not feel bad, you are not losing anything"
    exit 1
fi
echo

echo "I am not so sure. Do you really want me do delete everyting?"
echo -n "('Yes, delete everything. Please. Now.' or 'no'): "
read delete_evth
I_want_to_delete_evth="0"
if [[ ${delete_evth,,} == "yes, delete everything. please. now." ]]; then
    I_want_to_delete_evth="1"
else
    echo "Wrong answer. Aborting. "
    echo "You should not feel bad, you are not losing anything"
    exit 1
fi
echo

echo "Are you really sure?"
echo -e "\e[31mTHIS OPERATION CAN NOT BE UNDONE!\e[0m"
echo -n "('Yes, for God's sake!' or 'no'): "
read really_sure
I_am_really_sure="0"
if [[ ${really_sure,,} == "yes, for god's sake!" ]]; then
    I_am_really_sure="1"
else
    echo "Wrong answer. Aborting. "
    echo "You should not feel bad, you are not losing anything"
    exit 1
fi
echo

echo "Okok, last question:"
echo "Which animal is in the docker logo? "
echo -n "(the answer I expect is composed by a single word): "
read logo
I_know_the_logo="0"
if [[ ${logo,,} == "whale" ]]; then
    I_know_the_logo="1"
else
    echo "Wrong answer. Aborting. "
    echo "You should not feel bad, you are not losing anything"
    exit 1
fi
echo

if [[ $I_know_the_logo == "1" ]] && [[ $I_have_understood == "1" ]] && [[ $I_want_to_delete_evth == "1" ]] && [[ $I_am_really_sure == "1" ]]; then
    echo "Ok, then you are not koking at all. "
    echo "Well, i guess i have to delete everything now."
    echo -e "\e[31mTOO LATE: THIS OPERATION CAN NOT BE REVERTED!\e[0m"
    docker stop $(docker ps -a -q)
    docker rm $(docker ps -a -q)
    docker images -q  | uniq | while read id; do
        # count tags for image
        COUNT=0
        while docker inspect -f '{{index .RepoTags '$I'}}' $id &> /dev/null ; do
            COUNT=$(($COUNT+1))
        done
        # if an image has more then one tag we delete the tag now because with docker rmi $(docker images -q) the duplicated id will not be removed
        if [[ $COUNT -gt 1 ]] ; then
            I=0
            while docker rmi $(docker inspect -f '{{index .RepoTags '$I'}}' $id) ; do
                I=$(($I+1))
            done
        fi
    done
    docker rmi $(docker images -q)
    docker volume rm $(docker volume ls -q)

    echo
    echo "~~~~~~"
    echo "I did everything that you asked. Enjoy a clean system! :D"
fi
