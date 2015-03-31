# TBD-evaluation
Conventional experiments on Multi-Target Tracking (MTT) are built upon the belief that fixing the detections to different trackers is sufficient to obtain a fair comparison. Instead, ee argue how the true behavior of a tracker is exposed when evaluated by varying the input detections rather than by fixing them. We propose a systematic and reproducible protocol and a MATLAB toolbox for generating synthetic data starting from ground truth detections, a proper set of metrics to understand and compare trackers peculiarities and respective visualization solutions.

# Proposed tools
This MATLAB toolbox is composed of three main components:
* **Data degradation**: this module is required to generate new detections from ground truth. It should only be employed for training, while generated data should be kept fixed for future comparison.
* **Evaluation**: this code partially extends the *DEVKIT* proposed at MOT Challenge (www.motchallenge.com) with the ability to measure tracks length and automatically process a whole set of detections at different pairs of control parameters.
* **Result visualization**: is needed to reproduce the exact same plots we reported in the original paper (see ref below).

## Data degradation
ciao ciao ciao
