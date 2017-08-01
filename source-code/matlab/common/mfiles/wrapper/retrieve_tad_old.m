function tadInputStruct = retrieve_tad(module, output, targetListSetName, includeRejected)
%function tadInputStruct = retrieve_tad(module, output, targetListSetName, includeRejected)
%
% If includeRejected is present ant true, then rejected targets will also
% be included (note that they will not have a targetDefinition since they
% were rejected).
% rejected is true if:
% - in merge if the skyGroupId is 0
% - in coa if no aperture is returned by matlab
% - in ama if the status is -2
%
% Returns a tadInputStruct similar to the following:
%
%
%  targetDefinitions: [1x3202 struct]
%    keplerId
%    maskIndex
%    referenceRow
%    referenceColumn
%    excessPixels
%    status
%  targets: [1x3065 struct]
%    keplerId
%    labels
%    referenceRow
%    referenceColumn
%    offsets
%    snr
%    badPixelCount
%    crowdingMetric
%    skyCrowdingMetric
%    fluxFractionInAperture
%    rejected
%    SNR
%    distanceFromEdge
%    isUserDefined
%    magnitude
%    ra
%    dec
%    effectiveTemp
%  maskDefinitions: [1x1024 struct]
%  coaImage: [1070x1132 double]
%  backgroundTargetDefinitions: [1x1116 struct]
%  backgroundMaskDefinitions: [1x1 struct]
%
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

import gov.nasa.kepler.systest.sbt.SandboxTools;
SandboxTools.displayDatabaseConfig;

import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;

dbService = DatabaseServiceFactory.getInstance();
targetSelectionCrud = TargetSelectionCrud(dbService);
targetCrud = TargetCrud(dbService);

targetListSet = targetSelectionCrud.retrieveTargetListSet(targetListSetName);

if(isempty(targetListSet))
    error('retrieve_tad: No targetListSet found for name=%s', targetListSetName);
end

targetTable = targetListSet.getTargetTable();

if(isempty(targetTable))
    error('retrieve_tad: No targetTable found for targetListSetName=%s', targetListSetName);
end

% target definitions
targetDefinitions = targetCrud.retrieveTargetDefinitions(targetTable, module, output).toArray();

if(isempty(targetDefinitions))
    % No target defs for this mod/out
    tadInputStruct = [];
    SandboxTools.close;
    return;
end

tadInputStruct.targetDefinitions = copyTargetDefs(targetDefinitions);

% observed targets
if(nargin >3 && includeRejected)
    observedTargets = targetCrud.retrieveObservedTargetsPlusRejected(targetTable, module, output).toArray();
else
    observedTargets = targetCrud.retrieveObservedTargets(targetTable, module, output).toArray();
end;

tadInputStruct.targets = copyTargets(observedTargets);

% mask definitions
maskTable = targetTable.getMaskTable();

if(isempty(maskTable))
    error('retrieve_tad: No maskTable found for targetListSetName=%s', targetListSetName);
end

maskDefinitions = targetCrud.retrieveMasks(maskTable).toArray();

if(isempty(maskDefinitions))
    error('retrieve_tad: No maskDefinitions found for targetListSetName=%s', targetListSetName);
end

tadInputStruct.maskDefinitions = copyMaskDefs(maskDefinitions);

% The associated LC TLS is only set for short cadence and reference pixel
% target list sets.  If it is set, get the background tables and the COA
% image from there.
associatedLcTls = targetListSet.getAssociatedLcTls();

if(~isempty(associatedLcTls))
    % get backgroundTargetTable from the associated LC TLS
    backgroundTargetTable = associatedLcTls.getBackgroundTable();
    
    % get COA image from the associated LC TargetTable
    lcTargetTable = associatedLcTls.getTargetTable();
    coaImage = targetCrud.retrieveImage(lcTargetTable, module, output);
    tadInputStruct.coaImage = coaImage.getModuleOutputImage();
else
    % get backgroundTargetTable from this TLS
    backgroundTargetTable = targetListSet.getBackgroundTable();

    % get COA image from this TargetTable
    coaImage = targetCrud.retrieveImage(targetTable, module, output);
    if isempty(coaImage)
        tadInputStruct.coaImage = [];
    else
        tadInputStruct.coaImage = coaImage.getModuleOutputImage();
    end
end

if(~isempty(backgroundTargetTable))
    % background target definitions
    backgroundTargetDefinitions = targetCrud.retrieveTargetDefinitions(backgroundTargetTable, module, output).toArray();

    if(isempty(backgroundTargetDefinitions))
        error('retrieve_tad: No backgroundTargetDefinitions found for targetListSetName=%s', targetListSetName);
    end

    tadInputStruct.backgroundTargetDefinitions = copyTargetDefs(backgroundTargetDefinitions);

    % background mask definitions
    backgroundMaskTable = backgroundTargetTable.getMaskTable();

    if(isempty(backgroundMaskTable))
        error('retrieve_tad: No backgroundMaskTable found for targetListSetName=%s', targetListSetName);
    end

    backgroundMaskDefinitions = targetCrud.retrieveMasks(backgroundMaskTable).toArray();

    if(isempty(backgroundMaskDefinitions))
        error('retrieve_tad: No backgroundMaskDefinitions found for targetListSetName=%s', targetListSetName);
    end

    tadInputStruct.backgroundMaskDefinitions = copyMaskDefs(backgroundMaskDefinitions);
