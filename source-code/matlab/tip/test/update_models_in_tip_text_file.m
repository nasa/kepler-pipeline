function os = update_models_in_tip_text_file( filename, configMaps )
% function os = update_models_in_tip_text_file( filename, configMaps )
%
% This TIP tool may be used to update the parameters in the TIP text file
% such that the parameters are as described in the -- ADJUST PARAMETERS --
% section below. These derived parameters are then updated using the
% transitGeneratorClass and written back out to the same file input. This
% file is checked to be sure it is a valid TIP file. An output struct
% containing the updated parameters is also available. 
%
% INPUTS:
%   filename      == TIP text filename, e.g. kplr2014259224025-01_tip.txt
%   configMaps    == configMaps from the original TIP inputsStruct
% OUTPUTS:
%   os            == output struct containing the updated parameters
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

% check that we've actually got a valid TIP file as input
display(['Validating TIP output file ',filename,' ...']);
if ~isvalid_transit_injection_parameters_file( filename )
    error(['Input TIP text file ',filename,' does not contain a valid set of simulation parameters.']);
end

% read the text file input
is = read_simulated_transit_parameters(filename);

% -- ADJUST PARAMETERS -- put your parameter adjusting TIP functions here!
os = adjust_model_parameters_per_mes(is);

% set up structs to update and check consistancy of parameters
simStruct = build_simulated_transits_struct_from_tip_parameter_struct(os);
simStruct.configMaps = configMaps;

% update derived parameters using transitGeneratorClass
simStruct = update_planet_model_with_derived_parameters(simStruct);

% build struct to output
os = update_tip_parameter_struct_from_simulated_transits_struct(os, simStruct);

% write the file back where it came from
display(['Writing TIP output file ',filename,' ...']);
write_simulated_transit_parameters( filename, os );

% check that we've actually written a valid TIP file
display(['Validating TIP output file ',filename,' ...']);
if ~isvalid_transit_injection_parameters_file( filename )
    error(['TIP tool produced the text file ',filename,' which does not contain a valid set of simulation parameters.']);
end