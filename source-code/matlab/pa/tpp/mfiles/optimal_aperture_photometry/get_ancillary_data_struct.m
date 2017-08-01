%==========================================================================
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
function ancillaryData = get_ancillary_data_struct(runStr, locationStr, nCadences, beginTime, startCadenceTimes)
%==========================================================================

% jitterLoadString = ['load ' locationStr  runStr '/Ajit_' runStr ];
% runparamsLoadString = ['load ' locationStr  runStr '/run_params_' runStr ];
% 
% eval(runparamsLoadString);
% 
% 
% % same set of data gaps appearing on all flux time series, as well as on
% % ancillary data
% iAvailable = introduce_data_gaps(nCadences);
% 
% 
% 
% % get jitter time series
% eval(jitterLoadString);
% [dx, dy] = get_jitter_time_series(Ajit_Cell);
% clear Ajit_Cell;
% 



tnow = beginTime;
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




% ancillary data

mnemonic = '';
timestamps = endTimes + 1721058.5 - 2400000.5;
values = zeros(nCadences,1); % each ancillary time series can have different lengths
uncertainties = zeros(nCadences,1);
isAncillaryEngineeringData = false;
maxAcceptableGapInHours = 12;

% create a structure array
ancillaryData = repmat(struct('mnemonic',mnemonic, 'timestamps',timestamps,...
    'values',values, 'uncertainties', uncertainties,...
    'isAncillaryEngineeringData', isAncillaryEngineeringData,...
    'maxAcceptableGapInHours', maxAcceptableGapInHours, 'modelOrderInDesignMatrix', 1),1,5);

% assemble manually

javaaddpath C:\path\to\matlab\pa\tpp\mfiles\optimal_aperture_photometry;
% convert startCadenceTimes in MJD to JD

startCadenceTimesJD = startCadenceTimes + 2400000.5;
[ra0s2, dec0s2, phi0s2] = generate_PPA_like_attitude_solution_time_series(startCadenceTimesJD);


ancillaryData(1).mnemonic = 'boresightRa';
ancillaryData(1).values = ra0s2(:);
ancillaryData(1).uncertainties = []; % leave unchanged for now
ancillaryData(1).timestamps = [];
ancillaryData(1).isAncillaryEngineeringData = false;
ancillaryData(1).maxAcceptableGapInHours = 2;
ancillaryData(1).modelOrderInDesignMatrix = 2;

ancillaryData(2).mnemonic = 'boresightDec';
ancillaryData(2).values = dec0s2(:);
ancillaryData(2).uncertainties = []; % leave unchanged for now
ancillaryData(2).timestamps = [];
ancillaryData(2).isAncillaryEngineeringData = false;
ancillaryData(2).maxAcceptableGapInHours = 2;
ancillaryData(2).modelOrderInDesignMatrix = 2;


ancillaryData(3).mnemonic = 'boresightRoll';
ancillaryData(3).values = phi0s2(:);
ancillaryData(3).uncertainties = []; % leave unchanged for now
ancillaryData(3).timestamps = [];
ancillaryData(3).isAncillaryEngineeringData = false;
ancillaryData(3).maxAcceptableGapInHours = 2;
ancillaryData(3).modelOrderInDesignMatrix = 2;






ancillaryData(4).mnemonic = 'fpTemp';


temperatureTimes = (0+1/96:1/96:93)'; % 4 samples per hour
nSamples = length(temperatureTimes);
tnow = beginTime;
temperatureTimes = (tnow:(1/96):(tnow + (nSamples-1)/96))'; % turn into a column vector


ancillaryData(4).values = sin(2*pi*.02*temperatureTimes);
ancillaryData(4).uncertainties = zeros(length(temperatureTimes),1);
ancillaryData(4).timestamps = temperatureTimes; % already set while creating the structure
ancillaryData(4).isAncillaryEngineeringData = true;
ancillaryData(4).maxAcceptableGapInHours = 12;
ancillaryData(4).modelOrderInDesignMatrix = 1;



ancillaryData(5).mnemonic = 'mainVoltage';
voltageTimes = (0+(1/(12*24)):1/(12*24):93)'; % 12 samples per hour
nSamples = length(voltageTimes);
tnow = beginTime;
voltageTimes = (tnow:(1/(12*24)):(tnow + (nSamples-1)/(12*24)))'; % turn into a column vector




ancillaryData(5).values = sawtooth(2*pi*.02*voltageTimes);
ancillaryData(5).uncertainties = zeros(length(voltageTimes),1);
ancillaryData(5).timestamps = voltageTimes; % already set while creating the structure
ancillaryData(5).isAncillaryEngineeringData = true;
ancillaryData(5).maxAcceptableGapInHours = 12;
ancillaryData(5).modelOrderInDesignMatrix = 1;


% ancillaryData(4).mnemonic = 'dx';
% ancillaryData(4).values = [];
% ancillaryData(4).uncertainties = []; % leave unchanged for now
% ancillaryData(4).timestamps = [];
% ancillaryData(4).isAncillaryEngineeringData = false;
% ancillaryData(4).maxAcceptableGapInHours = 2;
% ancillaryData(4).modelOrderInDesignMatrix = 2;
% 
% ancillaryData(5).mnemonic = 'dy';
% ancillaryData(5).values = [];
% ancillaryData(5).uncertainties = []; % leave unchanged for now
% ancillaryData(5).timestamps = [];
% ancillaryData(5).isAncillaryEngineeringData = false;
% ancillaryData(5).maxAcceptableGapInHours = 2;
% ancillaryData(5).modelOrderInDesignMatrix = 2;
% 
% 

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


return;
%--------------------------------------------------------------------------


