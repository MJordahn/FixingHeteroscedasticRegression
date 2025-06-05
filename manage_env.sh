#!/usr/bin/bash

ENV_NAME="het-regression"

# This script should be sourced not executed
if [ "${BASH_SOURCE[0]}" -ef "$0" ]
then
    echo "This script should be sourced, not executed."
    exit 1
fi

# Set path of project directory as environment variable
PROJECT_DIR=$(dirname `realpath "$1"`)
export PROJECT_DIR=${PROJECT_DIR}
echo "PROJECT_DIR: ${PROJECT_DIR}"


# Setup conda environment
if [[ $1 = "init" ]]
then
    echo $"Initializing conda environment"
    # Initialize conda
    /opt/miniconda3/bin/conda init
    source ~/.bashrc
    source /opt/miniconda3/etc/profile.d/conda.sh

    # Deactivate all conda environments
    for i in $(seq ${CONDA_SHLVL}); do
        conda deactivate
    done

    # Create new conda environment
    conda create -n ${ENV_NAME} python=3.11.11
    conda activate ${ENV_NAME}

    # Install requirements
    cd ${PROJECT_DIR}
    pip install -r requirements.txt
    pip install -e ${PROJECT_DIR}


# Setup environment
elif [[ $1 = "setup" ]]
then
    source /opt/miniconda3/etc/profile.d/conda.sh

    # Deactivate all conda environments
    for i in $(seq ${CONDA_SHLVL}); do
        conda deactivate
    done
    
    # Activate environment
    conda activate ${ENV_NAME}
    cd ${PROJECT_DIR}
    pip install -r requirements.txt


# Update requirements.txt
elif [[ $1 = "update" ]]
then
    pip freeze > ${PROJECT_DIR}/requirements.txt
    # Replace git reference with pointer to the current dir
    sed -i '/^-e git/d' ${PROJECT_DIR}/requirements.txt
    sed -i 's/@[a-f0-9]*$//' ${PROJECT_DIR}/requirements.txt
    #echo "-e ." >> ${PROJECT_DIR}/requirements.txt


# Deactivate environment
elif [[ $1 = "deactivate" ]]
then
    conda deactivate


# Delete environment
elif [[ $1 = "delete" ]]
then
    # Deactivate all conda environments
    for i in $(seq ${CONDA_SHLVL}); do
        conda deactivate
    done
    conda remove -n ${ENV_NAME} --all


else
    echo "Please use a valid option, i.e., run: "source manage_env.sh {init, setup, update, deactivate, delete}
fi