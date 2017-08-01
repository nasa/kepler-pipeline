%function read_pdc_flux_timeseries_from_text_files.m
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

function [midTime, fluxTimeSeries, keplerId, keplerMag, filledIndexStruct] = read_pdc_flux_timeseries_from_text_files(timeStampsFileName, fluxFileName)


% read the timestamps

fid = fopen(timeStampsFileName);
C = textscan(fid, '%f%f%f', 'delimiter', '|');

startTime = C{:,1};

midTime = C{:,2};

endTime = C{:,3};

fclose(fid);


% now read the flux time sereis, kepler mag, keplerID, filled indices

fid = fopen(fluxFileName);


% pre allocate memory

keplerId = zeros(5000,1);
keplerMag = zeros(5000,1);
tadCrowdingMetric = zeros(5000,1);
fluxTimeSeries = zeros( 32*48*3, 2000); % approximately cadences for 90 days, 2000 stars per modout
filledIndexStruct = repmat(struct('filledIndex', []), 5000,1);



starsCount = 0;
resizeDone = false;

while(~feof(fid))

    tline = fgetl(fid); % read one line

    C = textscan(tline, '%f', 'delimiter' ,'|'); % parse fields into a cell array
    C = C{:}; % turn cell array into a double array

    starsCount = starsCount +1;  % increment star count

    keplerId(starsCount) = C(1);  % first element is kepler Id
    keplerMag(starsCount) = C(2); % second element is kepler magnitude
    tadCrowdingMetric(starsCount) = C(3); % third element is crowding metric
    C = C(4:end); % remaining elements indicate flux time series

    if(~resizeDone)     % first time resize the pre-allocated array

        fluxTimeSeries = fluxTimeSeries(1:length(C), :);  % can't resize for number of stars since that count won't be known till we reach eof
        resizeDone = true;

    end

    fluxTimeSeries(:,starsCount) = C(:);  % here error will be thrown if the number of cadences in each flux time series is not the same

    tline = fgetl(fid);   % read next line for number of filled indices

    if(~isempty(tline))

        C = textscan(tline, '%d', 'delimiter' ,'|');

        C = C{:};

        filledIndexStruct(starsCount).filledIndex = C(:);
    else
        filledIndexStruct(starsCount).filledIndex = [];
    end

end

fluxTimeSeries = fluxTimeSeries(:,1:starsCount);

keplerId = keplerId(1:starsCount);
keplerMag = keplerMag(1:starsCount);
filledIndexStruct = filledIndexStruct(1:starsCount);


fclose(fid);
return

