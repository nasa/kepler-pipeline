function twoDBlackData = retrieve_two_d_black_model(module, output, startMjd, endMjd, rows, cols)
% function twoDBlackData = retrieve_two_d_black_model(module, output, startMjd, endMjd, rows, cols)
% or
% function twoDBlackData = retrieve_two_d_black_model(module, output, startMjd, endMjd)
% or
% function twoDBlackData = retrieve_two_d_black_model(module, output)
% 
% Returns a matlab TwoDBlackData object that contains data necessary to
% determine the TwoDBlack for any time between startMjd and endMjd.
%
% Rows and cols input args should be one-based.
%
% The date are the mean black level for each module output in DN.
% The scalar black levels were measured at realistic flight temperatures
% and should give a good measure of the black leavel for each module/output.
% 
% The six-arg call gets only the pixels on that module/output specified by the row/col vectors (pixels specified pairwise) for the specified time range.
% The four-arg call gets full images for that module/output for the specified time range
% The two-arg call gets full images for that module/output for the entire mission.
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

    if nargin ~= 2 && nargin ~= 4 && nargin ~= 6
        error('bad number of args in retrieve_two_d_black_model: usage is retrieve_two_d_black_model(module, output, [mjdStart, mjdEnd, [rows, cols]])');
    end

    if 6 == nargin && (length(rows) ~= length(cols))
        error('Rows and cols must be same length, if pixels are specified.');
    end

    % Instantiate an operations object:
    %
    import gov.nasa.kepler.fc.TwoDBlackModel;
    import gov.nasa.kepler.fc.twodblack.TwoDBlackOperations;
    ops = TwoDBlackOperations();
    
    % Retrieve a model, using the operations object:
    %
    if nargin == 6
        twoDBlackModel = ops.retrieveTwoDBlackModel(startMjd, endMjd, module, output, rows - 1, cols - 1); %N.B.: -1 for java indexing
    elseif nargin == 4
        twoDBlackModel = ops.retrieveTwoDBlackModel(startMjd, endMjd, module, output);
        rows = [];
        cols = [];
    elseif nargin == 2
        twoDBlackModel = ops.retrieveMostRecentTwoDBlackModel(module, output);
        rows = [];
        cols = [];
    end
    
    twoDBlackData = struct(  ...
        'mjds',          [], ...
        'rows',          [], ...
        'columns',       [], ...
        'blacks',        [], ...
        'uncertainties', [], ...
        'ccdRows',     twoDBlackModel.getCcdRows(), ...
        'ccdColumns',  twoDBlackModel.getCcdColumns());

    twoDBlackData.mjds          = unique(twoDBlackModel.getMjds());
    twoDBlackData.rows          = rows - 1; % transform to Java-based pixel coords to match the module interface
    twoDBlackData.columns       = cols - 1; % transform to Java-based pixel coords to match the module interface

    % Mimic .array.array construction that comes out of Persistent code:
    %
    blacks        = twoDBlackModel.getBlacks();
    uncertainties = twoDBlackModel.getUncertainties();
    
    nTimes = length(twoDBlackData.mjds);
    
    for itime=1:nTimes
        blackForTime = squeeze(blacks(itime, :, :));
        uncertaintiesForTime = squeeze(uncertainties(itime, :, :));
        
        if nargin == 6
            nPix = size(blackForTime, 1);
            for ipix = 1:nPix
                twoDBlackData.blacks(itime).array(1).array(ipix) = blackForTime(ipix);
                twoDBlackData.uncertainties(itime).array(1).array(ipix) = uncertaintiesForTime(ipix);
            end
        else
            nRows = size(blackForTime, 1);
            for irow = 1:nRows
                twoDBlackData.blacks(itime).array(irow).array = blackForTime(irow, :);
                twoDBlackData.uncertainties(itime).array(irow).array = uncertaintiesForTime(irow, :);
            end
        end
    end

    import gov.nasa.kepler.hibernate.fc.HistoryModelName    
    twoDBlackData.fcModelMetadata = get_model_metadata(twoDBlackModel.getFcModelMetadata);
    
    import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
    dbInstance = DatabaseServiceFactory.getInstance();
    dbInstance.clear();
SandboxTools.close;
return
