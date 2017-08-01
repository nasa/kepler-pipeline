function pdcInputs = pdc_generate_data(runNumber, dirString, nFewerStars, debugLevel)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pdcInputs = pdc_generate_data(runNumber, dirString, nFewerStars, debugLevel)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% The parameter nFewerStars allows one to generate a smaller size data set
% and debugLevel sets the value of debugFlag.
%
% This function extracts data for the PDC CSCI from an ETEM run and
% returns pdcInputs data structure  with the following fields:
%
%                                 debugFlag: 1
%               designMatrixPolynomialOrder: 2
%                        minLongDataGapSize: 40
%                     outlierThresholdSigma: 3.5
%                     outlierScanWindowSize: 48
%                        medianFilterLength: 11
%                              modelOrderAR: 10
%         correlationWindowlengthMultiplier: 3
%                      mjdCadenceStartTimes: [4464x1 double]
%                        mjdCadenceEndTimes: [4464x1 double]
%                 waveletFilterCoefficients: [12x1 double]
%                                targetData: [1x2000 struct]
%                             ancillaryData: [1x4 struct]
%
%       pdcInputs.ancillaryData is an array of structure with the following fields
%
%                           mnemonic: 'dx'
%                         timestamps: []
%                             values: [4464x1 double]
%                      uncertainties: [4464x1 double]
%         isAncillaryEngineeringData: 0
%                  dataGapIndicators: [4464x1 logical]
%
%       pdcInputs.targetData is an array of structure with the following fields
%                          relativeFlux: [4464x1 double]
%           uncertaintiesInRelativeFlux: [4464x1 double]
%         relativeFluxDataGapIndicators: [4464x1 logical]
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% dirString = 'C:\path\to\Retrofit_Pipeline\';
% dirString = 'path/to/etem/quarter/1/';
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

% run specific parameters
runString = ['run' num2str(runNumber)];

jitterLoadString = ['load ' dirString  runString '/Ajit_' runString ];
runparamsLoadString = ['load ' dirString  runString '/run_params_' runString ];

fluxWithGcrFile = [dirString  runString '/raw_flux_gcr_' runString '.dat' ];


eval(runparamsLoadString);

nStars = run_params.num_targets;

% read flux time series into an array
[flux] = read_rawflux_data( fluxWithGcrFile, nStars);



% temporarily reduce thenumber of stars to nFewerStars for unit testing
% data generation
if(exist('nFewerStars', 'var' ))
    if(nFewerStars < nStars)
        nStars = nFewerStars;
    end;
end;



% get jitter time series
eval(jitterLoadString);
[dx, dy] = get_jitter_time_series(Ajit_Cell);
clear Ajit_Cell;


% same set of data gaps appearing on all flux time series, as well as on
% ancillary data
nCadences = length(flux(:,1));
iAvailable = introduce_data_gaps(nCadences);


% create pdcInputs data structure
if(~exist('debugLevel', 'var' ))
    debugLevel = 0;
end;
pdcInputs.debugFlag = debugLevel;




pdcInputs.designMatrixPolynomialOrder = 2;
pdcInputs.minLongDataGapSize = 40;
pdcInputs.outlierThresholdSigma = 3.5;
pdcInputs.outlierScanWindowSize = 48;
pdcInputs.medianFilterLength = 11;
pdcInputs.modelOrderAR = 10;
pdcInputs.correlationWindowlengthMultiplier = 3;



tnow = datenum(now);
startTimes = (tnow:(1/48):(tnow + (nCadences-1)/48))'; % turn into a column vector
endTimes = startTimes+(1/48);

