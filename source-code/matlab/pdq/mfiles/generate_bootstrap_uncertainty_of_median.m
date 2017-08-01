function [stdMedian, lowerConfidenceLimit, upperConfidenceLimit] = generate_bootstrap_uncertainty_of_median(sampleValues)

% To generate a bootstrap uncertainty estimate for a given statistic from a
% set of data, a subsample of size <= size of the data set is generated
% from the data, and th estatistic is calculated. The subsample is
% generated with *replacement* so that any data point can be sampled
% multiple times or not sampled at all. This process is repeated for many
% subsamples, typically between 500 and 1000. The computed values for the
% statistic form an estimate of the sampling distribution of the statistic.
% To calculate the 90% confidence interval for the median, the sample
% medians are sorted into ascending order and the value of the 25th median
% (assuming exactly 500 subsamples were taken) is the lower confidence
% limit while th evalue of the 475th median (assuming exactly 500
% subsamples were taken) is the upper confidence limit.
% http://www.itl.nist.gov/div898/handbook/eda/section3/bootplot.htm
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

% order statistics, confidence limits ....

NUMBER_OF_SUBSAMPLES = 500;


nSampleLength = length(sampleValues);

SUBSAMPLE_SIZE = min(100, fix(0.5*nSampleLength));

medianVlaues = zeros(NUMBER_OF_SUBSAMPLES,1);


for iSubSampleSet = 1:NUMBER_OF_SUBSAMPLES
    
% The discrete uniform distribution arises from experiments equivalent to
% drawing a number from one to N out of a hat.
% 

% R = unidrnd(N,m,n) generates random numbers for the discrete uniform
% distribution with maximum N, where scalars m and n are the row and column
% dimensions of R.


    chosenIndices = unidrnd(nSampleLength, SUBSAMPLE_SIZE, 1);
    
    medianVlaues(iSubSampleSet) = median(sampleValues(chosenIndices));
    
end

medianVlaues = sort(medianVlaues);


% 90% confidence interval 

% to find exactly what indices give the 90% confidence limit for some other
% choice of NUMBER_OF_SUBSAMPLES is another problem (remember FCC OET-71)  

lowerConfidenceLimit = medianVlaues(25);

upperConfidenceLimit = medianVlaues(475);


stdMedian = std(medianVlaues); % for progation of uncertainties, a gaussian pdf is assumed 

return