function dynablackResultsStruct = perform_dynablack_fits(dynablackObject, dynablackResultsStruct)
% function dynablackResultsStruct = perform_dynablack_fits(dynablackObject, dynablackResultsStruct)
% 
% This dynablackClass method performs the dynablack fits and passes results back out to the controller through the results struct.
%
% INPUTS:   dynablackObject         = dynablackClass object
%           dynablackResultsStruct  = dynablack results structure which has been initialized
% OUTPUTS:  dynablackResultsStruct  = dynablack results structure which has been updated
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


% don't perform fits if invalid uow
if ~dynablackObject.validUow
    return;
end

% remove fixed offset and static 2D black from raw data per module parameters
dynablackObject = correct_fixed_offset_and_static_black(dynablackObject);

% mark fits start time
initialTime = clock;

% A1_SingleCadenceFits_vsRow
disp('Perform A1_SingleCadenceFits_vsRow...');
t0 = clock;
dynablackResultsStruct = A1_main( dynablackObject, dynablackResultsStruct );
display_elapsed_time(t0);

% % A2_SingleCadenceFits_vsColumn
disp('Perform A2_SingleCadenceFits_vsColumn...');
t0 = clock;
dynablackResultsStruct = A2_main( dynablackObject, dynablackResultsStruct );
display_elapsed_time(t0);

% B1a_LBTBCoeffFits
disp('Perform B1a_LBTBCoeffFits...');
t0 = clock;
dynablackResultsStruct = B1a_main( dynablackObject, dynablackResultsStruct );
display_elapsed_time(t0);

% B1b_HorizCoeffFits
disp('Perform B1b_HorizCoeffFits...');
t0 = clock;
dynablackResultsStruct = B1b_main( dynablackObject, dynablackResultsStruct );
display_elapsed_time(t0);

% B2a_RBAFlagger
disp('Perform B2a_RBAFlagger...');
t0 = clock;
dynablackResultsStruct = B2a_main( dynablackObject, dynablackResultsStruct );
display_elapsed_time(t0);


% % Moire pattern flagger not implemented.
% % B2b_MPDFlagger
% disp('Perform B2b_MPDFlagger...');
% t0 = clock;
% dynablackResultsStruct = B2b_main( dynablackObject, dynablackResultsStruct );
% display_elapsed_time(t0);
 
% B2c_Monitoring
disp('Perform B2c_Monitoring...');
t0 = clock;
dynablackResultsStruct = B2c_main( dynablackObject, dynablackResultsStruct );
display_elapsed_time(t0);

% % Fourier analysis of Moire patterns not implemented.
% % B3_FourierAnalysis
% disp('Perform B3_FourierAnalysis...');
% t0 = clock;
% dynablackResultsStruct = B3_main( dynablackObject, dynablackResultsStruct );
% display_elapsed_time(t0);
 
% % Implemented  under CAL. 
% % See initialize_dynoblack_models.m and retrieve_dynamic_2d_black.m
% % C3_BlackTimeSeriesGenerator
% disp('Perform C3_BlackTimeSeriesGenerator...');
% t0 = clock;
% dynablackResultsStruct = C3_main( dynablackObject, dynablackResultsStruct );
% display_elapsed_time(t0);


finalTime = clock;
disp(' ');
disp(['Total elapsed time for fits = ',num2str(etime(finalTime,initialTime)/60),' minutes']);
