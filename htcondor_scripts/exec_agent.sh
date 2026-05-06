#!/bin/bash

# setup basic paths
export PROJECT_DIR=/nethome/mareikeh/lst_agent_example # the directory you cloned the repository with example code to
export CONDA_DIR=/scratch/hartmann/miniconda3 #location of the miniconda installation



# Rename GPUs
source $PROJECT_DIR/htcondor_scripts/rename_gpus.sh

# Activate conda environment
source $CONDA_DIR/etc/profile.d/conda.sh
conda activate mcp_agent
export PYTHONPATH=$PYTHONPATH:$PROJECT_DIR
echo "Activated conda environment: $CONDA_DEFAULT_ENV"




echo "=== CUDA Debugging Information ==="

nvidia-smi
echo "CUDA_HOME: $CUDA_HOME"
echo "CUDA_VISIBLE_DEVICES: $CUDA_VISIBLE_DEVICES"
echo "==================================="
echo "HOSTNAME: $HOSTNAME"
which python



# Variables
SERVER_PORT=$1
SERVER_HOST=$2
echo "Server_port: $SERVER_PORT"
echo "Server_host: $SERVER_HOST"

SERVER_SCRIPT=$PROJECT_DIR/htcondor_scripts/start_vllm_server.sh
MODEL_PATH="Qwen3-8B"

# Start the server
echo "Starting server..."
bash $SERVER_SCRIPT $SERVER_HOST $SERVER_PORT $MODEL_PATH &
SERVER_PID=$!
echo "Server started with PID: $SERVER_PID"

# Wait for the server to initialize
sleep 300  # 5 minutes = 300 seconds

# Wait for the server to initialize
echo "Waiting for the server to be ready..."
MAX_RETRIES=15  # Set maximum retries (adjust based on server start time)
RETRY_INTERVAL=180 # Time in seconds between checks
END_POINT="http://$SERVER_HOST:$SERVER_PORT/v1"



export SERVER_END_POINT=$END_POINT

for ((i=1; i<=MAX_RETRIES; i++)); do
    # Check if the server is responding
    if curl -s "$END_POINT" >/dev/null; then
        echo "Server is ready!"
        break
    fi

    echo "Server not ready yet... retrying ($i/$MAX_RETRIES)"
    sleep $RETRY_INTERVAL
done

# If the server didn't start, exit
if ! curl -s "$END_POINT" >/dev/null; then
    echo "Server failed to start after $((MAX_RETRIES * RETRY_INTERVAL)) seconds."
    kill $SERVER_PID
    exit 1
fi


echo "Running experiments..."
echo $ENDPOINT
python example_agent.py --base_url "http://localhost:8080/v1" --model /scratch/common_models/$MODEL_PATH


# Stop the server after experiments complete
echo "Stopping server (Server PID: $SERVER_PID)..."
kill $SERVER_PID  # Send the termination signal
sleep 300  # Give the server some time to stop


# Check if the process is still running
if ps -p $SERVER_PID > /dev/null; then
  echo "Server did not stop. Forcing termination..."
  kill -9 $SERVER_PID  # Forcefully kill the process
else
  echo "Server stopped gracefully."
fi

# Wait for the process to fully terminate
wait $SERVER_PID 2>/dev/null
echo "Server process has been terminated."

echo "Main Experiment Workflow Completed!"
