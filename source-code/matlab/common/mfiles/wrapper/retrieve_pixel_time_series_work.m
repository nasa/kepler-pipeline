function timeSeriesStruct = retrieve_pixel_time_series_work(modules, outputs, startMjd, endMjd, getLongCadence, getCalibrated)
%
% Internal function.  Don't call this from the command line unless you're certain you don't
% want to use retrieve_pixel_time_series_uncalibrated or retrieve_pixel_time_series_calibrated.
%
% The sub-method for both retrieve_pixel_time_series_calibrated and retrieve_pixel_time_series_uncalibrated.
%
% The long/short cadence target time series extractor retrieves the original or
% calibrated time series of the long or short cadence target data for a
% specified mod/out for a given time interval.
%
% timeSeriesStruct = retrieve_pixel_time_series_work(modules, outputs, startMjd, endMjd, getLongCadence, getCalibrated)
%
% Coordinate System Note:
%   Since this wrapper is presenting data from java, the row and column
%   coordinates given here are zero-based (i.e., the pixel nearest to the
%   readout node has coordinates row=0, column=0.
%
% INPUTS:
%   modules                 A list of the desired modules.  All are returned
%                           if this is not specified.  Must be the same length as 'outputs' if
%                           specified.
%
%   outputs                 A list of the desired outputs.  All are returned
%                           if this is not specified.  Must be the same length as 'modules' if
%                           specified.
%
%   startMjd               The MJD of the start of the desired time
%                           interval.  
%
%   endMjd                 The MJD of the end of the desired time interval. 
%
%   getLongCadence         If 1, long cadence data is retrieved, if 0, short calibrated data is received.
%
%   getCalibrated          If 1, long cadence data is retrieved, if 0, short calibrated data is received.
%
% OUTPUTS:
%
%     pixel_timeSeriesStruct(nModOut):
%            module
%            output
%            mjdArray(nMjd)
%            isLongCadence
%            isOriginalData
%            backgroundData
%            collateralData
%            keplerIdTimeSeriesStruct(nTarget) -- target structure, with fields:
%                  keplerId
%                  row(nPixel)
%                  column(nPixel)
%                  isInOptimalAperture(nPixel)
%                  timeSeries(nMjd,nPixel)
%                  uncertainties(nMjd,nPixel)
%                  gapIndicators(nMjd,nPixel)
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

    % Parse args:
    %
    if nargin ~= 6
        error('MATLAB:SBT:wrapper:retrieve_pixel_time_series', ...
            'Wrong number of arguments, see help text.')
    end

    % Verify args (implicitly done in convert_from_module_output):
    %
    channels = convert_from_module_output(modules, outputs); %#ok<NASGU>

    import gov.nasa.kepler.hibernate.tad.TargetCrud;
    targetCrud = TargetCrud();

    for ichan = 1:length(modules)
        ccdModule = modules(ichan);
        ccdOutput = outputs(ichan);
        
        disp(sprintf('module %d output %d', ccdModule, ccdOutput));
        
        timeSeriesStruct(ichan) = do_channel(ccdModule, ccdOutput, startMjd, endMjd, getLongCadence, targetCrud, getCalibrated);
    end
SandboxTools.close;
return




function oneChannelTimeSeriesStruct = do_channel(ccdModule, ccdOutput, startMjd, endMjd, getLongCadence, targetCrud, getCalibrated)
    import gov.nasa.kepler.fc.SbtFcOperations;
    import gov.nasa.kepler.fs.api.FileStoreClient;
    import gov.nasa.kepler.fs.api.FloatTimeSeries;
    import gov.nasa.kepler.fs.api.FsId;
    import gov.nasa.kepler.fs.client.FileStoreClientFactory;
    import gov.nasa.kepler.mc.fs.PaFsIdFactory;
    import gov.nasa.kepler.mc.fs.CalFsIdFactory;
    import gov.nasa.kepler.mc.fs.DrFsIdFactory;
    import gov.nasa.kepler.hibernate.dr.LogCrud;
    import gov.nasa.kepler.mc.dr.MjdToCadence
    import gov.nasa.kepler.hibernate.tad.TargetTableLog;
    import gov.nasa.kepler.mc.TimeSeriesOperations;
    import java.util.ArrayList

    validMjds = get_cadence_mjds(startMjd, endMjd, getLongCadence);
    startCadence = validMjds(1).cadenceNumber;
    endCadence   = validMjds(end).cadenceNumber;
    
    % Create a single instance of the output struct vector, and repmat it to make the output:
    %
    oneChannelTimeSeriesStruct = struct(...
        'module', ccdModule, ...
        'output', ccdOutput, ...
        'mjdArray', zeros(1, length(validMjds))-1, ...
        'isLongCadence', getLongCadence, ...
        'isOriginalData', ~getCalibrated);


    if getLongCadence
        targetType = SbtFcOperations.getTargetType('LONG_CADENCE');
    else
        targetType = SbtFcOperations.getTargetType('SHORT_CADENCE');
    end    
    targetTableLogs = targetCrud.retrieveTargetTableLogs(targetType, startCadence, endCadence);

    fsclient = FileStoreClientFactory.getInstance();

    % Error out if more than one target table log is returned:
    if targetTableLogs.size() > 1
        for ii = 1:targetTableLogs.size() % N.B. MATLAB indexing
            ttLog = targetTableLogs.get(ii-1);
            mjds{ii} = get_mjd_cadences(ttLog.getCadenceStart(), ttLog.getCadenceEnd());
        end
        disp('Target Table MJD Ranges:')
        for ii = 1:length(mjds)
            mjd = mjds{ii};
            disp(sprintf('    TargetTableLog %d runs from MJD %8.2f to %8.2f', ii, mjd(1).mjdStartTime, mjd(end).mjdEndTime));
        end
        
        error('MATLAB:SBT:wrapper:retrieve_pixel_time_series', ...
            'User input MJD range: %9.2f - %9.2f crosses a quarter boundry.  Please use a time range that does not cross quarter boudries.', startMjd, endMjd);
    end
    
    for ittl = 0:(targetTableLogs.size() - 1) % N.B. Java indexing
        targetTableLog = targetTableLogs.get(ittl);

        % Check time bracketting:
        %
        loopStartCadence = targetTableLog.getCadenceStart();
        loopEndCadence   = targetTableLog.getCadenceEnd();
        if loopStartCadence > startCadence
            warning('MATLAB:SBT:wrapper:retrieve_pixel_time_series', ...
                'loopStartCadence %f is greater than the requested start cadence %f. Data from cadences smaller than loopStartCadence will not be returned', loopStartCadence, startCadence);
        end
        if loopEndCadence < endCadence
            warning('MATLAB:SBT:wrapper:retrieve_pixel_time_series', ...
                'loopEndCadence %f is less than the requested end cadence %f. Data from cadences larger than loopEndCadence will not be returned', loopEndCadence, endCadence);
        end

        targetTable = targetTableLog.getTargetTable();
        observedTargets = targetCrud.retrieveObservedTargets(targetTable, ccdModule, ccdOutput);
        

        disp('Extracting collateral data');
        collateralData = retrieve_collateral_data_work(getLongCadence, targetTable, ccdModule, ccdOutput, startCadence, endCadence);
        oneChannelTimeSeriesStruct.collateralData = collateralData;
        
        disp('Extracting background data');
        if getCalibrated
            backgroundData = retrieve_calibrated_background_data_work(targetCrud, fsclient, targetTable, ccdModule, ccdOutput, startCadence, endCadence);
        else
            backgroundData = retrieve_uncalibrated_background_data_work(targetCrud, fsclient, targetTable, ccdModule, ccdOutput, startCadence, endCadence);
        end
        oneChannelTimeSeriesStruct.backgroundPixelData = backgroundData;
        
        for itarget = 0:(observedTargets.size() - 1) % N.B. Java indexing
            disp(sprintf('target table logs: %d of %d, target %d of %d for this log', ittl+1, targetTableLogs.size(), itarget+1, observedTargets.size()))
            observedTarget = observedTargets.get(itarget);
            if getCalibrated
                targetData = retrieve_pixel_time_series_work_calibrated_target(observedTarget, ccdModule, ccdOutput, targetType, startCadence, endCadence, fsclient);
            else
                targetData = retrieve_pixel_time_series_work_uncalibrated_target(observedTarget, ccdModule, ccdOutput, targetType, startCadence, endCadence, fsclient);
            end
            oneChannelTimeSeriesStruct.keplerIdTimeSeriesStruct(itarget+1) = targetData;
        end 
        
        % Record the timestamps:
        %
        if length(oneChannelTimeSeriesStruct.mjdArray) ~= length(validMjds)
            error('MATLAB:SBT:wrapper:retrieve_pixel_time_series', ...
                'mjdArray has different length than validMjds.  Error');
        end

        for imjd = 1:length(validMjds)
            oneChannelTimeSeriesStruct.mjdArray(imjd) = validMjds(imjd).mjdMidTime;
        end
    end
return
