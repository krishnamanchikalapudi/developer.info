## Start Mock service
* execute start.sh or restart.sh

## [optional] windows folks
* Download jar from http://repo1.maven.org/maven2/com/github/tomakehurst/wiremock-jre8-standalone/2.24.1/wiremock-jre8-standalone-2.24.1.jar

## Mock service data setup
* Create API name json file at folder 'mappings'. example: mappings/user.json
* API resource in the one file. example: mappings/user.json contains 2 resources: /v1/user/health, /user/v1/
* __file/user/v1/health.json contains the response body

## Test service
curl -O http://repo1.maven.org/maven2/com/github/tomakehurst/wiremock-jre8-standalone/2.24.1/wiremock-jre8-standalone-2.24.1.jar  



- Health test
````
curl -w "\n" -X GET http://localhost:7080/user/v1/health
````

- User POST test
````
curl -w "\n" -H "Content-Type: application/json" -X POST  http://localhost:7080/user/v1/
````

- User GET test
````
curl -w "\n" -H "Content-Type: application/json" -X GET  http://localhost:7080/user/v1/
````

# More information 
* [http://wiremock.org/docs/request-matching/]
* [http://wiremock.org/docs/stubbing/]