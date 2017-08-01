function [dvDataObject, dvResultsStruct] = ...
                inject_transit_signature_into_centroid_data(dvDataObject,dvResultsStruct,...
                                                            targetIndex,raOffset,decOffset,...
                                                            epochBaryBkjd,period,duration)
%
% function [dvDataObject, dvResultsStruct] = ...
%                 inject_transit_signature_into_centroid_data(dvDataObject,dvResultsStruct,...
%                                                             targetIndex,raOffset,decOffset,...
%                                                             epochBaryBkjd,period,duration)
%
% Inject a transit-like signautre into the centroid timeseries for a single target in dvDataObject.
%
% INPUT:    dvDataObject                = data object as defined in dv_matlab_controller
%           dvResultsStruct             = data results struct as defined in dv_matlab_controller
%           targetIndex[int]            = index into dvDataObject.targetStruct
%           raOffset[double]            = amplitude of "transit' offset in the
%                                         row direction (degrees).
%           decOffset[double]           = amplitude of "transit' offset in the
%                                         column direction (degrees).
%           epochBaryBkjd[double]       = center time of first transit in
%                                         Barycentric Kepler Julian Days (days)
%           period[double]              = period of transit feature (days)
%           duration[double]            = duration of transit feature (hours)
% OUTPUT:   dvDataObject                = data object as input with
%                                         centroid time series modified.
%           dvResultsStruct             = data results struct with planet
%                                         transit added which matches
%                                         injected signature.
%
%
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



% ~~~~~~~~~~~~~~~~~~ build motion polynomials array
% Apparently motion polynomials only exist for the cadences run in PA (e.g. NOT in the quarterly roll gaps)
% Need to fill out the struct array for all cadences in UOW
tempMotion = [dvDataObject.targetTableDataStruct.motionPolyStruct];
motionCadencenumbers = [tempMotion.cadence];
cadenceNumbers = dvDataObject.dvCadenceTimes.cadenceNumbers;

% pick off single struct element and set invalid
singleMotionStruct = tempMotion(1);
singleMotionStruct.cadence = 0;
singleMotionStruct.rowPolyStatus = 0;
singleMotionStruct.colPolyStatus = 0;

% allocate space for a full array of motion polynomials
motionPolynomials = repmat(singleMotionStruct,length(cadenceNumbers),1);

% find which cadences we have motion polys for
[motionLogical, foundIdx] = ismember(cadenceNumbers, motionCadencenumbers);

% copy motion polys into full structure
motionPolynomials(motionLogical) = tempMotion(foundIdx(motionLogical));
clear tempMotion singleMotionStruct motionCadencenumbers


% parse needed fields
targetStruct = dvDataObject.targetStruct(targetIndex);
targetStruct.debugLevel = dvDataObject.dvConfigurationStruct.debugLevel;

planetFitConfigurationStruct = dvDataObject.planetFitConfigurationStruct;
trapezoidalFitConfigurationStruct = dvDataObject.trapezoidalFitConfigurationStruct;

configMaps = dvDataObject.configMaps;

% fractional transit depth in ppm
dummyTransitDepthPpm = 100;             

% As of 8/14/09 - Model parameter names and order in test data set
% {dvResultsStruct.targetResultsStruct(1).planetResultsStruct.allTransitsFit.modelParameters.name}'
% ans =
%     'eccentricity'
%     'transitEpochMjd'
%     'semiMajorAxisAu'
%     'minImpactParameter'
%     'planetRadiusEarthRadii'
%     'starRadiusSolarRadii'
%     'transitIngressTimeHours'
%     'transitDurationHours'
%     'orbitalPeriodDays'
%     'transitDepthPpm'
%     'longitudeOfPeriDegrees'
%
% Use function to get parameter list from fitter class


% build transit model struct for additional planet
paramList = get_planet_model_legal_fields('all');

% find indices of parameters which define injected signal
iEpoch      = find(strcmpi('transitEpochBkjd',paramList),1);
iDuration   = find(strcmpi('transitDurationHours',paramList),1);
iPeriod     = find(strcmpi('orbitalPeriodDays',paramList),1);
iDepth      = find(strcmpi('transitDepthPpm',paramList),1);


% initialize array of model parameters
modelParameters = repmat(struct('name','',...
                                'value',0,...
                                'uncertainty',-1,...
                                'fitted',false),...
                                length(paramList),1);

