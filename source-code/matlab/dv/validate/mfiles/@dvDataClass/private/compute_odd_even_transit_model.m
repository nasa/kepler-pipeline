function [transitModel, fitType] = compute_odd_even_transit_model( transitModel, planetResultsStruct, trapezoidalModelFittingEnabled, reducedParameterFitsEnabled )
%
% compute_odd_even_transit_model -- determine a first-guess transit model for use in odd-even transit fitting.
%
% transitModel = compute_odd_even_transit_model( transitModel, planetResultsStruct, reducedParameterFitsEnabled ) 
%    takes as its argument a planetResultsStruct (see comments for dv_matlab_controller for more information).  
%    The returned transit model contains the fitted transit parameters from reduced parameter fit with minimum
%    chi-square or all-transits fit of the given target.  
%
% [transitModel, fitType] = compute_odd_even_transit_model( ... ) determines the fit type
%    which produced the original transit model, and returns it.
%
% The method compute_odd_even_transit_model is a private method of the dvDataClass.
%
% Version date:  2014-November-26.
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
 
% Modification History:
%
%    2016-July-25, JL:
%        Seed odd-even transits fits with TCE parameters when reduced
%        parameter fits are disabled
%    2014-November-26, JL:
%       Seed all-odd-even transits fit in the order of reducedParameterFit - trapezoidalFit - TCE
%    2014-October-23, JL:
%        Seed odd-even transits fits in the order of trapezoidalFit - reducedParameterFit - TCE
%    2014-April-17, JL:
%        Fix a bug when reducedParameterFitsEnabled is false
%    2014-April-10, JL:
%        If reduced parameter fit is enabled, seed odd-even transit fitter with parameters from
%        the reduced parameetr fit with minimum chi-square metric
%    2011-January-21, JL:
%        Data is always fitted in whitened domain in DV. fitType is initially set to 12.
%    2010-October-25, JL:
%        When geometric transit model is used, copy the geometric model parameters to 
%        transitModel.planetModel and set fitType to 11.
%    2010-April-27, PT:
%        Eliminate odd-even flag at input, and eliminate offset of the reference epoch.
%    2009-August-20, PT:
%        assorted bugfixes.  Eliminate doubling of period.
%    2009-August-17, PT:
%        support for multiple fit types.  Copy the physical parameters from the original
%        data structure, not the fitted ones.
%    2009-July-29, PT:
%        change to use the planetResultsStruct.allTransitsFit structure to populate the
%        transitModel values.
%    2009-May-26, PT:
%        update yet again based on latest understanding of transitModel structure
%    2009-May-15, PT:
%        update based on current understanding of transitModel structure.
%
%=========================================================================================

% If the valid outputs of the reduced parameter fits are available, seed the odd-even transit fitter
% with parameters from the reduced parameter fit with the minimum chi-square metric;
% otherwise, seed the odd-even transit fit with parameters from the all transit fit.

  reducedParameterFits      = planetResultsStruct.reducedParameterFits;
  if isempty(reducedParameterFits)
      validChiSquareArray = [];
  else
      modelChiSquareArray       = [reducedParameterFits.modelChiSquare];
      validReducedParameterFits = reducedParameterFits(modelChiSquareArray>0);
      validChiSquareArray       = modelChiSquareArray(modelChiSquareArray>0);
  end
  
  modelParameters = [];
  
  if  reducedParameterFitsEnabled && ~isempty(validChiSquareArray)
    
      [ignored, minIndex] = min(validChiSquareArray);
      modelParameters     = validReducedParameterFits(minIndex).modelParameters;
      modelParameterNames = {modelParameters.name};
    
      disp(' ');
      disp(['  Seed odd-even transit model with parameters from the reduced parameter fit with fixed impact parameter ' num2str(modelParameters(strcmp('minImpactParameter', modelParameterNames)).value, '%1.2f')]);
      disp(' ');
    
%   elseif  trapezoidalModelFittingEnabled && planetResultsStruct.trapezoidalFit.fullConvergence
%       
%       modelParameters     = planetResultsStruct.trapezoidalFit.modelParameters;
%       
%       disp(' ');
%       disp('  Seed odd-even transit model with trapezoidal fit parameters');
%       disp(' ');
  
  else
      
      disp(' ');
      disp('  Seed odd-even transit model with TCE parameters');
      disp(' ');
    
  end

  if ~isempty(modelParameters) 
      
      modelParameterNames = {modelParameters.name};

      planetModel.transitEpochBkjd                  = modelParameters(strcmp('transitEpochBkjd',               modelParameterNames)).value;
      planetModel.orbitalPeriodDays                 = modelParameters(strcmp('orbitalPeriodDays',              modelParameterNames)).value;
      planetModel.ratioPlanetRadiusToStarRadius     = modelParameters(strcmp('ratioPlanetRadiusToStarRadius',  modelParameterNames)).value;
      planetModel.ratioSemiMajorAxisToStarRadius    = modelParameters(strcmp('ratioSemiMajorAxisToStarRadius', modelParameterNames)).value;
      planetModel.minImpactParameter                = modelParameters(strcmp('minImpactParameter',             modelParameterNames)).value;
      planetModel.eccentricity                      = modelParameters(strcmp('eccentricity',                   modelParameterNames)).value;
      planetModel.longitudeOfPeriDegrees            = modelParameters(strcmp('longitudeOfPeriDegrees',         modelParameterNames)).value;
      planetModel.starRadiusSolarRadii              = modelParameters(strcmp('starRadiusSolarRadii',           modelParameterNames)).value;
  
      transitModel.planetModel = planetModel;
      
  end      
  
% When geomertic transit model is used, set fitType to 11 (DV fitter in the unwhitened domain).  
% Otherwise, look at the value of the impact parameter to determine the fit type.

% Since there is no acceptable reason to fit the data in the unwhitened domain in DV, it is decided in
% a meeting by JJ, JT, PT and JL on January 21, 2011 that the data should always be fitted in the  
% whitened domain in DV.

  if strcmp(transitModel.modelNamesStruct.transitModelName, 'mandel-agol_geometric_transit_model')
%     fitType = 11;         % DV fitter in the unwhitened domain
      fitType = 12;         % DV fitter in the   whitened domain
  else
      if transitModel.planetModel.minImpactParameter == 0
          fitType = 1 ;
      else
          fitType = 0 ;
      end
  end
  