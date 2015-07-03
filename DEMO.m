%% TBD-evaluation MATLAB toolbox:
% Towards the evaluation of reproducible robustness in
% tracking-by-detection
clc; clear; close all;
addpath(genpath('.'));

fprintf('This file serves as a DEMO and reproduces the results presented in the paper.\n');
fprintf('That means we tested two trackers NN and TC_ODAL on PETS09-S2L2.\n');
fprintf('Additionally, we also present results from TUD-Stadtmitte and AVG-TownCentre to show how tracker can be tested on more sequences simultaneously.\n\n');

%% PLOT RESULTS FROM PETS09-S2L2
fprintf('----------------------------------------------------------------------------------------------------------------\n\n');
fprintf('NN and TC_ODAL on PETS09-S2L2...\n(press any key to continue)\n');
pause;
run('createPlotsForSequence.m');
fprintf('Of course you can change the parameters in the m file to see how the trackers behave on different sequences!\n\n');

%% PLOT AGGREGATE RESULTS FROM PETS09-S2L2, TUD-Stadtmitte and AVG-TownCentre
fprintf('----------------------------------------------------------------------------------------------------------------\n\n');
fprintf('NN and TC_ODAL aggregate results from PETS09-S2L2, TUD-Stadtmitte and AVG-TownCentre.\n');
fprintf('(press any key to continue)\n');
pause;
run('createPlotsForDataset.m');
fprintf('- MOTA matrices are not averaged, see MOTA_all on the original paper;\n');
fprintf('- note the number of GT tracks in the TL plots is the sum of all the GT tracks from the different sequences.\n\n');

%% ADDITIONAL INFO:
fprintf('----------------------------------------------------------------------------------------------------------------\n\n');
fprintf('To reduce the size of this archive, we didn''t include the synthtetic generated data and the tracker results.\n');
fprintf('You can download them from:\n');
fprintf('PETS09-S2L2    - http://goo.gl/UbNWpx\n');
fprintf('TUD-Stadmitte  - http://goo.gl/B5XVuK\n');
fprintf('AVG-TownCentre - http://goo.gl/p6zfgf\n\n');
fprintf('Or you can generate your own files through the [createDetectionsFromGT_OCCLUSIONS.m] and [createDetectionsFromGT_ROBUSTNESS.m] scripts.\n');
fprintf('For more information on the use of these scripts, read the guide.\n');