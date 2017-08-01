function outputs_struct = debug_matlab_controller(inputs_struct)
% function outputs_struct = debug_matlab_controller(inputs_struct)
%
% This function implements the debug pipeline module
% It simply multiplies the input 'original' by the input 'scalar' and
% returns the result
%
% The debug pipeline module is used to serve as an example and to
% verify that the pipeline is operating correctly
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

    disp('debug_matlab_controller START');

    outputs_struct = make_outputs();
    
    disp('debug_matlab_controller END');
    
    return

        
    function outputs = make_outputs()
        [m o r c] = do_raDec2Pix();

        outputs.outputElements = [];
        outputs.result = 42;
        outputs.func1 = 1;
        outputs.func2 = 2;
        outputs.module = m;
        outputs.output = o;
        outputs.row = r;
        outputs.column = c;

        sleepTime = inputs_struct.moduleParameters.sleepTimeMatlabSecs;

        if(sleepTime > 0)
            disp(['Sleeping for ' num2str(sleepTime) ' seconds']);
            pause(sleepTime);
        else
            disp('No sleep time (MATLAB-side) specified');
        end
    end
        
    function [m o r c] = do_raDec2Pix()

        for i = 1:5
            k = metrics_interval_start;

            disp('Calling RaDec2Pix');
            raDec2PixObject = raDec2PixClass(inputs_struct.raDec2PixModel, 'zero-based');
            import gov.nasa.kepler.common.ModifiedJulianDate;
            [m o r c] = ra_dec_2_pix(raDec2PixObject, inputs_struct.ra, inputs_struct.dec, inputs_struct.julianDate - ModifiedJulianDate.MJD_OFFSET_FROM_JD)

            metrics_interval_stop('debug.raDec2Pix.execTime',k);
        end
    end
end
