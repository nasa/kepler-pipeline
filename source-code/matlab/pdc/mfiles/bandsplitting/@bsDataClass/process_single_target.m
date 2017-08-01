function process_single_target(obj,targetIndex)

% pre-conditioning of lightcurves (mainly edge effect mitigation)
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
obj.pre_transform_conditioning(targetIndex);

% split into bands
obj.split_into_bands(targetIndex);

% post-conditioning of lightcurves (undoing pre-conditioning)
obj.post_transform_conditioning(targetIndex);

% plot subbands
%     if (obj.diagnosticStruct.plotSubbands)
%         if (ismember(obj.diagnosticStruct.targetsToMonitor,targetIndex))
%             figure;
%             for k=1:size(obj.allBands,2)
%                 subplot(size(obj.allBands,2),1,k);
%                 plot(obj.allBands(:,k));
%             end
%         end
%     end

% combine bands
% TODO: this method has to be called only once!!!
obj.combine_bands(targetIndex);

% Adjust fields in inputTargetDataStruct and obj.bandsTargetDataStruct{iBand}(targetIndex)
% so that they match, by removing/adding the
% extra/missing fields from inputTargetDataStruct to give it the same
% structure as obj.bandsTargetDataStruct{iBand}(targetIndex)

% Order the fields of inputTargetDataStruct
inputTargetDataStruct = orderfields(obj.inputTargetDataStruct(targetIndex));

% Identify and remove fields of inputTargetDataStruct that are not
% fields of obj.bandsTargetDataStruct{1}(1)
A = fields(inputTargetDataStruct);
B = fields(obj.bandsTargetDataStruct{1}(1));
tf = ~ismember(A,B);
inputTargetDataStruct = rmfield(inputTargetDataStruct,A(tf));


% Identify fields of obj.bandsTargetDataStruct{1}(1) that are not in
% inputTargetDataStruct
tf = ~ismember(B,A);
indices = find(tf');
% Copy these fields from obj.bandsTargetDataStruct{1}(1)
% to inputTargetDataStruct
for jj = indices
    inputTargetDataStruct = setfield(inputTargetDataStruct,B{jj},getfield(obj.bandsTargetDataStruct{1}(1),B{jj}) );
end

% Order the fields
inputTargetDataStruct = orderfields(inputTargetDataStruct);

% Generate results struct for the time domain
% obj.bandsTargetDataStruct is initialized in bsDataClass
% speed up the loop by minimizing the number of times referencing obj
combinedBands = obj.combinedBands;
combinedBandsUncertainties = obj.combinedBandsUncertainties;
for iBand = 1:obj.nBands
    obj.bandsTargetDataStruct{iBand}(targetIndex) = inputTargetDataStruct;
    obj.bandsTargetDataStruct{iBand}(targetIndex).values = combinedBands(:,iBand);
    obj.bandsTargetDataStruct{iBand}(targetIndex).uncertainties = combinedBandsUncertainties(:,iBand);
end

% Generate results struct for the wavelet domain: copy the targetInputStruct and write wavelet coefficients and their
% uncertainties into the .values and .uncertainties fields
% obj.waveletTargetDataStruct is initialized in bsDataClass
% Speed up the loop by minimizing the number of times referencing obj
% Another speedup comes from not having to copy
% inputTargetDataStruct(targetIndex) into
% obj.waveletTargetDataStruct{ii}(targetIndex)
% 05 June 2013 obj.waveletCoefficients and obj.waveletCoefficientsUncertainties are
% [1 x nTargets] arrays of structs
waveletCoefficients = obj.waveletCoefficients{targetIndex};
waveletCoefficientsUncertainties = obj.waveletCoefficientsUncertainties{targetIndex};
for iScale = 1:obj.nScales
    obj.waveletTargetDataStruct{iScale}(targetIndex).values = waveletCoefficients(:,iScale);
    obj.waveletTargetDataStruct{iScale}(targetIndex).uncertainties = waveletCoefficientsUncertainties(:,iScale);
end


end % function
