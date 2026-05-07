# LST agent example
This repo contains example code for running an LLM agent on the LST cluster via HTCondor. Information on the LST cluster can be found [here](https://wiki.lst.uni-saarland.de/doku.php?id=start). In case you are already working with HTCondor and use your own submit scripts, please make sure to implement the guidelines and best practices listed in the [wiki](https://drive.google.com/drive/u/0/folders/1t3SYmS7FFZib5yxxri-SSSR9Wvf3pRqQ).

In all scripts in ```/htcondor_scripts```
1. replace my username ```mareikeh``` with yours and
2. point to the location of your miniconda installation ```export CONDA_DIR=...```

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

These are the major things happening in ```exec_agent.sh```:

### 1. Start the vLLM server in the background.            
[vLLM](https://vllm.ai/) is a high-performance inference engine for large language models. The vllm serve command loads a model from disk into GPU memory and starts an HTTP server that exposes an OpenAI-compatible API — meaning the server speaks the same request/response format as api.openai.com. So instead of calling OpenAI's hosted models over the public internet, ```example_agent.py``` calls a model running locally on the cluster's GPU. There are other ways and libraries for running local models, but this is the only way I could figure out to make the combination of free LLM + langchain + langchain_mcpàdapters work. If you find a different solution, please let me know.

The script launches ```start_vllm_server.sh``` as a background process. The script then waits for the server to come up: it sleeps for an initial 5 minutes (vLLM needs time to load the model weights into GPU memory), then polls the /v1 endpoint with curl every 3 minutes, up to 15 times. As soon as the endpoint responds, the loop breaks.                                                                                                                                  
                                                            
 ### 2. Run the agent.
  Once the server is reachable, the script runs ```python example_agent.py``` with ```--base_url``` pointing at the local vLLM endpoint and ```--model``` pointing at the model path. The agent talks to vLLM over HTTP using the OpenAI-compatible API that vLLM exposes.      

Note that the cluster maintains a shared directory at ```/scratch/common_models/``` where many popular LLMs are already downloaded. Before downloading any model yourself (which wastes disk quota and time), check there first to see if the model you need is already available. ```exce?agent.sh``` is already pointing at the common directory.
  
 ### 3. Shut the vLLM server down.
 After the agent finishes, the script sends SIGTERM to kill vLLM and all its workers. This keeps the GPU reservation from being held by an unused server after the job is logically done.


