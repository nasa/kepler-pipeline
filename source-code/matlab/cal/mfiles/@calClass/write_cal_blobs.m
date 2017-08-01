function [calOutputStruct] = write_cal_blobs(calObject, calOutputStruct, blackCorrectionStructLC, smearCorrectionStructLC, calTransformStruct, compressedData)
% function [calOutputStruct] = write_cal_blobs(calObject, calOutputStruct, blackCorrectionStructLC, smearCorrectionStructLC, calTransformStruct, compressedData)
%
% This calClass method manages the writing of the blobs produced in CAL to local files. The calOutputStruct is updated
% with the blob filename.
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


metricsKey = metrics_interval_start;


% extract flags
dataFlags = calObject.dataFlags;
processFFI             = dataFlags.processFFI;
processLongCadence     = dataFlags.processLongCadence;
performExpLc1DblackFit = dataFlags.performExpLc1DblackFit; 
dynamic2DBlackEnabled  = dataFlags.dynamic2DBlackEnabled;
pouEnabled             = calObject.pouModuleParametersStruct.pouEnabled;

% extract input parameters
firstCall = calObject.firstCall;
lastCall  = calObject.lastCall;
ccdModule = calObject.ccdModule;
ccdOutput = calObject.ccdOutput;

% extract cadence times for 1D black fit blob
cadenceTimes = calObject.cadenceTimes;
startTimeStamps = cadenceTimes.startTimestamps;
midTimeStamps   = cadenceTimes.midTimestamps;
endTimeStamps   = cadenceTimes.endTimestamps;
cadenceNumbers  = cadenceTimes.cadenceNumbers;

% extract filenames
localFilenames = calObject.localFilenames;
stateFilePath  = localFilenames.stateFilePath;
fullPathPouBlobFilename = [stateFilePath,localFilenames.pouBlobFilename];
fullPathOneDBlackFitFilename = [stateFilePath,localFilenames.oneDBlackFitFilename];
fullPathSmearBlobFilename = [stateFilePath,localFilenames.smearBlobFilename];

%--------------------------------------------------------------------------
% write blob containing the error prop structure and compressed data
%--------------------------------------------------------------------------
tic;
if lastCall && pouEnabled
    % calTransformStruct and compressedData must be contained within a single matlab pou structure
    pouStruct.calTransformStruct    = calTransformStruct;
    pouStruct.compressedData        = compressedData;
    pouStruct.absoluteFirstCadence  = cadenceNumbers(1);
    pouStruct.absoluteLastCadence   = cadenceNumbers(end);

    struct_to_blob(pouStruct, fullPathPouBlobFilename);
    calOutputStruct.uncertaintyBlobFileName = localFilenames.pouBlobFilename;
    
    display_cal_status(['CAL:cal_matlab_controller: Error propagation struct saved to ' localFilenames.pouBlobFilename] , 1);
else
    calOutputStruct.uncertaintyBlobFileName = '';
end

clear calTransformStruct compressedData

%--------------------------------------------------------------------------
% write blob file containing LC 1D black fit 
%--------------------------------------------------------------------------
tic;

if firstCall && processLongCadence && performExpLc1DblackFit && ~processFFI && ~dynamic2DBlackEnabled

    blackFitStruct = struct('cadences', cadenceNumbers, ...
                            'startTimeStamps', startTimeStamps, ...
                            'midTimeStamps', midTimeStamps, ...
                            'endTimeStamps', endTimeStamps, ...
                            'module', ccdModule, ...
                            'output', ccdOutput, ...
                            'blackCorrectionStructLC',blackCorrectionStructLC);    
    struct_to_blob(blackFitStruct, fullPathOneDBlackFitFilename);
    calOutputStruct.oneDBlackFitBlobFileName = localFilenames.oneDBlackFitFilename;
    clear blackCorrectionStructLC    
    display_cal_status(['CAL:cal_matlab_controller: One D black fit struct saved to ' localFilenames.oneDBlackFitFilename] , 1);
else
    calOutputStruct.oneDBlackFitBlobFileName = '';
end

%--------------------------------------------------------------------------
% write blob file containing LC smear correction
%--------------------------------------------------------------------------
tic;
if firstCall && processLongCadence

    smearStruct = struct('cadenceNumbers', cadenceNumbers, ...
                            'startTimeStamps', startTimeStamps, ...
                            'midTimeStamps', midTimeStamps, ...
                            'endTimeStamps', endTimeStamps, ...
                            'module', ccdModule, ...
                            'output', ccdOutput, ...
                            'smearCorrectionStructLC',smearCorrectionStructLC);
    struct_to_blob(smearStruct, fullPathSmearBlobFilename);
    calOutputStruct.smearBlobFileName = localFilenames.smearBlobFilename;
    clear smearCorrectionStructLC    
    display_cal_status(['CAL:cal_matlab_controller: Smear correction struct saved to ' localFilenames.smearBlobFilename] , 1);    
else
    calOutputStruct.smearBlobFileName = '';
end

display_cal_status('CAL:cal_matlab_controller: CAL blobs written' , 1);
metrics_interval_stop('cal.write_cal_blobs.execTimeMillis',metricsKey);