% load parameter names                                        
for jParam=1:length(paramList)
    modelParameters(jParam).name = paramList{jParam};    
end

% load parameter values
modelParameters(iEpoch).value           = epochBaryBkjd;
modelParameters(iEpoch).uncertainty     = 0;
modelParameters(iDuration).value        = duration;
modelParameters(iDuration).uncertainty  = 0;
modelParameters(iPeriod).value          = period;
modelParameters(iPeriod).uncertainty    = 0;
modelParameters(iDepth).value           = dummyTransitDepthPpm;
modelParameters(iDepth).uncertainty     = 0;

% use last planet results struct as seed
transitStruct = dvResultsStruct.targetResultsStruct(targetIndex).planetResultsStruct(end).allTransitsFit;

% populate only needed fields
transitStruct.fullConvergence = true;
transitStruct.modelChiSquare  = 1;
transitStruct.modelParameterCovariance = zeros(length(paramList));
transitStruct.modelParameters = modelParameters;
transitStruct.planetNumber = transitStruct.planetNumber + 1;
transitStruct.transitModelName = 'gaussian';

% add this transit signature as the next planet in the results struct
newPlanetStruct = dvResultsStruct.targetResultsStruct(targetIndex).planetResultsStruct(end);
newPlanetStruct.allTransitsFit = transitStruct;
dvResultsStruct.targetResultsStruct(targetIndex).planetResultsStruct(end+1) = newPlanetStruct;
dvResultsStruct.targetResultsStruct(targetIndex).planetResultsStruct(end).planetNumber = transitStruct.planetNumber;

% convert row/column to ra/dec centroids using inverse motion polynomials
raDecCentroids = convert_row_col_centroids_to_ra_dec(targetStruct,...
                                                        motionPolynomials,...
                                                        dvDataObject.fcConstants);

% produce transit signature at barycentric timestamps
t = dvDataObject.barycentricCadenceTimes.midTimestamps;
transitModel = retrieve_dv_centroid_model_transit(transitStruct,...
                                                    targetStruct,...
                                                    t,...
                                                    planetFitConfigurationStruct,...
                                                    trapezoidalFitConfigurationStruct,...
                                                    configMaps);

quarters = dvDataObject.dvCadenceTimes.quarters;
gaps = dvDataObject.dvCadenceTimes.gapIndicators;
uniqueQuarters = unique(quarters(~gaps));                                                
                                                    
% run twice - once for prf centroids and once for fluxWeighted centroids
pass = 0;
while(pass<2)
    pass = pass + 1;
    if(pass == 1)
        centroidType = 'prf';
    else
        centroidType = 'fluxWeighted';
    end

    % parse ra/dec centroids
    raCentroid = raDecCentroids.(centroidType).ra.values;
    decCentroid = raDecCentroids.(centroidType).dec.values;

    % inject singal in each quarter separately
    for iQuarter = rowvec(uniqueQuarters)
        validCadences = quarters == iQuarter;
        % inject signature into ra/dec centroid time series
        raCentroid(validCadences) = raCentroid(validCadences) - raOffset .* transitModel(validCadences)./(dummyTransitDepthPpm * 1e-6);
        decCentroid(validCadences) = decCentroid(validCadences) - decOffset .* transitModel(validCadences)./(dummyTransitDepthPpm * 1e-6);
    end
    
    % overwrite ra/dec centroids
    raDecCentroids.(centroidType).ra.values = raCentroid;
    raDecCentroids.(centroidType).dec.values = decCentroid;
end

% convert ra/dec to row/column centroids using motion polynomials
rowColCentroids = convert_ra_dec_centroids_to_row_col(raDecCentroids,motionPolynomials);

% deal these back into dvDataObject
[targetStruct.centroids.prfCentroids.rowTimeSeries.values] = deal(rowColCentroids.prf.row.values);
[targetStruct.centroids.prfCentroids.columnTimeSeries.values] = deal(rowColCentroids.prf.col.values);
[targetStruct.centroids.fluxWeightedCentroids.rowTimeSeries.values] = deal(rowColCentroids.fluxWeighted.row.values);
[targetStruct.centroids.fluxWeightedCentroids.columnTimeSeries.values] = deal(rowColCentroids.fluxWeighted.col.values);

% update dataObject
targetStruct = rmfield(targetStruct,'debugLevel');
dvDataObject.targetStruct(targetIndex) = targetStruct;




