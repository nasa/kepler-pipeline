function backgroundPolyStruct = fill_background_polynomial_struct_array( backgroundPolyStruct, configMapObject, cadenceTimes, cadenceType )
%
% function backgroundPolyStruct = fill_background_polynomial_struct_array( backgroundPolyStruct, configMapObject, cadenceTimes, cadenceType )
%
% Fill array of background polynomial structs at cadence times by
% interpolating polynomials in the long cadence background polynomial
% array.
%
% INPUT
%   backgroundPolyStruct      = array of background polynomial struct from
%                               long cadence PA processing over unit of
%                               work
%   configMapObject           = array of spacecraft cong maps over unit of
%                               work
%   cadenceTimes              = cadence time struct from PA inputsStruct
%                               containing:
%                                   .cadenceNumbers
%                                   .startTimestamps
%                                   .midTimestamps
%                                   .endTimestamps
%                                   .gapIndicators
%   cadenceType               = cadence type; 'LONG' or 'SHORT'
% OUTPUT
%   backgroundPolyStruct      = array of background polynomials
%                               interpolated at cadence times scaled
%                               correctly for cadenceType data
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


% Interpolate the background polynomials for long cadence (if necessary) or
% for short cadence target processing. Save the interpolated polynomials
% for use in later invocations. For a short cadence unit of work, the
% background polynomials and covariances must first be scaled to compensate
% for the differences in numbers of coadds between the short and long
% cadence data.

nCadences = length(cadenceTimes.cadenceNumbers);
processLongCadence = strcmpi(cadenceType,'LONG');
backgroundPolyGapIndicators = ~logical([backgroundPolyStruct.backgroundPolyStatus]');

if( any(backgroundPolyGapIndicators) || length(backgroundPolyStruct) < nCadences )
    
    if( ~processLongCadence && ~all(backgroundPolyGapIndicators) )
        % make the background poly compatible with short cadence data
        backgroundPolyStruct = scale_lc_background_poly_to_sc( backgroundPolyStruct, configMapObject );
    end
    
    % interpolate to fill missing time stamps
    backgroundPolyStruct = interpolate_background_polynomials(backgroundPolyStruct, cadenceTimes, processLongCadence);    
end
