function cdq_validate_input_struct(cdqInputStruct)
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function cdq_validate_input_struct(cdqInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% This function validates cdqInputStruct.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%  Input:
%
%    cdqInputStruct is a structure containing the following fields: 
%
%                        bartOutputDir [string]         A string defining the directory of bart outputs.  
%                    fcConstantsStruct [struct]         Focal plane constants.
%                         channelArray [double array]   Array of channels to be processed.
%          chargeInjectionPixelRemoved [logical]        Flag indicating charge injection pixels are/aren't removed when it is true/false.
%                       modelFileNames [cell array]     Model file names for each module/outputs.
%                   modelFileAvailable [logical array]  Flag indicating the availability of model file for each module/outputs.
%                  daignosticFileNames [cell array]     Diagnostic file names for each module/outputs.
%              diagnosticFileAvailable [logical array]  Flag indicating the availability of diagnostic file for each module/outputs.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

%______________________________________________________________________
% top level validation
% validate the top level fields in cdqInputStruct
%______________________________________________________________________

% pmdInputStruct fields
fieldsAndBounds = cell(8,4);

fieldsAndBounds( 1,:)  = { 'bartOutputDir';                 []; []; [] };           % string
fieldsAndBounds( 2,:)  = { 'fcConstantsStruct';             []; []; [] };           % structure 
fieldsAndBounds( 3,:)  = { 'channelArray';                  []; []; '[1:84]''' };
fieldsAndBounds( 4,:)  = { 'chargeInjectionPixelRemoved';   []; []; [true false] };    
fieldsAndBounds( 5,:)  = { 'modelFileNames';                []; []; [] };           % cell array
fieldsAndBounds( 6,:)  = { 'modelFileAvailable';            []; []; [true false] };    
fieldsAndBounds( 7,:)  = { 'diagnosticFileNames';           []; []; [] };           % cell array
fieldsAndBounds( 8,:)  = { 'diagnosticFileAvailable';       []; []; [true false] };    

validate_structure(cdqInputStruct, fieldsAndBounds, 'cdqInputStruct');

clear fieldsAndBounds;


%______________________________________________________________________
% second level validation
% validate the structure field of cdqInputStruct.fcConstantsStruct
%______________________________________________________________________

fieldsAndBounds = cell(21,4);
fieldsAndBounds( 1,:)  = { 'MODULE_OUTPUTS';                 []; []; []};
fieldsAndBounds( 2,:)  = { 'nRowsImaging';                   []; []; []};
fieldsAndBounds( 3,:)  = { 'nColsImaging';                   []; []; []};
fieldsAndBounds( 4,:)  = { 'nLeadingBlack';                  []; []; []};
fieldsAndBounds( 5,:)  = { 'nTrailingBlack';                 []; []; []};
fieldsAndBounds( 6,:)  = { 'nMaskedSmear';                   []; []; []};
fieldsAndBounds( 7,:)  = { 'nVirtualSmear';                  []; []; []};
fieldsAndBounds( 8,:)  = { 'CCD_ROWS';                       []; []; []};
fieldsAndBounds( 9,:)  = { 'CCD_COLUMNS';                    []; []; []};
fieldsAndBounds(10,:)  = { 'LEADING_BLACK_START';            []; []; []};
fieldsAndBounds(11,:)  = { 'LEADING_BLACK_END';              []; []; []};
fieldsAndBounds(12,:)  = { 'TRAILING_BLACK_START';           []; []; []};
fieldsAndBounds(13,:)  = { 'TRAILING_BLACK_END';             []; []; []};
fieldsAndBounds(14,:)  = { 'MASKED_SMEAR_START';             []; []; []};
fieldsAndBounds(15,:)  = { 'MASKED_SMEAR_END';               []; []; []};
fieldsAndBounds(16,:)  = { 'VIRTUAL_SMEAR_START';            []; []; []};
fieldsAndBounds(17,:)  = { 'VIRTUAL_SMEAR_END';              []; []; []};
fieldsAndBounds(18,:)  = { 'CHARGE_INJECTION_ROW_START';     []; []; []};
fieldsAndBounds(19,:)  = { 'CHARGE_INJECTION_ROW_END';       []; []; []};
fieldsAndBounds(20,:)  = { 'CHARGE_INJECTION_COLUMN_START';  []; []; []};
fieldsAndBounds(21,:)  = { 'CHARGE_INJECTION_COLUMN_END';    []; []; []};

validate_structure(cdqInputStruct.fcConstantsStruct, fieldsAndBounds, 'cdqInputStruct.fcConstantsStruct');

clear fieldsAndBounds;


return
