function result = isvalid_tip_input_parameter_set( inputStruct, paramSetName )
% function result = isvalid_tip_input_parameter_set( inputStruct, paramSetName )
%
% This TIP function verifies the inputStruct contains the proper data needed to generate a simulated transit model. It verifies that a
% field exists for each of the needed parameters and that the fields contain column vectors of non-zero equal length without NaNs. It does
% not check for valid values or self consistancy of these parameters. If the file is found to be valid result = true. Otherwise result =
% false.
%
% INPUT:            inputStruct == [struct] containing the following fields and no more:
%                          keplerId: [nx1 double]
%                  impactParameters: [nx1 double]
%                        inputPhase: [nx1 double]
%                      offsetArcSec: [nx1 double]
%                       offsetPhase: [nx1 double]
%                       
%                       If paramSetName = 'sesDurationParamSet' must contain:
%                          inputSES: [nx1 double]
%                    inputDurations: [nx1 double]
%
%                       If paramSetName = 'periodRPlanetParamSet' must contain:
%                      planetRadius: [nx1 double]
%                 orbitalPeriodDays: [nx1 double]
%
%                                       Note all arrays must be column vectors of the same dimension.
%
%                 paramSetName  == [string]  TIP input parameter set name. {'sesDurationParamSet','periodRPlanetParamSet'}
% 
% OUTPUT:               result  == [logical] true if inputStruct is a valid TIP inputs parameter struct. false otherwise.
%
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

% common field names required by tip
headings = {'keplerId', 'impactParameters', 'inputPhase', 'offsetArcSec', 'offsetPhase'};

% add parameter set dependent field names
sesDurationHeading = {'inputSES', 'inputDurations'};
periodRadiusHeadings = {'planetRadius', 'orbitalPeriodDays'};    
switch paramSetName
    case 'sesDurationParamSet'
        headings = {headings{:}, sesDurationHeading{:}};                                                            %#ok<*CCAT>
    case 'periodRPlanetParamSet'
        headings = {headings{:}, periodRadiusHeadings{:}};
    otherwise
        error(['Generating parameter set ',generatingParamSetName,' is not recognized by TIP.']);
end
    
% assume file is good
result = true;
fNames = fieldnames(inputStruct);

% check required headings list against fields in inputStruct 
tf = ismember(headings, fNames);
if ~all(tf)
    result = false;
    return;
end


% all arrays under fields must be columns, must have the same length which is greater than zero and cannot contain NaNs
isCol = false(length(headings),1);
noNans = false(length(headings),1);
arrayLength = zeros(length(headings),1);
for iName = 1:length(headings)
    isCol(iName) = iscolumn(inputStruct.(headings{iName}));
    noNans(iName) = ~any(isnan(inputStruct.(headings{iName})));
    arrayLength(iName) = length(inputStruct.(headings{iName}));    
end
result = result & all(isCol);
result = result & all(noNans);
result =result & all_rows_equal(arrayLength);
result =result & all(arrayLength > 0);

