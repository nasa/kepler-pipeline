function [tppInputStruct, eeTempStruct] = build_tppInputStruct_from_etem_run(nCadences)
%   This function generates a tppInputStruct from the specified etem run and
%   target index range. Used for testing PA:encircledEnergy
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% 
% NASA acknowledges the SETI Institute's primary role in authoring and
% producing the Kepler Data Processing Pipeline under Cooperative
% Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
% NNX11AI14A, NNX13AD01A & NNX13AD16A.
% 
% This file is available under the terms of the NASA Open Source Agreement
% (NOSA). You should have received a copy of this agreement with the
% Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
% 
% No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
% WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
% INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
% WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
% INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
% FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
% TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
% CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
% OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
% OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
% FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
% REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
% AND DISTRIBUTES IT "AS IS."
% 
% Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
% AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
% SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
% THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
% EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
% PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
% SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
% STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
% PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
% REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
% TERMINATION OF THIS AGREEMENT.
%

disp(mfilename('fullpath'));

%   ETEM run name and location
locationStr='/path/to/etem/quarter/1/';
name='long_cadence_q_black_smear_back_gcr_';
run=90400;
%nCadences=20;       % pass 'build_time_series' without nCadences to get all available cadences in run

% choose range of target indices to export to tppInputStruct
a=1201;b=1400;

% choose polynomial order of fit and eeFraction for use in encircledEnergy.m
tppInputStruct.encircledEnergyStruct.polyOrder   = 4;
tppInputStruct.encircledEnergyStruct.eeFraction  = 0.95;

% get time series data - specifically, build targetStarStruct
[targetStarStruct, backgroundStruct, smearStruct]   = build_time_series(locationStr,run,name,nCadences);
tppInputStruct.targetStarStruct = targetStarStruct(a:b);

% add centroids
tppInputStruct.targetStarStruct=simple_target_centroid(tppInputStruct.targetStarStruct);

runStr = ['run',num2str(run)];
loadStr = [locationStr runStr  '/ktargets_' runStr];
load(loadStr, 'targetflux');

% add gaps at target level, add target flux
for i=1:length(tppInputStruct.targetStarStruct)
    tppInputStruct.targetStarStruct(i).expectedFlux=targetflux(i);
    tppInputStruct.targetStarStruct(i).gapList=[];
end


tppInputStruct.backgroundStruct=backgroundStruct;
tppInputStruct.smearStruct=smearStruct;

% generate eeTempStruct for use in development versions of encircledEnergy
eeTempStruct=generate_eeTempStruct_from_tppInputStruct(tppInputStruct);
% add encircledEnergyStruct field to tppInputStruct
tppInputStruct.encircledEnergyStruct = eeTempStruct.encircledEnergyStruct;


% clean up .mat file stored by function build_time_series
matfilename = ['timeSeries_run',num2str(run),'.mat'];
delete (matfilename);






