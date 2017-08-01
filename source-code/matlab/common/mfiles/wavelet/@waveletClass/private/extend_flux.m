function extendedFlux = extend_flux( initialFlux, outlierIndicators, outlierFillValues, ...
    noiseEstimationByQuarterEnabled, quarterIdVector, doZeroPadding )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% extend_flux -- private method of waveletClass that extends the flux to a
% power of two length.  Outliers are suppressed from entering
% the extension.  If noiseEstimationByQuarterEnabled is true, then the flux
% is broken into chunks and each chunk is extended to the same power of two
% length.
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

  % handle missing argument
  if ~exist( 'doZeroPadding', 'var' ) || isempty( doZeroPadding )
      doZeroPadding = false;
  end
  
  if noiseEstimationByQuarterEnabled
      % compute the length of each observed quarter
      [quarterLengths, observedQuarters, nQuarters] = get_quarter_lengths( quarterIdVector );
      
      % get the power of 2 extension length 
      finalLength = 2 ^ nextpow2( max(quarterLengths) );
      
      if doZeroPadding && ~isequal(length(initialFlux),length(quarterIdVector))
          % if we are extending a single pulse model then just use the same
          % zero padded single pulse for all quarters
          nQuarters = 1;
      end
      
      % initialize the extendedFlux and gapIndicators
      extendedFlux = zeros(finalLength, nQuarters);
      
      % If the input has the right dimensions then just exit
      if ~isequal(size(extendedFlux),size(initialFlux)) 
          
          % set aside the initialFlux values at outlierIndicators
          initialFluxAtOutliers = initialFlux(outlierIndicators);

          % perform the extension
          for iQuarter = 1:nQuarters
              
              % get the initialLength
              initialLength = quarterLengths(iQuarter);
              if ~isequal(finalLength,initialLength)
                  
                  % set up gapIndicators
                  gapIndicators = false(finalLength, 1);
                  
                  % do the extension
                  if ~doZeroPadding                      
                      % fill outliers in the initialFlux
                      initialFlux(outlierIndicators) = outlierFillValues;
                      extendedFlux(1:quarterLengths(iQuarter), iQuarter) = ...
                          initialFlux( quarterIdVector == observedQuarters(iQuarter) );
                      gapIndicators(quarterLengths(iQuarter)+1:end) = true;
                      
                      extendedFlux(:, iQuarter) = ...
                          fill_missing_quarters_via_reflection( extendedFlux(:, iQuarter), ...
                          gapIndicators ) ;
                      
                      % put back the initial flux values at outliers
                      initialFlux(outlierIndicators) = initialFluxAtOutliers;
                  end

                  % put back the initial flux
                  extendedFlux(1:quarterLengths(iQuarter), iQuarter) = ...
                      initialFlux( quarterIdVector == observedQuarters(iQuarter) );          
              else
                  extendedFlux(:,iQuarter) = ...
                      initialFlux( quarterIdVector == observedQuarters(iQuarter) );   
              end
          end    
      else
          extendedFlux = initialFlux;
      end
  else 
      % get the power of 2 extension length and initial length
      initialLength = length(initialFlux) ;
      finalLength = 2 ^ nextpow2(length(quarterIdVector));
      
      % If the input has the right dimensions then just exit
      if ~isequal(finalLength,initialLength) 
          
          % set up extended flux
          extendedFlux = zeros(finalLength,1) ;
          extendedFlux(1:initialLength) = initialFlux ;
          
          if ~doZeroPadding          
              % set up gapIndicators
              gapIndicators = false(finalLength,1) ;
              gapIndicators(initialLength+1:end) = true ;

              % fill outliers to prevent them in the extended region
              extendedFlux(outlierIndicators) = outlierFillValues;
              extendedFlux = fill_missing_quarters_via_reflection( extendedFlux, gapIndicators ) ;

              % put back the outliers
              extendedFlux(outlierIndicators) = initialFlux(outlierIndicators);
          end

          % if the mean or median of the initial flux was 0 then adjust the
          % extension accordingly
          if isequal(mean(initialFlux),0)
              extendedFlux(initialLength+1:end) = extendedFlux(initialLength+1:end) - ...
                  mean(extendedFlux(initialLength+1:end));
          end

          if isequal(median(initialFlux),0)
              extendedFlux(initialLength+1:end) = extendedFlux(initialLength+1:end) - ...
                  median(extendedFlux(initialLength+1:end));
          end
      else
          extendedFlux = initialFlux;
      end
      
  end  

return

