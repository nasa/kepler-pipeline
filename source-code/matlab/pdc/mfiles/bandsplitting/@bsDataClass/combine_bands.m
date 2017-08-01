function combine_bands(obj,targetIndex)

% If splitting method is not wavelet, simply copy all bands over
% This is not really program flow good design. It's a bit of a bandaid to support non-wavelet decomposition,
% which however might never really get used. It has mainly been implemented for testing and comparison.
% if (~strcmpi(obj.configStruct.splittingMethod,'wavelet'))
%    obj.combinedBands = obj.allBands;
%    obj.combinedBandsUncertainties = obj.allBandsUncertainties;
%    return
%end
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

% Get required fields from obj
hfigBands = obj.diagnosticData.hfigBands;
allBands = obj.allBands{targetIndex};
allBandsUncertainties = obj.allBandsUncertainties{targetIndex};
nBandGroups = obj.nBands;       % nominally 3
nAllBands = size(allBands,2);   % nominally 11
bandGroupBoundaries = obj.configStruct.groupingManualBandBoundaries;

% Initialize bandsplitting object fields
obj.combinedBands = zeros( size(allBands,1) , nBandGroups );
obj.combinedBandsUncertainties = zeros( size(allBandsUncertainties,1) , nBandGroups );

% Since KSOC-2726, the code was hard-wired to implement only the 'manual'
% groupingMethod with bandGroupBoundaries set to [1023 3],
% and nBandGroups = 3. Now we generalize to allow all possible bandGroups
% that can be made from contiguous subBands.
switch (lower(obj.configStruct.groupingMethod))
    
    case 'manual'
        
        % The 'manual' band combining method constructs bandGroups via
        % the vector bandGroupBoundaries. A bandGroup is a combination of
        % a contiguous set of subBands.
        
        % bandGroupBoundaries (nominally [1023 3]) specifies the
        % boundaries of all the desired bandGroups in cadences
        
        % nBandGroups is the number of bandGroups and must be one more than the
        % number of bandGroupBoundaries
        
        % bandGroupBoundaries must satisfy these conditions:
        % (1) The entries are monotonically decreasing positive integers
        % (2) Each entry must be one less than a power of 2
        % (3) The first entry must be less than 2^10 = 1024
        % (4) The length of groupingManualBoundaries must be less than or equal
        %     to 10. The largest possible number of bandGroups is
        %     nBandGroups = 11, when each bandGroup is a subBand
        
        % The bandGroups are formed as follows (see comments)
        
        % Check that nBandGroups and bandGroupBoundaries satisfy the
        % required constraints
        status = check_band_boundaries(nBandGroups,bandGroupBoundaries);
        if(status~=1)
            error('bandGroupBoundaries and/or nBandGroups do not satisfy the required constraints')
        end
        
        % boundaries of bandGroups are the powers of two immediately
        % greater than manualBoundaries. They are ordered by
        % decreasing scales. Nominal is [10 2]
        bandGroupBoundaryPowersOfTwo = log2(bandGroupBoundaries + 1);
        
        % Boundaries of subBands, in log2(cadences scales).
        % These are powers of two, in decreasing order.
        subBandPowersOfTwo = fliplr((1:nAllBands)-1); % inverse order
        
        % Combine subBands to form bandGroups
        % The cell array bandGroupSubBandIndexes contains indices of the
        % subBands which combine to make each bandGroup
        bandGroupSubBandIndexes = cell(1,nBandGroups);
        for iGroup = 1:nBandGroups
            
            % Specify which subBands and cadence scales compose this bandGroup
            if(iGroup == 1)
                % First bandGroup consists of subBands with bandGroupBoundaryPowersOfTwo
                % greater than or equal to the first entry of bandGroupBoundaryPowersOfTwo
                bandGroupSubBandIndexes{iGroup} = find(subBandPowersOfTwo >= bandGroupBoundaryPowersOfTwo(iGroup));
                
            elseif(iGroup > 1 && iGroup < nBandGroups)
                % bandGroups between the first and the last consist of subBands with
                % bandGroupBoundaryPowersOfTwo greater than or equal to that of the current
                % bandGroupBoundaryPowersOfTwo and less than than that of
                % the previous bandGroupBoundaryPowersOfTwo
                bandGroupSubBandIndexes{iGroup} = find(subBandPowersOfTwo >= bandGroupBoundaryPowersOfTwo(iGroup) & subBandPowersOfTwo < bandGroupBoundaryPowersOfTwo(iGroup-1));
                
            elseif(iGroup == nBandGroups)
                % Last bandGroup consists of subBands with bandGroupBoundaryPowersOfTwo
                % smaller than the bandGroupBoundaryPowersOfTwo of the next-to-the-last
                % group
                bandGroupSubBandIndexes{iGroup} = find(subBandPowersOfTwo < bandGroupBoundaryPowersOfTwo(iGroup-1));
            end
            
            % cadence scales of this bandGroup
            cadenceScales = 2.^(subBandPowersOfTwo(bandGroupSubBandIndexes{iGroup}));
            
            
            % Record which subBands and cadence scales compose this
            % bandGroup
            obj.infoStruct.bands(iGroup).subBands = bandGroupSubBandIndexes{iGroup};
            obj.infoStruct.bands(iGroup).cadenceScales = cadenceScales;
            
            % Combine the flux across the subBands belonging to this bandGroup
            obj.combinedBands(:,iGroup) = sum(allBands(:,bandGroupSubBandIndexes{iGroup}),2);
            obj.combinedBandsUncertainties(:,iGroup) = sum(allBandsUncertainties(:,bandGroupSubBandIndexes{iGroup}),2);
            
        end %for
        
    otherwise
        
        % Throw an error in case another groupingMethod than 'manual' was chosen
        disp('ERROR: bsParamStruct.combineMethod must be manual');
        
end % case


% Diagnostic Plotting
if ( (obj.diagnosticStruct.plotFigures) && (any(obj.diagnosticStruct.targetsToMonitor==n)) )
    nBands = size(obj.combinedBands,2);
    figure(hfigBands);
    for i=1:nBands
        subplot(nBands,1,i);
        plot(obj.combinedBands(:,i));
        title(['band ' int2str(i) '  (target ' int2str(n) ')']);
    end
end
return


%==========================================================================
function status = check_band_boundaries(nBandGroups,bandGroupBoundaries)

% Check that nBandGroups and bandGroupBoundaries satisfy the required
% constraints:

% nBandGroups is the number of bandGroups and is one more than the
% number of boundaries

% bandGroupBoundaries must satisfy these conditions:
% (1) The entries are monotonically decreasing positive integers
% (2) Each entry must be one less than a power of 2
% (3) The first entry must be less than 2^10 = 1024
% (4) The length of groupingManualBoundaries must be less than 11. The
%     largest possible number of bandGroups is 11, when each bandGroup
%     is a subBand

status = ( nBandGroups == length(bandGroupBoundaries) + 1 ) & ...
    ( sum(diff(bandGroupBoundaries) < 0) == length(bandGroupBoundaries) - 1 ) & ...
    ( isequal(mod(log2(bandGroupBoundaries+1),1),zeros(1,length(bandGroupBoundaries))) ) & ...
    ( bandGroupBoundaries(1) < 1024 ) & ...
    ( length(bandGroupBoundaries) < 11 );
return
