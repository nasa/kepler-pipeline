function etemTwoDBlackTestObject = etemTwoDBlackTestClass(twoDBlackData, runParamsObject, ...
    electronsToAduObject)
% function twoDBlackTestObject = twoDBlackTestClass(twoDBlackData, runParamsObject, ...
%     electronsToAduObject)
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

% extract necessary information for this run
module = get(runParamsObject, 'moduleNumber');
output = get(runParamsObject, 'outputNumber');
runStartMjd = datestr2mjd(get(runParamsObject, 'runStartDate'));
runEndMjd = runStartMjd + get(runParamsObject, 'runDurationDays');
exposuresPerCadence = get(runParamsObject, 'exposuresPerCadence');

if ( false )
    % create a twoDBlack object using information from SBT
    blackObject = twoDBlackClass(...
        retrieve_two_d_black_model(module, output, runStartMjd, runEndMjd));

    % get twoD Black data from twoDBlack object and assign it to our input data
    twoDBlackData.blackArrayAdu ...
        = get_two_d_black(blackObject, runStartMjd)*exposuresPerCadence;

else
    % create a twoDBlack object using user provided information.
    twoDBlackDataFilename=fullfile(twoDBlackData.blackDataDir, twoDBlackData.blackDataFilename);
    
    if ( 2 ~= exist( twoDBlackDataFilename ) )
        error('etemTwoDBlackTestClass: twoDBlackImage.mat is not found!');
    else
        load(twoDBlackDataFilename);
        twoDBlackData.blackArrayAdu = myTwoDBlackData * exposuresPerCadence;
    end
end

% instantiate the class
etemTwoDBlackTestObject = class(twoDBlackData, 'etemTwoDBlackTestClass', runParamsObject);
