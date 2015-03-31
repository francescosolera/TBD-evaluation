# TBD-evaluation
Conventional experiments on Multi-Target Tracking (MTT) are built upon the belief that fixing the detections to different trackers is sufficient to obtain a fair comparison. Instead, ee argue how the true behavior of a tracker is exposed when evaluated by varying the input detections rather than by fixing them. We propose a systematic and reproducible protocol and a MATLAB toolbox for generating synthetic data starting from ground truth detections, a proper set of metrics to understand and compare trackers peculiarities and respective visualization solutions.

# Proposed tools
This MATLAB toolbox is composed of three main components:
* **Data degradation**: this module is required to generate new detections from ground truth. It should only be employed for training, while generated data should be kept fixed for future comparison.
* **Evaluation**: this code partially extends the *DEVKIT* proposed at MOT Challenge (www.motchallenge.net) with the ability to measure tracks length and automatically process a whole set of detections at different pairs of control parameters.
* **Result visualization**: is needed to reproduce the exact same plots we reported in the original paper (see ref below).

## Data degradation
The toolbox provides 2 scripts to degrate the ground truth trajectories, `createDetectionsFromGT_OCCLUSIONS.m` and `createDetectionsFromGT_ROBUSTNESS.m`. The first one creates sets of detections with an increasing number of both occluded targets and occluded frames. The latter one instead, varies the detector precision and recall by inserting an increasing number of false positive and false negatives. Both the scripts have some configuration lines at the beginning, specifying the root folder of the toolbox and the name of the sequence to degradate.

```matlab
baseFolder = 'D:\lab\TBD_evaluation';
datasetName = 'AVG-TownCentre';

% control parameters
P_range = 0.5 : 0.1 : 1;
R_range = 0.5 : 0.1 : 1;

% number of run to account for randomness
d = 5;
```

Additionally, it is also required to specify the range of variation of the control parameters (precision/recall in the reported example) and the number of detection sets generated at the same level of the parameters. The dataset name must also be the name of the folder which contains all the sequence info, in a tree structure similar to the one reported below. For example, for the sequence `AVG-TownCentre`:
AVG-TownCentre
> gt
> > gt.txt
> det
> > det.txt
> img
> > 000001.jpg
> > 000002.jpg
> > ...
occlusions_data
robustness_data

The last two folders must be created but will be filled by the scripts that generates the degraded detections starting from the file `gt.txt`. The `det` folder is not mandatory and must only be created if true detector responses are available. The detection format in the .txt files are the one adopted in the MOT Challenge competition.
