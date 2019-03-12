# Editors information

To create a base release, enter this directory
- `cd CLO/src/ontology`
- and run the make command: `make release`

Robot must be installed.

If you have docker installed, run
- `docker pull obolibrary/odkfull` (to get the latest version of the odk release system)
- add the CLO repo as a whole as a shared folder (docker->preferences->File sharing: + add path to repo, apply and restart)
- `cd CLO/src/ontology`
- and run the command: `sh run.sh make release`

This way you always get the most up to date tools for ontology release like ROBOT and others, and you dont need to install robot locally.
