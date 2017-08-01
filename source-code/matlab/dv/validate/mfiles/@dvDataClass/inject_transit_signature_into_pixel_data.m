function [dvDataObject, dvResultsStruct, oneBasedRowColInjected] = ...
    inject_transit_signature_into_pixel_data(dvDataObject,dvResultsStruct,...
                                                targetIndex,testPixelIdx,...
                                                fractionalTransitDepth,epochBaryBkjd,period,duration)
%
% function [dvDataObject, dvResultsStruct, oneBasedRowColInjected] = ...
%     inject_transit_signature_into_pixel_data(dvDataObject,dvResultsStruct,...
%                                                 targetIndex,testPixelIdx,...
%                                                 fractionalTransitDepth,epochBaryBkjd,period,duration)
%
% Inject a transit-like signautre into the pixel timeseries at one-based
% [row, column] for a single target in dvDataObject.
%
% INPUT:    dvDataObject                = data object as defined in dv_matlab_controller
%           dvResultsStruct             = data results struct as defined in dv_matlab_controller
%           targetIndex[int]            = index into dvDataObject.targetStruct
%           rowOffset[double]           = amplitude of "transit' offset in the
%                                         row direction (pixels).
%           columnOffset[double]        = amplitude of "transit' offset in the
%                                         column direction (pixels).
%           epochBaryBkjd[double]       = center time of first transit in
%                                         Barycentric Kepler Julian Days (days)
%           period[double]              = period of transit feature (days)
%           duration[double]            = duration of transit feature (hours)
% OUTPUT:   dvDataObject                = data object as input with
%                                         centroid time series modified.
%           dvResultsStruct             = data results struct with planet
%                                         transit added which matches
%                                         injected signature.
%           oneBasedRowColInjected      = nx2 array of one based row/column
%                                         coordinates of pixels with
%                                         injected signal
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

% parse needed fields
targetStruct = dvDataObject.targetStruct(targetIndex);
targetStruct.debugLevel = dvDataObject.dvConfigurationStruct.debugLevel;

planetFitConfigurationStruct = dvDataObject.planetFitConfigurationStruct;
trapezoidalFitConfigurationStruct = dvDataObject.trapezoidalFitConfigurationStruct;
configMaps = dvDataObject.configMaps;

% fractional transit depth in ppm
transitDepthPpm = fractionalTransitDepth * 1e6;             


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

% build transit struct for additional planet
transitStruct = dvResultsStruct.targetResultsStruct(targetIndex).planetResultsStruct(end).allTransitsFit;

transitStruct.planetNumber = transitStruct.planetNumber + 1;
transitStruct.transitModelName = 'gaussian';

transitStruct.modelParameters(strcmp({transitStruct.modelParameters.name},'transitEpochBkjd')).value = epochBaryBkjd;
transitStruct.modelParameters(strcmp({transitStruct.modelParameters.name},'transitDurationHours')).value = duration;
transitStruct.modelParameters(strcmp({transitStruct.modelParameters.name},'orbitalPeriodDays')).value = period;
transitStruct.modelParameters(strcmp({transitStruct.modelParameters.name},'transitDepthPpm')).value = transitDepthPpm;

% produce transit signature at barycentric timestamps
t = dvDataObject.barycentricCadenceTimes.midTimestamps;
transitModel = retrieve_dv_centroid_model_transit(transitStruct,...
                                                    targetStruct,...
                                                    t,...
                                                    planetFitConfigurationStruct,...
                                                    trapezoidalFitConfigurationStruct,...
                                                    configMaps);

% convert transit model to fractional out-of-transit value
transitModel = transitModel + 1;

% add this transit signature as the next planet in the results struct
newPlanetStruct = dvResultsStruct.targetResultsStruct(targetIndex).planetResultsStruct(end);
newPlanetStruct.allTransitsFit = transitStruct;
dvResultsStruct.targetResultsStruct(targetIndex).planetResultsStruct(end+1) = newPlanetStruct;
dvResultsStruct.targetResultsStruct(targetIndex).planetResultsStruct(end).planetNumber = transitStruct.planetNumber;

% use first target table to pick off row/column coordinates
rows = [dvDataObject.targetStruct(targetIndex).targetDataStruct(1).pixelDataStruct(testPixelIdx).ccdRow];
cols = [dvDataObject.targetStruct(targetIndex).targetDataStruct(1).pixelDataStruct(testPixelIdx).ccdColumn];
oneBasedRowColInjected = [rows(:), cols(:)];

% inject transitsignature into selected pixels for this target table
for iTable = 1:length( dvDataObject.targetStruct(targetIndex).targetDataStruct )
       
    % parse pixel time series data
    targetDataStruct = dvDataObject.targetStruct(targetIndex).targetDataStruct(iTable);
    pixelTimeSeries = [targetDataStruct.pixelDataStruct.calibratedTimeSeries];
    pixelValues = [pixelTimeSeries.values];

    % find the pixel indices in this table
    thisTableRow = [dvDataObject.targetStruct(targetIndex).targetDataStruct(1).pixelDataStruct.ccdRow];
    thisTableCol = [dvDataObject.targetStruct(targetIndex).targetDataStruct(1).pixelDataStruct.ccdColumn];
    thisTableRowCol = [thisTableRow(:),thisTableCol(:)];
    [TF, thisTableIdx] = ismember(oneBasedRowColInjected,thisTableRowCol, 'rows'); 
    
    % scale selected pixels by modified transit model
    pixelValues(:,testPixelIdx) = scalecol( transitModel, pixelValues(:,thisTableIdx) );
    
    % deal all pixel values back into pixel time series
    [nCadences, nPixels] = size(pixelValues);    
    pixelCellArray = mat2cell(pixelValues,nCadences,ones(1,nPixels));
    [pixelTimeSeries.values] = deal(pixelCellArray{:});

    % deal pixel timeseries back into pixelDataStruct
    pixelTimeSeriesCellArray = mat2cell(pixelTimeSeries,1,ones(1,nPixels));
    [targetDataStruct.pixelDataStruct.calibratedTimeSeries] = deal(pixelTimeSeriesCellArray{:});
 
    % update dataObject
    dvDataObject.targetStruct(targetIndex).targetDataStruct(iTable) = targetDataStruct;

end

