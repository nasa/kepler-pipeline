function returnObject = get(ccdObject, propName)
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
switch propName
    case 'className' 
        returnObject = ccdObject.className;

	case 'ccdPlaneObjectList' 
        returnObject = ccdObject.ccdPlaneObjectList;
	case 'flatFieldObjectList' 
        returnObject = ccdObject.flatFieldObjectList;
	case 'visibleBackgroundObjectList' 
        returnObject = ccdObject.visibleBackgroundObjectList;
	case 'pixelBackgroundObjectList' 
        returnObject = ccdObject.pixelBackgroundObjectList;
	case 'pixelEffectObjectList' 
        returnObject = ccdObject.pixelEffectObjectList;
	case 'electronsToAduObject' 
        returnObject = ccdObject.electronsToAduObject;

	case 'targetScienceManagerObject' 
        returnObject = ccdObject.targetScienceManagerObject;


    % pixels of interest structs
    case 'poiStruct'
        returnObject = get(ccdObject.cadenceDataObject, 'poiStruct');
    case 'targetStruct'
        returnObject = get(ccdObject.cadenceDataObject, 'targetStruct');
    case 'backgroundStruct'
        returnObject = get(ccdObject.cadenceDataObject, 'backgroundStruct');
    case 'leadingBlackStruct'
        returnObject = get(ccdObject.cadenceDataObject, 'leadingBlackStruct');
    case 'maskedSmearStruct'
        returnObject = get(ccdObject.cadenceDataObject, 'maskedSmearStruct');
    case 'virtualSmearStruct'
        returnObject = get(ccdObject.cadenceDataObject, 'virtualSmearStruct');
    case 'trailingBlackStruct'
        returnObject = get(ccdObject.cadenceDataObject, 'trailingBlackStruct');

    case 'wellDepthVariation'
        returnObject = get(ccdObject.wellDepthVariationObject);
        
    case 'badFitPixelStruct'
        returnObject = ccdObject.badFitPixelStruct;
        
    case 'requantizationTable'
        returnObject = ccdObject.requantizationTable;
    case 'requantTableLcFixedOffset'
        returnObject = ccdObject.requantTableLcFixedOffset;
    case 'requantTableScFixedOffset'
        returnObject = ccdObject.requantTableScFixedOffset;
    case 'requantizationOffset'
        returnObject = ccdObject.requantizationOffset;
    case 'requantizationMeanBlack'
        returnObject = ccdObject.requantizationMeanBlack;
        
    case 'ssrOutputDirectory' 
        returnObject = ccdObject.ssrOutputDirectory;
    case 'dataBufferSize' 
        returnObject = ccdObject.dataBufferSize;

    % motion and pointing
	case 'dvaMotionObject' 
        returnObject = ccdObject.dvaMotionObject;
	case 'jitterMotionObject' 
        returnObject = ccdObject.jitterMotionObject;
	case 'motionGridRow' 
        returnObject = ccdObject.motionGridRow;
	case 'motionGridCol' 
        returnObject = ccdObject.motionGridCol;
    
    otherwise
        error([propName,' Is not a valid ccdObject property']);
end
