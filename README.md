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

<pre>
AVG-TownCentre
|-- gt
|   |-- gt.txt
|-- det
|   |-- det.txt
|-- img
|   |-- 000001.jpg
|   |-- 000002.jpg
|   |-- ...
|-- robustness_data
|-- occlusions_data
</pre>

The last two folders must be created but will be filled by the scripts that generates the degraded detections starting from the file `gt.txt`. The `det` folder is not mandatory and needs to be created only if true detector responses are available. The detection format in the .txt files are the one adopted in the MOT Challenge competition. By running the scripts a number of txt files in `_data` folders the will be created. This number is the product of the number of steps each control parameter has (6*6 in this case) and the number of runs (5 in the example).

## Evaluation
Now is the time to run the trackers you want to evaluate to create the a 1:1 output file for each one created in the previous section, *i.e.* an output for each different detection input. Once you have these results, you should organize them in a directory tree as follows. Suppose we have tested a tracker named `trk1`, then we should have in the root folder of this toolbox:

<pre>
trackers
|-- trk1
|   |-- AVG-TownCentre
|   |   |-- occlusions_results
|   |   |   |-- AVG-TownCentre_P0.00_R0.00_01.txt
|   |   |   |-- ...
|   |   |   |-- AVG-TownCentre_P0.80_R0.60_03.txt
|   |   |   |-- ...
|   |   |-- robustness_results
|   |   |   |-- AVG-TownCentre_P0.00_R0.00_01.txt
|   |   |   |-- ...
|   |   |   |-- AVG-TownCentre_P0.80_R0.60_03.txt
|   |   |   |-- ...
|   |   |-- det_results
|   |   |   |-- det.txt
</pre>

Inside the `trackers` folder, one folder must exists for each tracker one which to compare. Inside each trackers specific folders, one folder for each sequence has to be created containing at least `occlusion_results` and `robustness_results`. These two folder must contain the .txt files containing the tracking results. The name of the files must be the same of the input detections so that the toolbox can parse the values of P and R (in the example) and the number of the run. Once these folder are set up as shown above, the script `evaluateExperiments.m' can be lunched. It only needs some configurations:
```matlab
baseFolder      = 'D:\lab\TBD_evaluation';
trackerName     = 'trk1';
seqName         = 'AVG-TownCentre';
resultsFolder   = 'robustness_results';
```
