# LST agent example
This repo contains example code for running an LLM agent on the LST cluster via HTCondor. Information on the LST cluster can be found [here](https://wiki.lst.uni-saarland.de/doku.php?id=start). In case you are already working with HTCondor and use your own submit scripts, please make sure to implement the guidelines and best practices listed in the [wiki](https://drive.google.com/drive/u/0/folders/1t3SYmS7FFZib5yxxri-SSSR9Wvf3pRqQ).

## Download miniconda
In order to install python packages on the cluster, we need to use the Miniconda package manager. Go to your scratch directory, and install Miniconda following the instructions [here](https://www.anaconda.com/docs/getting-started/miniconda/install/linux-install#curl)

## Install requirements
Now we can install requirements using miniconda. For this, we need to submit ```htcondor_scripts/run_install.sub``` to htcondor:

```> condor_submit run_install.sub```

This will execute what we specify in ```htcondor_scripts/exec_install.sh```. In the example, ```exec_install.sh``` creates and activates a new conda environment and installs the python packages specified in requirements.txt

## Run python code
Now we can execute the python code. Again, we need to submit whatever we want to run as a job to the HTCondor queue using a .sub script.

```> condor_submit run_agent.sub```

This will send the contents of ```htcondor_scripts/exec_agent.sh``` to execution.

This is what happens in ```exec_agent.sh```:

