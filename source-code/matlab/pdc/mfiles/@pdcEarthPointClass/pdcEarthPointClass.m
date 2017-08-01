classdef pdcEarthPointClass
% =========================================================================================================================
%% pdcEarthPointClass
%
%    Functionality:
%    ----------------------------------------------------------------------------------------------------------------------
%
%    1. Calculate earth-point component of goodnessMetric (WHOLE CHANNEL)
%
%         pdcEarthPointClass.calc_earthpoint_goodnessmetric_for_modout( rawTargetDataStruct , correctedTargetResultsStruct , cadenceTimes )
%                      rawTargetDataStruct           : targetDataStruct, as from inputsStruct
%                      correctedTargetResultsStruct  : targetResultsStruct, as from outputsStruct
%                      cadenceTimes                  : cadenceTimes, as from inputsStruct
%
%    ----------------------------------------------------------------------------------------------------------------------
%    2. Calculate earth-point component of goodnessMetric (WHOLE CHANNEL, EACH EARTHPOINT INDIVIDUALLY)
%
%         pdcEarthPointClass.calc_earthpoint_goodnessmetric_for_modout_individual( rawTargetDataStruct , correctedTargetResultsStruct , cadenceTimes )
%                      rawTargetDataStruct           : targetDataStruct, as from inputsStruct
%                      correctedTargetResultsStruct  : targetResultsStruct, as from outputsStruct
%                      cadenceTimes                  : cadenceTimes, as from inputsStruct
%         (returns a Nx2 matrix, where N is the number of targets)
%
%    ----------------------------------------------------------------------------------------------------------------------
%    3. Calculate earth-point component of goodnessMetric (SINGLE TARGET)
%
%         pdcEarthPointClass.calc_single_earthpoint_goodnessmetric( rawTargetDataStruct , correctedTargetResultsStruct , cadenceTimes, iTarget, iEP )
%                      rawTargetDataStruct           : targetDataStruct, as from inputsStruct
%                      correctedTargetResultsStruct  : targetResultsStruct, as from outputsStruct
%                      cadenceTimes                  : cadenceTimes, as from inputsStruct
%                      iTarget                       : index of target to calculate goodness for
%                      iEP                           : [OPTIONAL] index of Earth Point to calculate goodness for (usually 1 or 2)
%                                                      if 0, calculatess goodness for EP 1 and EP 2, and averages
%                                                      (this is default behavior is iEP is not specified)
%
%    ----------------------------------------------------------------------------------------------------------------------
%
%    4. Diagnostic evaluation and plotting of earth-point and goodness components
%
%         pdcEarthPointClass.evaluate_earthpoints( rawTargetDataStruct , correctedTargetResultsStruct , cadenceTimes, iTarget, iEP )
%                      rawTargetDataStruct           : targetDataStruct, as from inputsStruct
%                      correctedTargetResultsStruct  : targetResultsStruct, as from outputsStruct
%                      cadenceTimes                  : cadenceTimes, as from inputsStruct
%                      iTarget                       : index of target to calculate goodness for
%                      iEP                           : index of Earth Point to calculate goodness for (usually 1 or 2)
%
%    ----------------------------------------------------------------------------------------------------------------------
%
%    5. Create instances of pdcEarthPointClass, for diagnostics and further computation
%          Two calling options, for inputs or outputs:
%          a) Constructor 1:
%                 pdcEarthPointClass(rawTargetStruct,cadenceTimes,iTarget,iEP)
%                      rawTargetDataStruct           : targetDataStruct, as from inputsStruct
%                      cadenceTimes                  : cadenceTimes, as from inputsStruct
%                      iTarget                       : index of target to calculate goodness for
%                      iEP                           : index of Earth Point to calculate goodness for (usually 1 or 2)
%          b) Constructor 2:
%                 pdcEarthPointClass(correctedTargetStruct,cadenceTimes,iTarget,iEP,cadenceRange)
%                      rawTargetDataStruct           : targetDataStruct, as from inputsStruct
%                      cadenceTimes                  : cadenceTimes, as from inputsStruct (can be empty)
%                      iTarget                       : index of target to calculate goodness for
%                      iEP                           : index of Earth Point to calculate goodness for (usually 1 or 2)
%                      cadenceRange                  : cadence indices for earthPoint region, usually use the respective
%                                                      property of the output of input constructor, see (a)
%
%           Note: unused inputs exist because Matlab's pseudo-OOP model does not supported constructor overloading.
%                 nothing left to say about that...
%
%    ----------------------------------------------------------------------------------------------------------------------
%
%    NOTE: Some parts of the code are a bit unclean. Due to a very adhoc decision that we want to
%          include this in 8.2, there was no prototyping. This IS the prototype.
%          Some things to clean up if time permits later:
%          a) A cleaner separation of member functions, static functions, and out-of-class
%             helper functions. For instance, some of them are weird hybrids that are class
%             methods but return values rather than an object with the respective values modified.
%          b) Some of the hard-coded constants and parameters (e.g. the weightings, or whether or not
%             to perform Normalization or HarmonicsRemoval) could be input parameters. On the other hand,
%             ideally we will just optimize these settings once and don't touch them ever again.
%          c) Should experiment with other gapfilling methods, and/or play with the parameters (e.g. the AR window size).
%
%          The actual calculation of the goodness value for an earth-point correction is alchemy.
%          There's a healthy blend of seemingly arbritrary constants, which have been empirically
%          tuned. The same applies to the final nonlinear mappin within the [0,1] interval.
%
%    ----------------------------------------------------------------------------------------------------------------------
%
%    NOTE: To avoid problems with the unfortunately not very well defined targetDataStruct vs targetResultsStruct
%          structure types in PDC, the methods (1)-(4) also take the 'wrong' input, and convert it accordinly
%          if needed. For instance, one can also call calc_single_earthpoint_goodnessmetric on two input structures.
%
% =========================================================================================================================
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
    
%% ------------------------- Constants (in lieu of static properties) ----------------
    properties (Constant = true)
        PRE_WIDTH = 500;        % was 300 % What is this parameter? I think it's the number of cadences before the Earth-point that is investigated.
        RECOVER_WIDTH = 150;    % was 150
        POST_WIDTH = 500;       % was 150
        GFRANGE = 500;          % range for gap-filling
        WEIGHT_EXPREL  = 0.0   % relative weight of exponential-fit part, relative (input vs output)
        WEIGHT_EXPABS  = 1.0;  % relative weight of exponential-fit part, absolute (output only)
        WEIGHT_GF      = 0;    % relative weight of gap-filling part
        WEIGHT_VAR     = 0;    % variability part (output only)
        STRETCH_FACTOR = 1.0;  % stretching exponent. larger values makes overall goodness lower
        ALPHA          = 0.65; % nonlinear mapping constant for final metric value
        BETA           = 3.0;  % nonlinear mapping constant for final metric value
        LOCALDETREND   = 0;    % if true, removes linear trend in window of exponential fit
        USELINEARFIT   = 1;    % use linear fit in log-domain instead of nonlinearfit
        FITEDGEREGION  = 10;   % region to exclude when averaging 2nd derivative (overfit problem with linear term)
        SCALE_RECOVER  = 5e6;  % factor used to scale the recover derivative to obtain relative goodness
        VERBOSITY      = false;% If VERBOSITY = true then display warning messsages
    end
%% ------------------------- Properties ----------------------------------------------
    properties (GetAccess = 'public' , SetAccess = 'public')    
        gapFillingEnabled = 0;  % disable, if not required for calculation
        removeHarmonics = false;    % if true, harmonics are removed on input time series
        normalize = 1;          % 0: don't normalize. 1: median. 2: std
        debugLevel = 0;         % 1: plot stuff
        % data
        cadenceRange = [];      % full cadence range of PRE, GAP, RECOVERY, GAP
        values = [];            % values (of what?!? target flux values?)
        gaps = [];              % gap Indicators
        filledRecover = [];     % recover period filled with Rob's gap filler
        expfitPre = [];         % exponential fit to PRE region
        expfitRecover = [];     % exponential fit to RECOVER region
        expfitPost = [];        % exponential fit to POST region
        uncertainties = [];     % uncertainties (needed for gap-filling algorithm)
        timeStamps = [];        % time stamps (needed at all??)
        indPreEP = [];          % indices of PRE phase
        indGapEP = [];          % indices of GAP phase
        indRecoverEP = [];      % indices of RECOVERY phase
        indPostEP = [];         % indicies of POST phase
        fullTimes = [];         % indices of all cadences
        fullValues = [];        % values of all cadences
        fullGaps = [];          % gap-indicators of all cadences
        fullUncertainties = []; % uncertainties of all cadences (needed for gap-filling algorithm)
        source = struct(...
            'type','',...       % 'input' or 'output'
            'keplerId',0,...    % keplerId
            'index',0);         % index
    end
