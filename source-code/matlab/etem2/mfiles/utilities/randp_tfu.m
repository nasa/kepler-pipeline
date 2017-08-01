function [out] = randp_tfu(in)
%
% (Identical to MATLAB randp, but I just took out the part where it rounds to nearest int;
%  thus, this version does not round the result) - TFU 5/5/99
% I also removed all seed logic as I want it to give a different result each time !
%
% RANDP Generates Poisson distributed random numbers and matrices.
% 	RANDP(IN) is a matrix of the same size and shape as IN with random
%	entries from a Poisson distribution with mean (and variance) equal
%       to the values in IN.  The current seed for the uniform random
%       generator is the starting seed if no seed is specified.  The seeds
%       for the uniform and normal random generators are restored, but the
%       last seed used can be returned in SEEDOUT.
%
% 	RANDP with no arguments is a scalar from a Poisson population
%          with mean 1. The uniform random generator seed is changed.
% 	RANDP('seed') returns the current seed of the Poisson generator.
%          NOTE: this is the same seed as the uniform generator
% 	RANDP('seed',s) sets the Poisson (and uniform) generator seed to s.
% 	RANDP('seed',0) resets the seed its startup value.
% 	RANDP('seed',sum(100*clock)) sets it to a different value each time.
%       RANDP(IN, seed) uses the specified seed and restores the seed for the
%           uniform and normal random generators (normal mode of operation)
%           The final seed value can be returned in SEEDOUT
%       RANDP(IN, seed, N) uses specified seed and restores seeds as above
%           also changes the cutoff threshold for using the normal
%           distribution as an approximation to the Poisson from the default
%           value of 36 to the specified value of N.  The default returns to
%           36 on the next call unless N is given.  Note that the seed must
%           be given in order to change the threshold in the way.
% 
% 	See also RAND, RANDN.
%
%  ALGORITHM:  Independent exponential random deviates (waiting times
%     between events) are generated and summed.  When the sum first exceeds
%     the mean, then the number of events that would have occurred in the
%     waiting time equal to the mean is one less than the number of terms in
%     the sum.  The number of terms in the sum is a random variable and has
%     a Poisson distribution.  For large parameter values (equal or above a
%     preset value of 36), a normal approximation is used:  normally
%     distributed RVs with mean and variance equal to IN (> 36) are generated,
%     clipped at zero, and rounded to the nearest integer.  This will be
%     sufficiently accurate for most applications and greatly increases
%     the speed (six sigma is greater than zero).
%
%  AUTHOR:  Neil Endsley
%
%  REFERENCES:  
%
%     Press, W. H., et al., Numerical Recipes in C, 2nd Ed., pp293-295,
%     Cambridge Unoversity Press, 1992
%
%  REVISION HISTORY: initial release 4/12/97   
%
%  FUNCTIONS CALLED: none beyond standard Matlab
%
%  EXTERNAL EFFECTS: RAND seed can be changed as noted above 
%
%  ERROR RETURNS: Warning issued when RAND seed is changed
%
%  RESTRICTIONS:  To change the threshold for when to use the normal
%     approximation, a seed variable must be passed.
%
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


N = 36;  % threshold for normal approximation to Poisson

   out = -ones(size(in));
   if any(in < N) % Use the direct method (counting method)
      
      smalls = find(in < N); % find the small values
      g      = exp(-in(smalls)); % exponential comparison value
      sout   = -ones(size(g));
      t      =  ones(size(g));
      
      while any(t > g)  % for any t that are still too big...
         rejects    = find(t > g);
         t(rejects) = rand(size(rejects)).*t(rejects);
   
         % adding exponential deviates is equivalent to multiplying
         % uniform deviates: we compare to the exponential
         sout(rejects) = sout(rejects) + 1; % count the iterations
      end
      
      out(smalls) = sout;  % set out to the values generated for small numbers

   end

   % For all values over N, use the Gaussian approximation
   big    = find(in >= N);
   big_in = in(big);
   
  %out(big) = round(max(sqrt(big_in).*randn(size(big_in))+big_in,0));
   out(big) =       max(sqrt(big_in).*randn(size(big_in))+big_in,0); %TFU removed round
   
return