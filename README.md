# movenet_demo

Movenet demo

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


A frame of video or an image, represented as an int32 tensor of dynamic shape: 1xHxWx3, where H and 
W need to be a multiple of 32 and the larger dimension is recommended to be 256. To prepare the 
input image tensor, one should resize (and pad if needed) the image such that the above conditions 
are hold. Please see the Usage section for more detailed explanation. Note that the size of the 
input image controls the tradeoff between speed vs. accuracy so choose the value that best suits 
your application. The channel order is RGB with values in [0, 255].

Movenet ouputs a float tensor of shape [1, 6, 56].
● The first dimension is the batch dimension, which is always equal to 1.
● The second dimension corresponds to the maximum number of instance detections. The
model can detect up to 6 people in the image frame simultaneously.
● The third dimension represents the predicted bounding box/keypoint locations and
scores. The first 17 * 3 elements are the keypoint locations and scores in the format:
[y_0, x_0, s_0, y_1, x_1, s_1, …, y_16, x_16, s_16], where y_i, x_i, s_i are the
yx-coordinates (normalized to image frame, e.g. range in [0.0, 1.0]) and confidence
scores of the i-th joint correspondingly. The order of the 17 keypoint joints is: [nose, left
eye, right eye, left ear, right ear, left shoulder, right shoulder, left elbow, right elbow, left
wrist, right wrist, left hip, right hip, left knee, right knee, left ankle, right ankle]. The
remaining 5 elements [ymin, xmin, ymax, xmax, score] represent the region of the
bounding box (in normalized coordinates) and the confidence score of the instance.