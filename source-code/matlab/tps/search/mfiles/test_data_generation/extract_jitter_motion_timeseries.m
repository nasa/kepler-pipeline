%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [dx, dy] = Get_JitterTimeSeries(jitter_loadstr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Function Name: Get_JitterTimeSeries.m
% Modification History - This is managed by CVS.
% Software level: Prototype Code
%
% Description: This function extracts the dx, dy time series from the cell
% structure output by an ETEM run.
%
% Inputs: 
%         Matlab workspace name that contains Ajit_Cell
%
% Output: 
%         dx - a vector of pointing errors in x direction
%         dy - a vector of pointing errors in y direction
%
%
% 
%  H.Chandrasekaran - 11/22/05
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

% load C:\path\to\ETEM\Results\run200\Ajit_run200.mat
% whos
%   Name           Size                 Bytes  Class     Attributes
% 
%   Ajit_Cell      5x5               25001200  cell                
%   col_3d         5x5x94               18800  double              
%   mesh_col       5x5                    200  double              
%   mesh_row       5x5                    200  double              
%   nout           1x1                      8  double              
%   row_3d         5x5x94               18800  double              
% 
% Ajit_Cell
% Ajit_Cell = 
%     [4464x28 double]    [4464x28 double]    [4464x28 double]    [4464x28 double]    [4464x28 double]
%     [4464x28 double]    [4464x28 double]    [4464x28 double]    [4464x28 double]    [4464x28 double]
%     [4464x28 double]    [4464x28 double]    [4464x28 double]    [4464x28 double]    [4464x28 double]
%     [4464x28 double]    [4464x28 double]    [4464x28 double]    [4464x28 double]    [4464x28 double]
%     [4464x28 double]    [4464x28 double]    [4464x28 double]    [4464x28 double]    [4464x28 double]


% load motionBasis
% whos
%   Name               Size               Bytes  Class     Attributes
% 
%   motionBasis1       5x5             24396464  struct              
%   motionGridCol      5x5                  200  double              
%   motionGridRow      5x5                  200  double              
% 
% motionBasis1(1)
% 
% ans = 
% 
%     designMatrix: [4356x28 double]

%extract_jitter_motion_timeseries.m


function [dx, dy] = extract_jitter_motion_timeseries(motionBasisLoadString)

eval(motionBasisLoadString); % loads motionBasis

[middleStructRowNumber, middleStructColumnNumber]  = size(motionBasis1);

middleStructRowNumber = round(middleStructRowNumber/2);

middleStructColumnNumber = round(middleStructColumnNumber/2);

[numberOfCadences, numberOfCoeffts] = size(motionBasis1(middleStructRowNumber,middleStructColumnNumber).designMatrix);

if(numberOfCoeffts < 3)
    error('number of columns in the motionBasis.DesignMatrix < 3')
end


for i = middleStructRowNumber
    
    for j = middleStructColumnNumber
        
        jitterDesignMatrix = motionBasis1(i,j).designMatrix;
        
        dx = jitterDesignMatrix(1:numberOfCadences, 2)/jitterDesignMatrix(1, 1);
        
        dy = jitterDesignMatrix(1:numberOfCadences, 3)/jitterDesignMatrix(1, 1);
        
    end
    
end

return;



