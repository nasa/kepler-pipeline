function [ headers, formatString ] = retrieve_tip_column_headers_and_format()
%
% function [ headers, formatString, nNominalColumns ] = retrieve_tip_column_headers_and_format()
% 
% This function provides a single source for the TIP simulated transits parameter text file column headings and numeric format string.
% INPUT:    (empty)
% OUTPUT:   headers         == cell array of strings containing column headings
%           formatString    == cell array of format strings for a single row in the TIP text file
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


% define header names here
headers = {'keplerId',...
            'transitDepthPpm',...
            'transitDurationHours',...
            'orbitalPeriodDays',...
            'epochBjd',...
            'eccentricity',...
            'longitudeOfPeriDegrees',...
            'transitSeparationDays',...
            'transitOffsetEnabled',...
            'transitOffsetDepthPpm',...
            'transitOffsetArcsec',...
            'transitOffsetPhase',...
            'skyOffsetRaArcSec',...
            'skyOffsetDecArcSec',...
            'sourceOffsetRaHours',...
            'sourceOffsetDecDegrees',...
            'semiMajorAxisOverRstar',...
            'RplanetOverRstar',...
            'planetRadiusREarth',...
            'impactParameter',...
            'stellarRadiusRsun',...
            'stellarMassMsun',...
            'stellarLog10Gravity',...
            'stellarEffectiveTempKelvin',...
            'stellarLog10Metalicity',...
            'transitBufferCadences',...
            'singleEventStatistic',...
            'normalizedEpochPhase'};


% define numeric format string for line of text output
formatString = {'%10i',...              % keplerId                       % custom targets have 9 digits
                '%18.8f',...            % transitDepthPpm                % 36uppm resolution
                '%18.8f',...            % transitDurationHours           % 36ums resolution
                '%18.8f',...            % orbitalPeriodDays              % 0.8ms resolution
                '%18.8f',...            % epochBjd                       % 0.8ms resolution
                '%12.8f',...            % eccentricity                   % [0 1] 8 digits of resoltion should be plenty
                '%12.8f',...            % longitudeOfPeriDegrees         % [-180 180] it's an angle in degrees right?
                '%18.8f',...            % transitSeparationDays          % 0.8ms resolution
                '%2i',...               % transitOffsetEnabled           % it's a boolean so this is extreme overkill
                '%12.2f',...            % transitOffsetDepthPpm          % 100% transit on background is 1000000 ppm - 7 digits
                '%12.8f',...            % transitOffsetArcsec            % should be << 1000 (typically < 10)
                '%12.8f',...            % transitOffsetPhase             % [-pi pi]
                '%12.8f',...            % skyOffsetRaArcSec              % should be << 1000 (typically < 10)
                '%12.8f',...            % skyOffsetDecArcSec             % should be << 1000 (typically < 10)
                '%12.8f',...            % sourceOffsetRaHours            % [0 24]
                '%12.8f',...            % sourceOffsetDecDegrees         % [0 180]
                '%16.8f',...            % semiMajorAxisOverRstar         % lean toward planets orbiting outside the star. 1e-3 rStar resolution
                '%16.8f',...            % RplanetOverRstar               % small planet / large star (1e-5), large planet / small star (1e5)
                '%16.8f',...            % planetRadiusREarth             % 
                '%12.8f',...            % impactParameter                % [0 1] but could be > 1 by a small fraction for grazing transits
                '%16.8f',...            % stellarRadiusRsun              % should support stars much larger or much smaller than the sun
                '%16.8f',...            % stellarMassMsun                % "
                '%12.4f',...            % stellarLog10Gravity            % nobody knows these beyond 3 digits of precision
                '%12.4f',...            % stellarEffectiveTempKelvin     % should be to the degree at most
                '%12.4f',...            % stellarLog10Metalicity         % nobody knows these beyond 3 digits of precision
                '%2i',...               % transitBufferCadences          % overkill. usually is 3 or 4
                '%16.8f',...            % singleEventStatistic           % not sure how much resolution we need onthe SES but 1e-4 should be fine
                '%12.8f'};              % normalizedEpochPhase           % [0 1]
          
return;