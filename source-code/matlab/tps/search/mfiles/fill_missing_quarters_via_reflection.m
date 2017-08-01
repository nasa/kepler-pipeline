function timeSeriesWithGapsFilled = fill_missing_quarters_via_reflection( ...
    timeSeriesWithGaps, gapIndicators, indexOfAstroEvents, gapFillParametersStruct )
%
% fill_missing_quarters_via_reflection -- fill missing quarter-sized gaps by reflecting in
% data from either side.
%
% timeSeriesWithGapsFilled = fill_missing_quarters_via_reflection( timeSeriesWithGaps,
%    gapIndicators ) performs a simple filling of long gaps using reflected data from both
%    sides of the gap, if possible.  The gaps can exceed the length of data available, in
%    which case multiple reflections are used.  If data is available from both sides of
%    the gap, then the fill uses reflections from both sides, tapered linearly; otherwise,
%    data from the available side is used.  Fill any astroEvents so they
%    dont perturb the long gap fill.
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

%=========================================================================================

  timeSeriesWithGapsFilled = timeSeriesWithGaps ;
  nCadences                = length( timeSeriesWithGaps ) ;

  if(~any(~gapIndicators))
      return;
  end  
  
  gapLocations = find_datagap_locations(gapIndicators);

  if(isempty(gapLocations))
      return;
  end
  
% if there are no astro events then set it to empty

  if ~exist('indexOfAstroEvents', 'var')
      indexOfAstroEvents = [] ;
  end

% if indexOfAstroEvents is zero then identify them internally

  if isequal(indexOfAstroEvents, 0)
      indexOfAstroEvents = identify_astrophysical_events(timeSeriesWithGaps, ...
        gapIndicators, gapFillParametersStruct);
  end
  
% fill outliers so they dont affect the long gap fill

  if ~isempty(indexOfAstroEvents)
      outlierIndicators = false(nCadences,1) ;
      outlierIndicators(indexOfAstroEvents) = true ;
      timeSeriesWithGaps = fill_short_gaps( timeSeriesWithGaps, outlierIndicators, ...
              [], 0, gapFillParametersStruct, [] );
  end
  
% triplicate the time series and the gap indicators -- this ensures that the filled gaps
% in the second copy will have proper continuity between the last cadence and the first
% cadence; this is needed when extending a time series because of all the operations we
% later do in circular fashion
  
  timeSeriesWithGaps       = repmat(timeSeriesWithGaps,3,1) ;
  timeSeriesWithGapsFilled = repmat(timeSeriesWithGapsFilled,3,1) ;
  gapIndicators            = repmat(gapIndicators,3,1) ;
  gapLocations             = find_datagap_locations(gapIndicators);
  
  nCadencesOriginal = nCadences ;
  nCadences         = 3 * nCadences ;
  
  middleCopyStart = nCadencesOriginal + 1 ;
  middleCopyEnd   = nCadencesOriginal * 2 ;
  
  gapLengths = gapLocations(:,2) - gapLocations(:,1)+ 1; 
  numberOfGaps = length(gapLengths);

    
% define extended gap regions which will permit us to easily find left and right data
% segments

  extendedGapLocations = [1 1 ; gapLocations ; nCadences nCadences] ;

% loop over gaps

  for iGap = 1:numberOfGaps
      
      thisGapLength = gapLengths(iGap) ;
      leftDataLocation  = [extendedGapLocations(iGap,2) ...
          extendedGapLocations(iGap+1,1)-1] ;
      rightDataLocation = [extendedGapLocations(iGap+1,2)+1 ...
          extendedGapLocations(iGap+2,1)] ;
            
%     get fill from left side, if any

      if leftDataLocation(2) >= leftDataLocation(1)
          
          leftGapData = timeSeriesWithGaps( leftDataLocation(1):leftDataLocation(2) ) ;
          leftFill = [] ;
          while length(leftFill) < thisGapLength
              
              leftGapData = flipud(leftGapData) ;
              leftFill    = [leftFill ; leftGapData] ;
              
          end
          leftFill    = leftFill(1:thisGapLength) ;
          leftFillOk  = true ;
          
      else
          
          leftFill   = zeros(thisGapLength, 1) ;
          leftFillOk = false ;
          
      end
      
%     get fill from right side, if any -- note that we are constructing the right fill in
%     reverse, and then flipping it, so we wind up needing 2 extra flips wrt what we did
%     on the left

      if rightDataLocation(2) >= rightDataLocation(1)
          
          rightGapData = flipud( ...
              timeSeriesWithGaps(rightDataLocation(1):rightDataLocation(2)) ) ;
          rightFill = [] ;
          while length(rightFill) < thisGapLength
              
              rightGapData = flipud( rightGapData ) ;
              rightFill    = [rightFill ; rightGapData] ;
              
          end
          rightFill   = flipud( rightFill(1:thisGapLength) ) ;
          rightFillOk = true ;
          
      else
          
          rightFill   = zeros( thisGapLength, 1 ) ;
          rightFillOk = false ;
          
      end
      
