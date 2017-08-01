function targetTimeSeries = retrieve_target_time_series(ccdModules, ccdOutputs, startCadence, endCadence, isLongCadence, isCalibrated)
%
% targetTimeSeries = retrieve_target_time_series(ccdModules, ccdOutputs, startCadence, endCadence)
% or
% targetTimeSeries = retrieve_target_time_series(ccdModules, ccdOutputs, startCadence, endCadence, isLongCadence, isCalibrated)
%
%  INPUTS:
%
%     ccdModules     A vector of modules.
%     ccdOutputs     A vector of outputs.
%     startCadence   Start cadence of the requested data.
%     endCadence     Start cadence of the requested data.
%     isLongCadence  Boolean flag to indicate long/short cadence.  Defaults to true.
%     isCalibrated   Boolean flag to indicate calibrated or uncalibrated data output.  Defaults to true.
%
% OUTPUTS:
% 
%     targetTimeSeries      A vector of structs length(ccdModules) long.  It has the following fields:
%
%      module               The CCD module number.
%      output               The CCD output number
%      mjdArray             The array of valid MJDs between startCadence and endCadence.
%      isLongCadence        A boolean flag to indicate if this data is long cadence data.
%      isOriginalData       A boolean flag to indicate if this data is uncalibrated (true) or calibrated (false).
%      targetContainers     A vector of structs, one per target, with the following fields:
%          keplerId:            The Kepler ID of this target.
%          rows                 The zero-based row addresses of this target.
%          columns              The zero-based column addresses of this target.
%          timeSeries           A length(rows) x length(mjdArray) matrix of the time series data for each pixel at each timestamp.
%          uncertainty          A length(rows) x length(mjdArray) matrix of the time series uncertainty for each pixel at each timestamp.
%                               If isOriginal data is true, this will be zero-filled.
%          gapIndicators        A length(rows) x length(mjdArray) matrix of gap indicators for each pixel at each timestamp.
% 
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

    import gov.nasa.kepler.systest.sbt.SandboxTools;
    SandboxTools.displayDatabaseConfig;
   
    import gov.nasa.kepler.systest.sbt.SbtRetrieveTargetTimeSeries;
    sbt = SbtRetrieveTargetTimeSeries();

    switch nargin
        case 4
            isLongCadence = true;
            isCalibrated = true;
        case 6
            ;
        otherwise
            error('Error in nargin switch block for retrieve_target_time_series. See helptext for proper usage.');
    end

    pathJava = sbt.retrieveTargetTimeSeries(ccdModules, ccdOutputs, startCadence, endCadence, isLongCadence, isCalibrated);
    path = pathJava.toCharArray()';

    disp('Unpacking SDF file.  This can take some time.');
    targetStruct = sbt_sdf_to_struct(path);
    targetTimeSeries = targetStruct.channels;
    
    % Reshape the data substructs for ease of use:
    %
    for ichannel = 1:length(targetTimeSeries)
        for itarget = 1:length(targetTimeSeries(ichannel).targetContainers)

            rowCount = length(targetTimeSeries(ichannel).targetContainers(itarget).rows);
            colCount = length(targetTimeSeries(ichannel).targetContainers(itarget).timeSeries(1).array);

            data = zeros(rowCount, colCount);
            uncert = zeros(size(data));
            gaps = zeros(size(data));
            
            for ipixel = 1:length(targetTimeSeries(ichannel).targetContainers(itarget).timeSeries)
                data(ipixel, :) = targetTimeSeries(ichannel).targetContainers(itarget).timeSeries(ipixel).array;
                uncert(ipixel, :) = targetTimeSeries(ichannel).targetContainers(itarget).uncertainty(ipixel).array;
                gaps(ipixel, :) = targetTimeSeries(ichannel).targetContainers(itarget).gapIndicators(ipixel).array;
            end
            
            targetTimeSeries(ichannel).targetContainers(itarget).timeSeries = data;
            targetTimeSeries(ichannel).targetContainers(itarget).uncertainty = uncert;
            targetTimeSeries(ichannel).targetContainers(itarget).gapIndicators = gaps;
        end
    end
return
