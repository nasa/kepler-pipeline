% function [ bsTargetResultsStructs , bsDataObject ] = bs_controller_split( 
%                             bsTargetInputStruct , 
%                             bsConfigStruct , 
%                             bsDiagnosticInputStruct)
%
%    INPUTS:
%        bsTargetInputStruct
%            targetDataStruct, just like regular input to MAP in PDCC
%        bsConfigStruct
%            band splitting configuration parameters, see (...) for field definitions
%        bsDiagnosticInputStruct
%            diagnostic parameters
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

function [bsTargetResultsStructs, bsDataObject] = bs_controller_split(bsTargetInputStruct, bsConfigStruct, bsDiagnosticInputStruct )

% create main band splitting object
bsDataObject = bsDataClass(bsTargetInputStruct,bsConfigStruct,bsDiagnosticInputStruct);
bsDataObject.process_all_targets();

% outputs
bsTargetResultsStructs.bands = bsDataObject.bandsTargetDataStruct;
bsTargetResultsStructs.wavelets = bsDataObject.waveletTargetDataStruct;

% added this line in case bsDiagnosticInputStruct input is empty
if(isempty(bsDiagnosticInputStruct))
    bsDiagnosticInputStruct = bsDataObject.diagnosticStruct;
end

% Decide what to save, based on parameters set in bsDiagnosticInputStruct
if (bsDiagnosticInputStruct.saveBandSplittingObject)
    
    % save bsDataStruct for diagnostic purposes
    bsDataStruct = struct(bsDataObject);
    intelligent_save('bsDataStruct', 'bsDataStruct');
    clear bsDataStruct;
    
elseif(bsDiagnosticInputStruct.saveMultiResolutionAnalysis)
    
    % Save multiresolution analysis (wavelet coefficients and all the flux bands)
    % as well as bsInfoStruct
    bsWaveletStruct = bsDataObject.waveletTargetDataStruct;
    waveletCoefficients = bsDataObject.waveletCoefficients;
    bsAllBands = bsDataObject.allBands;
    bsInfoStruct = bsDataObject.infoStruct;
    
    % Save for bandsplitting diagnostics
    % intelligent_save('bsWaveletStruct', 'bsWaveletStruct');
    intelligent_save('bsWaveletCoefficients', 'waveletCoefficients');
    intelligent_save('bsAllBands', 'bsAllBands');
    intelligent_save('bsInfoStruct', 'bsInfoStruct');
else
    
    % Save minimal info for bandsplitting diagnostics
    bsInfoStruct = bsDataObject.infoStruct;
    intelligent_save('bsInfoStruct', 'bsInfoStruct');
    % bsTargetDataStruct = bsDataObject.bandsTargetDataStruct;
    % intelligent_save('bsTargetDataStruct', 'bsTargetDataStruct');
end

end



