function time_series_struct = retrieve_target_time_series_uncalibrated(modules, outputs, start_mjd, end_mjd, get_long_cadence)
%
% The long/short cadence target time series extractor retrieves the original or
% calibrated time series of the long or short cadence target data for a
% specified mod/out for a given time interval.
%
% target_time_series_struct = retrieve_target_time_series_uncalibrated(modules, outputs, start_mjd, end_mjd)
% or
% target_time_series_struct = retrieve_target_time_series_uncalibrated(modules, outputs, start_mjd, end_mjd, get_long_cadence)
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
%   start_mjd               The MJD of the start of the desired time
%                           interval.  
%
%   end_mjd                 The MJD of the end of the desired time interval. 
%
%   get_long_cadence        Optional flag.  If 1, long cadence data is retrieved,
%                           if 0, short calibrated data is received.  Defaults to 1.
%
% OUTPUTS:
%
%     target_time_series_struct(nModOut):
%            module
%            output
%            mjdArray(nMjd)
%            isLongCadence
%            isOriginalData
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
    if nargin < 4 || nargin > 5
        error('MATLAB:SBT:wrapper:retrieve_target_time_series', ...
            'Wrong number of arguments, see help text.')
    end
    
    % Default get_long_cadence to 1:
    %
    if nargin < 5
        get_long_cadence = 1;
    end

    try
        % Verify args (implicitly done in convert_from_module_output):
        %
        channels = convert_from_module_output(modules, outputs);

        import gov.nasa.kepler.hibernate.tad.TargetCrud;
        target_crud = TargetCrud();

        for ichan = 1:length(modules)
            ccd_module = modules(ichan);
            ccd_output = outputs(ichan);

            time_series_struct(ichan) = do_channel(ccd_module, ccd_output, start_mjd, end_mjd, get_long_cadence, target_crud);
        end
        SandboxTools.close;
    catch
        SandboxTools.close;
        rethrow(lasterror)
    end
return




function one_channel_time_series_struct = do_channel(ccd_module, ccd_output, start_mjd, end_mjd, get_long_cadence, target_crud)
    import gov.nasa.kepler.fc.SbtFcOperations;
    import gov.nasa.kepler.fs.api.FileStoreClient;
    import gov.nasa.kepler.fs.api.FloatTimeSeries;
    import gov.nasa.kepler.fs.api.FsId;
    import gov.nasa.kepler.fs.client.FileStoreClientFactory;
    import gov.nasa.kepler.mc.fs.CalFsIdFactory;
    import gov.nasa.kepler.hibernate.tad.TargetTableLog;
    import gov.nasa.kepler.mc.TimeSeriesOperations;

    % Create a single instance of the output struct vector:
    %
    one_channel_time_series_struct = struct(...
        'module', ccd_module, ...
        'output', ccd_output, ...
        'mjdArray', [], ...
        'isLongCadence', get_long_cadence, ...
        'isOriginalData', 1, ... % uncalibrated
        'keplerIdTimeSeriesStruct', ...
            struct( ....
                'keplerId',             0, ...
                'row',                 [], ...
                'column',              [], ...
                'isInOptimalAperture', [], ...
                'timeSeries',          [], ...
                'uncertainties',       [], ...
                'gapIndicators',       []) );

    valid_mjds = get_cadence_mjds(start_mjd, end_mjd);
    start_cadence = valid_mjds(1).cadenceNumber;
    end_cadence   = valid_mjds(end).cadenceNumber;

    tsOps = TimeSeriesOperations();

    if get_long_cadence
        target_type = SbtFcOperations.getTargetType('LC');
    else
        target_type = SbtFcOperations.getTargetType('SC');
    end    
    targetTableLogs = target_crud.retrieveTargetTableLogs(target_type, start_cadence, end_cadence);

    for ittl = 0:targetTableLogs.size() - 1 % N.B. Java indexing
        lcLog = targetTableLogs.get(ittl);

        loop_start_cadence = lcLog.getCadenceStart();
        loop_end_cadence   = lcLog.getCadenceEnd();

        % Record the timestamps:
        %
        mjdToCadence = MjdToCadence(CadenceType.LONG);
        cadence_times = mjdToCadence.cadenceTimes(loop_start_cadence, loop_end_cadence);
        one_channel_time_series_struct.mjdArray = cadence_times.midTimestamps;

        % Get the background target table logs (necessary for the
        % ScienceTimeSeriesOperations object)
        %
        bkgLog = target_crud.retrieveTargetTableLogs(SbtFcOperations.getTargetType('BC'), loop_start_cadence, loop_end_cadence).get(0);

        % Get science time series ops object:
        %
        sciOps = ScienceTimeSeriesOperations(lcLog, bkgLog, ccd_module, ccd_output);
        sciOps.setTargetCrud(target_crud);


        % Get target defs, and extract the FS IDs for the pixels in them:
        %
        targetDefinitions = sciOps.getTargetDefinitions();

        for itargdef = 0:targetDefinitions.size()-1 % N.B. Java indexing

            if targetDefinition.getCcdModule() ~= ccd_module
                error('module mismatch!');
            end
            if targetDefinition.getCcdOutput() ~= ccd_output
                error('output mismatch!');
            end

            keplerId = targetDefinition.getKeplerId();
            one_channel_time_series_struct.keplerIdTimeSeriesStruct(itargdef).keplerId = keplerId;
            
            mask = targetDefinition.getMask();
            offsets = mask.getOffsets();

            fs_ids_data = [];
            for ioffset = 0:offsets.size()-1 % N.B. Java indexing
                row = offset.getRow() + targetDefinition.getReferenceRow();
                column = offset.getColumn() + targetDefinition.getReferenceColumn();

                one_channel_time_series_struct.keplerIdTimeSeriesStruct(itargdef).row(ioffset) = row;
                one_channel_time_series_struct.keplerIdTimeSeriesStruct(itargdef).column(ioffset) = column;
                
                fs_id = CalFsIdFactory.getTimeSeriesFsId( ...
                        PixelTimeSeriesType.SOC_CAL, SbtFcOperations.getTargetType('LC'), ...
                        ccd_module, ccd_output, ...
                        row, column);
                fs_ids_data(end+1) = fs_id;
            end

            % The name timeSerieses indicates multiple timeseries:
            %
            timeSeriesesData = tsOps.readPixelTimeSeriesAsFloat(fs_ids_data, loop_start_cadence, loop_end_cadence);
            
            if timeSeriesesData.length ~= length(fs_ids_data)
                error('timeSeriesesData/fs_ids length mismatch!');
            end
            
            for itimeseries = 1:timeSeriesesData.length
                one_channel_time_series_struct.keplerIdTimeSeriesStruct(itargdef).timeSeries(   :, itimeseries) = timeSeriesesData(itimeseries).fseries;
                one_channel_time_series_struct.keplerIdTimeSeriesStruct(itargdef).gapIndicators(:, itimeseries) = timeSeriesesData(itimeseries).getGapIndicators();
            end


        end
    end
    
return
