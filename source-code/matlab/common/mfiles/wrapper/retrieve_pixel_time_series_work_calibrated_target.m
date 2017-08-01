function keplerIdTimeSeriesStruct = retrieve_pixel_time_series_work_calibrated_target(observedTarget, ccdModule, ccdOutput, targetType, startCadence, endCadence, fsclient)
% function keplerIdTimeSeriesStruct = retrieve_pixel_time_series_work_calibrated_target(observedTarget, ccdModule, ccdOutput, targetType, startCadence, endCadence, fsclient)
%
% Internal function.  Don't call this from the command line unless you're certain you don't
% want to use retrieve_pixel_time_series_uncalibrated or retrieve_pixel_time_series_calibrated.
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
    import gov.nasa.kepler.fc.SbtFcOperations;
    import gov.nasa.kepler.fs.api.FileStoreClient;
    import gov.nasa.kepler.fs.api.FloatTimeSeries;
    import gov.nasa.kepler.fs.api.FsId;
    import gov.nasa.kepler.fs.client.FileStoreClientFactory;
    import gov.nasa.kepler.mc.fs.PaFsIdFactory;
    import gov.nasa.kepler.mc.fs.CalFsIdFactory;
    import gov.nasa.kepler.mc.fs.DrFsIdFactory;
    import java.util.ArrayList
    
    keplerIdTimeSeriesStruct = struct( ....
                'keplerId',            observedTarget.getKeplerId(), ...
                'row',                 [], ...
                'column',              [], ...
                'isInOptimalAperture', [], ...
                'timeSeries',          [], ...
                'uncertainties',       [], ...
                'gapIndicators',       [] );
            
    aperture = observedTarget.getAperture();
    if isempty(aperture)
        warning('MATLAB:SBT:wrapper:retrieve_pixel_time_series_work_calibrated_target', ...
                'The aperture for observedTarget with Kepler ID %d is null. Skipping.', int32(observedTarget.getKeplerId()));
        return
    end
    apertureOffsets = aperture.getOffsets();
    apRow = zeros(apertureOffsets.size(), 1);
    apCol = zeros(apertureOffsets.size(), 1);
    for iapoff = 0:(apertureOffsets.size()-1) % N.B. java indexing
        apOffset = apertureOffsets.get(iapoff);
        apRow(iapoff+1) = aperture.getReferenceRow + apOffset.getRow();
        apCol(iapoff+1) = aperture.getReferenceColumn + apOffset.getColumn();
    end
    
    targetDefinitions = observedTarget.getTargetDefinitions().toArray();
    
    fsIdsCal = ArrayList();
    fsIdsUncert = ArrayList();

    dataType = SbtFcOperations.getCalPixelTimeSeriesType('SOC_CAL');
    uncertType = SbtFcOperations.getCalPixelTimeSeriesType('SOC_CAL_UNCERTAINTIES');

    % Generate a matrix of unique row/column pairs for the pixels in this
    % target's target definitions:
    %
    rowCol = [];
    for itarg = 1:length(targetDefinitions)
        td = targetDefinitions(itarg);
        refRow = td.getReferenceRow();
        refCol = td.getReferenceColumn();

        targOffsets = td.getMask.getOffsets();
        for ioff = 0:(targOffsets.size()-1)
            offset = targOffsets.get(ioff);
            row = offset.getRow() + refRow;
            col = offset.getColumn() + refCol;
            rowCol(end+1, :) = [row col];
        end
    end
    uniqRowCol = unique(rowCol, 'rows');

    % Extract the FsIds for the unique pixels:
    %
    for ipix = 1:size(uniqRowCol, 1)
        row = uniqRowCol(ipix, 1);
        col = uniqRowCol(ipix, 2);
        
        fsIdsCal.add(   CalFsIdFactory.getTimeSeriesFsId(dataType,   targetType, ccdModule, ccdOutput, row, col));
        fsIdsUncert.add(CalFsIdFactory.getTimeSeriesFsId(uncertType, targetType, ccdModule, ccdOutput, row, col));

        keplerIdTimeSeriesStruct.row(end+1) = row;
        keplerIdTimeSeriesStruct.column(end+1) = col;
        isInOptimalAperture = any(apRow == row & apCol == col);
        keplerIdTimeSeriesStruct.isInOptimalAperture(end+1) = isInOptimalAperture;
    end

    fsIdsArrayCal    = SbtFcOperations.makeArrayFromList(fsIdsCal);
    fsIdsArrayUncert = SbtFcOperations.makeArrayFromList(fsIdsUncert);

    % The name tses* indicates multiple timeseries:
    %
    tsesCal = fsclient.readTimeSeriesAsFloat(fsIdsArrayCal, startCadence, endCadence, false);
    tsesUncert = fsclient.readTimeSeriesAsFloat(fsIdsArrayUncert, startCadence, endCadence, false);

    if length(tsesCal) ~= fsIdsArrayCal.length || length(tsesUncert) ~= fsIdsArrayUncert.length
        error('MATLAB:SBT:wrapper:retrieve_pixel_time_series', 'timeSerieses/fs_ids length mismatch!');
    end

    for itimeseries = 1:length(tsesCal)
        data   = tsesCal(itimeseries).fseries;
        gaps   = tsesCal(itimeseries).getGapIndicators();
        uncert = tsesUncert(itimeseries).fseries;

        keplerIdTimeSeriesStruct.timeSeries(   :, itimeseries) = data;
        keplerIdTimeSeriesStruct.gapIndicators(:, itimeseries) = logical(gaps);
        keplerIdTimeSeriesStruct.uncertainties(:, itimeseries) = uncert;
    end
return
