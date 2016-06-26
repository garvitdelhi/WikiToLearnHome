Setup local WikiToLearn instance with WikiToLearnHome
======================================================

Introduction
------------

This file descrbes how to setup a non-production basic local WTL
environment, and is used to generate the [documentation page on meta][meta-guide].

If you are reading this online, be aware that
this page is imported from [WTLH github repo][WTLH-repo] repo, thus if
you are willing to improve this page you are free to edit its mediawiki
code, we promise to read the history and to merge the diff with our
markdown code before importing it!

**!!DISCLAIMER!! WikiToLearn does not accept any responsbility or liability if your computer is damaged in any way.**

Requirements
------------

-   64-Bit Computer (docker need a 64 bit system)
-   GNU/Linux with docker or Windows/OSX with virtualization compatability and
    enabled
-   Stable internet connection (download size can be up to 10 GB)

This procedure may fail if you have no Internet access or if the connection is filtered by firewall – this could happen in public places such as universities, libraries, airports, etc.

GNU/Linux installation
------------------

### Prerequisites

WTL and WTLH have some dependecies:

* any version
    - curl
    - rsync
    - dirname
    - realpath
    - git
    - pandoc

* specific version required
    - docker ( >= 1.10.3)
    - python3

#### Ubutnu/Debian prerequisites install

``` {.bash}
sudo apt-get install curl rsync coreutils realpath git python3 pandoc
```

#### Arch prerequisites install

``` {.bash}
sudo pacman -Sy curl rsync coreutils git python3 pandoc
```

`realpath` is in `AUR`


#### Docker installation

Docker is a quickly evolving technology, and it may be possible that the
your distro official repository do not have yet the docker version
requierd to run WTL. We thus recommend to install docker following the
[official guide][docker-install]

#### Pandoc

Pandoc is used to convert markdown documentation into mediawiki, that can be
imported to [meta][meta], thus this is not a real prerequisite, it is only
needed if you are willing to help us keeping our online documentation
up to date!

### Download this repo

The entire code is available on [GitHub][GitHub]. If you plan to modify
the online version of the code, you will need to register on GitHub, since
this repo is hosted there.

For more information and
tutorials on 'Git' check these out:

-   [git official documentation][git-official-documentation]
-   [git official book][git-official-book]
-   [atlassian git tutorials][<https://www.atlassian.com/git/tutorials/>]
-   [think-like-a-git][<http://think-like-a-git.net/>]

Before anything else, navigate to the directory in which you want to
clone the repository – the home directory is a reasonable choice.

``` {.bash}
cd ~
```

Then you can proceed to the actual download with the following command
line:

``` {.bash}
git clone --recursive https://github.com/WikiToLearn/WikiToLearnHome.git
```

This creates a folder called WikiToLearnHome (inside your home
directory) which contains all the necessary files.

This folder contains all script used to manage the WikiToLearn instance.

Before the download of all the code you have to generate a
[GitHub token][GitHub-token] (leave all the *scopes* unchecked) (used for
composer).

``` {.bash}
cd WikiToLearnHome
./create-config.sh -t <github token>
```

We recommend using SSH to communicate with github
([guide on ssh key generation here][help]).

After this setup you can download the WikiToLearn repository using this
script

``` {.bash}
./instance.sh download
```

### Start and stop the server

To start the local server the command is

``` {.bash}
./instance.sh first-run
```

Now you can work on your local instance of WikiToLearn and see your work
on [www.tuttorotto.biz][www.tuttorotto.biz]

You can shutdown the server with

``` {.bash}
./instance.sh stop
```

And start again with

``` {.bash}
./instance.sh start
```

Sometimes you might want to wipe out the server and for this you can use

``` {.bash}
./instance.sh delete
```

### Update WikiToLearnHome

In order to keep WikiToLearnHome updated you have to run

``` {.bash}
./instance.sh update-home
```

Vagrant Installation for Windows/OSX
-------------------------------------

WTL is build to work on GNU/Linux. It uses GNU/Linux software, enclosed
inside docker containers, that require the GNU/Linux kernel.
Hence, if you want to develop WTL from a Windows/OSX environment you need to
install a virtual linux system.
We remind yout in order do use a virtualization software, you have to enable virtalization in your BIOS, as explained in [this page](/How_To_Enable_Virtualization_On_Your_PC).

### Vagrant Installation

Using Vagrant is a quite simple way of using a virtual linux system for
development purposes.

This procedure requires using port 8080 tcp, 3128 tcp, 2121 to 2221 tcp
on your host, this shouldn't be a problem unless you are running a
network server (apache2, remote web control, ecc.).

If you have a **Windows/OSX** operating system, then you need to run a
WikiToLearn instance using Vagrant. You can also install Vagrant if you
have a Linux o.s. However, it is not required to get a fully working
installation. You can just skip to the next step.

First, you need to install:

-   [VirtualBox] as engine for vagrant
-   [Vagrant] for Windows/OS X users, for Linux it's optional. On
    Windows require restart.

Now you have to download the last [devvagrant]. You can download a
snapshot as zip and then unzip it in your directory or use “git clone”
to clone the repo.

Now you have to

``` {.bash}
cd devvagrant # Where there is the Vagrantfile
vagrant up
```

This can take a while because it will download the VM.

And then log in to the shell with vagrant command

``` {.bash}
vagrant ssh
```

The machine has a FTP server to simplify file transfer, the server is
anonymous and is reachable with 127.0.0.1 address at 2121 port.You have
to configure your browser to get proxy configuration file from
<http://127.0.0.1:8080>. To configure it on Mac OS X, go to System
Preferences -&gt; Network -&gt; Advanced -&gt; Proxy -&gt; Automatic
Proxy Configuration and write <http://127.0.0.1:8080> as URL.

Once you set up everything, you can proceed following the Linux Installation
Guide, starting from [cloning the git repo][cloning-repo-section].


[WTLH-repo]: https://github.com/WikiToLearn/WikiToLearnHome "WTLH repo"

[GitHub]: https://github.com/WikiToLearn

[<https://www.atlassian.com/git/tutorials/>]: https://www.atlassian.com/git/tutorials/
[<http://think-like-a-git.net/>]: http://think-like-a-git.net/
[git-official-documentation]: https://git-scm.com/doc
[git-official-book]: https://git-scm.com/book/en/v2

[docker-install]: https://docs.docker.com/engine/installation/GNU/Linux/

[GitHub-token]: https://github.com/settings/tokens
[help]: https://help.github.com/articles/generating-an-ssh-key/
[www.tuttorotto.biz]: http://www.tuttorotto.biz
[meta]: https://meta.wikitolearn.org
[meta-guide]: http://meta.wikitolearn.org/WikiToLearn_Home/WikitoLearn_Home_Documentation/Local_WikiToLearn_Instance "WTLH - meta.wikitolearn.org"

[VirtualBox]: https://www.virtualbox.org/wiki/Downloads/
[Vagrant]: https://docs.vagrantup.com/v2/installation/
[devvagrant]: https://github.com/WikiToLearn/devvagrant

[cloning-repo-section]: http://meta.wikitolearn.org/WikiToLearn_Home/WikitoLearn_Home_Documentation/Local_WikiToLearn_Instance#Download_this_repo
