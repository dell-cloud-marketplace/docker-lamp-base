# docker-lamp-base
A basic LAMP image for dependant images such as [dell/wordpress](https://github.com/dell-cloud-marketplace/docker-wordpress).

This blueprint installs a basic [LAMP](http://en.wikipedia.org/wiki/LAMP_\(software_bundle\))
 stack - a popular combination of open source software components, used to build dynamic web sites.

## Components
The stack comprises the following components:

Name       | Version    | Description
-----------|------------|------------------------------
Ubuntu     | Trusty     | Operating system
MySQL      | 5.5        | Database
Apache     | 2.4.7      | Web server
PHP        | 5.5.9     | Scripting language

## Usage

### Basic Example
Start your image binding host port 8080 to port 80 (Apache Web Server/HTTP), 443 to 443 (Apache Web Server/HTTPS) and 3306 to 3306 (MYSQL) in your container:

    sudo docker run -d -p 8080:80 -p 3306:3306 -p 443:443 dell/lamp-base

Test your deployment:

    curl http://localhost:8080/

## Administration

### Connecting to MySQL
The first time that you run your container, a new user admin with all privileges will be created in MySQL with a random password. To get the password, check the logs of the container. 

    sudo docker logs <container_id>
    
You will see some output like the following:

    ===================================================================
    You can now connect to this MySQL Server using:

        mysql -u admin -p47nnf4FweaKu -h<host> -P<port>

    Please remember to change the above password as soon as possible!
    MySQL user 'root' has no password but only allows local connections
    ===================================================================


In this case, `47nnf4FweaKu` is the password allocated to the `admin` user.

Remember that the `root` user has no password but it's only accessible from within the container.

You can now test your deployment:

     mysql -u admin -p47nnf4FweaKu -h127.0.0.1 -P3306


### Connecting to MySQL from the Application
The bundled MySQL server has a `root` user with no password for local connections. Simply connect from your
PHP code with this user:


    <?php
    $mysql = new mysqli("localhost", "root");
    echo "MySQL Server info: ".$mysql->host_info;
    ?>


## Reference

### Image Details

Based on  [tutum/lamp](https://github.com/tutumcloud/tutum-docker-lamp)

Pre-built Image   | [https://registry.hub.docker.com/u/dell/lamp-base](https://registry.hub.docker.com/u/dell/lamp-base) 
