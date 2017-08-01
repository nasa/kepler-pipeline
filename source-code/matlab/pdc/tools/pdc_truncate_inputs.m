% function pdc_truncate_inputs.m
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
function inputsStruct = pdc_truncate_inputs(blobFileRoot,nTargetsTruncated,truncateCadences,nCadencesTruncated)
% 14 Mar 2013, by jcat
%==========================================================================
% Truncates the input data to pdc_matlab_controller to a desired number of 
% targets and cadences per target. Start in the directory with the required
% input files, which are pdc-inputs-0.mat and the blobxxx.mat file
% NOTE: *Before* running this code, you must copy the original blobxxx.mat
% file to blobxxx_original.mat
%==========================================================================
% Inputs required
%  blobFileRoot -- root of blob file name, eg. 'blob1438959443402720356'
%  nTargetsTruncated -- number of targets to keep
%  truncateCadences -- 'Y' or 'N'
%  nCadencesTruncated -- [] if truncateCadences == 'N'; otherwise, number
%   of cadences to keep
% Outputs 
%  inputsStruct, truncated version of inputsStruct
%==========================================================================
% The script will
% (1) Truncate the data in the original version of blobFile and save it as 
%     blobFile.
% (2) Truncate the data in inputsStruct in pdc-inputs-0.mat
% You can then run pdc in the normal way on the truncated data set:
% outputStruct = pdc_matlab_controller(inputsStruct)
%==========================================================================


%==========================================================================
% User-supplied inputs
% Name of the original blob file
originalBlobFile = [blobFileRoot,'_original.mat'];

%==========================================================================
% Load the input file
load pdc-inputs-0.mat;

% Truncate every field of inputsStruct that depends on the number of targets
inputsStruct.targetDataStruct = inputsStruct.targetDataStruct(1:nTargetsTruncated);

% Option to truncate the number of cadences to be processed
if(truncateCadences == 'Y')
    
    %==========================================================================
    % Load the copy of the original blob file, truncate it to the desired number of cadences and save
    % the truncated version as blobFileName
    load(originalBlobFile)
    inputStruct = inputStruct(1:nCadencesTruncated);
    save([blobFileRoot,'.mat'],'inputStruct');
    
    % Truncate every field of inputsStruct that depends on the number of cadences
    inputsStruct.endCadence = inputsStruct.startCadence - 1 + nCadencesTruncated;
    
    fn = fieldnames(inputsStruct.cadenceTimes);
    for jj = 1:length(fn) - 1;
        evalString = sprintf('inputsStruct.cadenceTimes.%s = inputsStruct.cadenceTimes.%s(1:%d)',fn{jj},fn{jj},nCadencesTruncated);
        eval(evalString);
    end
    
    fn = fieldnames(inputsStruct.longCadenceTimes);
    for jj = 1:length(fn) - 1;
        evalString = sprintf('inputsStruct.longCadenceTimes.%s = inputsStruct.longCadenceTimes.%s(1:%d)',fn{jj},fn{jj},nCadencesTruncated);
        eval(evalString);
    end
    
    for jj = 1:nTargetsTruncated
        inputsStruct.targetDataStruct(jj).values = inputsStruct.targetDataStruct(jj).values(1:nCadencesTruncated);
        inputsStruct.targetDataStruct(jj).gapIndicators = inputsStruct.targetDataStruct(jj).gapIndicators(1:nCadencesTruncated);
        inputsStruct.targetDataStruct(jj).uncertainties = inputsStruct.targetDataStruct(jj).uncertainties(1:nCadencesTruncated);
    end
    
    inputsStruct.motionBlobs.blobIndices = inputsStruct.motionBlobs.blobIndices(1:nCadencesTruncated);
    inputsStruct.motionBlobs.gapIndicators = inputsStruct.motionBlobs.gapIndicators(1:nCadencesTruncated);
    inputsStruct.motionBlobs.endCadence = inputsStruct.endCadence;
    
    inputsStruct.cadenceTimes.dataAnomalyFlags.attitudeTweakIndicators         = inputsStruct.cadenceTimes.dataAnomalyFlags.attitudeTweakIndicators(1:nCadencesTruncated);
    inputsStruct.cadenceTimes.dataAnomalyFlags.safeModeIndicators              = inputsStruct.cadenceTimes.dataAnomalyFlags.safeModeIndicators(1:nCadencesTruncated);
    inputsStruct.cadenceTimes.dataAnomalyFlags.coarsePointIndicators           = inputsStruct.cadenceTimes.dataAnomalyFlags.coarsePointIndicators(1:nCadencesTruncated);
    inputsStruct.cadenceTimes.dataAnomalyFlags.argabrighteningIndicators       = inputsStruct.cadenceTimes.dataAnomalyFlags.argabrighteningIndicators(1:nCadencesTruncated);
    inputsStruct.cadenceTimes.dataAnomalyFlags.excludeIndicators               = inputsStruct.cadenceTimes.dataAnomalyFlags.excludeIndicators(1:nCadencesTruncated);
    inputsStruct.cadenceTimes.dataAnomalyFlags.earthPointIndicators            = inputsStruct.cadenceTimes.dataAnomalyFlags.earthPointIndicators(1:nCadencesTruncated);
    
    inputsStruct.longCadenceTimes.dataAnomalyFlags.attitudeTweakIndicators         = inputsStruct.longCadenceTimes.dataAnomalyFlags.attitudeTweakIndicators(1:nCadencesTruncated);
    inputsStruct.longCadenceTimes.dataAnomalyFlags.safeModeIndicators              = inputsStruct.longCadenceTimes.dataAnomalyFlags.safeModeIndicators(1:nCadencesTruncated);
    inputsStruct.longCadenceTimes.dataAnomalyFlags.coarsePointIndicators           = inputsStruct.longCadenceTimes.dataAnomalyFlags.coarsePointIndicators(1:nCadencesTruncated);
    inputsStruct.longCadenceTimes.dataAnomalyFlags.argabrighteningIndicators       = inputsStruct.longCadenceTimes.dataAnomalyFlags.argabrighteningIndicators(1:nCadencesTruncated);
    inputsStruct.longCadenceTimes.dataAnomalyFlags.excludeIndicators               = inputsStruct.longCadenceTimes.dataAnomalyFlags.excludeIndicators(1:nCadencesTruncated);
    inputsStruct.longCadenceTimes.dataAnomalyFlags.earthPointIndicators            = inputsStruct.longCadenceTimes.dataAnomalyFlags.earthPointIndicators(1:nCadencesTruncated);
    
end % truncateCadences

