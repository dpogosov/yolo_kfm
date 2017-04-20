# yolo_kfm
The Nature Conservancy Fisheries Monitoring

Team: Classifying Nemo

## Solution
1. Network: trained [YOLO v2](https://pjreddie.com/darknet/yolo/) (you only look once) convolutional network 
2. Basic weights: were downloaded from http://pjreddie.com/media/files/darknet19_448.conv.23
3. Dataset: the given training set plus extra images from imagenet and internet
4. Data augmentation: almost all the images were recursive augmented by 
	- rotation,
	- crop and move,
	- adding white noise,
	- horizontal flipping,
	- scaling (incorporated in the training pipeline)

## Files description
Detector is based on the modified [Darkflow](https://github.com/thtrieu/darkflow) framework.
#### darkflow - folder with the framework (needs python, tensorflow and opencv)
- *darkflow/test* - folder for the test images (stage 1)
- *darkflow/test_stg2* - folder for the test images (stage 2)
- *darkflow/test/out/output_converter.m* - the file that converts the network output to CSV for submission and does fine tuning (needs matlab)
- *darkflow/test_stg2/out/output_converter2.m* - the file that converts the network output to CSV for submission and does fine tuning (needs matlab)
- *darkflow/test_stg2/out/output_converter_pseudo_label.m* - could be used for pesudo-labelling (needs matlab)
- *darkflow/[yolo-KFM_1.weights](https://drive.google.com/drive/folders/0BwYTO3UZXciuYWUtQ1FvUzc5MWM?usp=sharing)* - weights for the first model (only two were allowed to upload)
- *darkflow/[yolo-KFM_2.weights](https://drive.google.com/drive/folders/0BwYTO3UZXciuYWUtQ1FvUzc5MWM?usp=sharing)* - weights for the second model (only two were allowed to upload)
- *darkflow/[yolo-KFM_extra.weights](https://drive.google.com/drive/folders/0BwYTO3UZXciuYWUtQ1FvUzc5MWM?usp=sharing)* - weights were obtained with extra training (not uploaded)
#### extras - folder with some extra scripts (need matlab)
- *extras/im_test3.m* - needs for manual classifying images (shows an image and buttons to copy the image to a class folder)
- *extras/aughmenter_yolo.m* - makes augmented data from the training set (from json files)
- *extras/aughmenter_yolo1.m* - makes augmented data from the training set (from txt (label) files)
- *extras/kfm_converter_labels.m* - converts json labels to YOLO format
- *extras/euclid.py* - slightly modified [labeller](https://github.com/prabindh/euclid) (needs python)
- *extras/auyolo_test2.m* - augments test images to improve quality of predictions
- *extras/output_converter2aug.m* - the file that converts the network output (from augmented set) to CSV for submission and does fine tuning (needs matlab)
- *extras/dir.mat* - supplementary for the converter above

#### training - folder with training relevant files

#### cluster_manual.pdf - some useful guidlines for working with computing clusters SURFsara and Speedy.

## Training
### Framework
The network was trained in [Darknet](https://github.com/prabindh/darknet).
#### Compiling
You should compile the framework before usage. 
I recommend to change the hard path to cuda in Makefile to $(CUDA_HOME)
In addition add a couple of env. variables (with the correct path in your machine):

*export PATH=$PATH:/usr/local/cuda-8.0/bin*

*export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-8.0/lib64*

#### Training
You should configure Yolo. All the relevant files are in the folder _training_. Simple put them to [Darknet](https://github.com/prabindh/darknet) folder.

Example of the traning command (with pretrained [weights](http://pjreddie.com/media/files/darknet19_448.conv.23)) on the first two GPUs:

*./darknet detector train data/KFM.data yolo-KFM.cfg darknet19_448.conv.23 -gpus 0,1*

#### Guidlines
[Here](https://github.com/prabindh/darknet) and [here](https://github.com/AlexeyAB/darknet) you can find very nice guidlines about training YOLO.


### Data preparation
1) Convert [labels](https://github.com/autoliuweijie/Kaggle/tree/master/NCFM/datasets) for [the given training set](https://www.kaggle.com/c/the-nature-conservancy-fisheries-monitoring/download/train.zip) by *kfm_converter_labels.m*
2) Augment the trainng data with _aughmenter_yolo.m_
3) Add extra images and label them by _euclid.py_
4) Augment the extra data with *aughmenter_yolo2.m*

Or simple download [the whole training dataset](https://drive.google.com/drive/folders/0BwYTO3UZXciuYWUtQ1FvUzc5MWM?usp=sharing)

## How to use
0) Download this [repo](https://github.com/dpogosov/yolo_kfm.git); download [the weights](https://drive.google.com/drive/folders/0BwYTO3UZXciuYWUtQ1FvUzc5MWM?usp=sharing) and put them to the darkflow folder

### Stage 1
1) Put the [test images (stg1)](https://www.kaggle.com/c/the-nature-conservancy-fisheries-monitoring/download/test_stg1.zip) to the folder darkflow/test. 
Note that the number of the files should be exact divided by 16. Hence, for 1000 test images there are extra (fake) 8 images. Do not delete them!
2) Run *darkflow/test_s1_m#.sh* to start prediction for the model *#*
3) Run *darkflow/test/out/output_converter.m* to convert predictions from the step 2 to CSV file. **Note** likelhoods fine tuning: gain 1.2, threshold 0.1
4) Done!

### Stage 2
1) Put the [test images (stg2)](https://www.kaggle.com/c/the-nature-conservancy-fisheries-monitoring/download/test_stg2.7z) to the folder darkflow/test_stg2. 
Note that the number of the files should be exact divided by 16. Hence, for 12153 test images there are extra (fake) 7 images. Do not delete them!
2) Run *darkflow/test_s2_m#.sh* to start prediction for the model *#*
3) Run *darkflow/test_stg2/out/output_converter2.m* to convert predictions to CSV file. Note that the converter merges the previous stage *last.csv* file with the second stage predictions. You may run them sequentially, but the first stage result does not affect the second one. **Note** likelhoods fine tuning: gain 0.75, threshold 0.4
4) Done!

### Detection improvement
You may improve the quality of detection by augmenting test images.
1. Run the converter *auyolo_test2.m* in he folder with test images. Note by default it does rotation and flipping, but you can also do cropping and white noise adding.
2. Follow the pipelines above, only use *output_converter2aug.m, dir.mat* for conversion predictions to CSV file
