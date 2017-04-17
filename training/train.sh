#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=gpu_short
#SBATCH --time=01:00:00
#SBATCH --job-name=pogosov
module load cuda/8.0.44
module load cudnn/8.0-v5.1
srun ./darknet detector train data/KFM.data yolo-KFM.cfg ./darknet19_448.conv.23 -gpus 0,1
