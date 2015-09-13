[Notes for setting up PropForth6 and tools, git and github]


[setup]
sudo apt-get install minicom
sudo apt-get install build-essential
[install go from website go1.5.linux-amd64.tar.gz]
sudo tar -C /usr/local -xzf go1.5.linux-amd64.tar.gz

[Ensure your git user.name  and git user.email are set if you wish to contribute to github]
git config --list

[git commands]
git clone https://github.com/salsanci/PropForth6.git
cd PropForth6/
git checkout dev
git status
git log
git fetch 

[create a new branch by 'checking out' the new branch name]
git checkout -b 20150902_Linux 

[compile the go serial at least once]
cd tools/
cd serial_proxy/
[make build.sh executable]
./build.sh
ls 
[see that serial_proxy executable was created]

[MUST run pr.sh in the terminal before the build and text script tools will work]
[pr.sh must be run again in any new windw. I.E. if something does't work, probably you didn't run the pr.sh in that terminal yet]
cd ..
cd mygo/
./pr.sh
env
[notice that a PropForth6 entry has been added the PATH environment variable]
[notice that the PropForth6 entry to the PATH environment variable is local to THIS TERMINAL WINDOW ONLY.  If you open another termainal, this will not be present until you run the ./pr.sh script]

[install the go programs at least once]
go install goterm
go install goproxyterm
[notice a bin directoy was created in mygo, containing executables for goterm and goproxyterm]
goterm
[notice the goterm help message when gotern is executed without parameters]

[Move to the Linux directory...]
cd ..
cd ..
cd Linux

[CONNECT the PROPELLER BOARD and VIRTUAL COMMPORT]
[notice if you run the buildall script without the board connected you get the goterrm help menu 17 times]

[Devices -> USB Devices -> Parallax Inc Propeller Quickstart [1000] ]   Quickstart Rev B
[Devices -> USB Devices -> FTDI FT231X USB UART [1000] ]                Quickstart Rev B
[Devices -> USB Devices -> FTDI FT232R USB UART [0600] ]  Quickstart Rev A

./build.sh

[NOTE: BUILDALL.SH is NOT the top script, if things don't work, check you ran build.sh]



















