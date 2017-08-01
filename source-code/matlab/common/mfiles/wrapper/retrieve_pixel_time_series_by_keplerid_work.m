function pixelStruct = retrieve_pixel_time_series_by_keplerid_work(keplerIds, startMjd, endMjd, getLongCadence, getCalibrated, getCollateralAndBackground)
%
% function pixelStruct = retrieve_pixel_time_series_by_keplerid_work(keplerIds, startMjd, endMjd, getLongCadence, getCalibrated)
% or 
% function pixelStruct = retrieve_pixel_time_series_by_keplerid_work(keplerIds, startMjd, endMjd, getLongCadence, getCalibrated, getCollateralAndBackground)
%
% Internal function.  Don't call this from the command line unless you have a
% reason to not use retrieve_pixel_time_series_uncalibrated_by_keplerid or
% retrieve_pixel_time_series_calibrated_by_keplerid.
%
% The long/short cadence target time series extractor retrieves the original or
% calibrated time series of the long or short cadence target data for a
% specified vector of kepler IDs in a given time interval.
%
% Coordinate System Note:
%   Since this wrapper is presenting data from java, the row and column
%   coordinates given here are zero-based (i.e., the pixel nearest to the
%   readout node has coordinates row=0, column=0.
%
% INPUTS:
%   keplerIds               A list of the desired keplerIds.  One or more
%                           must be specified.
%
%   startMjd               The MJD of the start of the desired time interval.  
%
%   endMjd                 The MJD of the end of the desired time interval. 
%
%   getCalibrated          If 1, long cadence data is retrieved, if 0, short calibrated data is received.
%
%   getLongCadence         If 1, long cadence data is retrieved, if 0, short calibrated data is received.
%
%   getCollateralAndBackground If 1, collateral and background data is retreived.  If 0, collateral and background data is skipped.  Defaults to 0.
%
%
%
% OUTPUTS:
%
%     pixel_timeSeriesStruct:
%            mjdArray(nMjd)
%            isLongCadence
%            isOriginalData
%            keplerIdTimeSeriesStruct(nTarget) -- target structure, with fields:
%                  keplerId
%                  ccdModule
%                  ccdOutput
%                  row(nPixel)
%                  column(nPixel)
%                  isInOptimalAperture(nPixel)
%                  timeSeries(nMjd,nPixel)
%                  uncertainties(nMjd,nPixel)
%                  gapIndicators(nMjd,nPixel)
%            collateralAndBackground(nModOut) -- a struct array containing the collateral and background info for each channel that a kepler ID was requested on 
%                ccdModule -- the CCD module of this collateral/background data 
%                ccdOutput -- the CCD output of this collateral/background data
%                collateralData -- a vector of the collateral data for this module/output
%                backgroundPixelData -- a vector of the collateral background pixel data for this module/output
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

    if isempty(keplerIds)
        error('Matlab:SBT:retrieve_pixel_time_series_by_keplerid_work', 'No Kepler IDs given! Kepler ID vector cannot be empty');
    end

    if ~exist('getCollateralAndBackground', 'var')
        getCollateralAndBackground = 0;
    end
    
    import gov.nasa.kepler.fc.SbtFcOperations;
    if getLongCadence
        targetType = SbtFcOperations.getTargetType('LONG_CADENCE');
        getLongCadence = 1;
    else
        targetType = SbtFcOperations.getTargetType('SHORT_CADENCE');
        getLongCadence = 0;
    end

    import gov.nasa.kepler.fs.client.FileStoreClientFactory;
    fsclient = FileStoreClientFactory.getInstance();

    % Get the cadence range of the user-input MJDs:
    %
    validMjds = get_cadence_mjds(startMjd, endMjd, getLongCadence);
    startCadence = validMjds(1).cadenceNumber;
    endCadence   = validMjds(end).cadenceNumber;

    % Get the mod/out pairs that the targets fall on for these MJDs:
    %
    [allModules allOutputs] = get_all_modules_and_outputs(keplerIds, validMjds);
        
    % Set some of output struct pixelStruct's fields:
    %
    pixelStruct.isLongCadence = getLongCadence;
    pixelStruct.isOriginalData = ~getCalibrated;    
    for imjd = 1:length(validMjds)
        pixelStruct.mjdArray(imjd) = validMjds(imjd).mjdMidTime;
    end

     % Loop over the targetTableLogs for this target type/cadence range:
     %
    import gov.nasa.kepler.hibernate.tad.TargetCrud;
    targetCrud = TargetCrud();
    targetTableLogs = targetCrud.retrieveTargetTableLogs(targetType, startCadence, endCadence);
    
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
        targetTable = targetTableLog.getTargetTable();

        % Retrieve the start/stop cadences for this target table log:
        %
        loopStartCadence = targetTableLog.getCadenceStart();
        loopEndCadence   = targetTableLog.getCadenceEnd();

        % Get this channel's targets:
        %
        itarget = 0;
        for ichannel = 1:length(allModules)
            ccdModule = allModules(ichannel);
            ccdOutput = allOutputs(ichannel);
            
            % Get a vector of the kepler IDs of the observed targets for
            % this mod/out:
            %
            observedTargets = targetCrud.retrieveObservedTargets(targetTable, ccdModule, ccdOutput);
            otKeplerIds = [];
            for ii = 0:(observedTargets.size() - 1) % N.B. Java indexing
                otKeplerIds(ii+1) = observedTargets.get(ii).getKeplerId();
            end
            
            % Process the user-requested kepler IDs that are on this
            % channel.  DO NOT process the targets on this channel that
            % have not been requested by the user:
            %
            [tf matchingIndices] = ismember(keplerIds, otKeplerIds);
            nonzeroTf = find(tf);

            for ii = 1:length(nonzeroTf)

                % Get the target for the ii^th user-requested kepler ID for
                % on this channel:
                %
                matchingIndex = matchingIndices(nonzeroTf(ii));
                observedTarget = observedTargets.get(matchingIndex-1); % N.B. Java indexing

                % Get the time series data for this target:
                %
                if getCalibrated
                    targetData = retrieve_pixel_time_series_work_calibrated_target(observedTarget, ccdModule, ccdOutput, targetType, loopStartCadence, loopEndCadence, fsclient);
                else
                    targetData = retrieve_pixel_time_series_work_uncalibrated_target(observedTarget, ccdModule, ccdOutput, targetType, loopStartCadence, loopEndCadence, fsclient);
                end
                targetData.ccdModule = ccdModule;
                targetData.ccdOutput = ccdOutput;
                
                % Write target data to output struct:
                %
                pixelStruct.keplerIdTimeSeriesStruct(itarget+1) = targetData;
                itarget = itarget + 1;
            end
              
            if getCollateralAndBackground
                % Get the collateral and background data
                %
                disp('Extracting collateral data');
                collateralData = retrieve_collateral_data_work(getLongCadence, targetTable, ccdModule, ccdOutput, startCadence, endCadence);
                disp('Extracting background data');
                if getCalibrated
                    backgroundData = retrieve_calibrated_background_data_work(targetCrud, fsclient, targetTable, ccdModule, ccdOutput, startCadence, endCadence);
                else
                    backgroundData = retrieve_uncalibrated_background_data_work(targetCrud, fsclient, targetTable, ccdModule, ccdOutput, startCadence, endCadence);
                end
                pixelStruct.collateralAndBackground(ichannel).collateralData = collateralData;
                pixelStruct.collateralAndBackground(ichannel).backgroundPixelData = backgroundData;
            end
            pixelStruct.collateralAndBackground(ichannel).ccdModule = ccdModule;
            pixelStruct.collateralAndBackground(ichannel).ccdOutput = ccdOutput;
        end
    end

return


function [allModules allOutputs] = get_all_modules_and_outputs(keplerIds, mjds)
% Return a list of the unique module/output pairs that keplerIds fall on
% for the time in mjds
%
    
    import gov.nasa.kepler.hibernate.cm.KicCrud;
    import gov.nasa.kepler.hibernate.fc.FcCrud;
    import gov.nasa.kepler.hibernate.fc.History;
    import gov.nasa.kepler.hibernate.fc.HistoryModelName;
    import gov.nasa.kepler.hibernate.fc.RollTime;
    import gov.nasa.kepler.common.TargetManagementConstants;
    
    modsAndOuts = [];
    
    customTargetKeplerIdStart = TargetManagementConstants.CUSTOM_TARGET_KEPLER_ID_START;
    isCustomTarget = keplerIds > customTargetKeplerIdStart;

    % Non-custom targets:
    %
    mjdsIndices = [1 length(mjds)];
    nonCustomKeplerIds = keplerIds(~isCustomTarget);
    if ~isempty(nonCustomKeplerIds)
        for imjd = 1:length(mjdsIndices)

            index = mjdsIndices(imjd);
            kicStruct = retrieve_comprehensive_kic_info(nonCustomKeplerIds, mjds(index).mjdStartTime);

            loopModsAndOuts = [kicStruct.ccdModule; kicStruct.ccdOutput]';
            modsAndOuts = [modsAndOuts; loopModsAndOuts];
        end
    end
    
    % Custom targets:
    %
    customKeplerIds = keplerIds(isCustomTarget);
    if ~isempty(customKeplerIds)
        customTargets = retrieve_kics_by_kepler_id(keplerIds(isCustomTarget));
        fcCrud = FcCrud();
        kicCrud = KicCrud();
        history = fcCrud.retrieveHistory(HistoryModelName.ROLLTIME);


        for imjd = 1:length(mjdsIndices)
            for icustom = 1:length(customTargets)
                index = mjdsIndices(imjd);
                rolltime = fcCrud.retrieveRollTime(mjds(index).mjdStartTime, history);

                sg = kicCrud.retrieveSkyGroup(customTargets(icustom).getSkyGroupId, int32(rolltime.getSeason));
                loopModsAndOuts = [sg.getCcdModule; sg.getCcdOutput]';
                modsAndOuts = [modsAndOuts; loopModsAndOuts];
            end
        end
    end 
    uniqueModsAndOuts = unique(modsAndOuts, 'rows');
    allModules = uniqueModsAndOuts(:,1);
    allOutputs = uniqueModsAndOuts(:,2);
return
