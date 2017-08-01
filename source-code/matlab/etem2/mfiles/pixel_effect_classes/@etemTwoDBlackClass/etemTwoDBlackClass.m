function etemTwoDBlackObject = etemTwoDBlackClass(twoDBlackData, runParamsObject, ...
    electronsToAduObject)
% function twoDBlackObject = twoDBlackClass(twoDBlackData, runParamsObject, ...
%     electronsToAduObject)
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

module = get(runParamsObject, 'moduleNumber');
output = get(runParamsObject, 'outputNumber');
runStartMjd = datestr2mjd(get(runParamsObject, 'runStartDate'));
runEndMjd = runStartMjd + get(runParamsObject, 'runDurationDays');
exposuresPerCadence = get(runParamsObject, 'exposuresPerCadence');

if isempty(twoDBlackData.filename)
	blackObject = twoDBlackClass(...
    	retrieve_two_d_black_model(module, output, runStartMjd, runEndMjd));
	twoDBlackData.blackArrayAdu ...
    	= get_two_d_black(blackObject, runStartMjd)*exposuresPerCadence;
else
	load(twoDBlackData.filename)
	% file is assumed to have the 2d black array in the variable black2dImage
	twoDBlackData.blackArrayAdu = black2dImage*exposuresPerCadence;
end
 
% blackArrayAdu = retrieve_two_d_black_model(module, output, runStartMjd, ...
%     runEndMjd);
% twoDBlackData.blackElectrons = reshape(convert_ADU_to_electrons(electronsToAduObject, ...
%     blackArrayAdu.blacks.array), size(blackArrayAdu.blacks.array))*exposuresPerCadence;

% instantiate the class
etemTwoDBlackObject = class(twoDBlackData, 'etemTwoDBlackClass', runParamsObject);

