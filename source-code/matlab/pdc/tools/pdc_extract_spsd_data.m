function spsdOutputStruct = pdc_extract_spsd_data(spsdControllerResult,targetDataStruct,fluxCorrectionStruct)
% function spsdOutputStruct = pdc_extract_spsd_data(spsdControllerResult,targetDataStruct,fluxCorrectionStruct)
%      this function extracts the SPSD data for the targets in targetDataStruct
%      purpose: detecting and correcting SPSDs requires an ensemble of light curves
%               however, a whole ensemble of light curves (e.g. a full mod.out) is impossible to use
%               while developing and testing PDC 8.0
%               this function emulates the generation of SPSD data by looking up the respective values
%               from a preprocessed run (with all targets)
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

    nTargets = length(targetDataStruct);
    
    spsdOutputStruct.clean.count = 0;
    spsdOutputStruct.clean.index = [];
    spsdOutputStruct.clean.keplerId = [];
    spsdOutputStruct.spsds.count = 0;
    spsdOutputStruct.spsds.index = [];
    spsdOutputStruct.spsds.keplerId = [];
    
    for i=1:nTargets        
        idxClean = find( targetDataStruct(i).keplerId  == spsdControllerResult.clean.keplerId );
        idxSpsd = find ( targetDataStruct(i).keplerId  == spsdControllerResult.spsds.keplerId );
        if (~isempty(idxClean))
            spsdOutputStruct.clean.count = spsdOutputStruct.clean.count+1;
            spsdOutputStruct.clean.index(spsdOutputStruct.clean.count) = i; % spsdControllerResult.clean.index(idxClean);
            spsdOutputStruct.clean.keplerId(spsdOutputStruct.clean.count) = spsdControllerResult.clean.keplerId(idxClean);
        end
        if (~isempty(idxSpsd))
            spsdOutputStruct.spsds.count = spsdOutputStruct.spsds.count+1;
            spsdOutputStruct.spsds.index(spsdOutputStruct.spsds.count) = i; % spsdOutputStruct.spsds.count;
            spsdOutputStruct.spsds.keplerId(spsdOutputStruct.spsds.count) = spsdControllerResult.spsds.keplerId(idxSpsd);
            spsdOutputStruct.spsds.target(spsdOutputStruct.spsds.count) = spsdControllerResult.spsds.targets(idxSpsd);
            spsdOutputStruct.spsds.target(spsdOutputStruct.spsds.count).index = spsdOutputStruct.spsds.count;
            spsdOutputStruct.spsds.target(spsdOutputStruct.spsds.count).cumulativeCorrection = spsdOutputStruct.spsds.target(spsdOutputStruct.spsds.count).cumulativeCorrection ./ fluxCorrectionStruct(i).medianFlux;
        end
    end

end