%% ------------------------- Methods ----------------------------------------------
    methods (Access = 'public')
        % ============================================================================================
        % --- Constructor from inputsStruct.targetDataStruct and outputsStruct.targetResultsStruct ---
        % ============================================================================================
        function obj = pdcEarthPointClass(targetDataStruct,cadenceTimes,iTarget,iEP,varargin)
            if (~isempty(varargin))
                % optional input argument in case inputsStruct is actually an outputsStruct
                EPin = varargin{1};
            end
            if (~isempty(cadenceTimes))
                % is INPUTSSTRUCT.TARGETDATASTRUCT
                obj = obj.construct_from_inputsStruct(targetDataStruct,cadenceTimes,iTarget,iEP);
            else
                % is OUTPUTSSTRUCT.TARGETRESULTSSTRUCT
                obj = obj.construct_from_outputsStruct(targetDataStruct,iTarget,EPin);
            end
        end
        % ===========================================================================
        % --- Plot EP ---
        % ===========================================================================
        function a_ = plotEP(obj,varargin)
            PLOTTYPE = 0; % new plot
            if (~isempty(varargin))
                h_ = varargin{1};
                if (strcmp(get(h_,'type'),'figure'))
                    figure(h_);
                    a_ = axis;
                    PLOTTYPE = 1; % existing figure
                end
                if (strcmp(get(h_,'type'),'axes'))
                    a_ = axis(h_);
                    PLOTTYPE = 2; % existing axes
                end
            end
            if (PLOTTYPE==0)
                figure;
                a_ = axis;
            end
            hold on;
            plot(obj.cadenceRange(obj.indPreEP),obj.values(obj.indPreEP),'b');
%             plot(obj.cadenceRange(obj.indGapEP),obj.values(obj.indGapEP),'g');
            plot(obj.cadenceRange(obj.indRecoverEP),obj.values(obj.indRecoverEP),'r');
            plot(obj.cadenceRange(obj.indPostEP),obj.values(obj.indPostEP),'b');
            plot(obj.cadenceRange(obj.indRecoverEP),obj.expfitRecover,'k');
            plot(obj.cadenceRange(obj.indRecoverEP),obj.filledRecover,'g'); % obj.filledRecover(obj.indRecoverEP)
            axis tight;            
            box on;
            title(['EP values (source=' obj.source.type ')']);
        end
        
        % ===========================================================================
        % --- Plot Full TimeSeries ---
        % ===========================================================================
        function a_ = plotFull(obj,varargin)
            PLOTTYPE = 0; % new plot
            if (~isempty(varargin))
                h_ = varargin{1};
                if (strcmp(get(h_,'type'),'figure'))
                    figure(h_);
                    a_ = axis;
                    PLOTTYPE = 1; % existing figure
                end
                if (strcmp(get(h_,'type'),'axes'))
                    a_ = axis(h_);
                    PLOTTYPE = 2; % existing axes
                end
            end
            if (PLOTTYPE==0)
                figure;
                a_ = axis;
            end
            hold on;
            plot(obj.fullTimes(~obj.fullGaps),obj.fullValues(~obj.fullGaps),'b');
            axis tight;            
            box on;
            title(['EP full time-series (source=' obj.source.type ')']);
        end
        
        % ===========================================================================
        % --- get PRE ---
        % ===========================================================================
        function values = get_pre(obj)
            if (isempty(obj.indPreEP))
                values = [];
            else
                values = obj.values(obj.indPreEP);
            end
        end
        % ===========================================================================
        % --- get RECOVERY ---
        % ===========================================================================
        function values = get_recovery(obj)
            values = obj.values(obj.indRecoverEP);
        end
        % ===========================================================================
        % --- get POST ---
        % ===========================================================================
        function values = get_post(obj)
            values = obj.values(obj.indPostEP);
        end
        
        % ===========================================================================
        % --- Calc ExpFit for PRE, RECOVER, POST ---        
        % ===========================================================================
        function [PF RMS] = calc_expfit_magnitude(obj)
            val = obj.linear_detrend();            
            X{1} = obj.indPreEP;
            X{2} = obj.indRecoverEP;
            X{3} = obj.indPostEP;
            Y{1} = val(obj.indPreEP);
            Y{2} = val(obj.indRecoverEP);
            Y{3} = val(obj.indPostEP);
            
            suffix = {'pre','recover','post'};            
            %***
            % PRE
            % Earth-point at beginning of quarter
            % KSOC-4849: Or the Earth-Point is too close to the
            % beginning of the quarter
            if (isempty(obj.indPreEP) || length(Y{1}) < obj.PRE_WIDTH)
                PF.(suffix{1})  = [];
                RMS.(suffix{1}) = [];
            else
                k = 1;
                % - first fragment
                x = (1:obj.RECOVER_WIDTH)';
                y = Y{k}(1:obj.RECOVER_WIDTH);
                if (obj.LOCALDETREND)
                    y = local_detrend(y);
                end
                [ yfit1 rms1 fitcoeffs1 ] = fitexp(x,y);            
                % - last fragment
                x = (1:obj.RECOVER_WIDTH)';
                y = Y{k}(obj.PRE_WIDTH-obj.RECOVER_WIDTH+1:obj.PRE_WIDTH);
                if (obj.LOCALDETREND)
                    y = local_detrend(y);
                end
                [ yfit2 rms2 fitcoeffs2 ] = fitexp(x,y);
                % - average over both
                df1 = mean(diff(yfit1,2)); % second derivative, average curvature
                df2 = mean(diff(yfit2,2)); % second derivative, average curvature
                PF.(suffix{k}) = max([abs(df1) abs(df2)]); % use MEAN to make more sensitive
%                 PF.(suffix{k}) = max([abs(real(fitcoeffs1(2))) abs(real(fitcoeffs2(2)))]); % use MEAN to make more sensitive
                RMS.(suffix{k}) = max([rms1 rms2]); % use MEAN to make more sensitive
            end
                        
            %***
            % RECOVERY
            k = 2;
            x = (1:obj.RECOVER_WIDTH)';
            y = Y{k};
            if (obj.LOCALDETREND)
                y = local_detrend(y);
            end
            [ yfit rms fitcoeffs ] = fitexp(x,y);
            df = mean(diff(yfit,2)); % second derivative, average curvature
            PF.(suffix{k}) = abs(df);
%             PF.(suffix{k}) = abs(real(fitcoeffs(2)));
            RMS.(suffix{k}) = rms;
            
            %***
            % POST
            k = 3;
            % - first fragment
            x = (1:obj.RECOVER_WIDTH)';
            y = Y{k}(1:obj.RECOVER_WIDTH);
            if (obj.LOCALDETREND)
                y = local_detrend(y);
            end
            [ yfit1 rms1 fitcoeffs1 ] = fitexp(x,y);            
            % - last fragment
            x = (1:obj.RECOVER_WIDTH)';
            y = Y{k}(obj.POST_WIDTH-obj.RECOVER_WIDTH+1:obj.POST_WIDTH);
            if (obj.LOCALDETREND)
                y = local_detrend(y);
            end
            [ yfit2 rms2 fitcoeffs2 ] = fitexp(x,y);
            % - average over both
            df1 = mean(diff(yfit1,2)); % second derivative, average curvature
            df2 = mean(diff(yfit2,2)); % second derivative, average curvature
            PF.(suffix{k}) = max([abs(df1) abs(df2)]); % use MEAN to make more sensitive
%             PF.(suffix{k}) = max([abs(real(fitcoeffs1(2))) abs(fitcoeffs2(2))]); % use MEAN to make more sensitive
            RMS.(suffix{k}) = max([rms1 rms2]); % use MEAN to make more sensitive
                        
        end
        
        % ===========================================================================        
        % --- Calc GapFill diff ---
        % ===========================================================================        
        function [gfdiff] = calc_gapfilldiff_magnitude(obj)
            X = obj.values(obj.indRecoverEP) - obj.filledRecover; %(obj.indRecoverEP);            
            ind = ~isnan(X);
            gfdiff = sqrt(sum(X(ind).*X(ind))/length(ind));
