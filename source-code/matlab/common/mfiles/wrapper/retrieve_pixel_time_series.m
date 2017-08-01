function pixelTimeSeries = retrieve_pixel_time_series(ccdModules, ccdOutputs, startMjd, endMjd, isLongCadence, isCalibrated)
%
% pixelTimeSeries = retrieve_pixel_time_series(ccdModules, ccdOutputs, startMjd, endMjd, isLongCadence, isCalibrated)
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
        
    if nargin ~= 6
        error('incorrect number of arguments. See helptext.');
    end
    
    import gov.nasa.kepler.systest.sbt.SbtRetrievePixelTimeSeries;
    
    mjdChunk = 15;
    numMjdChunks = ceil((endMjd - startMjd)/mjdChunk);
    
    for ichunk = 1:numMjdChunks
        startMjdChunk = (ichunk - 1) * mjdChunk + startMjd;
        endMjdChunk = startMjdChunk + mjdChunk;
        if endMjdChunk > endMjd
            endMjdChunk = endMjd;
        end
        msg = sprintf('\nChunk %d (%.1f to %.1f) of %d (each chunk is %d MJDs)', ichunk, startMjdChunk, endMjdChunk, numMjdChunks, mjdChunk);
        disp(msg);
        
        pathJava = SbtRetrievePixelTimeSeries.retrievePixelTimeSeries(ccdModules, ccdOutputs, startMjdChunk, endMjdChunk, isLongCadence, isCalibrated);

        path = pathJava.toCharArray()';

        pixelTimeSeriesSdf = sbt_sdf_to_struct(path);
        if isempty(pixelTimeSeriesSdf)
            pixelTimeSeries = [];
            return;
        end

        disp('Converting java data...');
        % If it is the first chunk, set pixelTimeSeries to the output of repackage_to_match_old_sbt.  If it isn't,
        % concatenate the data from this chunk's pixelTimeSeriesSdf onto the end of pixelTimeSeries
        %
        if ichunk == 1
            pixelTimeSeries = repackage_to_match_old_sbt(pixelTimeSeriesSdf, isCalibrated);
        else
            pixelTimeSeries = repackage_to_match_old_sbt(pixelTimeSeriesSdf, isCalibrated, pixelTimeSeries);
        end
        disp('Done converting java data.');
    end

    SandboxTools.close;
return