% (http://www.mathworks.com/support/solutions/data/1-19T9M.html?solution=1-% 19T9M)
% The Julian day number, JD, and MATLAB's datenum, T, are measuring the
% same thing -- number of days (and fractions of days) since some arbitrary
% ancient origin. One is simply an offset of the other. The Julian day
% number starts at noon, while the MATLAB datenum starts at midnight, so
% the offset involves half a day.
%
% Here is the formula, applied to the time when you want to write this:
%
% JD = T + 1721058.5
%


pdcInputs.mjdCadenceStartTimes = startTimes + 1721058.5 - 2400000.5;
pdcInputs.mjdCadenceEndTimes = endTimes + 1721058.5 - 2400000.5;

pdcInputs.waveletFilterCoefficients = daubh0(12);

relativeFlux = zeros(nCadences,1); % allocate maximum size expected
uncertaintiesInRelativeFlux = zeros(nCadences,1); % allocate maximum size expected
relativeFluxDataGapIndicators = true(nCadences,1); % allocate maximum size expected
% create a structure array
targetData = repmat(struct('relativeFlux',relativeFlux, 'uncertaintiesInRelativeFlux',uncertaintiesInRelativeFlux,...
    'relativeFluxDataGapIndicators',relativeFluxDataGapIndicators),1,nStars);

for j = 1:nStars

    targetData(j).relativeFlux = flux(:,j);
    targetData(j).relativeFluxDataGapIndicators = iAvailable; % gaps could be different for different stars
    % targetData(j).uncertaintiesInRelativeFlux =  ; % leave it unchanges
    % at 0's
end;

pdcInputs.targetData = targetData;


% ancillary data

mnemonic = 'jitter';
timestamps = endTimes + 1721058.5 - 2400000.5;
values = zeros(nCadences,1); % each ancillary time series can have different lengths
uncertainties = zeros(nCadences,1);
isAncillaryEngineeringData = false;
dataGapIndicators = true(nCadences,1);

% create a structure array
ancillaryData = repmat(struct('mnemonic',mnemonic, 'timestamps',timestamps,...
    'values',values, 'uncertainties', uncertainties,...
    'isAncillaryEngineeringData', isAncillaryEngineeringData,...
    'dataGapIndicators', dataGapIndicators),1,4);

% assemble manually

ancillaryData(1).mnemonic = 'dx';
ancillaryData(1).values = dx;
% ancillaryData(1).uncertainties = 0; % leave unchanged for now
ancillaryData(1).timestamps = [];
ancillaryData(1).isAncillaryEngineeringData = false;
ancillaryData(1).dataGapIndicators = iAvailable;

ancillaryData(2).mnemonic = 'dy';
ancillaryData(2).values = dy;
% ancillaryData(2).uncertainties = 0; % leave unchanged for now
ancillaryData(2).timestamps = [];
ancillaryData(2).isAncillaryEngineeringData = false;
ancillaryData(2).dataGapIndicators = iAvailable;


ancillaryData(3).mnemonic = 'fpTemp';
temperatureTimes = (0:1/96:93)'; % 4 samples per hour
ancillaryData(3).values = sin(2*pi*.02*temperatureTimes);
ancillaryData(3).uncertainties = zeros(length(temperatureTimes),1);
ancillaryData(3).timestamps = temperatureTimes; % already set while creating the structure
ancillaryData(3).isAncillaryEngineeringData = true;
ancillaryData(3).dataGapIndicators = true(length(temperatureTimes),1);
ancillaryData(3).dataGapIndicators(250:265) = false;



ancillaryData(4).mnemonic = 'mainVoltage';
voltageTimes = (0:1/(12*24):93)'; % 4 samples per hour
ancillaryData(4).values = sawtooth(2*pi*.02*voltageTimes);
ancillaryData(4).uncertainties = zeros(length(voltageTimes),1);
ancillaryData(4).timestamps = voltageTimes; % already set while creating the structure
ancillaryData(4).isAncillaryEngineeringData = true;
ancillaryData(4).dataGapIndicators = true(length(voltageTimes),1);
ancillaryData(4).dataGapIndicators(400:415) = false;

pdcInputs.targetData = targetData;
pdcInputs.ancillaryData = ancillaryData;

return
%--------------------------------------------------------------------------
function [flux] = read_rawflux_data(fluxWithGcrFile, nStars)
%--------------------------------------------------------------------------
fid = fopen(fluxWithGcrFile,'r','ieee-le');

flux = fread(fid,[nStars,inf],'float32');
fclose(fid);
flux = flux';
return;

%--------------------------------------------------------------------------
function [dx, dy] = get_jitter_time_series(Ajit_Cell)
%--------------------------------------------------------------------------
[numberOfCadences, numberOfCoefficients] = size(Ajit_Cell{3,3});
for i = 3
    for j = 3
        ajit = Ajit_Cell{i,j};
        dx = ajit(1:numberOfCadences, 2)/ajit(1, 1);
        dy = ajit(1:numberOfCadences, 3)/ajit(1, 1);
    end
end

return;

%--------------------------------------------------------------------------
function iAvailable = introduce_data_gaps(nCadences)
%--------------------------------------------------------------------------

nShortGaps = 10;
nLongGaps = 2;
% short data gap  less than 2 hours = 4 samples
shortDataGapSize = 4;

% fixed long data gap of 8 days (spacecraft enters  safe mode just after
% contact and the safe mode is recognized 4 days later and corrected after
% another 4 days - KADN-260017)

longDataGapSize = 48; % one day of gap per monthly contact

iAvailable = true(nCadences,1);



rand('state',0);

for j = 1:nShortGaps
    lengthOfCurrentDataGap = fix(rand(1,1)*shortDataGapSize);
    % where to locate this data gap?

    if(j==1)
        startIndex = fix(rand(1,1)*nCadences);
    else
        startIndex = endIndex + fix(rand(1,1)*nCadences); % begin j-th datagap at this index
        if(startIndex > nCadences)
            startIndex  = mod(startIndex,nCadences);
        end;
    end;
    endIndex = startIndex + lengthOfCurrentDataGap; % end j-th datagap at this index
    if(endIndex > nCadences)
        endIndex = nCadences;
    end;
    iAvailable(startIndex:endIndex) = false; % introduce jth datagap which is "lengthOfCurrentDataGap " long
end;

% introduce one day data gap monthly - 31 day and 62 day
for k = 1:2

    % choose gap length for this gap
    lengthOfCurrentDataGap = longDataGapSize;

    % where to locate this data gap?
    if(k == 1)
        startIndex = (31*2*24) +1; %locate the gap at the end of 31st day
    else
        startIndex = (62*2*24) +1; %locate the gap at the end of 31st day
    end;
    endIndex = startIndex + lengthOfCurrentDataGap; % end j-th datagap at this index

    if(endIndex > nCadences)
        endIndex = nCadences;
    end;
    iAvailable(startIndex:endIndex) = false; % introduce jth datagap which is "lengthOfCurrentDataGap " long
end;




% for k = j+1:j+nLongGaps
%
%     % choose gap length for this gap
%     lengthOfCurrentDataGap = longDataGapSize;
%
%     % where to locate this data gap?
%     if(k == j+1)
%         startIndex = mod(fix(rand(1,1)*nCadences)+20*96, nCadences); %locate the gap in the first half
%     else
%         % second long data gap within 10 days
%         startIndex = endIndex + fix(rand(1,1)*10*96); % begin j-th datagap at this index
%     end;
%     endIndex = startIndex + lengthOfCurrentDataGap; % end j-th datagap at this index
%
%     if(endIndex > nCadences)
%         endIndex = nCadences;
%     end;
%     iAvailable(startIndex:endIndex) = 0; % introduce jth datagap which is "lengthOfCurrentDataGap " long
%
% end;


return;
%--------------------------------------------------------------------------