%     depending on whether we have left fill, right fill, or both, we need to adjust the
%     weights used for the taper
      
      if leftFillOk && rightFillOk
          
          % KSOC-4934: there are three taper options, we have chosen to use the 10% sigmoid taper.
          % However, for reference I am keeping the other two taper in here for reference.

          % KSOC-4953: The sigmoid taper needs at least 2 points. 
          % If thisGapLength is less than 20 then use the linear taper.

          if (thisGapLength < 20)
              % Option 1: Use linear taper
              leftWeight  = linspace(1,0,thisGapLength) ;
              rightWeight = linspace(0,1,thisGapLength) ;
          else
              % Option 2: Use sigmoid taper
              leftWeight  = flipud(narrow_sigmoid(thisGapLength)) ;
              rightWeight = narrow_sigmoid(thisGapLength) ;
          end
          
      elseif ~leftFillOk
          
          leftWeight  = zeros(1,thisGapLength) ;
          rightWeight = ones(1,thisGapLength) ;
          
      else
          
          leftWeight  = ones(1,thisGapLength) ;
          rightWeight = zeros(1,thisGapLength) ;
          
      end
      
%     perform the tapered fill 

       %if leftFillOk && rightFillOk
       %    % Option 3: Use phase transition (PT) taper
       %    % The functional form of this taper is different than 1 or 2 and so we need this conditional to select this taper.
       %    timeSeriesWithGapsFilled( gapLocations(iGap,1):gapLocations(iGap,2) ) = pt_taper (leftFill, rightFill);
       %else
            timeSeriesWithGapsFilled( gapLocations(iGap,1):gapLocations(iGap,2) ) = ...
                rightFill .* rightWeight(:) + leftFill .* leftWeight(:) ;
       %end
      
  end % loop over gaps
  
% discard the first and third copy, preserving only the middle copy

  timeSeriesWithGapsFilled = timeSeriesWithGapsFilled(middleCopyStart:middleCopyEnd) ;
          

end

%=========================================================================================
% A sigmoid function only covering the middle 10% of the function of nPoints. The rest is simply either zero of one.

function y = narrow_sigmoid(nPoints)

    % Fraction of full curve that is of a sigmoid
    sigmoidFraction = 0.1;

    nSigmoidPoints = round(nPoints * sigmoidFraction);

    sigmoidCurve = sigmoid(nSigmoidPoints);
    
    onesLength      = round(nPoints * ((1 - sigmoidFraction) / 2.0));
    onesSection     = ones(onesLength,1);
    zerosSection    = zeros(onesLength,1);
    y = [zerosSection' sigmoidCurve onesSection']';

    % Rounding may result in being not the correct data length. Pad alternating the ones and zeros in this case
    pointsOff = nPoints - length(y);
    toggle = true;
    if(pointsOff > 0)
        for iPoint = 1 : pointsOff
            if toggle
                y = [0' y']';
            else
                y = [y' 1']';
            end
            toggle = ~toggle;
        end
    elseif(pointsOff < 0)
        for iPoint = 1 : abs(pointsOff)
            if toggle
                y = y(2:end);
            else
                y = y(1:end-1);
            end
            toggle = ~toggle;
        end
    end

end
    

%=========================================================================================
% a Logistic function-based sigmoid curve
% 
% Npoints can be as low as 2 but you really want at least 10 points to make a discernable sigmoid shape.

function y = sigmoid(nPoints)

    if (nPoints < 2)
        error('Too few points to generate sigmoid');
    end

    step = (10 - (-10)) / (nPoints-1);
    x= -10:step:10;
    y = (1 ./ (1 + exp(-x)));

end

%=========================================================================================
% Phase Transition (PT) taper
% Blends two signals by placing them 90 degrees apart on a complex plane and then uses a phase rotation to blend the two signals. 
% It converts the two signal vectors into polar coordinates, then adjusts for the rotating axis of the taper and projects to the x-axis.

function taperedSignal = pt_taper (leftFill, rightFill)

    nPoints = length(leftFill);
    if (length(rightFill) ~= nPoints)
        error('pt_taper: Right and Left signals must be the same length');
    end

    % Linear taper in phase angle
    phaseAngle = linspace(0,pi/2,nPoints)' ;

    % Convert the two signals into polar coordinates
    [theta,r] = cart2pol(leftFill, rightFill);

    % Blend the two signals beginning purely with one and then phasing linearly to the other signal.
    % When phaseAgnle = 0 we are purely using the leftFill vector.
    % When Phase Angle is pi/2 we are purely using the rightFill vector.
    taperedSignal = r .* cos(theta-phaseAngle);

end