function pixTs = repackage_to_match_old_sbt(pixelTimeSeriesSdf, isCalibrated, pixTs)
% pixTs = repackage_to_match_old_sbt(pixelTimeSeriesSdf, isCalibrated, pixelTimeSeries)
% 
% Calling this with three args concatenates the data from pixelTimeSeriesSdf onto the end of pixelTimeSeries.
% Calling this with two args just copies the pixelTimeSeriesSdf into pixelTimeSeries.
%

    if nargin < 2 || nargin > 3
        warning('SBT:retrieve_pixel_time_series', 'Internal error: Illegal number of arguments to repackage_to_match_old_sbt.');
    end

    isAppendingData = (nargin == 3);
    if ~isAppendingData
        pixTs = [];
    end

    for ichannel = 1:length(pixelTimeSeriesSdf.channelData)

        % The following are the same whether or not new data is being appended to an existing pixelTimeSeries struct:
        %
        pixTs(ichannel).module = pixelTimeSeriesSdf.channelData(ichannel).module;
        pixTs(ichannel).output = pixelTimeSeriesSdf.channelData(ichannel).output;
        pixTs(ichannel).isLongCadence = pixelTimeSeriesSdf.channelData(ichannel).isLongCadence;
        pixTs(ichannel).isOriginalData = pixelTimeSeriesSdf.channelData(ichannel).isOriginalData;

        for itarget = 1:length(pixelTimeSeriesSdf.channelData(ichannel).keplerIdTimeSeriesStruct)
            pixTs(ichannel).keplerIdTimeSeriesStruct(itarget).keplerId            = pixelTimeSeriesSdf.channelData(ichannel).keplerIdTimeSeriesStruct(itarget).keplerId;
            pixTs(ichannel).keplerIdTimeSeriesStruct(itarget).row                 = pixelTimeSeriesSdf.channelData(ichannel).keplerIdTimeSeriesStruct(itarget).row;
            pixTs(ichannel).keplerIdTimeSeriesStruct(itarget).column              = pixelTimeSeriesSdf.channelData(ichannel).keplerIdTimeSeriesStruct(itarget).column;
            pixTs(ichannel).keplerIdTimeSeriesStruct(itarget).isInOptimalAperture = pixelTimeSeriesSdf.channelData(ichannel).keplerIdTimeSeriesStruct(itarget).isInOptimalAperture;
        end

        % The following are the different depending on whether new data are being appended to an existing pixelTimeSeries struct:
        %
        if ~isAppendingData
            pixTs(ichannel).mjdArray                        = pixelTimeSeriesSdf.channelData(ichannel).mjdArray;
            pixTs(ichannel).calibratedBackgroundPixelData   = pixelTimeSeriesSdf.channelData(ichannel).calibratedBackgroundPixelData;
            pixTs(ichannel).uncalibratedBackgroundPixelData = pixelTimeSeriesSdf.channelData(ichannel).uncalibratedBackgroundPixelData;
            pixTs(ichannel).collateralData                  = pixelTimeSeriesSdf.channelData(ichannel).collateralData;
        else
            for ipix = 1:length(pixTs(ichannel).collateralData)
                pixTs(ichannel).collateralData(ipix).timeSeries    = [pixTs(ichannel).collateralData(ipix).timeSeries;    pixelTimeSeriesSdf.channelData(ichannel).collateralData(ipix).timeSeries];
                pixTs(ichannel).collateralData(ipix).gapIndicators = [pixTs(ichannel).collateralData(ipix).gapIndicators; pixelTimeSeriesSdf.channelData(ichannel).collateralData(ipix).gapIndicators];
            end

            pixTs(ichannel).mjdArray = [pixTs(ichannel).mjdArray; pixelTimeSeriesSdf.channelData(ichannel).mjdArray];
            for ipix = 1:length(pixTs(ichannel).calibratedBackgroundPixelData)
                pixTs(ichannel).calibratedBackgroundPixelData(ipix).timeSeries    = [pixTs(ichannel).calibratedBackgroundPixelData(ipix).timeSeries;    pixelTimeSeriesSdf.channelData(ichannel).calibratedBackgroundPixelData(ipix).timeSeries];
                pixTs(ichannel).calibratedBackgroundPixelData(ipix).uncertainties = [pixTs(ichannel).calibratedBackgroundPixelData(ipix).uncertainties; pixelTimeSeriesSdf.channelData(ichannel).calibratedBackgroundPixelData(ipix).uncertainties];
                pixTs(ichannel).calibratedBackgroundPixelData(ipix).gapIndicators = [pixTs(ichannel).calibratedBackgroundPixelData(ipix).gapIndicators; pixelTimeSeriesSdf.channelData(ichannel).calibratedBackgroundPixelData(ipix).gapIndicators];
            end
            
            for ipix = 1:length(pixTs(ichannel).uncalibratedBackgroundPixelData)
                pixTs(ichannel).uncalibratedBackgroundPixelData(ipix).timeSeries    = [pixTs(ichannel).uncalibratedBackgroundPixelData(ipix).timeSeries;    pixelTimeSeriesSdf.channelData(ichannel).uncalibratedBackgroundPixelData(ipix).timeSeries];
                pixTs(ichannel).uncalibratedBackgroundPixelData(ipix).gapIndicators = [pixTs(ichannel).uncalibratedBackgroundPixelData(ipix).gapIndicators; pixelTimeSeriesSdf.channelData(ichannel).uncalibratedBackgroundPixelData(ipix).gapIndicators];
            end

        end


        for itarget = 1:length(pixelTimeSeriesSdf.channelData(ichannel).keplerIdTimeSeriesStruct)
            [timeSeries uncertainties gapIndicators] = get_pixel_data_internal(pixelTimeSeriesSdf, ichannel, itarget, isCalibrated);

            if ~isAppendingData
                if isCalibrated
                    pixTs(ichannel).keplerIdTimeSeriesStruct(itarget).timeSeries = timeSeries;
                    pixTs(ichannel).keplerIdTimeSeriesStruct(itarget).timeSeriesUncalibrated = [];
                else
                    pixTs(ichannel).keplerIdTimeSeriesStruct(itarget).timeSeries = [];
                    pixTs(ichannel).keplerIdTimeSeriesStruct(itarget).timeSeriesUncalibrated = timeSeries;
                end
                pixTs(ichannel).keplerIdTimeSeriesStruct(itarget).uncertainties = uncertainties;
                pixTs(ichannel).keplerIdTimeSeriesStruct(itarget).gapIndicators = gapIndicators;
            else
                if isCalibrated
                    pixTs(ichannel).keplerIdTimeSeriesStruct(itarget).timeSeries = [pixTs(ichannel).keplerIdTimeSeriesStruct(itarget).timeSeries;  timeSeries];
                    %pixTs(ichannel).keplerIdTimeSeriesStruct(itarget).timeSeriesUncalibrated = []; % not necessary, it's already a null vector
                else
                    %pixTs(ichannel).keplerIdTimeSeriesStruct(itarget).timeSeries = []; % not necessary, it's already a null vector
                    pixTs(ichannel).keplerIdTimeSeriesStruct(itarget).timeSeriesUncalibrated = [pixTs(ichannel).keplerIdTimeSeriesStruct(itarget).timeSeriesUncalibrated; timeSeries];
                end
                pixTs(ichannel).keplerIdTimeSeriesStruct(itarget).uncertainties = [pixTs(ichannel).keplerIdTimeSeriesStruct(itarget).uncertainties; uncertainties];
                pixTs(ichannel).keplerIdTimeSeriesStruct(itarget).gapIndicators = [pixTs(ichannel).keplerIdTimeSeriesStruct(itarget).gapIndicators; gapIndicators];
            end

        end
    end
