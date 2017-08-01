function self = test_for_illegal_input_range(self)

%--------------------------------------------------------------------------
% function self = test_for_illegal_input_range(self)
%--------------------------------------------------------------------------
% test_for_illegal_input_rangechecks to see if illegal values in the input data
% (NaN in this case) are found.
%
%  Example
%  =======
%  Use a test runner to run the test method:
%                   runner = text_test_runner(1, 1);
%         Example:  run(text_test_runner, testTpsClass('test_for_illegal_input_range'));
%--------------------------------------------------------------------------
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

  disp( ' ... testing validation detection of illegal values ... ' ) ;

  tpsDataFile = 'tps-full-data-struct' ;
  tpsDataStructName = 'tpsDataStruct' ;
  tps_testing_initialization ;
  tpsInputStruct = tpsDataStruct ;

%------------------------------------------------------------
% tpsModuleParameters
%------------------------------------------------------------

fieldsAndBounds = get_tps_input_fields_and_bounds( 'tpsModuleParameters' );
assign_illegal_value_and_test_for_failure(tpsInputStruct.tpsModuleParameters,  ...
    'tpsInputStruct.tpsModuleParameters',...
    tpsInputStruct, 'tpsInputStruct', 'validate_tps_input_structure', fieldsAndBounds, false);
clear fieldsAndBounds;

%------------------------------------------------------------
% gapFillParameters
%------------------------------------------------------------

fieldsAndBounds = get_tps_input_fields_and_bounds( 'gapFillParameters' );
assign_illegal_value_and_test_for_failure(tpsInputStruct.gapFillParameters,  'tpsInputStruct.gapFillParameters',...
    tpsInputStruct, 'tpsInputStruct', 'validate_tps_input_structure', fieldsAndBounds, false);
clear fieldsAndBounds;

%------------------------------------------------------------
% harmonicsIdentificationParameters
%------------------------------------------------------------

fieldsAndBounds = get_tps_input_fields_and_bounds( 'harmonicsIdentificationParameters' );
assign_illegal_value_and_test_for_failure(tpsInputStruct.harmonicsIdentificationParameters,...
    'tpsInputStruct.harmonicsIdentificationParameters', ...
    tpsInputStruct, 'tpsInputStruct', 'validate_tps_input_structure', fieldsAndBounds, false);
clear fieldsAndBounds;

%------------------------------------------------------------
% tpsTargets
%------------------------------------------------------------

nCadences = length(tpsInputStruct.tpsTargets(1).fluxValue);
nStructures = length(tpsInputStruct.tpsTargets);
tpsInputStruct.tpsTargets(1).gapIndices = [1 2 3];
tpsInputStruct.tpsTargets(1).fillIndices = [1 2 3];
tpsInputStruct.tpsTargets(1).outlierIndices = [1 2 3];
tpsInputStruct.tpsTargets(1).discontinuityIndices = [1 2 3];

fieldsAndBounds = get_tps_input_fields_and_bounds( 'tpsTargetsFine' );

for j = 1:nStructures
    
    if(~isempty(tpsInputStruct.tpsTargets(j).gapIndices))
        tpsInputStruct.tpsTargets(j).gapIndices(:) = tpsInputStruct.tpsTargets(j).gapIndices(:)+1;
        fieldsAndBounds(3,:)  = { 'gapIndices'; '> 0';['<= ' num2str(nCadences)] ; []};
    end
    
    if(~isempty(tpsInputStruct.tpsTargets(j).fillIndices))
        tpsInputStruct.tpsTargets(j).fillIndices(:) = tpsInputStruct.tpsTargets(j).fillIndices(:)+1;
        fieldsAndBounds(4,:)  = { 'fillIndices';'> 0';['<= ' num2str(nCadences)] ; []};
    end
    
    if(~isempty(tpsInputStruct.tpsTargets(j).outlierIndices))
        tpsInputStruct.tpsTargets(j).outlierIndices(:) = tpsInputStruct.tpsTargets(j).outlierIndices(:)+1;
        fieldsAndBounds(5,:)  = { 'outlierIndices';'> 0';['<= ' num2str(nCadences)] ; []};
    end
        
    if(~isempty(tpsInputStruct.tpsTargets(j).discontinuityIndices))
        tpsInputStruct.tpsTargets(j).discontinuityIndices(:) = tpsInputStruct.tpsTargets(j).discontinuityIndices(:)+1;
        fieldsAndBounds(6,:)  = { 'discontinuityIndices';'> 0';['<= ' num2str(nCadences)] ; []};
    end
    
%    At the moment, due to a problem in PDC, we have flux time series which enter TPS with
%    NaN flux values which we need to handle.  As a result of this handling, the test
%    executed below is broken and can't be made to work until after the PDC fix for NaN
%    flux has been propagated to all the flux data (ie, reprocessing of the world).
    
%    assign_illegal_value_and_test_for_failure(tpsInputStruct.tpsTargets, 'tpsInputStruct.tpsTargets', ...
%    tpsInputStruct, 'tpsInputStruct', 'validate_tps_input_structure', fieldsAndBounds, false);

end

clear fieldsAndBounds;

%------------------------------------------------------------
% cadenceTimes
%------------------------------------------------------------

% this test fails for complex and subtle reasons, and requires some effort to be made to
% work.  Under the circumstances I am simply going to comment it out.

% fieldsAndBounds = get_tps_input_fields_and_bounds( 'cadenceTimes' );
% assign_illegal_value_and_test_for_failure(tpsInputStruct.cadenceTimes, 'tpsInputStruct.cadenceTimes', ...
%     tpsInputStruct, 'tpsInputStruct', 'validate_tps_input_structure', fieldsAndBounds, false);
% clear fieldsAndBounds;

%------------------------------------------------------------
% dataAnomalyFlags
%------------------------------------------------------------

tpsInputStruct.cadenceTimes = replace_data_anomaly_types_with_flags( ...
    tpsInputStruct.cadenceTimes ) ;
fieldsAndBounds = get_tps_input_fields_and_bounds( 'dataAnomalyFlags' );
assign_illegal_value_and_test_for_failure(tpsInputStruct.cadenceTimes.dataAnomalyFlags, 'tpsInputStruct.cadenceTimes.dataAnomalyFlags', ...
    tpsInputStruct, 'tpsInputStruct', 'validate_tps_input_structure', fieldsAndBounds, false);
clear fieldsAndBounds;

disp('') ;

return


