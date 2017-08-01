function motion_polys = retrieve_motion_polys(startMjd, endMjd, varargin)
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% motion_poly_struct = retrieve_motion_polys(startMjd, endMjd)
%  or
% motion_poly_struct = retrieve_motion_polys(startMjd, endMjd, isLongCadence)
%  or
% motion_poly_struct = retrieve_motion_polys(startMjd, endMjd, ccdModules, ccdOutputs)
%  or
% motion_poly_struct = retrieve_motion_polys(startMjd, endMjd, ccdModules, ccdOutputs, isLongCadence)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% This script retrieves the motion polynomial data for an input range of MJDs,
% and an optional list of module/outputs.  If only MJDs are given as arguments,
% data for all 84 module/outputs will be returned.
%
%
%
% INPUTS:
%
%   startMjd:   The start MJD for the desired time range.
%
%   endMjd:     The end MJD for the desired time range.
%
%   (Optional) ccdModules:  A vector of CCD module number. 
%                            Must be given if ccdOutputs is given,
%                            and must be the same length as ccdOutputs.
%
%   (Optional) ccdOutputs:  A vector of CCD output number.  
%                            Must be given if ccdModules is given, 
%                            and must be the same length as ccdModules.
%
%   (Optional) isLongCadence: A flag specifying if the data to be retrieved is for long or short cadence data.
%                               Defaults to 1 (long cadence).  To specify short cadence, use 0.
%
%
% OUTPUTS:
%
%       motion_poly_struct:  nModOut x nCadences of structures with the
%                            following fields:
%
%           .cadence = cadence #
%
%           .mjdStartTime  = the mjd of the start of the cadence 
%
%           .mjdMidTime    = the mjd of the midpoint of the cadence
%
%           .mjdEndTime    = the mjd of the end of the cadence
%
%           .module = module #
%
%           .output = output #
%
%           .rowPoly = row polynomial structure,
%                      see help for weighted_polyfit2d for details.
%
%           .rowPolyStatus = flag indicating good or bad status of rowPoly.
%
%           .colPoly = column polynomial structure.
%
%           .colPolyStatus = flag indicating good or bad status of colPoly.
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

    import gov.nasa.kepler.common.FcConstants;
    import gov.nasa.kepler.mc.blob.BlobOperations;

    % Define constants for date checking:
    %
    LOW_MJD =  54000;
    HIGH_MJD = 64000;
    LOW_MJD_LIMIT  = sprintf('>= %d', LOW_MJD);
    HIGH_MJD_LIMIT = sprintf('<= %d', HIGH_MJD);

    % Validate number of arguments
    %
    if nargin < 2 || nargin > 5
        error('MATLAB:SBT:wrapper:retrieve_motion_poly', ...
              'The retrieve_motion_poly tool must be called with 2, 3, 4, or 5 arguments, %d were given.  See help text.', nargin);
    end

    % Use library code to validate module/output arguments: the
    % convert_from_module_output routine validates these arguments. 
    %
    if nargin == 4 || nargin == 5
        ccdModules = varargin{1};
        ccdOutputs = varargin{2};
        channels = convert_from_module_output(ccdModules, ccdOutputs);
    else 
        num_channels = FcConstants.nModules * FcConstants.nOutputsPerModule;
        channels = 1:num_channels;
    end

    % Use isLongCadence arg, if given, otherwise default to 1.
    %
    if nargin == 3 || nargin == 5
        isLongCadence = varargin{end};
    else 
        isLongCadence = 1;
    end

    % Validate input MJDs
    %
    fieldsAndBounds = {'startMjd'; LOW_MJD_LIMIT;  HIGH_MJD_LIMIT;  []};
    validate_field(startMjd, fieldsAndBounds, 'MATLAB:SBT:wrapper:retrieve_ancillary_data:invalidInput');
    fieldsAndBounds = {'endMjd'; LOW_MJD_LIMIT;  HIGH_MJD_LIMIT;  []};
    validate_field(endMjd, fieldsAndBounds, 'MATLAB:SBT:wrapper:retrieve_ancillary_data:invalidInput');

         
    % Get the start/middle/end MJDs of the cadences of the input MJD vector
    all_mjds = get_cadence_mjds(startMjd, endMjd, isLongCadence);
    
    % Create a single copy of the struct that will populate the output
    % matrix:
    %
    motion_polys = struct(  ...
           'cadence',       0, ... % cadence #
           'mjd',           0, ... % mjd of the cadence
           'module',        0, ... % module #
           'output',        0, ... % output #
           'rowPoly',       0, ... % row polynomial structure, see help for weighted_polyfit2d for details.
           'rowPolyStatus', 0, ... % flag indicating good or bad status of rowPoly.
           'colPoly',       0, ... % column polynomial structure.
           'colPolyStatus', 0);    % flag indicating good or bad status of colPoly.


    
    % Create output matrix of structs by duplicating one_motion_poly:
    %
    motion_polys = repmat(motion_polys, length(channels), length(all_mjds));
    blobOperations = BlobOperations();%DatabaseServiceFactory.getInstance());

    % Loop over channel/cadence combinations, record the motion polynomial 
    % for each combo. 
    %
    for ichannel = 1:length(channels)
        [ccdModule ccdOutput] = convert_to_module_output(channels(ichannel));
        x = clock; msg = sprintf('working on mod %d out %d; %02d:%02d', ccdModule, ccdOutput, x(4), x(5)); disp(msg);
        
        % Get the motion coeff polynomial metadata for this mod/out/cadence:
        %
        startCadence = all_mjds(1).cadenceNumber;
        endCadence = all_mjds(end).cadenceNumber;
        %x = clock; msg = sprintf('\tstart java call; %02d:%02d', x(4), x(5)); disp(msg);
        polyBlobSeriesJava = blobOperations.retrieveMotionBlobFileSeries(ccdModule, ccdOutput, startCadence, endCadence);
        %x = clock; msg = sprintf('\tdone java call; %02d:%02d', x(4), x(5)); disp(msg);
        
        pbsBlobIndices = polyBlobSeriesJava.blobIndices;
        pbsGapIndicators =  polyBlobSeriesJava.gapIndicators;
        pbsStartCadence = polyBlobSeriesJava.startCadence;
        pbsEndCadence = polyBlobSeriesJava.endCadence;
        filenames = polyBlobSeriesJava.blobFilenames;
        if isempty(filenames)
            warning('Skipping module %d output %d-- no blob filenames returned for time range %f - %f', ccdModule, ccdOutput, startMjd, endMjd);
            continue;
        end
        
        polyBlobSeries = struct('blobIndices',   [], ... 
                                'gapIndicators', [], ...
                                'blobFilenames', {}, ...
                                'startCadence',  [], ... 
                                'endCadence',    []);
        polyBlobSeries(1).blobIndices = pbsBlobIndices;
        polyBlobSeries(1).gapIndicators = pbsGapIndicators;
        polyBlobSeries(1).startCadence = pbsStartCadence;
        polyBlobSeries(1).endCadence = pbsEndCadence;
        for iname = 1:polyBlobSeriesJava.blobFilenames.length
            polyBlobSeries(1).blobFilenames{iname} = filenames(iname);
        end

        %x = clock; msg = sprintf('\tstart poly_blob_series_to_struct call; %02d:%02d', x(4), x(5)); disp(msg);
        %polyBlobSeries
        polyStruct = poly_blob_series_to_struct(polyBlobSeries, startCadence, endCadence);
        %x = clock; msg = sprintf('\tend poly_blob_series_to_struct call; %02d:%02d', x(4), x(5)); disp(msg);
        length_mjds = length(all_mjds);

        for imjd = 1:length(all_mjds)
            loop_mjd = all_mjds(imjd);
            
            % Set time fields:
            %
            motion_polys(ichannel, imjd).mjdStartTime  = loop_mjd.mjdStartTime;
            motion_polys(ichannel, imjd).mjdMidTime    = loop_mjd.mjdMidTime;
            motion_polys(ichannel, imjd).mjdEndTime    = loop_mjd.mjdEndTime;
            motion_polys(ichannel, imjd).cadence       = loop_mjd.cadenceNumber;

            % Set mod/out for output struct:
            %
            motion_polys(ichannel, imjd).module = ccdModule;
            motion_polys(ichannel, imjd).output = ccdOutput;
            
            motion_polys(ichannel, imjd).rowPoly       = polyStruct(imjd).rowPoly;
            motion_polys(ichannel, imjd).rowPolyStatus = polyStruct(imjd).rowPolyStatus;
            motion_polys(ichannel, imjd).colPoly       = polyStruct(imjd).colPoly;
            motion_polys(ichannel, imjd).colPolyStatus = polyStruct(imjd).colPolyStatus;
        end
    end

    import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
    dbInstance = DatabaseServiceFactory.getInstance();
    dbInstance.clear();
SandboxTools.close;
return