return

function [timeSeries uncertainties gapIndicators] = get_pixel_data_internal(pixelTimeSeriesSdf, ichannel, itarget, isCalibrated)
    if isCalibrated
        numCadences = length(pixelTimeSeriesSdf.channelData(ichannel).keplerIdTimeSeriesStruct(itarget).timeSeries(1).array);
        numPixels   = length(pixelTimeSeriesSdf.channelData(ichannel).keplerIdTimeSeriesStruct(itarget).timeSeries);
    else
        numCadences = length(pixelTimeSeriesSdf.channelData(ichannel).keplerIdTimeSeriesStruct(itarget).timeSeriesUncalibrated(1).array);
        numPixels   = length(pixelTimeSeriesSdf.channelData(ichannel).keplerIdTimeSeriesStruct(itarget).timeSeriesUncalibrated);
    end

    timeSeries    = zeros(numCadences, numPixels);
    uncertainties = zeros(numCadences, numPixels);
    gapIndicators = zeros(numCadences, numPixels);

    for ipixel = 1:numPixels
        if isCalibrated
            timeSeriesForThisPixel    = pixelTimeSeriesSdf.channelData(ichannel).keplerIdTimeSeriesStruct(itarget).timeSeries(ipixel).array;
            uncertaintiesForThisPixel = pixelTimeSeriesSdf.channelData(ichannel).keplerIdTimeSeriesStruct(itarget).uncertainties(ipixel).array;
        else
            timeSeriesForThisPixel    = pixelTimeSeriesSdf.channelData(ichannel).keplerIdTimeSeriesStruct(itarget).timeSeriesUncalibrated(ipixel).array;
            uncertaintiesForThisPixel = zeros(size(timeSeriesForThisPixel));
        end
        gapIndicatorsForThisPixel = pixelTimeSeriesSdf.channelData(ichannel).keplerIdTimeSeriesStruct(itarget).gapIndicators(ipixel).array;
        
        timeSeries(:,ipixel)    = timeSeriesForThisPixel;
        uncertainties(:,ipixel) = uncertaintiesForThisPixel;
        gapIndicators(:,ipixel) = gapIndicatorsForThisPixel;
    end
return
