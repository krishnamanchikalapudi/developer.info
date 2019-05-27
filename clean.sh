#!/bin/bash
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

printf "\n\n ************************************************************* \n"
echo -e "Cleaning unused containers \n "
printf "\n ************************************************************* \n\n"
 
docker container prune -f  &
docker system prune -f &

containerLs=`docker container ls -a`
if [ ! -z "$containerLs" ]; then
    echo -e $containerLs
else
    printf "\n\n%s\n" " -------- ALL local images removed! -------- "
fi

echo -e "**** Current DT: $DATE_TIME \n "
exit 0