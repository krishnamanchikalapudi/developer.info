### Pre-requisite
[X] [Python 3.8 or higher](https://www.python.org/downloads/)
[X] [R 4.x](https://www.r-project.org/)

### Start Container
`````
./run.sh
`````

### Stop Containers
`````
./stop.sh
`````

### Installing via CRAN 'R'
Exceute below commands to allow R kernel to Juypter
`````
install.packages('IRkernel')
IRkernel::installspec(user = FALSE)
`````
