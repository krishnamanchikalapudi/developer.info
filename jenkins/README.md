
### login
`````````
docker login -u iamkittu
`````````

### pull latest image
`````````
docker pull jenkins/jenkins:latest
`````````

### run
`````
docker container run -d -p 7080:8080 -v jenkins_home:~/TOOLS/jenkins jenkins/jenkins:latest
`````

### List container command & pattern  'docker container ls -a'
`````
docker container ls -a
`````


### Stop containers & pattern  'docker container stop CONTAINER_ID'
`````
docker container stop 25efce8300f2a5d58c40396d27d811e42038d47f8dd528323acce2dff451e915
`````

### Remove unused containers
`````
docker container prune -f 
`````

### mac - check process
`````
lsof -nP -iTCP:7080
`````