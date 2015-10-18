[Notes for setting up PropForth6 and tools, git and github]

[setup]
sudo apt-get install minicom
sudo apt-get install build-essential
[install go from website go1.5.linux-amd64.tar.gz]
sudo tar -C /usr/local -xzf go1.5.linux-amd64.tar.gz

[Ensure your git user.name  and git user.email are set if you wish to contribute to github]
[git user.name is the user name you use to log in to github.]
[notice that you cannot use you email to log in to github]

git config --list
git config --global user.name "prof-braino"

*** remove the invcoorrect github commands *****

(removve) git clone https://github.com/salsanci/PropForth6.git
git clone https://github.com/PropForth6/PropForth6.git
cd PropForth6/
git checkout dev
git status
git log
git fetch 

[create a new branch by 'checking out' the new branch name]
git checkout -b 20150902_Linux 

**** add the new github commands from 20151018 ****
[git commands]
[  -- clone the PF6 repository]
git clone https://github.com/PropForth6/PropForth6.git

cd to PF6

[check the current branch (should be master by default)]
git branch 
[notice there are no other branches visible yet]

[see the list of active branches]
git branch -a
[see that there are other branches, including dev, and whatever sal and the others are working on]

[retrieve the dev branch so you have the current state to work from]

[switch to dev branch (we do all development dev branched from the previous master)]
git checkout -b dev origin/dev

[at this point, you should have the dev branch, which is that most recent snapshot of the code, test by sal]
[this should be an "everything working" starting point for you further development]

========================================================

[create a new branch for me (doug) to work in for testing]
[branch naming convention YYYYMMDDusernameDevelomentObjective]
[on October 18, 2015, doug's task was to run the build test]
[NOTE branch is created when we use the CHECKOUT command]
git checkout -b  20151018dougbuildtest

===================
[task 1 add a file]
[ -- in a text editor, create any new file, save it; ]
[ -- example is dougCreated.txt in doc directory ]

[check the created file is noticed]
git status
[should report "doc/dougCreated.txt" is modified and needs to be added, in RED]

[add the file (add all the new files in the directory that need adding)]
git add . 

[check state with git sttatus]
git status

[shows the files are ready to commit, in green

[task 2 update an existing  file]
[ -- in an text editor, edit any file, and save]

[check state with git sttatus]
git status

[shows the file is mdified]

[add the changed file (to the staging area) with an explanatory message]

git commit -a -m "updated setup docs"


===================

OK-let try this edit readme, ok

now in order to push this back up,

git status

git commit -a -m "fix typo"

git push -u --all

it works! all my testing will be in this branch
continue testing here. 





*** end of new github commands *****

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



















