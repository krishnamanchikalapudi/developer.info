export NODE_HOME=/usr/local/bin/node
export NPM_HOME=/usr/local/bin/npm

export PYTHON_HOME=/Library/Python/2.7/site-packages
export AWS_CLI_HOME=~/.local/lib/aws/bin
export S2I_HOME=~/TOOLS/source-to-image
export GRADLE_HOME=~/TOOLS/gradle-5.0
export M2_HOME=~/TOOLS/maven-3.x
export JAVA_HOME=/Library/Java/JavaVirtualMachines/amazon-corretto-8.jdk/Contents/Home
export CATALINA_HOME=~/TOOLS/tomcat-9.x/

export PATH=$NODE_HOME:$NPM_HOME:$PYTHON_HOME:$AWS_CLI_HOME:$S2I_HOME:$GRADLE_HOME/bin:$M2_HOME/bin:$JAVA_HOME:$CATALINA_HOME:$PATH:

complete -C ~/TOOLS/vault/vault vault