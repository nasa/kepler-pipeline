function tadTargets = retrieve_tad_targets(module, output, targetListSetName, includeRejected)
%function tadTargets = retrieve_tad_targets(module, output, targetListSetName, includeRejected)
% 
% Returns the the target struct (product of TAD/COA) for all targets on the
% specified module output.  Does not require that the products of the rest 
% of the TAD pipeline (BPA/AMT/AMA) be present in the database.
%
% If includeRejected is present and true, then rejected targets will also
% be included.
% rejected is true if:
% - in merge if the skyGroupId is 0
% - in coa if no aperture is returned by matlab
% - in ama if the status is -2
%
% Returns a tadTargets struct similar to the following:
%
%
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
%  coaImage: [1070x1132 double]
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

% observed targets
if(nargin >3 && includeRejected)
    observedTargets = targetCrud.retrieveObservedTargetsPlusRejected(targetTable, module, output).toArray();
else
    observedTargets = targetCrud.retrieveObservedTargets(targetTable, module, output).toArray();
end;

tadTargets.targets = copyTargets(observedTargets);

% get COA image (only works if this is a long cadence target list set)
coaImage = targetCrud.retrieveImage(targetTable, module, output);
if(~isempty(coaImage))
    tadTargets.coaImage = coaImage.getModuleOutputImage();
else
    warning('retrieve_tad: no COA image available because this is not a long cadence target list set');
end;

% Clear Hibernate cache
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
dbService = DatabaseServiceFactory.getInstance();
dbService.clear();

SandboxTools.close;
return;

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

