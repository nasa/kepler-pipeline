function [pmdOutputStruct, pmdTempStruct] = pmd_track_trend_cosmic_ray_metrics(pmdTsStruct, pmdOutputStruct, pmdTempStruct, parameters, ...
    cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, crString, ...
    fieldString1, titleString)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [pmdOutputStruct, pmdTempStruct] = pmd_track_trend_cosmic_ray_metrics(pmdTsStruct, pmdOutputStruct, pmdTempStruct, parameters, ...
%   cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, crString, fieldString1)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function performs track and trend analysis of cosmic ray metrics.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

if      strcmp(fieldString1, 'hitRate'       )  
    fieldString2 = 'HitRate';
elseif  strcmp(fieldString1, 'meanEnergy'    )  
    fieldString2 = 'MeanEnergy';
elseif  strcmp(fieldString1, 'energyVariance')  
    fieldString2 = 'EnergyVariance';
elseif  strcmp(fieldString1, 'energySkewness')  
    fieldString2 = 'EnergySkewness';
elseif  strcmp(fieldString1, 'energyKurtosis')  
    fieldString2 = 'EnergyKurtosis';
else
    return;
end
if (~exist('titleString', 'var') || isempty(deblank(titleString)))
    titleString = char([]) ;
end
scale = false ;

eval(['tsMetric        = pmdTsStruct.'   crString 'CosmicRayMetrics.' fieldString1 ';']);
eval(['smoothingFactor = parameters.'    crString 'CosmicRay' fieldString2 'SmoothingFactor;']);
eval(['lowerBound      = parameters.'    crString 'CosmicRay' fieldString2 'FixedLowerBound;']);
eval(['upperBound      = parameters.'    crString 'CosmicRay' fieldString2 'FixedUpperBound;']);
eval(['adaptiveXFactor = parameters.'    crString 'CosmicRay' fieldString2 'AdaptiveXFactor;']);

metricName = [ crString 'CosmicRay ' fieldString1];

[metricReport, metricTempData] = ppa_create_report(parameters, tsMetric, smoothingFactor, lowerBound, upperBound, adaptiveXFactor, ...
    metricName, cadenceTimestamps, cadenceGapIndicators, ccdModule, ccdOutput, scale, ...
    titleString);

eval(['pmdOutputStruct.report.'          crString 'CosmicRayMetrics.' fieldString1 ' = metricReport;'   ]);
eval(['pmdTempStruct.'                   crString 'CosmicRayMetrics.' fieldString1 ' = metricTempData;' ]);

return