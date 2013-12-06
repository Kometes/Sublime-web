# Sublime-web v0.1
Remote web build and publishing system for Sublime.
Allows multiple users to collaborate remotely on a central server with web frameworks such as CppCMS (C++) and Django (Python).  Users can develop a web app in Sublime and view their changes from their own private subdomain on your web server.



# Usage

## Build targets
To see all build targets with their keyboard shortcuts, open `Tools -> Command Palette`
- *Build*: push changes to your dev site using git, build your web app remotely, then reload the web service
- *Run*: build then bring your browser into view and refresh the current page
- *Clean*: remove any intermediate build files on your dev site
- *Publish*: push changes to the project root repo, build a release version of your web app from your dev site, then update a distribution branch and push it to the public site
- *Web Down*: take down the public site and show a "down for maintenance" page to visitors. The public site is made available for private development at the address `dev.<domain>`.
- *Web Up*: bring up the public site


## Remote commands
- a shortcut to SSH into your project's server:

    ```
    cd <project>
    ../Sublime-web/dev/connect.sh
    ```



# Setup

## Dependency setup

### Server dependencies
- Install SSH `sudo apt-get install openssh-server`. Add each user's public key to their authorized keys, so they can log in without a password prompt:
    ```
    su <user>
    cd
    mkdir .ssh
    cat /tmp/id_rsa.<user>.pub >> .ssh/authorized_keys
    ```

- Install Git `sudo apt-get install git-core`. Set up the git user and add each user's public key to git's authorized keys:
    ```
    sudo adduser git
    su git
    cd
    mkdir .ssh
    cat /tmp/id_rsa.<user>.pub >> .ssh/authorized_keys
    ```

- install Apache with modules
    ```
    sudo apt-get install apache2 libapache2-mod-macro
    sudo a2enmod macro
    
    #set up SSL, create a self-signed certificate
    sudo a2enmod ssl
    sudo mkdir /etc/apache2/ssl
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt

    sudo service apache2 restart
    ```

- add git and all users to a dev group:

        sudo groupadd dev
        sudo usermod -aG dev git
        sudo usermod -aG dev <user>

- allow the dev group to restart the apache web service:

        sudo sh -c "echo '%dev ALL=NOPASSWD: /usr/bin/service apache2 *' >> /etc/sudoers"

- allow the dev group to change apache sites:

        sudo chown -R root.dev /etc/apache2/sites-* /var/lib/apache2
        sudo chmod -R g+ws /etc/apache2/sites-* /var/lib/apache2

- install a web framework (ex. [CppCMS](http://cppcms.com), [Django](http://www.djangoproject.com))

### Mac OS X client dependencies
- install [Git](http://git-scm.com)
- upgrade Bash to v4.2:

        brew install bash
        sudo cp /bin/bash /bin/bash-3.2
        sudo ln -sf /usr/local/bin/bash /bin/bash

- set up [subl](https://www.sublimetext.com/docs/2/osx_command_line.html)

## Sublime-web project setup

### Server project setup
- download Sublime-web:
    ```
    cd <serverRoot>     #ex. /mnt/foo
    sudo git clone git@github.com:Qarterd/Sublime-web.git
    ```

- install the Sublime-web apache config:
    ```
    sudo cp -r Sublime-web/setup/apache/* /etc/apache2
    sudo a2enconf app
    ```

- create a project from the template project for your framework:
    ```
    sudo mkdir <project>-dev-<user>  #user is your SSH login name
    cd <project>-dev-<user>
    cp -r ../Sublime-web/setup/project/common/* .
    cp -r ../Sublime-web/setup/project/<framework>/* .
    mv foo.sublime-project <project>.sublime-project
    mv gitignore .gitignore
    mv gitignore.dist .gitignore.dist
    ```

    #### CppCMS project setup
    - coming soon

    #### Django project setup
    - hack the apache process name so it's large enough to contain some virtualhost wsgi instance info
        ```
        sudo service apache2 stop
        sudo ln -s /usr/sbin/apache2 /usr/sbin/apache2------------------------------
        echo "export APACHE_HTTPD=/usr/sbin/apache2------------------------------" | sudo tee -a /etc/apache2/envvars
        sudo service apache2 start
        ```

    - create your django project `django-admin.py startproject <project> web`
    - follow the instructions in `web/wsgi-shared.py` and `web/settings-shared.py`

- in your project config set *serverRoot* to the parent directory:
    ```
    sed -i "s;\(serverRoot=\).*;\1$(cd .. && pwd);" Sublime-web/project-config.sh
    ```

- init repos for the root origin, private user dev sites, and the public site:
    ```
    sudo ../Sublime-web/admin/repo-init.sh <project> <user>
    sudo ../Sublime-web/admin/repo-init.sh <project> <other_user>
    sudo ../Sublime-web/admin/repo-init.sh <project> public
    ```

- init apache private user dev sites, and the public site:
    ```
    ../Sublime-web/admin/web-init.sh <project> <domain> <user> <framework>
    ../Sublime-web/admin/web-init.sh <project> <domain> <other_user> <framework>
    #ex. web-init.sh foo foo.com bob cppcms
    ```

- protect the private user dev sites by adding a password for each user `htpasswd web/.htpasswd <user>`

### Mac OS X client project setup
- download Sublime-web:
    ```
    cd <clientRoot>     #ex. ~/work
    git clone git@github.com:Qarterd/Sublime-web.git
    ```

- clone your project, add the user dev repo, and copy user settings:
    ```
    git clone git@<server>:/repo/<project>.git
    cd <project>
    git remote add dev git@<server>:/repo/<project>-dev-<user>
    cp ../Sublime-web/setup/project/common/Sublime-web/user-config.sh Sublime-web
    ```

- open your project in sublime `<project>.sublime-project`
- select the build system `Tools -> Build System -> web debug`
- copy the key bindings in `../Sublime-web/setup/user.sublime-keymap` to `Sublime Text -> Preferences -> Key Bindings - User`
- edit and configure `Sublime-web/project-config.sh` and `Sublime-web/user-config.sh`
- open a browser to your private dev site `http://<user>.dev.foo.com`
- try to compile and run with *command+shift+x*


## Optional setup

### Push Sublime-web itself to your server on build
- on the server prepare Sublime-web for remote development, init the root and user repos:
    ```
    cd <serverRoot>
    rm -rf Sublime-web/.git
    mv Sublime-web Sublime-web-dev-<user>
    cd <project>
    sudo ../Sublime-web-dev-<user>/admin/repo-init.sh Sublime-web <user>
    sudo ../Sublime-web-dev-<user>/admin/repo-init.sh Sublime-web <other_user>
    ```

- on each user client set up the remote repos and sync:
    ```
    cd Sublime-web
    git remote rename origin github
    git remote add origin git@<server>:/repo/Sublime-web.git
    git remote add dev git@<server>:/repo/Sublime-web-dev-<user>
    git fetch origin
    git reset --hard origin/master
    ```

- add Sublime-web as an external project:
    ```
    sed -i "s/\(extProjects=\).*/\1Sublime-web/" Sublime-web/project-config.sh
    ```

### Remove a project

- remove the repos:
    ```
    sudo rm -rf <serverRoot>/<project>*
    sudo rm -f /repo/<project>*
    ```

- remove the apache sites `rm -f /etc/apache2/sites-*/*<project>*`


