%%   precondition 
% Fills gaps  in time series smoothly.
% Adds pad to each end using parity+time reversed data.
% Removes outliers at 3 sigma level.
% 
%   Revision History:
%
%       Version 0   - 3/14/11     released for Science Office use
%       Version 0.1 - 4/30/11     improved/corrected documentation
%                                 replaced some enumerated values with
%                                 variable names
%       Version 0.2 - 9/26/11     fixed short gap defect; fixed mislocated residual ordering; 
%                                 made W obolete (left as argument for
%                                 compatibility); added/changed lines noted by 
%                                 % JK110926
% 
% <html>
% <style type="text/css"> pre.codeinput {background: #FFFF66; padding: 30px;} </style>
% </html>
% 
%%
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
function outStruct = precondition( obj, fluxIn, gapsIn, L, W )
%% 1.0 ARGUMENTS
% 
% Function returns:
%
% * |outStruct -| Output structure
% * |.fluxOut        -| Output Vector: time series of length: length(V_In)+L-1(or 0) if L
%                 is odd(or even)                
% * |.mask     -| Output mask defines an additional buffer around gaps
%                 to identify near long gap and end zones (with 5 samples)
%
% Function Arguments:
%
% * |fluxIn      -|  Input Vector: time Series
% * |gapsIn      -|  Gap Map (Logical) for input time series
% * |L        -|  Padding Length parameter: ceil(L-1)/2 data points are
%                 added to each end of the output time series
%
%% 2.0 CODE
%

warning off MATLAB:polyfit:PolyNotUnique


%% 2.1 INITIALIZATION
%

% anonymous function
ind=@(x,i) x(i);

% constants
gap1PolyRange= 7; % range for single point gap fill modeling
gapBufferLength    = 5; % length of additional buffer around gaps and end zones
outlierSigma= 3; % 3 sigma differential outlier threshold
outlierMedianRange=10; % range for median outlier correction

nCadences    = length(fluxIn);
paddingLength        = ceil((L-1)/2.);
fluxOut           = zeros(nCadences+2*paddingLength,1);

% Gap starts and ends
gapsIn       = gapsIn;
dGaps         = diff(gapsIn);
dGapsPositiveInd      = find(dGaps==1)+1; % Indices of first gapped cadence in each gap
dGapsNegativeInd      = find(dGaps==-1);  % Indices of last gapped cadence in each gap

% account for gap at beginning of interval
if ~isempty(dGapsPositiveInd) && ~isempty(dGapsNegativeInd) && dGapsPositiveInd(1)>dGapsNegativeInd(1) % Note short-circuit &&
    gapStarts=[1 dGapsPositiveInd];
else
    gapStarts=dGapsPositiveInd;
end

% account for gap at end of interval
if ~isempty(dGapsPositiveInd) && ~isempty(dGapsNegativeInd) && dGapsPositiveInd(end)>dGapsNegativeInd(end)
    gapEnds=[dGapsNegativeInd nCadences];
else
    gapEnds=dGapsNegativeInd;
end

% lengths of gaps
gapLengths           = gapEnds-gapStarts+1; 

% number of gaps
gapCount       = length(gapLengths);

% which gaps are more than 1 data point
longGapIndices   = find(gapLengths>1);

% number of gaps with more than 1 data point
longGapCount   = length(longGapIndices);

%% 2.2 PRECONDITION

%% 2.2.1 TRANSFER NOT-GAP DATA TO OUTPUT VECTOR

fluxOut(find(~gapsIn)+paddingLength)=fluxIn(~gapsIn);


%% 2.2.2 FILL GAPS OF LENGTH 1
for k=1:gapCount
    
    if gapLengths(k)==1
        
        % range to model for gap fill (balance number of points before and after)
        beforeRange0=max(1,gapStarts(k)-gap1PolyRange):gapStarts(k)-1;
        beforeRange=beforeRange0(~isinf(fluxIn(beforeRange0)));
        numCadencesBefore=length(beforeRange);
        
        afterRange0=gapStarts(k)+1:min(nCadences,gapStarts(k)+gap1PolyRange);
        afterRange=afterRange0(~isinf(fluxIn(afterRange0)));
        numCadencesAfter=length(afterRange);
        
        thisHalfWidth=min(numCadencesBefore, numCadencesAfter);
         
        if thisHalfWidth>2
            
            range1 = [beforeRange(end-thisHalfWidth+1:end), afterRange(1:thisHalfWidth)];

            % local fit and order residuals by size
            polyCoefs = polyfit(range1-gapStarts(k),fluxIn(range1),2);
            [residuals residualInd] = sort(abs(fluxIn(range1)-polyval(polyCoefs,range1-gapStarts(k))));

            % local fit excluding points with 2 largest residuals and calculate
            % new residuals (NOTE: these steps are just a quick robust fit)
            polyCoefs = polyfit(range1(residualInd(1:end-2))-gapStarts(k),fluxIn(range1(residualInd(1:end-2))),2);
            residuals = fluxIn(range1(residualInd(1:end-2)))-polyval(polyCoefs,range1(residualInd(1:end-2))-gapStarts(k));

            % fill gap with modeled value + random noise term selected from
            % among residuals
            
            fluxOut(gapStarts(k)+paddingLength)=polyCoefs(end)+residuals(randi(length(residuals)));
            
        elseif numCadencesBefore==0 % gap at start
            
             fluxOut(gapStarts(k)+paddingLength)=median(fluxIn(afterRange(1:3)));
             
        elseif numCadencesAfter==0  % gap at end
            
             fluxOut(gapStarts(k)+paddingLength)=median(fluxIn(beforeRange(1:3)));
             
        else % gap within 2 LC of start or end
            
            range1 = [beforeRange(end-thisHalfWidth+1:end), afterRange(1:thisHalfWidth)];
                       
            fluxOut(gapStarts(k)+paddingLength)=median(fluxIn(range1));
            
        end

        
    end
    
end
%% 2.2.2 FILL GAPS OF LENGTH >1

% buffer at start and end of time series
excludeList=[1:gapBufferLength,nCadences+1-gapBufferLength:nCadences];

for k=1:longGapCount
            
        % ranges to model for gap fill same length as gap: 
        % before start
        range1 = gapStarts(longGapIndices(k))-1:-1:max(1,gapStarts(longGapIndices(k))-gapLengths(longGapIndices(k)));
        numCadencesRange1=length(range1);
        % after end
        if k<longGapCount,                                                              % JK110926
            countToNextGap=gapStarts(longGapIndices(k+1))-gapEnds(longGapIndices(k))-1; % JK110926
        else                                                                            % JK110926
            countToNextGap=nCadences-gapEnds(longGapIndices(k));                        % JK110926
        end                                                                             % JK110926
        range2start=min([nCadences, ...                                                 % JK110926
                         gapEnds(longGapIndices(k))+gapLengths(longGapIndices(k)), ...  % JK110926
                         gapEnds(longGapIndices(k))+countToNextGap]);                   % JK110926
        range2 = range2start:-1:gapEnds(longGapIndices(k))+1;                           % JK110926
        numCadencesRange2=length(range2);
        
        % polynomial order and outlier exclusion counts
        polyOrder1=max(0,min(2,floor(numCadencesRange1/6)));                            % JK110926
        polyOrder2=max(0,min(2,floor(numCadencesRange2/6)));                            % JK110926
        numExtremeResidToExclude1=max(0,min(4,floor(numCadencesRange1/6)));             % JK110926
        numExtremeResidToExclude2=max(0,min(4,floor(numCadencesRange2/6)));             % JK110926
        
        if numCadencesRange1==numCadencesRange2 % far enough away from start/end
            
            % weight is linear 0 to 1 across gap
            weight = ((1:gapLengths(longGapIndices(k)))-1.0)/(gapLengths(longGapIndices(k))-1);
            
            % local fit range1 as above to determine starting gap value
            polyCoefs = polyfit(range1'-gapStarts(longGapIndices(k))+0.5,fluxOut(range1+paddingLength),polyOrder1); % JK110926
            [~, residualInd] = sort(abs(fluxOut(range1+paddingLength)-polyval(polyCoefs,range1-gapStarts(longGapIndices(k))+0.5)')); % JK110926
            polyCoefs = polyfit(range1(residualInd(1:end-numExtremeResidToExclude1))'-gapStarts(longGapIndices(k))+0.5, ...
                fluxOut(range1(residualInd(1:end-numExtremeResidToExclude1))+paddingLength),polyOrder1); % JK110926
            startval=polyCoefs(end);

            % local fit range2 as above to determine ending gap value
            polyCoefs = polyfit(range2'-gapEnds(longGapIndices(k))-0.5,fluxOut(range2+paddingLength),polyOrder2); % JK110926
            [~, residualInd] = sort(abs(fluxOut(range2+paddingLength)-polyval(polyCoefs,range2-gapEnds(longGapIndices(k))-0.5)')); % JK110926        
            polyCoefs = polyfit(range2(residualInd(1:end-numExtremeResidToExclude2))'-gapEnds(longGapIndices(k))-0.5, ...
                fluxOut(range2(residualInd(1:end-numExtremeResidToExclude2))+paddingLength),polyOrder2); % JK110926
            endval=polyCoefs(end);

            % fill gap with weighted reversed data pivoting around start and
            % end values derived above
            fluxOut((gapStarts(longGapIndices(k)):gapEnds(longGapIndices(k)))+paddingLength)= ...
                (1-weight').*(2*startval-fluxOut(range1+paddingLength))+weight'.*(2*endval-fluxOut(range2+paddingLength));

                        
        else  % near start/end case

            rangeDiff=numCadencesRange1-numCadencesRange2;
            % weight is linear 0 to 1 across gap
            weight = [zeros(1,abs(max(0,rangeDiff))), ...
                      ((1:(gapLengths(longGapIndices(k))-abs(rangeDiff)))-1.0)/ ...
                      (gapLengths(longGapIndices(k))-abs(rangeDiff)-1),ones(1,abs(min(0,rangeDiff)))];

            % local fit range1 as above to determine starting gap value
            polyCoefs = polyfit(range1'-gapStarts(longGapIndices(k))+0.5,fluxOut(range1+paddingLength),polyOrder1); % JK110926
            [~, residualInd] = sort(abs(fluxOut(range1+paddingLength)-polyval(polyCoefs,range1-gapStarts(longGapIndices(k))+0.5)')); % JK110926        
            polyCoefs = polyfit(range1(residualInd(1:end-numExtremeResidToExclude1))'-gapStarts(longGapIndices(k))+0.5, ...
                fluxOut(range1(residualInd(1:end-numExtremeResidToExclude1))+paddingLength),polyOrder1); % JK110926
            startval=polyCoefs(end);

            % local fit range2 as above to determine ending gap value
            polyCoefs = polyfit(range2'-gapEnds(longGapIndices(k))-0.5,fluxOut(range2+paddingLength),polyOrder2); % JK110926
            [~, residualInd] = sort(abs(fluxOut(range2+paddingLength)-polyval(polyCoefs,range2-gapEnds(longGapIndices(k))-0.5)')); % JK110926        
            polyCoefs = polyfit(range2(residualInd(1:end-numExtremeResidToExclude2))'-gapEnds(longGapIndices(k))-0.5, ...
                fluxOut(range2(residualInd(1:end-numExtremeResidToExclude2))+paddingLength),polyOrder2); % JK110926
            endval=polyCoefs(end);

            %*** 
            % There is a  robustness issue with this code below, see KSOC-3277. The code here is a bit terse so not clear what's going on.  I, JCS, am not
            % that familiar with this code. It looks like the above reversedBeforeData and reversedAfterData are not long enough to properly fill the gap.  I cam
            % going to add in mean-value padding on the appropriate side for each to make them the same length as weight for below. Weight, by the way, does
            % appear to be the correct length for the long gap here that this code crashed on.
            
            % Also noticed I should be filling with mean-values, not zeros
            meanReversedBeforeData  = nanmean(fluxOut(range1+paddingLength));
            meanReversedAfterData   = nanmean(fluxOut(range2+paddingLength));
            % If a long gap is right at the beginning or end then tjhe above means could result in NaN. If so, do what we can to recover a mean
            if (isnan(meanReversedBeforeData) && ~isnan(meanReversedAfterData))
                meanReversedBeforeData = meanReversedAfterData;
            elseif (~isnan(meanReversedBeforeData) && isnan(meanReversedAfterData))
                meanReversedAfterData = meanReversedBeforeData; 
            elseif (~isnan(meanReversedBeforeData) && ~isnan(meanReversedAfterData))
                % both are NaN! Just use mean of whole flux (not good but better than nothing!)
                meanReversedBeforeData  = nanmean(fluxOut);
                meanReversedAfterData   = nanmean(fluxOut);
            end


            % fill gap with weighted reversed data pivoting around start and
            % end values derived above
            reversedBeforeData=[fluxOut(range1+paddingLength)',meanReversedBeforeData * ones(1,abs(min(0,rangeDiff)))]';
            reversedAfterData=[meanReversedAfterData * ones(1,abs(max(0,rangeDiff))),fluxOut(range2+paddingLength)']';

            % Here is the added code to extend the length of the above two vectors
            if (length(reversedBeforeData) ~= length(weight) || length(reversedAfterData) ~= length(weight))
                nMissingIndices         = length(weight) - length(reversedBeforeData);
                reversedBeforeData      = vertcat(reversedBeforeData, meanReversedBeforeData * ones(nMissingIndices,1));
                nMissingIndices         = length(weight) - length(reversedAfterData);
                reversedAfterData       = vertcat(meanReversedAfterData * ones(nMissingIndices,1), reversedAfterData);
            end
            
            fluxOut((gapStarts(longGapIndices(k)):gapEnds(longGapIndices(k)))+paddingLength)= ...
                (1-weight').*(2*startval-reversedBeforeData)+weight'.*(2*endval-reversedAfterData);

            
        end
            
        % buffer around long gap
        excludeList=[excludeList, gapStarts(longGapIndices(k))-gapBufferLength:gapEnds(longGapIndices(k))+gapBufferLength];
            
end

%% 2.2.3 PAD ENDS
%

% ranges to model for start/end pads: half length of pad: 
% at start
range1 = 1:ceil((paddingLength-1)/2.);
% at end
range2 = nCadences-ceil((paddingLength-1)/2.)+1:nCadences;  % JK110926

% range of padded regions
padRange=1:paddingLength;

% local fit range1 to determine start value
polyCoefs = polyfit(range1',fluxOut(range1+paddingLength),2);
[residuals residualInd] = sort(abs(fluxOut(range1+paddingLength)-polyval(polyCoefs,range1)'));        
polyCoefs = polyfit(range1(residualInd(1:end-2))',fluxOut(range1(residualInd(1:end-2))+paddingLength),2);
startval=polyCoefs(end);

% local fit range2 todetermine end value
polyCoefs = polyfit(range2'-nCadences-1,fluxOut(range2+paddingLength),2);
[residuals residualInd] = sort(abs(fluxOut(range2+paddingLength)-polyval(polyCoefs,range2-nCadences-1)'));        
polyCoefs = polyfit(range2(residualInd(1:end-2))'-nCadences-1,fluxOut(range2(residualInd(1:end-2))+paddingLength),2);
endval=polyCoefs(end);

% fill paded regions with weighted reversed data pivoting around start and
% end values derived above
fluxOut(padRange)=(2*startval-fluxOut(2*paddingLength+1-padRange));
fluxOut(padRange+nCadences+paddingLength)=(2*endval-fluxOut(nCadences+paddingLength+1-padRange));


%% 2.2.4 CORRECT 3 SIGMA DIFFERENTIAL OUTLIERS 
% This reduces false positives in the detector due to outliers.
% It does not move the SPSD locaton because the median 
% selects a value on the correct side of the step.
% The resulting timeseries is used only by the detector, the
% outliers are not removed in the final SPSD-corrected time series.
%

% first differences
dFluxOut=diff(fluxOut);

% robust 3 sigma of first differences
sd3 = outlierSigma*(quantile(dFluxOut, .84) - quantile(dFluxOut, .16))/2;

% outlier positions
outlierInd=find(abs(dFluxOut)>sd3);

% median corrections at detected locations and the position immediately
% after
for k=1:length(outlierInd),
    fluxOut(outlierInd(k))=median(fluxOut(max(1,outlierInd(k)-outlierMedianRange):min(end,outlierInd(k)+outlierMedianRange)));
    fluxOut(outlierInd(k)+1)=median(fluxOut(max(1,outlierInd(k)-outlierMedianRange+1):min(end,outlierInd(k)+outlierMedianRange+1)));
end


%% 3.0 BUILD OUTPUT STRUCTURE
%

outStruct.fluxOut    = fluxOut;
outStruct.mask = ~ismember(1:nCadences,excludeList);

warning on MATLAB:polyfit:PolyNotUnique

%%
end

