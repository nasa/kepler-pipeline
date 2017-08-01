% Notes: current list of configurable parameters for generating ETEM2 data
% for data validation testing purposes
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


%--------------------------------------------------------------------------
% ETEM2 run parameters
%--------------------------------------------------------------------------
numCadences         default: 1440
ccdModule           default: 7
ccdOutput           default: 3
cadenceType         default: long

numberOfTargets     default: 2000
targetListSet       TBD
runStartDate        TBD
requantTableID      TBD
observingSeason     default: 1

%--------------------------------------------------------------------------
% ccd/science effects to include in run
%--------------------------------------------------------------------------

2D       2D black                   default: On (=enabled)
ST       stars                      default: On
SM       smear                      default: On
DC       dark current               default: On
darkCurrentValueInAdu               default: 1

NL       nonlinearity               default: On
LU       lde undershoot             default: On
FF       flat field                 default: On

RN       read noise                 default: On
QN       quantization noise         default: On
SN       shot noise                 default: On

ZD       zodiacal light             default: Off
SB       stellar background         default: Off
DV       dva motion                 default: On
JT       jitter                     default: On
SV       stellar variability        default: On  (see below for further info)

AP       astrophysics               default: On  (see below for further info)
TE       transiting Earths          default: On  (see below for further info)
TJ       transiting Jupiters        default: On  (see below for further info)
EB       eclipsing binaries         default: On  (see below for further info)
BB       background binaries        default: On  (see below for further info)

CR       cosmic rays                default: On
RQ       requantized data           default: On
POU      POU enabled in CAL/PA      default: enabled



%--------------------------------------------------------------------------
% Stellar variability (SV) configurables
%--------------------------------------------------------------------------

Defaults within ETEM2:
stellarRotationRange     default: [0.8, 1.2]
numRotationSpeeds        default: 3


%--------------------------------------------------------------------------
% Astrophysics (AP) configurables common to all types:
%
%   TE   transiting Earths
%   TJ   transiting Jupiters
%   EB   eclipsing binaries
%   BB   background binaries
%--------------------------------------------------------------------------

methodForSelectingTargets      'random' or 'all', default is 'random'
(the option 'byKeplerID'is not yet implemented)

numTargetsToInjectScience       default: 20

For methodForSelectingTargets = 'random':
selectionMagnitudeRange         default: [12 13]
selectionEffTempRange           default: [5240 6530]
selectionlogGRange              default: [4 5]

*Note: for the available targets with values within these selected ranges,
    randperm (which calls rand) is used to select the targets.


    %--------------------------------------------------------------------------
    % Astrophysics (AP) configurables for each transit type
    %
    % *Note that the planetary/stellar parameters are randomly selected from within
    % the given ranges via:    pick = range(1) + rand(1,1)*(range(2) - range(1))
    %
    % I have not yet tried an etem run with changes to these defaults, nor have
    % I tried to force some parameters by setting equal limits - I will find
    % out soon (by trial or by asking Steve) and report back!
    %--------------------------------------------------------------------------

    Defaults within ETEM2 for TE (transiting Earths):
    radiusRange                 default: [0.5 3]
    radiusUnits                 default: 'earthRadius'
    eccentricityRange           default: [0 0.8]
    orbitalPeriodRange          default: [10 20]
    orbitalPeriodUnits          default: 'day'
    periCenterDateRange         default: [datestr2mjd('1-Jan-2008') datestr2mjd('31-Dec-2008')]
    minimumImpactParameterRange default: [0 0.7]
    depthRange                  default: []


    Defaults within ETEM2 for TJ (transiting Jupiters)
    radiusRange                 default: [0.5 3]
    radiusUnits                 default: 'jupiterRadius'
    eccentricityRange           default: [0 0.8]
    orbitalPeriodRange          default: [10 20]
    orbitalPeriodUnits          default: 'day'
    periCenterDateRange         default: [datestr2mjd('1-Jan-2008') datestr2mjd('31-Dec-2008')]
    minimumImpactParameterRange default: [0 0.7]
    depthRange                  default: []


    Defaults within ETEM2 for EB (eclipsing binaries)
    effectiveTemperatureRange   default: [4800 6500]
    logGRange                   default: [3 5]
    orbitalPeriodRange          default: [10 20]
    orbitalPeriodUnits          default: 'day'
    periCenterDateRange         default: [datestr2mjd('1-Jan-2008') datestr2mjd('31-Dec-2008')]
    minimumImpactParameterRange default: [0 0.7]);


    Defaults within ETEM2 for BB (background binaries)
    effectiveTemperatureRange   default: [4800 6500]
    logGRange                   default: [3 5]
    orbitalPeriodRange          default: [10 20]
    orbitalPeriodUnits          default: 'day'
    periCenterDateRange         default: [datestr2mjd('1-Jan-2008') datestr2mjd('31-Dec-2008')]
    minimumImpactParameterRange default: [0 0.7]
    pixelOffsetRange            default: [0.5 1.5]
    magnitudeOffsetRange        default: [5 7]




    The individual & combined light curve data (including kepler ID, description
    of injected science, light curves, plus a bunch of other good stuff) are output
    to a matfile in the etem run directory: scienceTargetList.mat

    some examples:
    %
    % targetScienceProperties(3) =
    %
    %     description: 'Transiting Jupiters'
    %        keplerId: [9145980 9210192]
    %
    %
    %     targetList(100) =
    %                 keplerId: 9274472
    %           lightCurveList: [1x1 struct]
    %           lightCurveData: []
    %      compositeLightCurve: [4320x1 double]
    %          keplerMagnitude: 13.9190
    %                       ra: 288.9946
    %                      dec: 45.7791
    %        logSurfaceGravity: 4.4040
    %           logMetallicity: -0.1070
    %     effectiveTemperature: 5112
    %                     flux: 3.6561e+04
    %                      row: 48
    %                   column: 863
    %              rowFraction: 4
    %           columnFraction: 9
    %        visiblePixelIndex: 870428
    %            subPixelIndex: 84
    %              initialData: [1x1 struct]
    %
    %