# Spring PetClinic Sample Application using JFrog CLI

## Prerequisites
- Read and understand the PetClinic application original documentation: [ReadME.MD](readme-original.md)
- Read and understand the PetClinic application jenkins pipeline documentation: [ReadME.MD](readme.md)

## Objective
Develop a DevOps pipeline to automate tasks such as code compile, unit testing, creation of container, and upload of artifacts to a repository. This will streamline the software development process using JFrog CLI.


Note: This process with not deploy to the envionrmnet platform. 

:lady_beetle: Vulnerability report at [https://krishnamanchikalapudi.github.io/spring-petclinic/](https://krishnamanchikalapudi.github.io/spring-petclinic/) :lady_beetle:

[Spring-Petclinic](https://github.com/krishnamanchikalapudi/spring-petclinic) using JF-CLI to Package, BuildInfo, & RBv2: [![JF-CLI: MVN & Gradle](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-java.yml/badge.svg)](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-java.yml)

## Pipeline samples
| CI/CD | Description | Code | [youtube.com/@DayOneDev](https://youtube.com/@DayOneDev) |
| ------------- |:-------------:| -------------:| -------------:|
| [GitHub Actions](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-mvn.yml) | [JF-CLI](https://jfrog.com/getcli/) build with MVN | [![JF-CLI with MVN](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-mvn.yml/badge.svg)](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-mvn.yml) | [![Walk through demo](https://img.youtube.com/vi/xce4lr8C_Hw/0.jpg)](https://www.youtube.com/watch?v=xce4lr8C_Hw) | 
| [GitHub Actions](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-mvn-xray.yml) | [JF-CLI](https://jfrog.com/getcli/) build with MVN + Xray | [![JF-CLI with MVN + Xray](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-mvn-xray.yml/badge.svg)](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-mvn-xray.yml) | [![Walk through demo](https://img.youtube.com/vi/K80gFYAlgAY/0.jpg)](https://www.youtube.com/watch?v=K80gFYAlgAY) | 
| [GitHub Actions](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-mvn-docker.yml) | [JF-CLI](https://jfrog.com/getcli/) build with MVN + Docker | [![JF-CLI with MVN + Docker](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-mvn-docker.yml/badge.svg)](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-mvn-docker.yml) | [![Walk through demo](https://img.youtube.com/vi/K607IBugGc4/0.jpg)](https://www.youtube.com/watch?v=K607IBugGc4) | 
| [GitHub Actions](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-mvn-docker-xray.yml) | [JF-CLI](https://jfrog.com/getcli/) build with MVN + Docker + Xray | [![JF-CLI with MVN + Docker + Xray](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-mvn-docker-xray.yml/badge.svg)](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-mvn-docker-xray.yml) | [![Walk through demo](https://img.youtube.com/vi/7Pw4uMbjCMo/0.jpg)](https://www.youtube.com/watch?v=7Pw4uMbjCMo) | 
| [GitHub Actions](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-mvn-rbv2.yml) | [JF-CLI](https://jfrog.com/getcli/) build with MVN + RBv2 | [![JF-CLI with MVN + Docker + Xray](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-mvn-rbv2.yml/badge.svg)](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-mvn-rbv2.yml) | Not Yet | 
| [GitHub Actions](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-gradle.yml) | [JF-CLI](https://jfrog.com/getcli/) build with Gradle | [![JF-CLI with Gradle](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-gradle.yml/badge.svg)](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-gradle.yml) | [![Walk through demo](https://img.youtube.com/vi/qcz-pw4PE-o/0.jpg)](https://www.youtube.com/watch?v=qcz-pw4PE-o) | 
| [GitHub Actions](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-gradle-xray.yml) | [JF-CLI](https://jfrog.com/getcli/) build with Gradle + Xray | [![JF-CLI with Gradle + Xray](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-gradle-xray.yml/badge.svg)](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-gradle-xray.yml) | [![Walk through demo](https://img.youtube.com/vi/pgMnLHk-DB4/0.jpg)](https://www.youtube.com/watch?v=pgMnLHk-DB4) | 
| [GitHub Actions](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-gradle-bpr.yml) | [JF-CLI](https://jfrog.com/getcli/) build with Gradle + Build Promote | [![JF-CLI with Gradle + Build Promote](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-gradle-bpr.yml/badge.svg)](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-gradle-bpr.yml) | Not Yet | 
| [GitHub Actions](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-query-artifacts.yml) | [JF-CLI](https://jfrog.com/getcli/)to Query Artifact properties | [![JF-CLI to Query Artifact properties](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-query-artifacts.yml/badge.svg)](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-query-artifacts.yml) |  | 
| Jenkins | Build with MVN | [Jenkinsfile](./scripts-jenkins/Jenkinsfile) | [![Walk through demo](https://img.youtube.com/vi/zgiaPIp-ZZA/0.jpg)](https://www.youtube.com/watch?v=zgiaPIp-ZZA) | 
| Jenkins | [JF-CLI](https://jfrog.com/getcli/) build with MVN | [Jenkinsfile.jfcli.mvn](./scripts-jenkins/Jenkinsfile.jfcli.mvn) | [![Walk through demo](https://img.youtube.com/vi/F-6B7mgIqqI/0.jpg)](https://www.youtube.com/watch?v=F-6B7mgIqqI) | 
| Jenkins | [JF-CLI](https://jfrog.com/getcli/) build with MVN + Xray | [Jenkinsfile.jfcli.mvn-xray](./scripts-jenkins/Jenkinsfile.jfcli.mvn-xray) | [![Walk through demo](https://img.youtube.com/vi/76E1jQQOxIg/0.jpg)](https://www.youtube.com/watch?v=76E1jQQOxIg) |
| Jenkins | [JF-CLI](https://jfrog.com/getcli/) build with MVN + Docker | [Jenkinsfile.jfcli.mvn-docker](./scripts-jenkins/Jenkinsfile.jfcli.mvn-docker) | Not Yet | 
| Jenkins | [JF-CLI](https://jfrog.com/getcli/) build with MVN + Docker + Xray | [Jenkinsfile.jfcli.mvn-docker-xray](./scripts-jenkins/Jenkinsfile.jfcli.mvn-docker-xray) | Not Yet | 
| Jenkins | [JF-CLI](https://jfrog.com/getcli/) build with MVN + RBv2 | [Jenkinsfile.jfcli.mvn-rbv2](./scripts-jenkins/Jenkinsfile.jfcli.mvn-rbv2) | Not Yet | 
| [GitLab Pipelines](https://gitlab.com/krishnamanchikalapudi/spring-petclinic/-/pipelines) | [JF-CLI](https://jfrog.com/getcli/) build with MVN | [![JF-CLI with MVN and Xray](https://gitlab.com/krishnamanchikalapudi/spring-petclinic/badges/main/pipeline.svg)](https://gitlab.com/krishnamanchikalapudi/spring-petclinic/-/blob/main/.gitlab-ci.yml) | [![Walk through demo](https://img.youtube.com/vi/pDIW8rHZGEA/0.jpg)](https://www.youtube.com/watch?v=pDIW8rHZGEA) | 
| Shell Script | [JF-CLI](https://jfrog.com/getcli/) build with MVN | [jf-cli-mvn.sh](./scripts-sh/jf-cli-mvn.sh) | [![Walk through demo](https://img.youtube.com/vi/NhOPPVn3b6M/0.jpg)](https://www.youtube.com/watch?v=NhOPPVn3b6M) | 
| Shell Script | [JF-CLI](https://jfrog.com/getcli/) build with MVN + Xray | [jf-cli-mvn-xray.sh](./scripts-sh/jf-cli-mvn-xray.sh) | Not Yet | 
| Shell Script | [JF-CLI](https://jfrog.com/getcli/) build with MVN + Docker| [jf-cli-mvn-docker.sh](./scripts-sh/jf-cli-mvn-docker.sh) | Not Yet |
| Shell Script | [JF-CLI](https://jfrog.com/getcli/) build with MVN + Docker + Xray| [jf-cli-mvn-docker-xray.sh](./scripts-sh/jf-cli-mvn-docker-xray.sh) | Not Yet | 
| Shell Script | [JF-CLI](https://jfrog.com/getcli/) build with MVN + RBv2| [jf-cli-mvn-rbv2.sh](./scripts-sh/jf-cli-mvn-rbv2.sh) | Not Yet | 
| Shell Script | [JF-CLI](https://jfrog.com/getcli/) build with Gradle | [jf-cli-gradle.sh](./scripts-sh/jf-cli-gradle.sh) | [![Walk through demo](https://img.youtube.com/vi/ATeok1eqM0o/0.jpg)](https://www.youtube.com/watch?v=ATeok1eqM0o) | 
| Shell Script | [JF-CLI](https://jfrog.com/getcli/) build with Gradle + Xray | [jf-cli-gradle-xray.sh](./scripts-sh/jf-cli-gradle-xray.sh) | [![Walk through demo](https://img.youtube.com/vi/BNC-5JWP4dI/0.jpg)](https://www.youtube.com/watch?v=BNC-5JWP4dI) | 
| Shell Script | [JF-CLI](https://jfrog.com/getcli/) build with Gradle + Build-Promote | [jf-cli-gradle-bpr.sh](./scripts-sh/jf-cli-gradle-bpr.sh) | Not Yet | 
| [GitHub Actions](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/frogbot-scan-repository.yml) | [FrogBot](https://docs.jfrog-applications.jfrog.io/jfrog-applications/frogbot) for Security | [![Frogbot Scan and Fix](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/frogbot-scan-repository.yml/badge.svg)](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/frogbot-scan-repository.yml) |  | 
| [GitHub Actions](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-security.yml) | [JF-CLI](https://jfrog.com/getcli/) for Security | [![JFrog Security using JF-CLI](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-security.yml/badge.svg)](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/workflows/jfcli-security.yml) |  | 
| Shell Script | [JF-CLI](https://jfrog.com/getcli/) Security using Curation, Xray, and JAS | [jf-cli-security.sh](./scripts-sh/jf-cli-security.sh) | Not Yet | 
| Coverity Scan | [Coverity Scan: spring-petclinic](https://scan.coverity.com/projects/spring-petclinic) | [![Coverity Scan: spring-petclinic](https://scan.coverity.com/projects/30985/badge.svg)](https://scan.coverity.com/projects/spring-petclinic) |  | 

<!-- 
| CI/CD | Description | Code | [youtube.com/@DayOneDev](https://youtube.com/@DayOneDev) |
|    |    |    |    | 
|    |    |    |    | 
|    |    |    |    | 
-->

## Pipeline: Flow Diagrams
### DevOps pipeline using JFrog Products
<img src="./images/pipeline.svg">

### JF-CLI Docker pipeline
<img src="./images/DevSecOps-Docker.svg">

### JF-CLI Maven pipeline
<img src="./images/DevSecOps-mvn.svg">

### Maven pipeline
<img src="./images/mvnpipeline.svg">

#### Error solutions
- <details><summary>Error: Exchanging JSON web token with an access token failed: getaddrinfo EAI_AGAIN access</summary>
    It is possbile that JF_RT_URL might be a NULL value. Ref [https://github.com/krishnamanchikalapudi/spring-petclinic/actions/runs/10892482444](https://github.com/krishnamanchikalapudi/spring-petclinic/actions/runs/10892482444)
</details>
- <details><summary>Error: Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?</summary>
Rancher desktop 
``````
limactl start default
``````
or
``````
    docker context ls
    docker context inspect --format '{{ .Endpoints.docker.Host }}
    DOCKER_HOST=unix:///Users/krishnam/.rd/docker.sock docker ps
``````
</details>
- <details><summary>Error: ould not transfer artifact org.apache.maven.plugins:maven-enforcer-plugin:jar:3.5.0 from/to artifactory-release: status code: 403, reason phrase:  (403)</summary>
Update repo 
</details>


## Validate Github Actions workflow locally
- Pre install: [https://github.com/nektos/act](https://github.com/nektos/act)
<img src="https://raw.githubusercontent.com/wiki/nektos/act/quickstart/act-quickstart-2.gif">
- Start image=psazuse.jfrog.io/krishnam-docker-remote/ubuntu:latest -s mysecret=foo
- 
- 


### Errors

- <details><summary>Error: Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?</summary>
    brew install --cask docker 
    docker context ls
    docker context inspect --format '{{ .Endpoints.docker.Host }}
    DOCKER_HOST=unix:///Users/krishnam/.rd/docker.sock docker ps # test that it works using linked socket file    
</details>







## LAST UMCOMMIT
`````
git reset --hard HEAD~1
git push origin -f
`````

## License
The Spring PetClinic sample application is released under version 2.0 of the [Apache License](https://www.apache.org/licenses/LICENSE-2.0).

<img src="./images/DayOne.png">