%             tmp = obj.filledRecover(obj.indRecoverEP);
%             gfdiff = abs(gfdiff/nanmedian(tmp(ind)));
        end

        % ===========================================================================
        % --- Calc Variability for PRE, RECOVER, POST ---        
        % ===========================================================================
        function [VARIA] = calc_variability(obj)
            val = obj.linear_detrend();            
            X{1} = obj.indPreEP;
            X{2} = obj.indRecoverEP;
            X{3} = obj.indPostEP;
            Y{1} = val(obj.indPreEP);
            Y{2} = val(obj.indRecoverEP);
            Y{3} = val(obj.indPostEP);
            % PRE
            if (isempty(obj.indPreEP))
                % This Earth-point is at quarter beginning
                VARIA.PRE = [];
                var2 = []; % The the recover and post calculations
            else
                y = Y{1}(1:obj.RECOVER_WIDTH);
                var1 = nanstd( y );
                y = Y{1}(obj.PRE_WIDTH-obj.RECOVER_WIDTH+1:obj.PRE_WIDTH);
                var2 = nanstd( y );
                VARIA.PRE = mean([var1 var2]);
            end
            % RECOVER
            y = Y{2};
            var1 = nanstd( y );
            VARIA.RECOVER = mean([var1 var2]);
            % POST
            y = Y{3}(1:obj.RECOVER_WIDTH);
            var1 = nanstd( y );
            y = Y{3}(obj.POST_WIDTH-obj.RECOVER_WIDTH+1:obj.POST_WIDTH);
            var2 = nanstd( y );
            VARIA.POST = mean([var1 var2]);            
        end

        % ===========================================================================
        % --- Calc Avg Baseline Diff for PRE, RECOVER, POST ---        
        % ===========================================================================
        function [RMS] = calc_baseline_diff(obj)
            [val baseline] = obj.linear_detrend();
            XX{1} = val(obj.indPreEP);
            XX{2} = val(obj.indRecoverEP);
            XX{3} = val(obj.indPostEP); 
            X{1} = val(obj.indPreEP) - baseline(obj.indPreEP);
            X{2} = val(obj.indRecoverEP) - baseline(obj.indRecoverEP);
            X{3} = val(obj.indPostEP) - baseline(obj.indPostEP);
            suffix = {'pre','recover','post'};
            for i=1:3
                if (isempty(obj.indPreEP))
                    % This Earth-point is at quarter beginning
                    RMS = [];
                    continue;
                end
                X{i} = power( X{i} , 2 );
                rmsarea.(suffix{i}) = sqrt(sum(X{i}(~isnan(X{i}))));
                rmsarea.(suffix{i}) = rmsarea.(suffix{i}) / nanmedian(XX{i});
                if (obj.debugLevel>1)
                    disp([ (suffix{i}) ': ' num2str(rmsarea.(suffix{i}))]);
                    figure;
                    x = (1:length(X{i}))';
                    plot(x,X{i},'b');
                    title(suffix{i});
                end
            end
            RMS = rmsarea.recover / (rmsarea.pre+rmsarea.post) *2;
        end
        
        % ===========================================================================
        % --- gap filling (currently using Rob's PA algorithm) ---
        % ===========================================================================
        function [ gapFilledValues ] = gap_filling(obj)
%         function [ gapFilledValues ] = gap_filling(obj)
            % Rob's gap filling
            
            % * version 1: just using EP window
%             gaps = obj.gaps;
%             gaps(obj.indGapEP) = true;
%             gaps(obj.indRecoverEP) = true;
%             uncertainties = obj.uncertainties;
%             uncertainties(uncertainties==0) = nanmedian(uncertainties); % avoid 0s in uncertainties (crash in gf_predict)
%             gapFilledValues = gf_iterative(obj.values,gaps,uncertainties,200); % min([obj.PRE_WIDTH obj.POST_WIDTH])-10);
            % * version 2: full time series (seems to perform worse?)
            gaps = obj.fullGaps;
            gaps(obj.cadenceRange(obj.indGapEP)) = true;
            gaps(obj.cadenceRange(obj.indRecoverEP)) = true;
            gapFilledValues = gf_iterative(obj.fullValues,gaps,obj.fullUncertainties,obj.GFRANGE); % min([obj.PRE_WIDTH obj.POST_WIDTH])-10);
            gapFilledValues = gapFilledValues(obj.cadenceRange);
        end
        % ===========================================================================
        % --- exponential fit (performed in log domain) ---
        % ===========================================================================
        function [ expfitPre expfitRecover expfitPost ] = do_expfit(obj)
            val = obj.linear_detrend();
            X{1} = obj.indPreEP;
            X{2} = obj.indRecoverEP;
            X{3} = obj.indPostEP;
            Y{1} = val(obj.indPreEP);
            Y{2} = val(obj.indRecoverEP);
            Y{3} = val(obj.indPostEP);
            suffix = {'pre','recover','post'};
            if (obj.debugLevel==1)
                f = figure;
            end
            for i=1:3
                if (i==1 && isempty(obj.indPreEP))
                    % This Earth-point is at quarter beginning
                    expfitPre = [];
                    continue;
                end
                x = (1:length(Y{i}))';
                [ yfit rms fitcoeffs ] = fitexp(x,Y{i});
                PF.(suffix{i}) = abs(fitcoeffs(1));
                RMS.(suffix{i}) = rms;
                if (obj.debugLevel>1)
                    figure;
                    plot(x,y,'b');
                    hold on;
                    plot(x,yfit,'r');
                    title([ obj.source.type '   ' suffix{i}]);                    
                end
                switch (i)
                    case 1
                        expfitPre = yfit;
                    case 2
                        expfitRecover = yfit;
                    case 3
                        expfitPost = yfit;
                end
            end
        end
        % ===========================================================================

        
    end
%% ------------------------- Methods ----------------------------------------------
    methods (Access = 'private')
        % ===========================================================================
        % --- Constructor from inputsStruct.targetDataStruct ---
        % ===========================================================================
        function obj = construct_from_inputsStruct(obj,targetDataStruct,cadenceTimes,iTarget,iEP)
            if (iTarget>length(targetDataStruct))
                error(['requested target ' int2str(iTarget) ' but only ' int2str(length(targetDataStruct)) ' in targetDataStruct.']);
                % execution is terminated after error.
            end
            % extract data
            nCadences = length(targetDataStruct(iTarget).values);
            gaps = targetDataStruct(iTarget).gapIndicators;
            values = targetDataStruct(iTarget).values;
           %values(gaps) = nan; % this causes pain. but it seems necessary. alternative would be linear gap_filling            
            uncertainties = targetDataStruct(iTarget).uncertainties;
            % store full data
            obj.fullTimes = (1:nCadences)';
            obj.fullValues = values;
            obj.fullGaps = gaps;
            obj.fullUncertainties = uncertainties;
            % extract EP data
            [nEP,ind,cadences] = obj.get_number_of_earthpoints(targetDataStruct,cadenceTimes,iTarget);
            if (iEP>nEP)
                if (iTarget==1) % throw warning for 1st target
                    if (obj.VERBOSITY)
                        disp(['could not extract earthpoint #' int2str(iEP) ', found only ' int2str(nEP) ' earthpoints in time series']);
                    end
                end
                obj.cadenceRange = [];
                return;
            end
            % remove harmonics, if requested
            if (obj.removeHarmonics)
                values = obj.remove_harmonics();
                obj.fullValues = values;
            end
            % normalize, if requested
            if (obj.normalize>0)
                values = obj.normalize_flux();
                obj.fullValues = values;
            end
            % KSOC-3289: if the earthpoint is close to a quarter edge then these index ranges will result in out of range cadence indices. 
            % Remove these out of range indices
            obj.indPreEP = (cadences{iEP}(1)-1-obj.PRE_WIDTH : cadences{iEP}(1)-1)';
            obj.indPreEP = obj.indPreEP(obj.indPreEP > 0);
            obj.indGapEP = (cadences{iEP}(1) : cadences{iEP}(end))';
            obj.indRecoverEP = (cadences{iEP}(end)+1 :cadences{iEP}(end)+obj.RECOVER_WIDTH)';
            obj.indRecoverEP = obj.indRecoverEP(obj.indRecoverEP <= nCadences);
            obj.indPostEP = (cadences{iEP}(end)+obj.RECOVER_WIDTH+1 : cadences{iEP}(end)+obj.RECOVER_WIDTH+obj.POST_WIDTH)';
            obj.indPostEP = obj.indPostEP(obj.indPostEP <= nCadences);

            obj.cadenceRange = [ obj.indPreEP ; obj.indGapEP ; obj.indRecoverEP ; obj.indPostEP ];

            % set indices to 1-based relative to the first cadence in the pre-range (obj.indPreEP) (instead of absolute quarter cadence numbers)
            if (isempty(obj.indPreEP))
                % if indPreEP is empty then the Earth-point started at the beginning of the quarter.
                startCadence = 1;
            else
                startCadence = obj.indPreEP(1);
            end
            obj.indPostEP       = obj.indPostEP     - startCadence +1;
            obj.indRecoverEP    = obj.indRecoverEP  - startCadence +1;
            obj.indGapEP        = obj.indGapEP      - startCadence +1;
            obj.indPreEP        = obj.indPreEP      - startCadence +1;
            % set other data fields
            obj.values = values( obj.cadenceRange );
            obj.gaps = gaps( obj.cadenceRange );
            obj.uncertainties = uncertainties( obj.cadenceRange );
            % set meta data
            obj.source.type = 'input';
            obj.source.keplerId = targetDataStruct(iTarget).keplerId;
            obj.source.index = iTarget;
            % gap filling for recover period
            if (obj.gapFillingEnabled)
                obj.filledRecover = obj.gap_filling();
            else
                obj.filledRecover = values(obj.indRecoverEP);
                if (obj.WEIGHT_GF>0 && obj.VERBOSITY)
                    disp('WARNING: gapFillingEnabled = 0, but weight for gapFill component >0.');
                end                
            end                       
            % calc expfit
            [ obj.expfitPre obj.expfitRecover obj.expfitPost ] = obj.do_expfit();
        end
        % ===========================================================================
        % --- Constructor from outputsStruct and indices---
        % ===========================================================================
        function obj = construct_from_outputsStruct(obj,targetResultsStruct,iTarget,EPin)
            if (iTarget>length(targetResultsStruct))
                error(['requested target ' int2str(iTarget) ' but only ' int2str(length(targetResultsStruct)) ' in targetResultsStruct.']);
                % execution is terminated after error.
            end
            nCadences = length(targetResultsStruct(iTarget).values);
            cadences = EPin.cadenceRange;
            if (cadences(end)>nCadences)
                error(['requested cadence range is' int2str(cadences(1)) '-' int2str(cadences(end)) ', but only ' int2str(nCadences) ' in time series']);
                % execution is terminated after error.
            end
            gaps = targetResultsStruct(iTarget).gapIndicators;
            values = targetResultsStruct(iTarget).values;
            uncertainties = targetResultsStruct(iTarget).uncertainties;
           %values(gaps) = nan;
            % store full data
            obj.fullTimes = (1:nCadences)';
            obj.fullValues = values;
            obj.fullGaps = gaps;            
            obj.fullUncertainties = uncertainties;
            % remove harmonics, if requested
            if (obj.removeHarmonics)
                values = obj.remove_harmonics();
                obj.fullValues = values;
            end
            % normalize, if requested
            if (obj.normalize>0)
                values = obj.normalize_flux();
                obj.fullValues = values;
            end            
            % extract EP data            
            % The pre_width is not always the full width if we are dealing with the earth-point right at the beginning, so set the pre-width for this
            % earth-point
            local_pre_width = length(EPin.indPreEP);

            GAP_WIDTH = length(cadences) - local_pre_width - obj.RECOVER_WIDTH - obj.POST_WIDTH;
            % set indices for parts
            % KSOC-3289: if the earthpoint is close to a quarter edge then these index rangeswill result in out of range cadence indices. 
            % Remove these out of range indices
            obj.indPreEP = cadences( 1 : local_pre_width );
            obj.indPreEP = obj.indPreEP(obj.indPreEP <= nCadences);
            obj.indGapEP = cadences( local_pre_width+1 : local_pre_width+GAP_WIDTH );
            obj.indGapEP = obj.indGapEP(obj.indGapEP > 0 & obj.indGapEP <= nCadences);
            obj.indRecoverEP = cadences( local_pre_width+GAP_WIDTH+1 : local_pre_width+GAP_WIDTH+obj.RECOVER_WIDTH );
            obj.indRecoverEP = obj.indRecoverEP(obj.indRecoverEP > 0 & obj.indRecoverEP <= nCadences);
            obj.indPostEP = cadences( local_pre_width+GAP_WIDTH+obj.RECOVER_WIDTH+1 : local_pre_width+GAP_WIDTH+obj.RECOVER_WIDTH+obj.POST_WIDTH );
            obj.indPostEP = obj.indPostEP(obj.indPostEP > 0 & obj.indPostEP <= nCadences);

            % set indices to 1-based relative to the first cadence in the pre-range (obj.indPreEP) (instead of absolute quarter cadence numbers)
            if (isempty(obj.indPreEP))
                % if indPreEP is empty then the Earth-point started at the beginning of the quarter.
                startCadence = 1;
            else
                startCadence = obj.indPreEP(1);
            end
            obj.indPostEP       = obj.indPostEP     - startCadence +1;
            obj.indRecoverEP    = obj.indRecoverEP  - startCadence +1;
            obj.indGapEP        = obj.indGapEP      - startCadence +1;
            obj.indPreEP        = obj.indPreEP      - startCadence +1;
            % set other data fields
            obj.cadenceRange = cadences;
            obj.values = values( obj.cadenceRange );
            obj.gaps = gaps( obj.cadenceRange );
            obj.uncertainties = uncertainties( obj.cadenceRange );            
            % set meta data
            obj.source.type = 'output';
            obj.source.keplerId = targetResultsStruct(iTarget).keplerId;
            obj.source.index = iTarget;
            % gap filling for recover period
            if (obj.gapFillingEnabled)
                obj.filledRecover = obj.gap_filling();
            else
                obj.filledRecover = values(obj.indRecoverEP);
                if (obj.WEIGHT_GF>0 && obj.VERBOSITY)
                    disp('WARNING: gapFillingEnabled = 0, but weight for gapFill component >0.');
                end                
            end
            % calc expfit
            [ obj.expfitPre obj.expfitRecover obj.expfitPost ] = obj.do_expfit();
        end
        
        % ===========================================================================
        % --- harmonic removal ---        
        % ===========================================================================
        function [harmonicRemovedValues harmonicTrend] = remove_harmonics(obj)
