function fpgInputStruct = make_fpg_inputs_from_pa(paOutputs, exampleFpgInputs)
% function fpgInputStruct = make_fpg_inputs_from_pa(paOutputs, exampleFpgInputs)
% paOutputs is an array of pa ouput structures
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
fpgInputStruct.version = exampleFpgInputs.version;
fpgInputStruct.debug = 0;
fpgInputStruct.fcConstants = convert_fc_constants_java_2_struct();
fpgInputStruct.timestampSeries = exampleFpgInputs.timestampSeries;
fpgInputStruct.fpgModuleParameters = exampleFpgInputs.fpgModuleParameters;
fpgInputStruct.fpgModuleParameters.doRobustFit = 0;
fpgInputStruct.fpgModuleParameters.maxBadDataCutoff = 1;
fpgInputStruct.raDec2PixModel = retrieve_ra_dec_2_pix_model();
for i=1:length(paOutputs)
    fpgInputStruct.motionBlobsStruct(i).blobIndices ...
        = zeros(size(paOutputs(i).targetStarResultsStruct(1).fluxTimeSeries(1).values));
    fpgInputStruct.motionBlobsStruct(i).gapIndicators ...
        = false(size(fpgInputStruct.motionBlobsStruct(i).blobIndices));
    fpgInputStruct.motionBlobsStruct(i).blobFilenames = {paOutputs(i).motionBlobFileName};
    fpgInputStruct.motionBlobsStruct(i).startCadence = 1;
    fpgInputStruct.motionBlobsStruct(i).endCadence ...
        = length(fpgInputStruct.motionBlobsStruct(i).blobIndices);
end
fpgInputStruct.geometryBlobFileName = exampleFpgInputs.geometryBlobFileName;

