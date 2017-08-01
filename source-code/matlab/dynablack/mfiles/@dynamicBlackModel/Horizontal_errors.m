function errDn = Horizontal_errors(obj, columnList, lcList)
%
% function errDn = Horizontal_errors(obj, columnList, lcList)
%
% Horizontal_errors (multiple pixel & LC case)
% Method for DynamicBlackModel objects for calculating error in horizontal component of black level
% 
% 
% ARGUMENTS
% 
% * Function returns:
% * --> |errDn  -| estimates column-dependent component of black-level error in DN/read for the given set of arguments.
%
% * Function arguments:
% * --> |obj         -| DynamicBlackModel object being estimated. 
% * --> |columnList -| which columns.
% * --> |lcList     -| which LCs.
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

% hard coded constants
ffiColumnCount          = 1132;
anotherColumnConstant   = 1124;
someColumnThreshold     = 293;
locateRcOffsetLo        = 7;
locateRcOffsetHi        = 6;
locateSmearLo           = 3;
locateSmearHi           = 2;
locateSmearOffset       = 1;
solMaxOffset            = 5;
solMin                  = 2;


if nargin > 0
    
    columnCount = length(columnList);
    lcCount = length(lcList);
    errDn = zeros(columnCount,lcCount);
    
    for columnId = 1:columnCount
        
        % build model elements
        column = columnList(columnId);
        linearRef = anotherColumnConstant/(ffiColumnCount-1)-0.5;
        quadRef =(linearRef*2)^2-1/3;
        linear = (column-1)/(ffiColumnCount-1)-0.5;
        quad =(linear*2)^2-1/3;
        
        % construct predictors (model) matrix
        predictorsRef = [0  1 linearRef quadRef];
        predictors = [double(column < someColumnThreshold) double(column >= someColumnThreshold) linear quad];
        
        % extract fitted coefficients and assemble into vector of [ RC ; smear - smearOffset ]
        rcCoeffRange = obj.Horizontal_errorParams.Count - locateRcOffsetLo:obj.Horizontal_errorParams.Count - locateRcOffsetHi;
        smearCoeffRange = obj.Horizontal_errorParams.Count - locateSmearLo:obj.Horizontal_errorParams.Count - locateSmearHi;
        smearCoeffOffsetRange = obj.Horizontal_errorParams.Count - locateSmearOffset:obj.Horizontal_errorParams.Count;
                
        coefficients = [obj.Horizontal_errorParams.estimates(obj.Predictors,rcCoeffRange,lcList)' ...
                        obj.Horizontal_errorParams.estimates(obj.Predictors, smearCoeffRange, lcList)' - ...
                        obj.Horizontal_errorParams.estimates(obj.Predictors, smearCoeffOffsetRange, lcList)'];
        
        % determine start of line ringing contribution
        sol = 0;        
        if column < obj.Horizontal_errorParams.Count - solMaxOffset && column > solMin
            sol = obj.Horizontal_errorParams.estimates(obj.Predictors,column - solMin,lcList);
        end
        
        % assemble result for ccd column
        errDn(columnId,1:lcCount) = sqrt( coefficients.^2 * predictors'.^2 + coefficients.^2 * predictorsRef'.^2 + sol'.^2 );
    end
end