else
    warning('retrieve_tad: No Background Table found for targetListSetName=%s', targetListSetName);
end

% Clear Hibernate cache
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
dbService = DatabaseServiceFactory.getInstance();
dbService.clear();

SandboxTools.close;
return

% copy the relevant fields from the Java List<TargetDefinition> to the
% MATLAB struct array
function matlabTargetDefinitions = copyTargetDefs(javaTargetDefinitions)

matlabTargetDefinitions = repmat(struct('keplerId', [], 'maskIndex', [], 'referenceRow', [], 'referenceColumn', [], ...
    'excessPixels', [], 'status', []), 1, length(javaTargetDefinitions));

for i = 1:length(javaTargetDefinitions)
    mask = javaTargetDefinitions(i).getMask();

    matlabTargetDefinitions(i).keplerId = javaTargetDefinitions(i).getKeplerId();
    matlabTargetDefinitions(i).maskIndex = mask.getIndexInTable();
    matlabTargetDefinitions(i).referenceRow = javaTargetDefinitions(i).getReferenceRow();
    matlabTargetDefinitions(i).referenceColumn = javaTargetDefinitions(i).getReferenceColumn();
    matlabTargetDefinitions(i).excessPixels = javaTargetDefinitions(i).getExcessPixels();
    matlabTargetDefinitions(i).status = javaTargetDefinitions(i).getStatus();
end;

import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
dbInstance = DatabaseServiceFactory.getInstance();
dbInstance.clear();

return

% copy the relevant fields from the Java List<ObservedTarget> to the
% MATLAB struct array
function matlabTargets = copyTargets(javaTargets)

matlabTargets = repmat(struct('keplerId', [], 'labels', [], 'referenceRow', [], 'referenceColumn', [], ...
    'offsets', [], 'snr', [], 'badPixelCount', [], 'crowdingMetric', [], 'skyCrowdingMetric', [], ...
    'fluxFractionInAperture', [], 'rejected', []), 1, length(javaTargets));

for i = 1:length(javaTargets)
    matlabTargets(i).keplerId = javaTargets(i).getKeplerId();
    matlabTargets(i).SNR = javaTargets(i).getSignalToNoiseRatio();
    matlabTargets(i).badPixelCount = javaTargets(i).getBadPixelCount();
    matlabTargets(i).crowdingMetric = javaTargets(i).getCrowdingMetric();
    matlabTargets(i).skyCrowdingMetric = javaTargets(i).getSkyCrowdingMetric();
    matlabTargets(i).fluxFractionInAperture = javaTargets(i).getFluxFractionInAperture();
    matlabTargets(i).distanceFromEdge = javaTargets(i).getDistanceFromEdge();
    matlabTargets(i).rejected = javaTargets(i).isRejected();
    matlabTargets(i).magnitude = javaTargets(i).getMagnitude();
    matlabTargets(i).ra = javaTargets(i).getRa();
    matlabTargets(i).dec = javaTargets(i).getDec();
    matlabTargets(i).effectiveTemp = javaTargets(i).getEffectiveTemp();
    
    labelsSet = javaTargets(i).getLabels();
    labelsArray = labelsSet.toArray();
    matlabTargets(i).labels = cell(length(labelsArray),1);
    
    for k = 1:length(labelsArray)
        matlabTargets(i).labels{k} = labelsArray(k);
    end;

    optimalAperture = javaTargets(i).getAperture();
    
    if(~isempty(optimalAperture))
        matlabTargets(i).referenceRow = optimalAperture.getReferenceRow();
        matlabTargets(i).referenceColumn = optimalAperture.getReferenceColumn();
        matlabTargets(i).isUserDefined = optimalAperture.isUserDefined();

        optApOffsets = optimalAperture.getOffsets();
        optApOffsetsArray = optApOffsets.toArray();
        matlabTargets(i).offsets = repmat(struct('row', [], 'column', []), 1, length(optApOffsetsArray));

        for j = 1:length(optApOffsetsArray)
            matlabTargets(i).offsets(j).row = optApOffsetsArray(j).getRow();
            matlabTargets(i).offsets(j).column = optApOffsetsArray(j).getColumn();
        end;
    end;
end;

return

% copy the relevant fields from the Java List<Mask> to the
% MATLAB struct array
function matlabMaskDefinitions = copyMaskDefs(javaMaskDefinitions)

matlabMaskDefinitions = repmat(struct('offsets', []), 1, length(javaMaskDefinitions));

for i = 1:length(javaMaskDefinitions)
    javaOffsets = javaMaskDefinitions(i).getOffsets();
    javaOffsets = javaOffsets.toArray();

    matlabTargetDefinitions.maskDefinitions(i).offsets = repmat(struct('row', [], 'column', []), 1, length(javaOffsets));

    for j = 1:length(javaOffsets)
        matlabMaskDefinitions(i).offsets(j).row = javaOffsets(j).getRow();
        matlabMaskDefinitions(i).offsets(j).column = javaOffsets(j).getColumn();
    end;

end;

return;
