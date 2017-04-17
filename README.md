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

## Files description (detection)
Detrector is based on the modified [darkflow](https://github.com/thtrieu/darkflow) framework.
- darkflow - folder with the framework (needs python, tensorflow and opencv)
- darkflow/test - folder with the test images (stage 1)
- darkflow/test/out/output_converter.m - the file that converts the network output to CSV for submission and does fine tuning (needs matlab)

## How to use
### Stage 1
1) Put the test images (stg1) are in the folder darkflow/test. 
Note that the number of the files number should be exact divided by 16. Hence, for 1000 test images there are extra (fake) 8 images. Do not delete them!
2) Run darkflow/test_s1_m#.sh to start prediction for the model #
3) Run darkflow/test/out/output_converter.m to convert predictions from the step 2 to CSV file
4) Done!

### Stage 2
1) Put the test images (stg2) to the folder darkflow/test_stg2. 
Note that the number of the files number should be exact divided by 16. Hence, for 12153 test images there are extra (fake) 7 images. Do not delete them!
2) Run darkflow/test_s2_m#.sh to start prediction for the model #
3) Run darkflow/test_stg2/out/output_converter2.m to convert predictions to CSV file. Note that the converter merges the previous stage last CSV file with the second stage predictions. You may run them sequentially, but the first stage result does noo affect the second one.
4) Done!

Extras

# todo:
Scripts, 
euclid, 
link to training + CFG's;
weights, 
darkflow
