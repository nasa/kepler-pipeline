function [desiredAttitudes,pdqOutputStruct] =  get_desired_attitude(pdqScienceObject, desiredAttitudeStruct,pdqOutputStruct )

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pdqScienceObject = desired_attitude_(pdqScienceObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% desired_attitude() returns the desired attitude solution for Kepler
% Uses aberrate_ra_dec() and FC Constanrts nominal pointing center
%
% Any remaining mean residuals indicate a difference between the best fit
% attitude solution and the desired attitude.
%
% Inputs:
%   pdqScienceClass
%
% Outputs:
%   desiredAttitudeRa   : desired Right ascenion
%   desiredAttitudeDec  : desired Declination
%   desiredAttitudeRoll : desired Roll angle
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

%--------------------------------------------------------------------------
% Obtain the nominal pointing position from FC Constants
%--------------------------------------------------------------------------

% get nominal pointing from FC, assume no uncertainty on the nominal
% pointing for now.....


desiredAttitudes = cat(1, desiredAttitudeStruct.nominalPointing);


raArray   = desiredAttitudes(:,1);
decArray  = desiredAttitudes(:,2);
rollArray = desiredAttitudes(:,3);


% Obtain pre-existing time series
% Append - if time series contains previous results
desiredAttitudeRa      = pdqScienceObject.inputPdqTsData.desiredAttitudeRa;
desiredAttitudeDec     = pdqScienceObject.inputPdqTsData.desiredAttitudeDec;
desiredAttitudeRoll    = pdqScienceObject.inputPdqTsData.desiredAttitudeRoll;

if(isempty(desiredAttitudeRa.values))

    desiredAttitudeRa.values   = raArray;
    desiredAttitudeDec.values  = decArray;
    desiredAttitudeRoll.values = rollArray;

    desiredAttitudeRa.uncertainties      = zeros(length(raArray),1);
    desiredAttitudeDec.uncertainties     = zeros(length(raArray),1);
    desiredAttitudeRoll.uncertainties    = zeros(length(raArray),1);

    % what about gap indicators? does not make sense to have a gap
    % in attitude solution.....but to complete the structure fill anyway...
    desiredAttitudeRa.gapIndicators   = false(length(raArray),1);
    desiredAttitudeDec.gapIndicators  = false(length(raArray),1);
    desiredAttitudeRoll.gapIndicators = false(length(raArray),1);

else

    gapIndicators   = false(length(raArray),1);

    desiredAttitudeRa.values      = [desiredAttitudeRa.values(:); raArray];
    desiredAttitudeDec.values     = [desiredAttitudeDec.values(:); decArray];
    desiredAttitudeRoll.values    = [desiredAttitudeRoll.values(:); rollArray];

    desiredAttitudeRa.uncertainties      = [desiredAttitudeRa.uncertainties(:); zeros(length(raArray),1)];
    desiredAttitudeDec.uncertainties     = [desiredAttitudeDec.uncertainties(:); zeros(length(raArray),1)];
    desiredAttitudeRoll.uncertainties    = [desiredAttitudeRoll.uncertainties(:); zeros(length(raArray),1)];

    desiredAttitudeRa.gapIndicators      = [desiredAttitudeRa.gapIndicators(:); gapIndicators(:)];
    desiredAttitudeDec.gapIndicators     = [desiredAttitudeDec.gapIndicators(:); gapIndicators(:)];
    desiredAttitudeRoll.gapIndicators    = [desiredAttitudeRoll.gapIndicators(:); gapIndicators(:)];


end

% Sort time series using the time stamps as a guide
[allTimes sortedTimeSeriesIndices] = ...
    sort([pdqScienceObject.inputPdqTsData.cadenceTimes(:); ...
    pdqScienceObject.cadenceTimes(:)]);

if (length(sortedTimeSeriesIndices) == length(desiredAttitudeRa.values) )

    desiredAttitudeRa.values      = desiredAttitudeRa.values(sortedTimeSeriesIndices);
    desiredAttitudeDec.values     = desiredAttitudeDec.values(sortedTimeSeriesIndices);
    desiredAttitudeRoll.values    = desiredAttitudeRoll.values(sortedTimeSeriesIndices);

    desiredAttitudeRa.uncertainties      = desiredAttitudeRa.uncertainties(sortedTimeSeriesIndices);
    desiredAttitudeDec.uncertainties     = desiredAttitudeDec.uncertainties(sortedTimeSeriesIndices);
    desiredAttitudeRoll.uncertainties    = desiredAttitudeRoll.uncertainties(sortedTimeSeriesIndices);


    desiredAttitudeRa.gapIndicators      = desiredAttitudeRa.gapIndicators(sortedTimeSeriesIndices);
    desiredAttitudeDec.gapIndicators     = desiredAttitudeDec.gapIndicators(sortedTimeSeriesIndices);
    desiredAttitudeRoll.gapIndicators    = desiredAttitudeRoll.gapIndicators(sortedTimeSeriesIndices);

end

% Also save new time series to the output data structure
pdqOutputStruct.outputPdqTsData.desiredAttitudeRa   = desiredAttitudeRa;
pdqOutputStruct.outputPdqTsData.desiredAttitudeDec  = desiredAttitudeDec;
pdqOutputStruct.outputPdqTsData.desiredAttitudeRoll = desiredAttitudeRoll;

return;