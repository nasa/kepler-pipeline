function sbt_validate_time_interval(startInterval, endInterval, isInputCadenceNumber, mnemonic)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function sbt_validate_time_interval(startInterval, endInterval, isInputCadenceNumber, mnemonic)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Check the validity of the parameters specifying a time interval.
%
% Inputs:
%   startInterval           Start cadence number or MJD start time of the specified time interval.
%   endInterval             End cadence number or MJD end time of the specified time interval.
%   isInputCadenceNumber    Flag indicating the inputs 'startInterval' and 'endInterval' are cadence numbers/MJDs when it is 1/0. 
%   mnemonic                A string describing the data to be checked.
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

if ( isempty(isInputCadenceNumber) )
    error(mnemonic, 'isInputCadenceNumber cannot be empty.'); 
elseif ( ~ismember(isInputCadenceNumber, [1 0]) )
    error(mnemonic, 'Valid value of isInputCadenceNumber should be 1 or 0.'); 
elseif isInputCadenceNumber==1
        timeString = 'cadence';
        lowerBoundString = '>= 0';
        upperBoundString = '<= 1e12';
else
        timeString = 'MJD';
        lowerBoundString = '>= 54000';
        upperBoundString = '<= 64000';
end

if ( isempty(startInterval) ||  isempty(endInterval) )
    error(mnemonic, ['Start and end ' timeString ' cannot be empty.']);
end

if ( length(startInterval)>1 || length(endInterval)>1 )
    error(mnemonic, ['Start and end ' timeString ' must be scalar, not vector.']);
end

if ( ~isfinite(startInterval) || ~isfinite(endInterval) )
    error(mnemonic, ['Start and end ' timeString ' cannot be NaN or Inf.']);
end

if ( ~( eval(['startInterval' lowerBoundString ' && startInterval' upperBoundString]) ) || ...
     ~( eval(['endInterval'   lowerBoundString ' && endInterval'   upperBoundString]) )  )
    error(mnemonic, ['Valid value of start and end ' timeString ' must be ' lowerBoundString ' and ' upperBoundString]);
end

if ( startInterval>endInterval )
    error(mnemonic, ['Start ' timeString ' must be less than or equal to end ' timeString]);
end