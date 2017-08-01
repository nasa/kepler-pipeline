function timeSeries = retrieve_ts(varargin)
%
% tsData = retrieve_ts(userFsIdPrefix, varargin)
%
% This script is a general purpose matlab-based retriever for time series in the filestore.
%
%
% INPUTS:
%       userFsIdPrefix -- A string describing the data to be extracted from
%                         the filestore.  Run "retrieve_ts()" (no
%                         arguments) to get the supported userFsIdPrefixes,
%                         or see below for examples.
%
%       varargin -- Different userFsIdPrefixes require different arguments.
%                   E.g., PrfCentroidRows requires a keplerIds vector and a
%                   start/stop cadence pair, but PaLcCosmicRayMeanEnergy
%                   takes a module/output pair and and start/stop cadence
%                   pair as arguments.  See the examples below for
%                   clarification.
%                      
%
% OUTPUTS:
%
%       tsData -- A struct (or array of structs, if a multiple-element
%                 array of kepler IDs is given as an input) with the
%                 following fields:
% 
%           data:       A N-element vector of the time series data,
%                          where N is the number of requested cadences.
%
%           gapIndicators: A N-element vector of the time series data,
%                          where N is the number of requested cadences.
%
%           startCadence: The first cadence requested.
%
%           endCadence: The last cadence requested.
%
%           validCadences: The inclusive range of valid cadences.
%
%           mjds: A N-element vector of the MJD midpoints of the the
%                 cadences startCadence-endCadence.
%
%
% Short Cadence Note:
%   Short cadence data can be extracted; the userFsIdPrefix is very similar
%   to the corresponding long cadence case.  Please run this script with no
%   arguments to generate a listing of both long and short cadence use 
%   cases.
%
% Examples:
%
%   Extract the PA flux time series and uncertainties for three keplerIds
%   for the first of 501 cadences and plot the ungapped data points with
%   errorbars:
%
%         keplerIds = [8413815 8348641 8480304];
%         startCadence = 0;
%         endCadence = 500;
%         tsFlux              = retrieve_ts('SapRawFluxLong',       keplerIds, startCadence, endCadence);
%         tsFluxUncertainties = retrieve_ts('SapRawFluxLongUncert', keplerIds, startCadence, endCadence);
%         errorbar(find(~tsFlux(1).gapIndicators), tsFlux(1).data(~tsFlux(1).gapIndicators), tsFluxUncertainties(1).data(~tsFluxUncertainties(1).gapIndicators))
%
%
%
%   Get the PA PRF centroid row values/uncertainties for three keplerIds for the first
%   501 cadences and plot the ungapped data with errorbars:
%         keplerIds = [8738591 8480097 8415474];
%         tsPrfCentRow       = retrieve_ts('PrfCentroidRows',       keplerIds, startCadence, endCadence);
%         tsPrfCentRowUncert = retrieve_ts('PrfCentroidRowsUncert', keplerIds, startCadence, endCadence);
%         errorbar(find(~tsPrfCentRow(1).gapIndicators), tsPrfCentRow(1).data(~tsPrfCentRow(1).gapIndicators), tsPrfCentRowUncert(1).data(~tsPrfCentRowUncert(1).gapIndicators))
%
%         tsPrfCentCol       = retrieve_ts('PrfCentroidCols',       keplerIds, startCadence, endCadence);
%         tsPrfCentColUncert = retrieve_ts('PrfCentroidColsUncert', keplerIds, startCadence, endCadence);
%         errorbar(find(~tsPrfCentCol(1).gapIndicators), tsPrfCentCol(1).data(~tsPrfCentCol(1).gapIndicators), tsPrfCentColUncert(1).data(~tsPrfCentColUncert(1).gapIndicators))
%
%
%
%   Get raw centroid rows/columns:
%         cols = retrieve_ts('CentroidCols', keplerIds, startCadence, endCadence);
%         rows = retrieve_ts('CentroidRows', keplerIds, startCadence, endCadence);
%         rowData = [rows.data];  colData = [cols.data];
%         rowGaps = [rows.gapIndicators];  colGaps = [cols.gapIndicators];
%         plot(rowData(~rowGaps), colData(~colGaps), 'x');
%
% Get PPA covariance matrices:
%        ts = retrieve_ts('PpaMaxAttitudeFocalPlaneResidual', 0, 400); plot([ts.mjds.mjdMidTime], ts.tseries(~ts.gapIndicators));
%        ts = retrieve_ts('PpaCovarianceMatrix11', 0, 400); plot([ts.mjds.mjdMidTime], ts.tseries(~ts.gapIndicators));
%        ts = retrieve_ts('PpaCovarianceMatrix12', 0, 400); plot([ts.mjds.mjdMidTime], ts.tseries(~ts.gapIndicators));
%        ts = retrieve_ts('PpaCovarianceMatrix13', 0, 400); plot([ts.mjds.mjdMidTime], ts.tseries(~ts.gapIndicators));
%        ts = retrieve_ts('PpaCovarianceMatrix22', 0, 400); plot([ts.mjds.mjdMidTime], ts.tseries(~ts.gapIndicators));
%        ts = retrieve_ts('PpaCovarianceMatrix23', 0, 400); plot([ts.mjds.mjdMidTime], ts.tseries(~ts.gapIndicators));
%        ts = retrieve_ts('PpaCovarianceMatrix33', 0, 400); plot([ts.mjds.mjdMidTime], ts.tseries(~ts.gapIndicators));
%
%
% Run the script with no args to get help on the contents of varargin.
%
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

    import gov.nasa.kepler.systest.sbt.SbtRetrieveTimeSeries;
    sbt = SbtRetrieveTimeSeries();

    if isempty(varargin)
        display(sbt.mnemonics());
        timeSeries = [];
        return
    end
    fsIdKey = varargin{1};
    
    
    if strcmp(fsIdKey, 'user_specified_fs_ids')
        fsIdNames = varargin{2};
        isFloat = logical(strcmp(varargin{3}, 'ts'));

        startCadence = int32(varargin{4});
        endCadence = int32(varargin{5});
        
        javaNames = javaArray('java.lang.String', length(fsIdNames));
        for i=1:length(fsIdNames)
            javaNames(i) = java.lang.String(fsIdNames(i));
        end
        
        pathJava = sbt.retrieveSpecificFsIds(javaNames, startCadence, endCadence, isFloat);
    else
        startArgs = 2;
        endArgs = nargin - 2;
        args = packageArgsInListOfLists(varargin{startArgs:endArgs});
        startCadence = int32(varargin{end-1});
        endCadence = int32(varargin{end});
        
        pathJava = sbt.retrieveTimeSeries(fsIdKey, args, startCadence, endCadence);
    end
    
    path = pathJava.toCharArray()';
    
    timeSeries = [];
    ts = sbt_sdf_to_struct(path);
    %this is probably a safe assumption since mixing difference cadence
    %types is bad.  TODO:  Check that the user has not requested 
    %different cadence types.
    mjds = get_mjds(startCadence, endCadence, sbt.cadenceTypeForMnemonic(fsIdKey));
    
    if ~isempty(ts)
        
        
        % Move the float/int data into the .data field and remove the
        % java  fields. This makes the output simpler for the matlab user.
        %
        for ii = 1:length(ts.timeSeries)
            if ts.timeSeries(ii).isFloat
                ts.timeSeries(ii).data = ts.timeSeries(ii).fdata;
            else
                ts.timeSeries(ii).data = ts.timeSeries(ii).idata;
            end
            ts.timeSeries(ii).mjds = mjds;
        end
        timeSeries = [];
        if ~isempty(ts.timeSeries)
            timeSeries = rmfield(ts.timeSeries, {'fdata', 'idata'});
        end
    end
    
    SandboxTools.close;
return

function mjds = get_mjds(startCadence, endCadence, cadenceType)
% Get the mjds using the SDF-based retrieve_cadence_logs:
    cadenceType = char(cadenceType.toLowerCase());
    isLongCadence = false;
    if strcmp(cadenceType, 'long')
        isLongCadence = true;
    end
    cadenceLogs = retrieve_cadence_logs(isLongCadence, startCadence, endCadence, true);
    mjds = [cadenceLogs.mjdMidTime]';
return

function rightArgs = packageArgsInListOfLists(varargin) 
    import java.lang.Object;
    import java.util.ArrayList;
    
    rightArgs = ArrayList();
    for ii = 1:nargin
        ithArg = ArrayList();

        if ischar(varargin{ii})
            ithArg.add(varargin{ii});
        else
            for jj = 1:length(varargin{ii})
                ithArg.add(varargin{ii}(jj));
            end
        end
        
        rightArgs.add(ithArg);
    end
return
