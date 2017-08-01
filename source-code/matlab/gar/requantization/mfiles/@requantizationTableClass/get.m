function val = get(requantizationTableObject,propertyName)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function val = get(requantizationTableObject,propertyName)
% GET Get requantizationTableClass property from the specified object
% and return the value. Property names are: numberOfBits,
% numberOfExposuresInLongCadence, guardBandLow, guardBandHigh,
% electronsPerADU, quantizationFraction, readNoiseInADU, and debugFlag.
%
% An error is generated if propertyName does not refer to a valid member.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

%The get method provides a way to access the data in the stock object using
%a "property name" style interface, similar to Handle GraphicrequantizationTable. While in
%this example the property names are similar to the structure field name,
%they can be quite different. You could also choose to exclude certain
%fields from access via the get method or return the data from the same
%field for a variety of property names, if such behavior suits your design.

%  An object 'requantizationTableObject' of class 'requantizationClass'
% containing the fields:
%                       meanBlackTable: [84x1 double]
%                 visibleCCDResidualBlackRange: [84x2 double]
%               vsmearResidualBlackRange: [84x2 double]
%               msmearResidualBlackRange: [84x2 double]
%                blackResidualBlackRange: [84x2 double]
%         virtualBlackResidualBlackRange: [84x2 double]
%          maskedBlackResidualBlackRange: [84x2 double]
%                            gainTable: [84x1 double]
%                       readNoiseTable: [84x1 double]
%     numberOfExposuresPerShortCadence: 9
%      numberOfExposuresPerLongCadence: 270
%       numberOfVirtualSmearRowsSummed: 5
%        numberOfMaskedSmearRowsSummed: 5
%           numberOfBlackColumnsSummed: 5
%                          fixedOffset: 80000
%                        guardBandHigh: 0.0500
%                    numberOfBitsInADC: 14
%                 quantizationFraction: 0.2500
%                            requantTableLength: 65536
%                        requantTableMinValue: 0
%                        requantTableMaxValue: 8388607
%                           debugLevel: 3



if(~exist('propertyname','var'))

    val = struct(requantizationTableObject);

else
    switch propertyName
        case 'meanBlackTable'
            val = requantizationTableObject.meanBlackTable;
        case 'fixedOffset'
            val = requantizationTableObject.fixedOffset;
        case 'numberOfExposuresPerShortCadence'
            val = requantizationTableObject.numberOfExposuresPerShortCadence;
        case 'guardBandHigh'
            val = requantizationTableObject.guardBandHigh;
        case 'gainTable'
            val = requantizationTableObject.gainTable;
        case 'quantizationFraction'
            val = requantizationTableObject.quantizationFraction;
        case 'readNoiseTable'
            val = requantizationTableObject.readNoiseTable;
        case 'numberOfExposuresPerShortCadence'
            val = requantizationTableObject.numberOfExposuresPerShortCadence;
        case 'numberOfExposuresPerLongCadence'
            val = requantizationTableObject.numberOfExposuresPerLongCadence;
        case 'requantTableLength'
            val = requantizationTableObject.requantTableLength;
        case 'requantTableMinValue'
            val = requantizationTableObject.requantTableMinValue;
        case 'requantTableMaxValue'
            val = requantizationTableObject.requantTableMaxValue;
        case 'debugFlag'
            val = requantizationTableObject.debugFlag;
        otherwise
            val = struct(requantizationTableObject);

    end
end

