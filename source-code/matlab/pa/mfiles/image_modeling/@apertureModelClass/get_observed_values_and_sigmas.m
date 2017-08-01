function [pixelValueMat, pixelSigmaMat, pixelGapMat] = ...
    get_observed_values_and_sigmas(obj, cadences)
%**************************************************************************
% function [pixelValueMat, pixelSigmaMat] = ...
%    get_observed_values_and_sigmas(obj, cadences)
%**************************************************************************
% Extract pixel values and uncertainties from the target group for the
% specified pixels. The same pixel may appear in more than one target and
% may have multiple values as a result. We take the values associated with
% the first appearance of each pixel in the target list.
%
% INPUTS
%     cadences      : An array of cadence numbers for which to retrieve
%                     pixel values (all available cadences are returned by
%                     default). 
% OUTPUTS
%     pixelValueMat : An nPixels-by-nCadences matrix of observed pixel
%                     values corresponding to the coordinates specified in
%                     ccdRow and ccdCol. 
%                                            
%     pixelSigmaMat : An nPixels-by-nCadences matrix of observed pixel
%                     uncertainties corresponding to the coordinates
%                     specified in ccdRow and ccdCol. 
%
%     pixelGapMat   : An nPixels-by-nCadences matrix of gap indicators.
%
% NOTES
%     The ordering of obj.observedPixels is the same as that of the
%     obj.pixelRows and obj.pixelColumns properties. This is guaranteed by
%     apertureModelClass.initialize().
%**************************************************************************
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

    if ~exist('cadences', 'var')
        cadences = 1:obj.get_num_cadences();
    end
    
    % Note that in apertureModelClass.initialize() the observed pixel array
    % was assigned such that the ordering agrees with obj.pixelRows and
    % obj.pixelColumns. It may be a good idea to confirm the ordering is
    % correct here, but it would also be slower.
    
    pixelValueMat = [obj.observedPixels.values]';
    pixelValueMat = pixelValueMat(:, cadences);
    
    pixelSigmaMat = [obj.observedPixels.uncertainties]';
    pixelSigmaMat = pixelSigmaMat(:, cadences);

    pixelGapMat = [obj.observedPixels.gapIndicators]';
    pixelGapMat = pixelGapMat(:, cadences);
end

%********************************* EOF ************************************