%         function [harmonicRemovedValues harmonicTrend] = remove_harmonics(obj)
            gapFillConfigurationStruct = obj.init_GapFillConfigurationStruct();
            harmonicsIdentificationConfigurationStruct = obj.init_HarmonicsIdentificationConfigurationStruct();
            [ harmonicRemovedValues harmonicTrend tmp1 tmp2 ] = pdc_remove_harmonics( obj.fullValues , ...
                                                                                      obj.fullGaps , ...
                                                                                      gapFillConfigurationStruct , ... 
                                                                                      harmonicsIdentificationConfigurationStruct );
        end                
        
        % ===========================================================================
        % --- normalization ---        
        % ===========================================================================
        function [normalizedFlux fluxMedian] = normalize_flux(obj)
%         function [normalizedFlux fluxMedian] = normalize_flux(obj)
            EPSILON = 1;
            fluxMedian = nanmedian(obj.fullValues);
            fluxStd = nanstd(obj.fullValues);
            
            switch (obj.normalize)
                case 1 % median
                    if (fluxMedian>EPSILON)
                        normalizedFlux = (obj.fullValues-fluxMedian) / fluxMedian;
                    else
                        normalizedFlux = obj.fullValues;
                    end
                case 2 % std
                    normalizedFlux = (obj.fullValues-fluxMedian) / fluxStd;
                otherwise
                    disp('Error: illegal normalization method');
            end
                        
        end
        
        % ===========================================================================
        % --- linear detrend ---        
        %       Gapped data is Naned
        % ===========================================================================
        function [detrendedValues baseline] = linear_detrend(obj)
%         function [detrendedValues baseline] = linear_detrend(obj)
            % perform fit only over PRE and POST region
            yall = obj.values([obj.indPreEP ; obj.indPostEP]);
            xall = [obj.indPreEP ; obj.indPostEP];
            % This removes the gaps from the data to polyfit to
            y = yall(~isnan(yall));
            x = xall(~isnan(yall));
            p = polyfit( x , y , 1 );
            % calculate baseline and detrend for whole range
            % Remember that the gaps will have NaNs!
            yall = obj.values;
            xall = (1:length(yall))';
            baseline = polyval(p,xall);
            xall = obj.cadenceRange;
            detrendedValues = yall-baseline+mean(baseline);            
            if (obj.debugLevel>0)                
                a_ = obj.plotEP();
                hold on;                
                plot( xall , baseline , 'm--' );
                plot( xall , detrendedValues , 'Color' , [ 0.5 0.5 0.5 ] );                
            end
        end

    end
%% ------------------------- Static Methods ---------------------------------------
    methods (Static)
        
        % This modified version of nlinfit has been broken out into a
        % separate file to satisfy Mathworks before releasing the code.
        beta = kepler_custom_nonlinearfit(X,y,model,beta,options);
        
        % ===========================================================================
        % TODO: Get this out of here. We should NOT be hard-coding configuration parameters
        function gapFillConfigurationStruct = init_GapFillConfigurationStruct()
%         function gapFillConfigurationStruct = init_GapFillConfigurationStruct(obj)
%             required for pdcEarthPointClass.remove_harmonics()
%             default values taken from PDC inputs as of 8.1
            gapFillConfigurationStruct = struct( ...
                            'madXFactor' , 10 , ...
                             'maxGiantTransitDurationInHours' , 72 , ...
                             'maxDetrendPolyOrder' , 25 , ...
                             'maxArOrderLimit' , 25 , ...
                             'maxCorrelationWindowXFactor' , 5 , ...
                             'gapFillModeIsAddBackPredictionError' , 1 , ...
                             'waveletFamily' , 'daub' , ...
                             'waveletFilterLength' , 12 , ...
                             'giantTransitPolyFitChunkLengthInHours' , 72 , ...
                             'removeEclipsingBinariesOnList' , 1 , ...
                             'arAutoCorrelationThreshold' , 0.0500 , ...
                             'cadenceDurationInMinutes'  , 30 );
        end
        % ===========================================================================
        % TODO: Get this out of here. We should NOT be hard-coding configuration parameters
        function harmonicsIdentificationConfigurationStruct = init_HarmonicsIdentificationConfigurationStruct()
