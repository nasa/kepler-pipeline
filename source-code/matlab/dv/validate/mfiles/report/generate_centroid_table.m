function centroidsTestTable = generate_centroid_table(motionResults, keplerMag)
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

if (motionResults.motionDetectionStatistic.significance < 0)
    centroidsTestTable = cell(0);
    return;
end

peakRaOffsetSigma= '';
if (motionResults.peakRaOffset.uncertainty > 0)
    peakRaOffsetSigma = sprintf('%1.4f', motionResults.peakRaOffset.value/...
        motionResults.peakRaOffset.uncertainty);
end
peakDecOffsetSigma = '';
if (motionResults.peakDecOffset.uncertainty > 0)
    peakDecOffsetSigma = sprintf('%1.4f', motionResults.peakDecOffset.value/...
        motionResults.peakDecOffset.uncertainty);
end
peakOffsetSigma = '';
if (motionResults.peakOffsetArcSec.uncertainty > 0)
    peakOffsetSigma = sprintf('%1.4f', motionResults.peakOffsetArcSec.value/...
        motionResults.peakOffsetArcSec.uncertainty);
end
sourceRaOffsetSigma = '';
if (motionResults.sourceRaOffset.uncertainty > 0)
    sourceRaOffsetSigma = sprintf('%1.4f', motionResults.sourceRaOffset.value/...
        motionResults.sourceRaOffset.uncertainty);
end
sourceDecOffsetSigma = '';
if (motionResults.sourceDecOffset.uncertainty > 0)
    sourceDecOffsetSigma = sprintf('%1.4f', motionResults.sourceDecOffset.value/...
        motionResults.sourceDecOffset.uncertainty);
end
sourceOffsetValue = 'N/A';
sourceOffsetUncertainty = '';
sourceOffsetSigma = '';
sourceOffsetUnits = '';
if (motionResults.sourceOffsetArcSec.uncertainty > 0)
    sourceOffsetValue = sprintf('%1.4e', motionResults.sourceOffsetArcSec.value);
    sourceOffsetUncertainty = sprintf('%1.4e', motionResults.sourceOffsetArcSec.uncertainty);
    sourceOffsetSigma = sprintf('%1.4f', motionResults.sourceOffsetArcSec.value/...
        motionResults.sourceOffsetArcSec.uncertainty);
    sourceOffsetUnits = 'arcseconds';
end

sourceRaHoursValue = 'N/A';
sourceRaHoursUncertainty = '';
sourceRaHoursUnits = '';
if (motionResults.sourceRaHours.uncertainty > 0)
    sourceRaHoursValue = sprintf('%1.8f', motionResults.sourceRaHours.value);
    sourceRaHoursUncertainty = sprintf('%1.4e', motionResults.sourceRaHours.uncertainty);
    sourceRaHoursUnits = 'hours';
end

sourceDecDegreesValue = 'N/A';
sourceDecDegreesUncertainty = '';
sourceDecDegreesUnits = '';
if (motionResults.sourceDecDegrees.uncertainty > 0)
    sourceDecDegreesValue = sprintf('%1.8f', motionResults.sourceDecDegrees.value);
    sourceDecDegreesUncertainty = sprintf('%1.4e', motionResults.sourceDecDegrees.uncertainty);
    sourceDecDegreesUnits = 'degrees';
end

centroidsTestTable = {...
    'Stellar Magnitude' sprintf('%1.4f', keplerMag.value) sprintf('%1.4e', keplerMag.uncertainty) '' '' '';
    
    'Motion Detection Statistic' ...
    sprintf('%1.4e', motionResults.motionDetectionStatistic.value) ...
    '' '' '' ...
    sprintf('%1.2f', 100*motionResults.motionDetectionStatistic.significance);
    
    'Peak RA Offset' ...
    sprintf('%1.4e', motionResults.peakRaOffset.value) ...
    sprintf('%1.4e', motionResults.peakRaOffset.uncertainty) ...
    'arcseconds' peakRaOffsetSigma '';
    
    'Peak Dec Offset' ...
    sprintf('%1.4e', motionResults.peakDecOffset.value) ...
    sprintf('%1.4e', motionResults.peakDecOffset.uncertainty) ...
    'arcseconds' peakDecOffsetSigma '';
    
    'Peak Offset Distance' ...
    sprintf('%1.4e', motionResults.peakOffsetArcSec.value) ...
    sprintf('%1.4e', motionResults.peakOffsetArcSec.uncertainty) ...
    'arcseconds' peakOffsetSigma '';
    
    'Source RA Offset' ...
    sprintf('%1.4e', motionResults.sourceRaOffset.value) ...
    sprintf('%1.4e', motionResults.sourceRaOffset.uncertainty) ...
    'arcseconds' sourceRaOffsetSigma '';
    
    'Source Dec Offset' ...
    sprintf('%1.4e', motionResults.sourceDecOffset.value) ...
    sprintf('%1.4e', motionResults.sourceDecOffset.uncertainty) ...
    'arcseconds' sourceDecOffsetSigma '';
    
    'Source Offset Distance' ...
    sourceOffsetValue sourceOffsetUncertainty ...
    sourceOffsetUnits sourceOffsetSigma '';
    
    'Source RA' ...
    sourceRaHoursValue sourceRaHoursUncertainty ...
    sourceRaHoursUnits '' '';
    
    'Source Dec' ...
    sourceDecDegreesValue sourceDecDegreesUncertainty ...
    sourceDecDegreesUnits '' '';
    
    };

