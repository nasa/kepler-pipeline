function [keplerId, medianWhiteningCoefficients, whiteningCoefficients] = get_wavelet_data(runId)

% Input string is either 'deep40' or 'shallow98'
% For 'shallow98', read the wavelet coefficients from local archive,
% produced by running get_wavelet_data_for_list_of_kepler_ids.m
% For 'deep40', read the wavelet coefficients from the nfs taskfiles
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

% Location of task files produced by local run of run_tasks_locally.m,
% which runs run_tps_wavelet_object_generator_on_nas.m locally and saves
% outputs.
switch runId
    
    case 'deep40'
        waveletCoeffDir = '/path/to/tps-matlab-2016148/tps-matlab-2016148-0/';
        
        
    case 'shallow98'
        waveletCoeffDir = strcat('/codesaver/work/transit_injection/wavelet_coefficients/','KSOC-5007/');
        
end

% ksoc-5007 test with 98 stars
% waveletCoeffDir = '/path/to/transitInjections/KSOC-5007/Shallow_FLTI_Test_1_with_100_stars/tps-matlab-2016159/tps-matlab-2016159-0/';

% Retrieve wavelet data
dirs = dir(waveletCoeffDir);
dirIdx = [dirs.isdir];
subDirs = dirs(dirIdx);
count = 0;
pathName0 = cell(1,length(subDirs));
tmp = struct('outputsStruct',[]);
waveletData = repmat(tmp,1,length(subDirs)-2);
for iDir = 1:length(subDirs)
    
    if(strfind(subDirs(iDir).name,'st-'))
        pathName0{iDir} = strcat(waveletCoeffDir,subDirs(iDir).name,'/tps-wavelet-object.mat');
        if(exist(pathName0{iDir},'file'))
            count = count + 1;
            load(pathName0{iDir});
            waveletData(1,count).outputsStruct = outputsStruct;%.waveletStructArray.waveletObject;
        end
        
    end
end

% Truncate
pathName = pathName0(1:count);
waveletData = waveletData(1:count);

% Package up wavelet data into a struct
targetStruct = repmat(struct('data',[],'keplerId',[]),1,length(waveletData));
for iTarget = 1:count
    data0 = waveletData(1,iTarget).outputsStruct.waveletStructArray.waveletObject;
    % data = get(tmp,'*'); %not needed if tmp is a struct
    data = data0;
    % data = struct(data);
    targetStruct(iTarget).data = data;
    targetStruct(iTarget).keplerId = waveletData(1,iTarget).outputsStruct.keplerId;
    targetStruct(iTarget).skyGroup = waveletData(1,iTarget).outputsStruct.skyGroup;
end

% Loop over targets and get the wavelet coefficients
nQuarters = 17;
medianWhiteningCoefficients = zeros(length(waveletData),11);
keplerId = zeros(length(waveletData),1);
nQuartersForThisTarget = zeros(1,length(waveletData));
whiteningCoefficients = zeros(length(waveletData),nQuarters*size(data.whiteningCoefficients(:,:,1),1),size(data.whiteningCoefficients(:,:,1),2));
for iTarget = 1:length(waveletData)
    
    keplerId(iTarget) = targetStruct(iTarget).keplerId;
    nQuartersForThisTarget(iTarget) = size(targetStruct(iTarget).data.whiteningCoefficients,3);
    
    % Initialize whitening coefficients array for this target
    whiteningCoefficients0 = [];

    % Get the whitening coefficient time series
    % Handle the case of fewer than 17 quarters of data
    for iQuarter = 1:nQuartersForThisTarget(iTarget)
        
        whiteningCoefficients0 = [whiteningCoefficients0;squeeze(targetStruct(iTarget).data.whiteningCoefficients(:,:,iQuarter))];
        
    end % iQuarter
    
    % Whitening coefficient time series
    whiteningCoefficients(iTarget,1:nQuartersForThisTarget(iTarget)*size(data.whiteningCoefficients(:,:,1),1),:) = whiteningCoefficients0;
    
    % Median of whitening coefficient time series
    medianWhiteningCoefficients(iTarget,:) = median(whiteningCoefficients0);
    
end % iTarget



