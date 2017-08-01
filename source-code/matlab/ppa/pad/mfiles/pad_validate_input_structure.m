function pad_validate_input_structure(padInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pad_validate_input_structure(padInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function first checks for the presence of expected fields in the input
% structure, then checks whether each parameter is within the appropriate
% range.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:  A data structure 'padInputStruct' with the following fields:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level
%
%     padInputStruct contains the following fields:
%
%                            cadenceTimes: [struct]  cadence times and gap indicators
%                     padModuleParameters: [struct]  module parameters for PAD
%                             fcConstants: [struct]  focal plane constants
%              spacecraftConfigMaps: [struct array]  one or more spacecraft config maps
%                          raDec2PixModel: [struct]  ra-dec to pixel model
%                  motionPolyStruct: [struct array]  motion polynomials structures 
%
%--------------------------------------------------------------------------
%   Second level
%
%     cadenceTimes is a struct with the following fields:
%
%          startTimestamps: [double array]  cadence start times, MJD
%            midTimestamps: [double array]  cadence mid times, MJD
%            endTimestamps: [double array]  cadence end times, MJD
%           gapIndicators: [logical array]  true if cadence is unavailable
%          requantEnabled: [logical array]  true if requantization was enabled
%
%--------------------------------------------------------------------------
%   Second level
%
%     padModuleParameters is a struct with the following fields:
%
%                      gridRowStart: [int]  start of row    of grid for grid of fake target stars
%                        gridRowEnd: [int]  end   of row    of grid for grid of fake target stars
%                      gridColStart: [int]  start of column of grid for grid of fake target stars
%                        gridColEnd: [int]  end   of column of grid for grid of fake target stars
%                       alertTime: [float]  number of days at the end of valid time duration for alert generation
%                     horizonTime: [float]  number of days for trend prediction
%                    trendFitTime: [float]  number of days at the end of valid time duration for trend fit
%       initialAverageSampleCount: [float]  number of samples for inititial average
%          minTrendFitSampleCount: [float]  minimum number of samples for trend fit
%          deltaRaSmoothingFactor: [float]  smoothing  factor of delta ra
%          deltaRaFixedLowerBound: [float]  fixed lower bound of delta ra
%          deltaRaFixedUpperBound: [float]  fixed upper bound of delta ra
%          deltaRaAdaptiveXFactor: [float]  adaptive bound X factor of delta ra
%         deltaDecSmoothingFactor: [float]  smoothing  factor of delta dec 
%         deltaDecFixedLowerBound: [float]  fixed lower bound of delta dec
%         deltaDecFixedUpperBound: [float]  fixed upper bound of delta dec   
%         deltaDecAdaptiveXFactor: [float]  adaptive bound X factor of delta dec
%        deltaRollSmoothingFactor: [float]  smoothing  factor of delta roll  
%        deltaRollFixedLowerBound: [float]  fixed lower bound of delta roll 
%        deltaRollFixedUpperBound: [float]  fixed upper bound of delta roll
%        deltaRollAdaptiveXFactor: [float]  adaptive bound X factor of delta roll
%                        debugLevel: [int]  debug level of PAD
%               plottingEnabled: [logical]  flag indicating plot is enabled
%
%--------------------------------------------------------------------------
%   Second level
%
%     motionBlobs is blob series with the following fields:
%   
%           blobIndices: [float array]  blob indices
%       gapIndicators: [logical array]  blob gap indicators
%              blobFilenames: [string]  blob filenames
%                  startCadence: [int]  start cadence index
%                    endCadence: [int]  end   cadence index
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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


if nargin == 0
    % generate error and return
    error('PAD:padInputStruct:EmptyInputStruct', 'The function must be called with an input structure.')
end

%______________________________________________________________________
% top level validation
% check for the presence of top level fields in padInputStruct
%______________________________________________________________________

% padInputStruct fields
fieldsAndBounds = cell(6,4);
fieldsAndBounds(1,:)  = { 'cadenceTimes';           []; []; [] };       % structure
fieldsAndBounds(2,:)  = { 'padModuleParameters';    []; []; [] };       % structure
fieldsAndBounds(3,:)  = { 'fcConstants';            []; []; [] };       % structure, validate only needed fields
fieldsAndBounds(4,:)  = { 'spacecraftConfigMaps';   []; []; [] };       % structure array, do not validate
fieldsAndBounds(5,:)  = { 'raDec2PixModel';         []; []; [] };       % structure, validate only needed fields
fieldsAndBounds(6,:)  = { 'motionPolyStruct';       []; []; [] };       % structure array

validate_structure(padInputStruct, fieldsAndBounds, 'padInputStruct');

clear fieldsAndBounds;

%--------------------------------------------------------------------------
% second level validation.
% validate the fields in padInputStruct.cadenceTimes
%--------------------------------------------------------------------------

% padInputStruct.cadenceTimes fields
fieldsAndBounds = cell(5,4);

fieldsAndBounds(1,:)   = { 'startTimestamps';   [];     []; 	[] };
fieldsAndBounds(2,:)   = { 'midTimestamps';     [];     [];     [] };
fieldsAndBounds(3,:)   = { 'endTimestamps';     [];     [];     [] };
fieldsAndBounds(4,:)   = { 'gapIndicators';     [];     [];     [true; false] };
fieldsAndBounds(5,:)   = { 'requantEnabled';    [];     [];     [true; false] };

validate_structure(padInputStruct.cadenceTimes, fieldsAndBounds, 'padInputStruct.cadenceTimes');

cadenceTimes = padInputStruct.cadenceTimes;
cadenceTimes.startTimestamps = cadenceTimes.startTimestamps(~cadenceTimes.gapIndicators);
cadenceTimes.midTimestamps   = cadenceTimes.midTimestamps(~cadenceTimes.gapIndicators);
cadenceTimes.endTimestamps   = cadenceTimes.endTimestamps(~cadenceTimes.gapIndicators);

fieldsAndBounds = cell(3,4);

fieldsAndBounds(1,:)   = { 'startTimestamps';   '>= 54000';     '<= 64000'; 	[] };
fieldsAndBounds(2,:)   = { 'midTimestamps';     '>= 54000';     '<= 64000';     [] }; 
fieldsAndBounds(3,:)   = { 'endTimestamps';     '>= 54000';     '<= 64000';     [] };

validate_structure(cadenceTimes, fieldsAndBounds, 'padInputStruct.cadenceTimes');

clear fieldsAndBounds;

%______________________________________________________________________
% second level validation
% validate the fields in padInputStruct.padModuleParameters  
%______________________________________________________________________

fieldsAndBounds = cell(23,4);
fieldsAndBounds( 1,:)  = { 'gridRowStart';                      '>= 0';     '< 1070';   [] };
fieldsAndBounds( 2,:)  = { 'gridRowEnd';                        '>= 0';     '< 1070';   [] };
fieldsAndBounds( 3,:)  = { 'gridColStart';                      '>= 0';     '< 1132';   [] };
fieldsAndBounds( 4,:)  = { 'gridColEnd';                        '>= 0';     '< 1132';   [] };

fieldsAndBounds( 5,:)  = { 'horizonTime';                       '>= 0';     '<= 100';   [] }; 
fieldsAndBounds( 6,:)  = { 'trendFitTime';                      '>= 0';     '<= 30';    [] };
fieldsAndBounds( 7,:)  = { 'minTrendFitSampleCount';            '>= 0';     '<= 500';   [] };
fieldsAndBounds( 8,:)  = { 'initialAverageSampleCount';         '>= 0';     '<= 500';   [] };
fieldsAndBounds( 9,:)  = { 'alertTime';                         '>= 0';     '<= 30';    [] };

fieldsAndBounds(10,:)  = { 'deltaRaSmoothingFactor';            '>=  0';    '<= 1';     [] };
fieldsAndBounds(11,:)  = { 'deltaRaFixedLowerBound';            '>= -1';    '<= 1';     [] };
fieldsAndBounds(12,:)  = { 'deltaRaFixedUpperBound';            '>= -1';    '<= 1';     [] };
fieldsAndBounds(13,:)  = { 'deltaRaAdaptiveXFactor';            '>=  0';    '<= 10';    [] };

fieldsAndBounds(14,:)  = { 'deltaDecSmoothingFactor';           '>=  0';    '<= 1';     [] };
fieldsAndBounds(15,:)  = { 'deltaDecFixedLowerBound';           '>= -1';    '<= 1';     [] };
fieldsAndBounds(16,:)  = { 'deltaDecFixedUpperBound';           '>= -1';    '<= 1';     [] };
fieldsAndBounds(17,:)  = { 'deltaDecAdaptiveXFactor';           '>=  0';    '<= 10';    [] };

fieldsAndBounds(18,:)  = { 'deltaRollSmoothingFactor';          '>=  0';    '<= 1';     [] };
fieldsAndBounds(19,:)  = { 'deltaRollFixedLowerBound';          '>= -1';    '<= 1';     [] };
fieldsAndBounds(20,:)  = { 'deltaRollFixedUpperBound';          '>= -1';    '<= 1';     [] };
fieldsAndBounds(21,:)  = { 'deltaRollAdaptiveXFactor';          '>=  0';    '<= 10';    [] };

fieldsAndBounds(22,:)  = { 'debugLevel';                        '>= 0';     '<= 5';     [] };
fieldsAndBounds(23,:)  = { 'plottingEnabled';                   [];         [];         [true false] };

validate_structure(padInputStruct.padModuleParameters, fieldsAndBounds, 'padInputStruct.padModuleParameters');

clear fieldsAndBounds;

%______________________________________________________________________
% second level validation
% validate the fields in padInputStruct.fcConstants (validate only needed fields)
%______________________________________________________________________

fieldsAndBounds = cell(1,4);
fieldsAndBounds( 1,:) = { 'MODULE_OUTPUTS';         '== 84';    [];    [] };

validate_structure(padInputStruct.fcConstants, fieldsAndBounds, 'padInputStruct.fcConstants');

clear fieldsAndBounds;

%______________________________________________________________________
% second level validation
% validate the fields in padInputStruct.raDec2PixModel (validate only needed fields)
%______________________________________________________________________
                  
fieldsAndBounds = cell(10,4);
fieldsAndBounds( 1,:) = { 'mjdStart';                           '>= 54000';     '<= 64000'; [] };
fieldsAndBounds( 2,:) = { 'mjdEnd';                             '>= 54000';     '<= 64000'; [] };
fieldsAndBounds( 3,:) = { 'spiceFileDir';                       [];             [];         [] };
fieldsAndBounds( 4,:) = { 'spiceSpacecraftEphemerisFilename';   [];             [];         [] };
fieldsAndBounds( 5,:) = { 'planetaryEphemerisFilename';         [];             [];         [] };
fieldsAndBounds( 6,:) = { 'leapSecondFilename';                 [];             [];         [] };
fieldsAndBounds( 7,:) = { 'pointingModel';                      [];             [];         [] };
fieldsAndBounds( 8,:) = { 'geometryModel';                      [];             [];         [] };
fieldsAndBounds( 9,:) = { 'rollTimeModel';                      [];             [];         [] };
fieldsAndBounds(10,:) = { 'mjdOffset';                          '== 2400000.5'; [];         [] };

validate_structure(padInputStruct.raDec2PixModel, fieldsAndBounds, 'padInputStruct.raDec2PixModel');

clear fieldsAndBounds;

%______________________________________________________________________
% second level validation
% validate the fields in padInputStruct.motionBlobs
%______________________________________________________________________

% padInputStruct.motionBlobs fields
% fieldsAndBounds = cell(5,4);
% fieldsAndBounds( 1,:)  = { 'blobIndices';            [];         [];         [] };                  
% fieldsAndBounds( 2,:)  = { 'gapIndicators';          [];         [];         [true false] };
% fieldsAndBounds( 3,:)  = { 'blobFilenames';          [];         [];         [] };                  
% fieldsAndBounds( 4,:)  = { 'startCadence';           [];         [];         [] };
% fieldsAndBounds( 5,:)  = { 'endCadence';             [];         [];         [] };
% 
% for i=1:size(padInputStruct.motionBlobs,1)
%     for j=1:size(padInputStruct.motionBlobs,2)
%         validate_structure(padInputStruct.motionBlobs(i,j), fieldsAndBounds, 'padInputStruct.motionBlobs');
%     end
% end
% 
% clear fieldsAndBounds;

%______________________________________________________________________
% second level validation
% validate the fields in padInputStruct.motionPolyStruct
%______________________________________________________________________

% padInputStruct.motionPolyStruct fields
fieldsAndBounds = cell(10,4);
fieldsAndBounds( 1,:)  = { 'cadence';               '>= -1';    '< 2e7';    [] };
fieldsAndBounds( 2,:)  = { 'mjdStartTime';          '>= -1';    '<= 64000'; [] };
fieldsAndBounds( 3,:)  = { 'mjdMidTime';            '>= -1';    '<= 64000'; [] };
fieldsAndBounds( 4,:)  = { 'mjdEndTime';            '>= -1';    '<= 64000'; [] };
fieldsAndBounds( 5,:)  = { 'module';                [];         [];         '[-1 2:4, 6:20, 22:24]''' };
fieldsAndBounds( 6,:)  = { 'output';                [];         [];         '[-1 1 2 3 4]''' };
fieldsAndBounds( 7,:)  = { 'rowPoly';               [];         [];         [] };                  % a structure
fieldsAndBounds( 8,:)  = { 'rowPolyStatus';         [];         [];         '[0 1]''' };
fieldsAndBounds( 9,:)  = { 'colPoly';               [];         [];         [] };                  % a structure
fieldsAndBounds(10,:)  = { 'colPolyStatus';         [];         [];         '[0 1]''' };

for i=1:size(padInputStruct.motionPolyStruct,1)
    for j=1:size(padInputStruct.motionPolyStruct,2)
        validate_structure(padInputStruct.motionPolyStruct(i,j), fieldsAndBounds, 'padInputStruct.motionPolyStruct');
    end
end

clear fieldsAndBounds;

%______________________________________________________________________
% third level validation
% validate the fields in padInputStruct.motionPolyStruct.rowPoly and padInputStruct.motionPolyStruct.colPoly
%______________________________________________________________________

% padInputStruct.motionPolyStruct.rowPoly   
% padInputStruct.motionPolyStruct.colPoly fields
fieldsAndBounds = cell(13,4);
fieldsAndBounds(1,:)  = { 'offsetx';    [];     [];     '0'};
fieldsAndBounds(2,:)  = { 'scalex';     '>= 0'; [];     []};
fieldsAndBounds(3,:)  = { 'originx';    [];     [];     []};
fieldsAndBounds(4,:)  = { 'offsety';    [];     [];     '0'};
fieldsAndBounds(5,:)  = { 'scaley';     '>= 0'; [];     []};
fieldsAndBounds(6,:)  = { 'originy';    [];     []; 	[]};
fieldsAndBounds(7,:)  = { 'xindex';     [];     [];     '-1'};
fieldsAndBounds(8,:)  = { 'yindex';     [];     [];     '-1'};
fieldsAndBounds(9,:)  = { 'type';       [];     [];     {'standard'}};
fieldsAndBounds(10,:) = { 'order';      '>= 0'; '< 10'; []};
fieldsAndBounds(11,:) = { 'message';    [];     [];     {}};
fieldsAndBounds(12,:) = { 'coeffs';     [];     [];     []};    % TBD
fieldsAndBounds(13,:) = { 'covariance'; [];     [];     []};    % TBD
 
for i=1:size(padInputStruct.motionPolyStruct,1)
    for j=1:size(padInputStruct.motionPolyStruct,2)
        if ( padInputStruct.motionPolyStruct(i,j).rowPolyStatus )
            validate_structure(padInputStruct.motionPolyStruct(i,j).rowPoly, fieldsAndBounds, 'padInputStruct.motionPolyStruct.rowPoly');
        end
        if ( padInputStruct.motionPolyStruct(i,j).colPolyStatus )
            validate_structure(padInputStruct.motionPolyStruct(i,j).colPoly, fieldsAndBounds, 'padInputStruct.motionPolyStruct.colPoly');
        end
    end
end

clear fieldsAndBounds;

%------------------------------------------------------------

return