%         function harmonicsIdentificationConfigurationStruct = init_HarmonicsIdentificationConfigurationStruct(obj)
%             required for pdcEarthPointClass.remove_harmonics()
%             default values taken from PDC inputs as of 8.1
            harmonicsIdentificationConfigurationStruct = struct( ...
                            'falseDetectionProbabilityForTimeSeries' , 0.0010 , ...
                            'maxHarmonicComponents' , 10 , ... % Default is 25, that takes too long. 
                            'medianWindowLengthForPeriodogramSmoothing' , 47 , ...
                            'medianWindowLengthForTimeSeriesSmoothing' , 21 , ...
                            'minHarmonicSeparationInBins' , 25 , ...
                            'movingAverageWindowLength' , 47 , ...
                            'timeOutInMinutes' , 2.5000 );
        end
        % ===========================================================================        
        % ===========================================================================
        % --- detect Earth Points (STATIC) ---
        % ===========================================================================
        function [nEP,firstCads,cadences] = get_number_of_earthpoints(targetDataStruct,cadenceTimes,iTarget)
            % --- extract data
            nCadences = length(targetDataStruct(iTarget).values);
            % --- create indices of earth-points
            if (isfield(cadenceTimes,'dataAnomalyFlags'))
                % new format
                EP = cadenceTimes.dataAnomalyFlags.earthPointIndicators;
            else
                % old format
                EP = zeros(nCadences,1);
                for i=1:nCadences
                    EP(i) = strcmp(cadenceTimes.dataAnomalyTypes{i},'EARTH_POINT');
                end
            end
            indEP = find(EP);
            EPmappedToFirstCad = indEP - (0:length(indEP)-1)';
            firstEPcad = sort(unique(EPmappedToFirstCad));
            % KSOC-3289: if the earthpoint is close to a quarter edge then the index ranges will result in out of range cadence indices. 
            % So, we need to restrict the identification of earth-points to outside the constant widths to look past the earth-points
            % TODO: remove the following commented out line
           %firstEPcad = firstEPcad( firstEPcad > pdcEarthPointClass.PRE_WIDTH );  % exclude quarter beginning
            firstEPcad = firstEPcad( firstEPcad < (nCadences - (pdcEarthPointClass.RECOVER_WIDTH + pdcEarthPointClass.POST_WIDTH)));  % exclude quarter end
            nEP = length(firstEPcad);
            firstCads = firstEPcad;
            for i=1:nEP
                EPn{i} = zeros(nCadences,1);
                EPn{i}(indEP(EPmappedToFirstCad==firstEPcad(i))) = 1;
                cadences{i} = find(EPn{i});
            end
            if (nEP==0)
                cadences = [];
            end
        end
        % ===========================================================================
        % --- calc_earthpoint_goodnessmetric (STATIC) ---
        % ===========================================================================
        % function metric = calc_single_earthpoint_goodnessmetric(targetInputStruct,targetResultsStruct,cadenceTimes,iTarget,iEP)
        %
        %   targetInputStruct:         targetDataStruct from inputsStruct (converted from targetResultsStruct, if necessary)
        %   targetResultsStruct:       targetResultsStruct from outputsStruct (converted from targetDataStruct, if necessary)
        %   cadenceTimes:              cadenceTimes struct from inputsStruct
        %   iTarget:                   index of the target to calculate metric for
        %   iEP:                       [ OPTIONAL ] index of the earthpoint to calculate metric for (usually 1 or 2)
        %                                   if 0, calculate for both EPs and average [ DEFAULT ]
        function [metric_total metric_expRel metric_expAbs] = calc_single_earthpoint_goodnessmetric(...
                                                targetInputStruct,targetResultsStruct,cadenceTimes,iTarget, varargin)
        
            VERBOSITY = false;
            % return this value if illegal inputs provided
            % It's a little debatable if 1 or 0 should be the default value. If zero then the geometric mean between the components would be 0. By using 1, the
            % earth point goodness would result in inflated values. So, use NaN so that pdc_goodness_metric knows to ignore the value.
            DEFAULT_OUTPUT = NaN;
            
            if (isempty(varargin))
                iEP = 0;
            else
                iEP = varargin{1};
            end
            if (iEP==0)
                % This is the loop over all earth-points

                % This will calculate the earth-point goodness for all registered earth-point.
                [nEP,ind,cadences] = pdcEarthPointClass.get_number_of_earthpoints(targetInputStruct,cadenceTimes,iTarget);
                metricPart = repmat(struct('total', [], 'expRel', [], 'expAbs', []), [nEP,1]);
                for iEP = 1 : nEP
                    % TODO: investigate if we want to turn on first earth-point detection
                    % Skip first earth-point
                    if (ind(iEP) == 1)
                        continue;
                    end
                    [metricPart(iEP).total metricPart(iEP).expRel metricPart(iEP).expAbs] = ...
                        pdcEarthPointClass.calc_single_earthpoint_goodnessmetric(targetInputStruct,targetResultsStruct,cadenceTimes,iTarget,iEP);
                end
                % Use nanmean here so that if one of the earth-point calculations returns nan, we still get a meaningful number from the other.
                % Such a case is when only one earth-point is found.
                metric.total = nanmean([metricPart.total]);
                metric.expRel = nanmean([metricPart.expRel]);
                metric.expAbs = nanmean([metricPart.expAbs]);
            else
                WEIGHT_EXPREL = pdcEarthPointClass.WEIGHT_EXPREL;
                WEIGHT_EXPABS = pdcEarthPointClass.WEIGHT_EXPABS;
                WEIGHT_GF = pdcEarthPointClass.WEIGHT_GF;
                WEIGHT_VAR = pdcEarthPointClass.WEIGHT_VAR;
                STRETCH_FACTOR = pdcEarthPointClass.STRETCH_FACTOR;
                SCALE_RECOVER = pdcEarthPointClass.SCALE_RECOVER;

                %% sanity check - abort if illegal inputs
                % all cadences gapped
                if ( (~any(~targetInputStruct(iTarget).gapIndicators)) || (~any(~targetResultsStruct(iTarget).gapIndicators)) )
                    metric_total = DEFAULT_OUTPUT;
                    metric_expRel = DEFAULT_OUTPUT;
                    metric_expAbs = DEFAULT_OUTPUT;
                    if (VERBOSITY)
                        disp('WARNING: Please refrain from providing fully-gapped time-series. Thank you. EarthPoint-Goodness calculation aborted.');
                    end
                    return;
                end
                % all values zero
                if ( (~any(targetInputStruct(iTarget).values)) || (any(~targetResultsStruct(iTarget).values)) )
                    metric_total = DEFAULT_OUTPUT;
                    metric_expRel = DEFAULT_OUTPUT;
                    metric_expAbs = DEFAULT_OUTPUT;
                    if (VERBOSITY)
                        disp('WARNING: All flux-values for this target are zero. EarthPoint-Goodness calculation aborted.');
                    end
                    return;
                end
                
                % create classes
                EPin = pdcEarthPointClass(targetInputStruct,cadenceTimes,iTarget,iEP);
                if (isempty(EPin.cadenceRange))
                    % someone seems to be calling this with nonsense data. quit
                    metric_total = DEFAULT_OUTPUT;
                    metric_expRel = DEFAULT_OUTPUT;
                    metric_expAbs = DEFAULT_OUTPUT;
                    if (VERBOSITY)
                        disp('WARNING: Wrong inputs to pdcEarthPointClass.calc_single_earthpoint_goodnessmetric(). Aborting.');
                    end
                    return;
                end
                EPout = pdcEarthPointClass(targetResultsStruct,[],iTarget,iEP,EPin);

                % exponential fit
                % This first is not being used!
                %[PFin,RMSin] = EPin.calc_expfit_magnitude;
                [PFout,RMSout] = EPout.calc_expfit_magnitude;
                if (isempty(PFout.pre))
                    fOutPF = 1 - PFout.recover/(PFout.recover+PFout.post);
                else
                    fOutPF = 1 - PFout.recover/(PFout.pre+PFout.recover+PFout.post);
                end

                % output
                metric.expRel = power(fOutPF,1/2);
                metric.expAbs = 1/(1+PFout.recover*SCALE_RECOVER);
                metric.total = (WEIGHT_EXPREL*metric.expRel + WEIGHT_EXPABS*metric.expAbs) / ( WEIGHT_EXPREL + WEIGHT_EXPABS );

               %%*********
               %% TEST using PFin
               %% Subtract off the PFin to get the relative strength of the recovery
               %% PFnet should never be negative
               %PFnet.pre = max(PFout.pre - PFin.pre, 0.0);
               %PFnet.recover = max(PFout.recover - PFin.recover, 0.0);
               %PFnet.post = max(PFout.post - PFin.post, 0.0);
               %if (isempty(PFout.pre))
               %    if (PFnet.recover+PFnet.post == 0)
               %        fNetPF = 1;
               %    else
               %        fNetPF = 1 - PFnet.recover/(PFnet.recover+PFnet.post);
               %    end
               %else
               %    if (PFnet.pre+PFnet.recover+PFnet.post == 0)
               %        fNetPF = 1;
               %    else
               %        fNetPF = 1 - PFnet.recover/(PFnet.pre+PFnet.recover+PFnet.post);
               %    end
               %end
               %% output
               %metric.expRel = power(fNetPF,1/2);
               %metric.expAbs = 1/(1+PFnet.recover*SCALE_RECOVER);
               %metric.total = (WEIGHT_EXPREL*metric.expRel + WEIGHT_EXPABS*metric.expAbs) / ( WEIGHT_EXPREL + WEIGHT_EXPABS );
               %%*********

            end
            % function output (seriously? can't return individual fields of structures?)
            metric_total = metric.total; 
            metric_expRel = metric.expRel;
            metric_expAbs = metric.expAbs;            

        end
        
        % ===========================================================================
        % --- calc_earthpoint_goodnessmetric_for_modout (STATIC) ---
        %
        % calculates the EP goodness for all targets, averaging over both earthpoints
        % ===========================================================================
        function goodnessEP = calc_earthpoint_goodnessmetric_for_modout(rawTargetStruct,correctedTargetStruct,cadenceTimes)

            % Convert correctedTargetStruct to targetDataStruct if necessary
            if (isfield(correctedTargetStruct, 'correctedFluxTimeSeries'))
                correctedTargetStruct = pdc_convert_output_flux_to_targetDataStruct (correctedTargetStruct);
            end
    
            if (isfield(rawTargetStruct, 'correctedFluxTimeSeries'))
                rawTargetStruct = pdc_convert_output_flux_to_targetDataStruct (rawTargetStruct);
            end
            % Fill raw data gaps
            rawTargetStruct = pdc_fill_gaps(rawTargetStruct, cadenceTimes);
    
            % Remove Harmonics
           %gapFillConfigurationStruct = pdcEarthPointClass.init_GapFillConfigurationStruct();
           %harmonicsIdentificationConfigurationStruct = pdcEarthPointClass.init_HarmonicsIdentificationConfigurationStruct();
           %for iTarget=1:length(rawTargetStruct)
    
           %    display(['Removing harminics from targets ', num2str(iTarget), ' of ', num2str(length(rawTargetStruct))]);

           %    rawTargetStruct(iTarget).values = pdc_remove_harmonics(rawTargetStruct(iTarget).values, rawTargetStruct(iTarget).gapIndicators, ...
           %                                                gapFillConfigurationStruct, harmonicsIdentificationConfigurationStruct );
           %    correctedTargetStruct(iTarget).values = pdc_remove_harmonics(correctedTargetStruct(iTarget).values, correctedTargetStruct(iTarget).gapIndicators, ...
           %                                                gapFillConfigurationStruct, harmonicsIdentificationConfigurationStruct );
           %end

            % First find the flux signal strength in the earth point recovery bandpass
            % This is a seperate operation to run once over each target. Ideally this would be generated in the class object but the classes are generated a
            % couple layers down and once for each Earth-point whereas this is once per target. 
            signalStrengthInBandpass = pdcEarthPointClass.find_flux_signal_in_bandpass(correctedTargetStruct, cadenceTimes);

            for iTarget=1:length(rawTargetStruct)
                goodnessEP(iTarget,1) = pdcEarthPointClass.calc_single_earthpoint_goodnessmetric ...
                                            (rawTargetStruct,correctedTargetStruct,cadenceTimes,iTarget, 0);
            end

            % Scale the goodness by the strength of the flux signal within the recover bandpass
            goodnessEP = goodnessEP ./ signalStrengthInBandpass;
            % goodness should never be greater than 1
            % This can happen if signalStrengthInBandpass is a very small number
            goodnessEP(goodnessEP>1) = 1;
        end
        
        % ===========================================================================
        % --- calc_earthpoint_goodnessmetric_for_modout_individual (STATIC) ---
        %            
        % calculates the EP goodness for all targets, for both earthpoints individually
        % output is a Nx2 matrix, where N is the number of targets
        % ===========================================================================
        function goodnessEP = calc_earthpoint_goodnessmetric_for_modout_individual(rawTargetStruct,correctedTargetStruct,cadenceTimes)
    
            % The changes in calc_earthpoint_goodnessmetric_for_modout must be added here in order for this to work properly
            error ('calc_earthpoint_goodnessmetric_for_modout_individual is currently nonfunctioning');

            % Convert correctedTargetStruct to targetDataStruct if necessary
            if (isfield(correctedTargetStruct, 'correctedFluxTimeSeries'))
                correctedTargetStruct = pdc_convert_output_flux_to_targetDataStruct (correctedTargetStruct);
            end
    
            if (isfield(rawTargetStruct, 'correctedFluxTimeSeries'))
                rawTargetStruct = pdc_convert_output_flux_to_targetDataStruct (rawTargetStruct);
            end
    

            for iTarget=1:length(rawTargetStruct)
                for iEP=1:3
                    goodnessEP(iTarget,iEP) = pdcEarthPointClass.calc_single_earthpoint_goodnessmetric(rawTargetStruct,correctedTargetStruct,cadenceTimes,iTarget,iEP);
                end
            end
        end
        
        % ===========================================================================
        % --- nonlinear_map_onezero_interval (STATIC) ---
        % ===========================================================================
        function ymapped = nonlinear_map_onezero_interval(y)
        % function ymapped = nonlinear_map_onezero_interval(y)
            mapfun = @(x) (x-pdcEarthPointClass.ALPHA)./(1+pdcEarthPointClass.BETA*abs(x-pdcEarthPointClass.ALPHA));
            ymapped = (mapfun(y)-mapfun(0)) / (mapfun(1)-mapfun(0));
        end
        
        % ===========================================================================
        % --- evaluate_earthpoints (STATIC) ---
        % ===========================================================================
        function metric = evaluate_earthpoints(rawTargetStruct,correctedTargetStruct,cadenceTimes,iTarget,iEP,varargin)
        % function evaluate_earthpoints(rawTargetStruct,correctedTargetStruct,cadenceTimes,iTarget,iEP, [debugLevel] )
        %          rawTargetStruct:        targetDataStruct from inputsStruct (converts from targetResultsStruct, if necessary)
        %          correctedTargetStruct:  targetResultsStruct from outputsStruct (converts from targetDataStruct, if necessary)
        %          cadenceTimes:           cadenceTimes struct from inputsStruct
        %          iTarget:                index of the target to calculate metric for
        %          iEP                     index of Earth Point to calculate goodness for (usually 1 or 2)
        
            % these constants set the weights and scaling for the total component of the EP GM
            % see calc_earthpoint_goodnessmetric
            WEIGHT_EXPREL = pdcEarthPointClass.WEIGHT_EXPREL;
            WEIGHT_EXPABS = pdcEarthPointClass.WEIGHT_EXPABS;
            WEIGHT_GF = pdcEarthPointClass.WEIGHT_GF;
            WEIGHT_VAR = pdcEarthPointClass.WEIGHT_VAR;
            STRETCH_FACTOR = pdcEarthPointClass.STRETCH_FACTOR;
            SCALE_RECOVER = pdcEarthPointClass.SCALE_RECOVER;

            PRECISION = 2;

            DOPLOT = 1;

            if (~isempty(varargin))
                debugLevel = varargin{1};
            else
                debugLevel = 0;
            end
            
        % convert inputs and outputs if necessary
            rawTargetStruct = pdcEarthPointClass.convert_targetResultsStruct_to_targetDataStruct(rawTargetStruct);
            correctedTargetStruct = pdcEarthPointClass.convert_targetDataStruct_to_targetResultsStruct(correctedTargetStruct);

        % create classes
            EPin = pdcEarthPointClass(rawTargetStruct,cadenceTimes,iTarget,iEP);
            EPout = pdcEarthPointClass(correctedTargetStruct,[],iTarget,iEP,EPin.cadenceRange);
            EPin.debugLevel = debugLevel;
            EPout.debugLevel = debugLevel;

        % exponential fit
            [PFin,RMSin] = EPin.calc_expfit_magnitude;
            [PFout,RMSout] = EPout.calc_expfit_magnitude;

            excessInPF  = (PFin.recover-mean([PFin.pre PFin.post]));
            excessOutPF = (PFout.recover-mean([PFout.pre PFout.post]));

            fInPF = 1 - PFin.recover/(PFin.pre+PFin.recover+PFin.post);
            fOutPF = 1 - PFout.recover/(PFout.pre+PFout.recover+PFout.post);

            excessInRms = (RMSin.recover-mean([RMSin.pre RMSin.post]));
            excessOutRms = (RMSout.recover-mean([RMSout.pre RMSout.post]));

            
        % baseline difference
            RMSbaseIn = EPin.calc_baseline_diff;
            RMSbaseOut = EPout.calc_baseline_diff;

        % gap-filling difference
            GFin = EPin.calc_gapfilldiff_magnitude;
            GFout = EPout.calc_gapfilldiff_magnitude;

        % variability
            VARin = EPin.calc_variability;
            VARout = EPout.calc_variability;
            
        % absolute value for input light curve (just for display purposes)
            inputAbsGoodness = 1/(1+PFin.recover*SCALE_RECOVER);
            metric.input = inputAbsGoodness;
            
        % output
            metric.expRel = power(fOutPF,1/2);
            metric.expAbs = 1/(1+PFout.recover*SCALE_RECOVER);
            metric.varAbs = VARout.RECOVER / mean([VARout.PRE VARout.POST]); % not yet normalized to (0..1]
%            metric.expMagnitude1 = excessInPF/excessOutPF;
%             metric.expMagnitude1 = power(fOutPF,1/2);
%             metric.expMagnitude2 = fInPF / (fInPF+fOutPF);  % outdated
%             metric.expMagnitude2 = 1/(1+PFout.recover*SCALE_RECOVER); % 1-PFout.recover*SCALE_RECOVER;
%             metric.expMagnitude3 = abs(excessInPF) / (abs(excessInPF)+abs(excessOutPF));
%             metric.expRms1 = excessInRms / excessOutRms;
%             metric.expRms2 = excessInRms / (excessInRms+excessOutRms);
%             metric.baseArea = RMSbaseIn / (RMSbaseIn+RMSbaseOut);   % larger: better, [0..1]
%             metric.gapFill = GFin / (GFin+GFout);                   % larger: better, [0..1]
        %     metric.gapFillAbs = 1/GFout;                            % larger: better

        % total component (as in calc_earthpoint_goodnessmetric)
%             exprel_part = metric.expMagnitude3;
%             expabs_part = metric.expMagnitude1;
%             gfrel_part = metric.gapFill;
%             gfabs_part = GFout;
%             metric.totalGeo = power( power(exprel_part,WEIGHT_EXPREL) * ...
%                                      power(expabs_part,WEIGHT_EXPABS) * ...
%                                      power(gfrel_part,WEIGHT_GF ) , ...
%                                      STRETCH_FACTOR/(WEIGHT_EXPREL+WEIGHT_EXPABS+WEIGHT_GF) );
            % apply some nonlinear weighting:
%             metric.totalMapped = pdcEarthPointClass.nonlinear_map_onezero_interval(metric.totalGeo);
            metric.total = (WEIGHT_EXPREL*metric.expRel + WEIGHT_EXPABS*metric.expAbs) / ( WEIGHT_EXPREL + WEIGHT_EXPABS );

        %     outstr{1,1} = ['expMagnitude1 (ratio):      ' num2str(metric.expMagnitude1)];
        %     outstr{2,1} = ['expMagnitude2 (diff):       ' num2str(metric.expMagnitude2)];
        %     outstr{3,1} = ['expMagnitude3 (rel ratio):  ' num2str(metric.expMagnitude3)];
        %     outstr{4,1} = ['expRms1:                    ' num2str(metric.expRms1)];
        %     outstr{5,1} = ['expRms2:                    ' num2str(metric.expRms2)];
        %     outstr{6,1} = ['baseArea:                   ' num2str(metric.baseArea)];
        %     outstr{7,1} = ['gapFillDiff:                ' num2str(metric.gapFill)];
        %     outstr{8,1} = ['Total:                      ' num2str(metric.total)];
            outstr{1,1} = 'expMag (rel):'; outstr{1,2} = num2str(metric.expRel,PRECISION);
            outstr{2,1} = 'expMag (abs):'; outstr{2,2} = num2str(metric.expAbs,PRECISION);
            outstr{3,1} = 'var    (abs):'; outstr{3,2} = num2str(metric.varAbs,PRECISION);
            outstr{4,1} = '\bf{total}       :'; outstr{4,2} = num2str(metric.total,PRECISION);


        %     outstr{8} = ['gapFillAbs:           ' num2str(metric.gapFillAbs)];

        % plot
            if (DOPLOT)
                figure;
                subplot(3,2,1);
                EPin.plotFull(gca);
                title([EPin.source.type '    keplerId ' int2str(EPin.source.keplerId) '    (' int2str(iTarget) ')' ]);
                subplot(3,2,2);
                EPin.plotEP(gca);
                title([EPin.source.type '    keplerId ' int2str(EPin.source.keplerId) '    EP #' int2str(iEP) ]);
                subplot(3,2,3);
                EPout.plotFull(gca);
                title([EPout.source.type '    keplerId ' int2str(EPout.source.keplerId) '    (' int2str(iTarget) ')' ]);
                subplot(3,2,4);
                EPout.plotEP(gca);
                title([EPout.source.type '    keplerId ' int2str(EPout.source.keplerId) '    EP #' int2str(iEP) ]);
                subplot(3,2,6);
                axis off;
                set(gca,'xlim',[0 1],'ylim',[0 1]);
        %         for i=1:length(outstr)
        %             text(0.1,1-i/length(outstr),outstr{i});
        %         end
                tabletext_in_figure( gca , 0.0 , 0.3 , 18 , outstr );
                set(gcf,'position',[ 2400 600 1000 750 ]);    
            end

        end        
        % =========================================================================================
        % --- convert_targetResultsStruct_to_targetDataStruct (STATIC) ---
        % =========================================================================================
        function targetDataStruct = convert_targetResultsStruct_to_targetDataStruct(targetResultsStruct)
        % function targetDataStruct = convert_targetResultsStruct_to_targetDataStruct(targetResultsStruct)
        % --------------------------------------------------------------------------------------------------
        %    Converts an outputsStruct.targetResultsStruct to an inputsStruct.targetDataStruct
        %    This is useful when trying to call the goodness metric calculation on two targetDataResultsStruct types, for instance.
        %    The following fields are converted:
        %      - values
        %      - gapIndicators
        %      - uncertainties
        %      - keplerId
        %
        %    If a targetDataStruct is provided as input already, the function does nothing and simply returns the input.
        % --------------------------------------------------------------------------------------------------
            if (isfield(targetResultsStruct,'correctedFluxTimeSeries'))
                % is indeed an outputsStruct.targetResultsStruct - convert it
                nTargets = length(targetResultsStruct);
                for i=1:nTargets
                    targetDataStruct(i).values = targetResultsStruct(i).correctedFluxTimeSeries.values;
                    targetDataStruct(i).uncertainties = targetResultsStruct(i).correctedFluxTimeSeries.uncertainties;
                    targetDataStruct(i).gapIndicators = targetResultsStruct(i).correctedFluxTimeSeries.gapIndicators;
                    targetDataStruct(i).keplerId = targetResultsStruct(i).keplerId;            
                end
            else
                % is already an intputsStruct.targetDataStruct
                targetDataStruct = targetResultsStruct;
            end
        end
        % =========================================================================================
        % --- convert_targetResultsStruct_to_targetDataStruct (STATIC) ---
        % =========================================================================================
        function targetResultsStruct = convert_targetDataStruct_to_targetResultsStruct(targetDataStruct)
        % function targetResultsStruct = convert_targetDataStruct_to_targetResultsStruct(targetDataStruct)
        % --------------------------------------------------------------------------------------------------
        %    Converts an inputsStruct.targetDataStruct to an outputsStruct.targetResultsStruct
        %    This is useful when trying to call the goodness metric calculation on two targetDataStruct types, for instance.
        %    The following fields are converted:
        %      - values
        %      - gapIndicators
        %      - uncertainties
        %      - keplerId
        %
        %    If a targetResultsStruct is provided as input already, the function does nothing and simply returns the input.
        % --------------------------------------------------------------------------------------------------
            if (~isfield(targetDataStruct,'correctedFluxTimeSeries'))
                % is indeed an inputsStruct.targetDataStruct - convert it
                nTargets = length(targetDataStruct);
                for i=1:nTargets
                    targetResultsStruct(i).correctedFluxTimeSeries.values = targetDataStruct(i).values;
                    targetResultsStruct(i).correctedFluxTimeSeries.uncertainties = targetDataStruct(i).uncertainties;
                    targetResultsStruct(i).correctedFluxTimeSeries.gapIndicators = targetDataStruct(i).gapIndicators;
                    targetResultsStruct(i).keplerId = targetDataStruct(i).keplerId;

                end
            else
                % is already an outputsStruct.targetResultsStruct
                targetResultsStruct = targetDataStruct;
            end
        end
        % =========================================================================================
        % Find the strength of the flux signal within the Earth-point bandpass
        %
        % This uses the corrected flux since it has all gaps filled and should only have stellar signals.
        %
        % We also fill the earth point recovery regions so the residual recoveries are not included int he calculation.
        %
        % Outputs:
        %   signalStrengthInBandpass -- [double array(nTargets)] a type of power band goodness
        %                                                         0 means STRONG signal in the band.
        %                                                         1 means no signal in the band.
        %
        % =========================================================================================
        function signalStrengthInBandpass = find_flux_signal_in_bandpass(correctedTargetDataStruct, cadenceTimes)

            nTargets = length(correctedTargetDataStruct);

            % Fill the earth point recovery regions so they are not counted in the power calculation
            EPgaps = pdc_mask_recovery_regions (false(length(correctedTargetDataStruct(1).gapIndicators),1), cadenceTimes, pdcEarthPointClass.RECOVER_WIDTH );
            for iTarget = 1 : nTargets
                correctedTargetDataStruct(iTarget).gapIndicators = correctedTargetDataStruct(iTarget).gapIndicators | EPgaps;
            end
            correctedTargetDataStruct = pdc_fill_gaps(correctedTargetDataStruct, cadenceTimes);

            % mean normalize flux
            normCorrectedTargetDataStruct = mapNormalizeClass.normalize_flux...
                (correctedTargetDataStruct, 'mean', false, true, cadenceTimes, pdcEarthPointClass.RECOVER_WIDTH);

            signalStrengthInBandpass = zeros(nTargets,1);
            
            % bandpass using median filter
            
           %fluxFigure = figure;
           %periodoFigure = figure;
            for iTarget = 1 : nTargets

               %display(['Working on target ', num2str(iTarget), ' of ', num2str(nTargets)]);

                [Pxx, w] = periodogram(normCorrectedTargetDataStruct(iTarget).values);
                
                % Convert from radians / cadence to cadences / cycle
                w = w / (2 * pi); % To get to cycles / cadence
                w = 1 ./ w; % To get to cadences / cycle

                % Find the power in the band
                upperIndex = find(w < pdcEarthPointClass.RECOVER_WIDTH / 2.0, 1, 'first');
                lowerIndex = find(w > pdcEarthPointClass.RECOVER_WIDTH * 10.0, 1, 'last');
                signalStrengthInBandpass(iTarget) = sum(Pxx(lowerIndex:upperIndex)) / (upperIndex - lowerIndex); 

                %***
                % TESTING PLOTS
               %figure(fluxFigure);
               %plot(normCorrectedTargetDataStruct(iTarget).values, '-b');
               %hold on;
               %plot(filteredFlux, '-r');
               %legend('Normalized Flux', 'Filtered Flux');
               %hold off;

               %figure(periodoFigure)
               %loglog(w, Pxx)
               %hold on
               %plot([pdcEarthPointClass.RECOVER_WIDTH pdcEarthPointClass.RECOVER_WIDTH], [min(Pxx) max(Pxx)], '-k')
               %xlabel('Cadences / cycle');
               %ylabel('power');
               %legend('Periodogram', 'Recovery Window Frequency');
               %title(['power in band:', num2str(signalStrengthInBandpass(iTarget))]);
               %hold off;

               %pause;
                %***

            end

            % Normalize the signal strength to [0,1]
            % 0 means STRONG signal in the band.
            % 1 means no signal in the band.
            medianSignal = median(signalStrengthInBandpass);
            signalStrengthInBandpass = signalStrengthInBandpass / medianSignal;
            % Scale so that really bad is ~0.01
            % The normalization by the median value should make the value below (2e-2) fairly universal assuming generally similar performance over all
            % quarters and mod.outs.
            signalStrengthInBandpass = signalStrengthInBandpass * 2e-2;
            signalStrengthInBandpass  = 1 ./(signalStrengthInBandpass +1);
           
           %figure;
           %plot(signalStrengthInBandpass, '*b')
           %title('Signal Strength in BandPass for Recover Regions');

        end

    end
end



% =========================================================================================
% CLASS-LESS HELPER FUNCTIONS
% =========================================================================================

%%
function [ yfit rms fitcoeffs ] = fitexp(x,y)
% function [ yfit rms fitparams ] = fitexp(x,y)
%   performs exponential fit (calculated in log domain)
%   taking either y, or -y, whichever is similar to exponential
%
%   INPUTS
%      x          : x vector
%      y          : y vector
%
%   OUTPUTS:
%      yfit       : the resulting exponential fit
%      rms        : root-mean-square difference between y and yfit 
%      fitcoeffs  : coefficients of the linear fit using polyfit()

    EPSILON = 0.00001;    
    DOPLOT = 0;
    
% check inputs    
    szx = size(x);
    szy = size(y);
    % turn to column-vector if not already
    if (szx(2)>szx(1))
        x = x';
    end
    if (szy(2)>szy(1))
        y = y';
    end
    
    if ( (szx(1)~=szy(1)) || (szx(2)~=szy(2)) )
        % sizes don't match, exit
        yfit_best = [];
        rms_best = [];
        fitcoeffs_best = [];
        return;
    end
    
    n = length(y);
    I = ~isnan(y); % indices of non-naned data (i.e. legit data)
    
    % Check if all data is NaN (all gaps?). If so, we cannot do anything
    if (sum(I) == 0)
        yfit = [];
        rms = [];
        fitcoeffs = [];
        return;
    end

    xx = x(I);
    yy = y(I);

    modelFun = @(p,x) p(1)*exp(p(2)*x);

% disable warnings, otherwise nlinfit will talk like there's no tomorrow
    w = warning('query','all');
    warning('off','all');
    
%% =============================================
%  linear fit in log-domain first to get starting point for nonlinear fit
    pf{1} = [ones(size(xx)), xx] \ log(yy);
    pfExp{1} = pf{1}; pfExp{1}(1) = exp(pf{1}(1));
    yfit{1} = modelFun(pfExp{1}, x);
    rms{1} = sqrt( sum((yfit{1}(I) - y(I)).^2) / n );
    fitcoeffs{1} = pf{1};
%% =============================================    

%% =============================================
%  now perform nonlinear fit
try
    % Using custom nlinfit for speed. If problems arrise revert back to the standarf function.
   %pfExp{2} = nlinfit(xx, yy, modelFun, pfExp{1});
    pfExp{2} = pdcEarthPointClass.kepler_custom_nonlinearfit(xx, yy, modelFun, pfExp{1});

    pf{2} = pfExp{2}; pf{2}(1) = log(pfExp{2}(1));
    yfit{2} = modelFun(pfExp{2}, x);
    rms{2} = sqrt( sum((yfit{2}(I) - y(I)).^2) / n );
    fitcoeffs{2} = pf{2};
catch exception
%     disp('EXCEPTION!');
    pf{2} = pf{1};
    yfit{2} = yfit{1};
    rms{2} = rms{1};
    fitcoeffs{2} = pf{2};
end

%% =============================================    

%% =============================================    
% offset
    m = min(yy);
    yyy = yy - m + EPSILON;
    pf{3} = [ones(size(xx)), xx] \ log(yyy);
    pfExp{3} = pf{3}; pfExp{3}(1) = exp(pf{3}(1));
    yfit{3} = modelFun(pfExp{3}, x);
    yfit{3} = yfit{3} + m - EPSILON;
    rms{3} = sqrt( sum((yfit{3}(I) - y(I)).^2) / n );
    fitcoeffs{3} = pf{3};
%% =============================================    

%% =============================================    
% offset and flip
    yyy = -yy;
    m = min(yyy);
    yyy = yyy - m + EPSILON;
    pf{4} = [ones(size(xx)), xx] \ log(yyy);
    pfExp{4} = pf{4}; pfExp{4}(1) = exp(pf{4}(1));
    yfit{4} = modelFun(pfExp{4}, x);
    yfit{4} = yfit{4} + m - EPSILON;
    yfit{4} = -yfit{4};
    rms{4} = sqrt( sum((yfit{4}(I) - y(I)).^2) / n );
    fitcoeffs{4} = pf{4};
%% =============================================

% enable warnings again
    warning(w);

%% find best one and prepare output
    k = -1;
    rms_best = inf;
    yfit_best = [];
    fitcoeffs_best = [];
    for i=1:4
        if ((rms{i}<rms_best) & (all(isreal(rms{i}))) )
            k = i;
            rms_best = rms{i};
            yfit_best = yfit{i};
            fitcoeffs_best = fitcoeffs{i};
        end
    end

%% plot
    if (DOPLOT)
        figure;
        plot(x,y,'ko-');
        hold on;
        p(1) = plot(x,yfit{1},'r');
        p(2) = plot(x,yfit{2},'g');
        p(3) = plot(x,yfit{3},'b');
        p(4) = plot(x,yfit{4},'m');
        set(p(k),'LineWidth',2);
        legend( ['raw data                 ' ] , ...
                ['linear fit (log-domain)  ' num2str(rms{1},2) ] , ...
                [ 'nonlinear fit           ' num2str(rms{2},2) ] , ...
                [ 'positive                ' num2str(rms{3},2) ] , ...
                [ 'negative                ' num2str(rms{4},2) ] );
    end
    
%% output
    yfit = yfit_best;
    rms = rms_best;
    fitcoeffs = fitcoeffs_best;
    
end

% =========================================================================================
% =========================================================================================


%%
function t_ = tabletext_in_figure(a_,x,y,fontsize,tableStrings)
% function t_ = tabletext_in_figure(a_,x,y,fontsize,tableStrings)
%
% INPUTS:
%   a_           : handle to axis to plot text in
%   x,y          : coordinates to place text (top left corner)
%   fontsize     : fontsize
%   tableStrings : a 2D cell array containing the table entries, e.g:
%
% tableStrings{1,1} = 'text 1';
% tableStrings{2,1} = 'text 2';
% tableStrings{3,1} = 'text 3';
% 
% tableStrings{1,2} = 'value 1';
% tableStrings{2,2} = 'value 2';
% tableStrings{3,2} = 'value 3';
%

    axis(a_);

    nRows = size(tableStrings,1);
    nCols = size(tableStrings,2);

    mystr = '$$\matrix{';
    for r=1:nRows
        for c=1:nCols
            mystr = [ mystr ' \mathrm{' tableStrings{r,c} '}' ];
            if (c<nCols)
                mystr = [ mystr ' & ' ];
            end
        end
        if (r<nRows)
            mystr = [ mystr ' \cr ' ];
        end
    end
    mystr = [ mystr '}$$' ];

    t_ = text('position',[ x y ],'fontsize',fontsize,'interpreter','latex','string',mystr);

end

% =========================================================================================
% =========================================================================================

function yy = local_detrend(y)
% function yy = local_detrend(y)
    I = ~isnan(y);
    x = (1:length(y))';
    pf = polyfit( x(I) , y(I) , 1 );
    pv = polyval(pf,x);
    pv = pv - mean(pv);
    yy(I) = y(I) - pv(I);
%     figure;
%     plot(x,y);
%     hold on
%     plot(x,yy,'r');
end

