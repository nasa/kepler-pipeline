function [highGuardBand lowGuardBand] = dg_read_high_low_guard_bands(startMjd, endMjd)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% [highGuardBand lowGuardBand] = dg_read_high_low_guard_bands(startMjd)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% INPUT: 
%           startMjd: [double] start time of data
%             endMjd: [double] end time of data
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% OUTPUT:
%           highGuardBand: [double] 95% x the number of quantization levels
%           lowGuardBand: [vector double 84x1] , 95% below the mean black for a
%           particular module output at a specified startMjd time
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% COMMENT: the retrieving of the black is really all of Kester's work
%
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

import gov.nasa.kepler.common.FcConstants;
quantSteps = FcConstants.MEAN_BLACK_TABLE_MAX_VALUE;
% high guard band is a fixed value for all module outputs
highGuardBand = quantSteps*0.95;



try % if low guard bands already exist don't need to read from DB again
    lowGuardBand = evalin('base', 'lowGuardBand');

    return

catch % if low guard bands are not in the base workspace, read in:

    % this takes a while so print out a message
    disp(sprintf('retrieving data from database\n'))
    % low guard band is computed on a per module output basis.
    % low guard band is defined as 0.95% below the mean black
    
    
    try 
    lowGuardBand = zeros(84,1);

    for module = [2:4, 6:20, 22:24]
        for output = 1:4
            channel = convert_from_module_output(module, output);
            model = retrieve_two_d_black_model(module, output, startMjd, endMjd);
            object = twoDBlackClass(model);
            blacks = get_two_d_black(object, startMjd);
            meanBlack = mean(mean(blacks));
            lowGuardBand(channel,1) = 0.95*meanBlack;
            disp(sprintf('high guard band = %5.2f', highGuardBand))
            disp(sprintf('retrieved mean black and computed low guard band for module %d output % d', module, output))
            disp(sprintf('mean black = %3.2f', meanBlack))
            disp(sprintf('low guard band = %3.2f\n\n\n', lowGuardBand(channel,1)))
        end
    end
    
    catch % and if retrieval of mean blacks from database fails, then load preexisting guardbands
        
        load lgb.mat
    end
end

return

    