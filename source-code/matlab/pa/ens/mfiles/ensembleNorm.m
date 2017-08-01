function [relFlux,relFluxUncert,ensSetOut,ensWeights,diagnostic] = ...
                   ensembleNorm(flux,fluxUncert,targetID,ensRadius,ensSetIn, ensWeightsIn, ...
                                            rowCentroid,colCentroid,var_thresh,n_iterate,updateEnsFlag,gain,readNoise)

% function [relFlux,relFluxUncert,ensSetOut,ensWeights,diagnostic] = ...
%                    ensembleNorm(flux,fluxUncert,targetID,ensRadius,ensSetIn, ensWeightsIn, ...
%                                             rowCentroid,colCentroid,var_thresh,n_iterate,updateEnsFlag,gain,readNoise)
%
% ENSEMBLENORM: selects an ensemble for each target and performs
% differential photometry using that ensemble.  Based on the function 
% CVS:so/Released/Prototypes/EnsNorm/diffphot.m written by N. Batalha,
% modified to work with ETEM output time series and have a Kepler-like interface.
%
% Inputs:
%   Item            Units         format, description
%   *********   *******     ******************
%   flux            ADU             flux[nimages,nstars]  raw flux time series for all stars
%   fluxUncert  relative        fluxUncert[nimages,nstars]  relative uncertainty time series
%   targetID    number       targetID[ntargets]  list of targets to use (indices into flux array columns)
%   ensRadius   pixels         [scalar] radius from target star from which to select ensemble targets
%   ensSetIn    id list          ensSetIn{nstars, nEnsPerStar} Cell array containing vectors (one for each star) of 
%                                               indices of comparison stars used to construct the ensemble for a given star
%   ensWeightsIn  list       list of weights for each ensemble member for each target
%   rowCentroid  pixels     rowCentroid[nstars]  array of target centroids
%	colCentroid  pixels      colCentroid[nstars]  
%	var_thresh 	relative   Threshold for variability test, ratio of the stdev of the differential light 
%                                              curve to the instrumental noise estimation (stdev).
%	n_iterate  	  integer   Number of iterations required to determine ensemble star weights
%   updateEnsFlag  0/1  flag to indicate whether ensemble should be updated (1)
%                                               or input ensemble list should be used (0). If updateEnsFlag=0, ensSetIn
%                                               and ensWeightIn must be input
%   gain            float        scalar number of electrons/ADU
%   readNoise   float        scalar readout noise electrons/pixel/read
% 
% Outputs:
%   relFlux            ADU          relFlux[nimages,nTarg]  raw flux time series for all stars
%   relFluxUncert  relative    relFluxUncert[nimages,nTarg]  relative uncertainty time series
%   ensSetOut       id list       ensSetOut{[1...n1],[1,...,n2],...} Cell array containing vectors (one for each star) of 
%                                               indices of comparison stars used to construct the ensemble for a given star
%   ensWeights    list           ensWeights{[1/s2^2,1/s3^2,...][1/s1^2,1/s3^2,...],,,} Cell array
%                                               containing vectors (one for each target) of weights for the ensemble
%	diagnostic      Array       diagnostic[n_iterate,nTarg] used to test for convergence in ensemble star weights.
%   
% Written by N. Batalha Jul 2005
%       18 Nov 2005, modified by DAC to handle ETEM data w/ Kepler-like interface
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

%%%%%% comments from diffphot %%%%%%%%
%function [lc,f,s2,s2new,ncomp,cstars,diagnostic] = diffphot(fn,star1,starn,n_near,var_thresh,n_iterate)
%
% INPUT
%	fn	Name of matlab save set containing data: 
%			Description		Units		Name
%			*********************	*****		**********************
%			flux			ADU		f[nimages,nstars] 
%			shot noise variance 	(relative)	sf2[nimages,nstars]
%			background		ADU		bg[nimages,nstars] 
%			bg noise variance	(relative)	sbg2[nimages,nstars] 
%			xy pixel positions	none		x0[nstars], y0[nstars]
%	star1		Index of first star to analyze
%	starn		Index of last star to analyze
%	n_near  	Number of stars to start out with in the ensemble (before variable star rejection)
%	var_thresh 	Threshold for variability test (ratio of the stdev of the differential light 
%			curve to the instrumental noise estimation (stdev).
%	n_iterate  	Number of iterations required to determine ensemble star weights

%OUTPUT
%	lc		Differential lightcurves; same dimensions as flux array (electrons)
%	f		Original lightcurve converted to units of electrons
%	s2		Total original instrumental noise (variance) for each star (electrons^2)
%	s2new 		Propagated errors (variance) for each star (electrons^2)
%	ncomp		Number of comparison stars used for each target to construct its ensemble
%	cstars  	Cell array containing vectors (one for each star) of indices of comparison 
%			stars used to construct the ensemble for a given star
%	diagnostic	Array used to test for convergence in ensemble star weights.

%DESCRIPTION
%
%Program constructs a weighted average of ensemble light curves which is then used to 
%remove common mode noise sources from the light curve of the target star.  The procedure
%is as follows (for stars star1 through starn):
%	1.  Find the closest n_near stars to the target
%	2.  Define a weight for each potential comparison star that is equal to the
%		instrumental variance for that star. At this point, weights also a function of time.
%	3.  Construct differential light curves of each potential comparison star using
%		a weighted ensemble (weights already defined) that includes all other comparison
%		stars (not itself).  The variance of the resulting differential light curve will 
%		be the new weighting factor for that comparison star.
%	4.  Iterate the weights in this same manner until the variances no longer improve
%		significantly. (Testing of the Vulcan data shows that <5 iterations is
%		sufficient; 
%	5.  Check for variability of a comparison star by computing the ratio of the 
%		standard deviation of the differential light curve to the instrumental
%		noise.  Stars with a ratio above var_thresh (generally 2-2.5) are tagged
%		as being variable.
%	6.  Repeat steps 2-4 using this new set of "constant" stars.
 
%The algorithm loosely follows the methodology of Broeg, Fernandez, and Neuhauser 
%(2005 AN 326 134).  The output arrays lc and f are the same except for the 
%light curves of star1 through starn.
%
% N. Batalha (July 2005)

% minimum number of ensemble stars
MIN_ENSEMBLE = 3;

% determine input sizes
[nimages,nstars]=size(flux);

% check to be sure input fluxes are the right size
if sum(size(fluxUncert) ~= [nimages,nstars])
    error('ENSEMBLENORM: input flux and uncertainty must have the same dimensions');
end

% make sure input ensemble set is the right size, if needed
if (updateEnsFlag==0 & (length(ensSetIn)~=nstars) & (length(ensWeightsIn)~=nstars))
    error('ENSENBLENORM: ensemble set must contain a list for each input star')
end

% determine the number of targets to process
nTarg = length(targetID);

if nTarg>nstars
    error('ENSEMBLENORM: input targetID array is larger than flux array')
end

% trim flux arrays if needed
if nTarg<nstars
    warning(['EnsembleNorm: processing a subset of only ',int2str(nTarg),' out of ',int2str(nstars),' stars']);
    flux = flux(:,targetID);
    fluxUncert = fluxUncert(:,targetID);
    ensSetIn = ensSetIn(targetID);
    rowCentroid = rowCentroid(targetID);
    colCentroid = colCentroid(targetID);
end

%Convergence diagnostic array
diagnostic=zeros(n_iterate-1,nTarg);

%CCD-specific parameters required for computations 
% gain=3.55;	%used to convert ADU to electron counts
% npix=121; 	%important for computing total readnoise contribution to noise budget
% readnoise=21;	%given here in electrons per pixel

% Initialize output arrays
%   arrays are the same size as the input arrays, but only columns
%   corresponding to stars in the targetID list will have non-zero values
relFlux = zeros(nimages,nTarg);
relFluxUncert = relFlux;
ncomp = zeros(1,nTarg);
ensSetOut=cell(1,nTarg);
ensWeights = cell(1,nTarg);

%convert all relevant quantities to units of electrons; make errors absolute, not relative
flux=flux.*gain;
fluxUncert = fluxUncert.*flux;		%convert relative error to absolute error
s2 = fluxUncert.^2;  % total variance

%% total noise calculation for Vulcan data
% bg=bg.*gain;
% sf=sqrt(sf2);
% sbg=sqrt(sbg2);
% sbg=sbg.*f;
% srn=readnoise*sqrt(npix);	%note: this might not be accurate for Kepler
%
%%compute total instrumental noise for all observations; will be used to compute first
%%estimate of weighting factors
% s2=sbg.^2+sf.^2+srn.^2;		%total variance

% temporary variables for centroids, keep only selected targets
x0 = rowCentroid(targetID);
y0 = colCentroid(targetID);

%loop through all stars
for i=1:nTarg
     	disp(['Target ',int2str(i),' out of ',int2str(nTarg)]);
	%Initialize arrays
    %   n_nearstars is the starting ensemble set, defaults to all stars -1
    %   (so the target is not in its ensemble)
	n_nearstars=nTarg-1;
	% vari=zeros(1,n_nearstars); 
    % var2=vari;
	%find nearest stars
	dist=sqrt((x0-x0(i)).^2+(y0-y0(i)).^2);
	[di,ii]=sort(dist);
	nearstars=ii(2:n_nearstars+1);	% indices of closest stars, sorted by distance from target
    % select only stars within ensRadius of target
    nearby = find(di~=0 & di <= ensRadius)-1; % skip closest one distance which is target itself
    nearstars = nearstars(nearby);  
    n_nearstars = length(nearstars);
    

	%compute normalized weights using instrumental errors as first guesses
	s2sub=s2(:,nearstars);
	norm=sum(1./s2sub,2);	%normalization factor
    % ci = (1./s2sub)./repmat(norm,1,n_nearstars);
% 	for j=1:n_nearstars, 
% 		ci(:,j)=(1./s2sub(:,j))./norm; 	%normalized weights for each comparison star
% 	end;

    if updateEnsFlag  % update, or generate, ensemble set
        
        % pre-allocate arrays
        vdifftmp=zeros(1,n_nearstars);

        %iterate the weights
        for j=1:n_iterate
            %for each comparison star, construct an ensemble using the "other" stars;
            %compute differential light curve and variance of that light curve
            for k=1:n_nearstars,
                %re-normalize the weights removing star k
                neartmp=nearstars; 
                neartmp(k)=[];
                ik = 1:n_nearstars; ik(k)=[];
                s2tmp=s2sub(:,ik);
%                 s2tmp=s2sub; 
%                 s2tmp(:,k)=[];
                norm=sum(1./s2tmp,2);
                nnorm  = repmat(norm,1,n_nearstars-1);
                citmp = (1./s2tmp)./nnorm;
    %     		for l=1:n_nearstars-1,
    % 				citmp(:,l)=(1./s2tmp(:,l))./norm; 
    % 			end;
                %compute ensemble that excludes star k
                ensemble=sum(citmp.*flux(:,neartmp),2); 
                diffens(:,k)=flux(:,nearstars(k))./(ensemble./median(ensemble)); 
                difftmp=diffens(:,k);
                %compute variance (new weight) for star k
                vdifftmp(k)=var(difftmp); 
            end;

            %compute new normalized weights for all stars
            s2sub=repmat(vdifftmp,nimages,1);
            % norm=sum(1./s2sub,2);
            % ci = (1./s2sub)./repmat(norm,1,n_nearstars);
    % 		for k=1:n_nearstars, 
    %             ci(:,k)=(1./s2sub(:,k))./norm; 
    %       end

            %convergence diagnostic test; Can be uncommented for additional testing
            %if (j > 1),
                    %test=sum(abs(s2sub(1,:)-s2old(1,:)));	%alternative #1
                            %test=1-sqrt(s2sub(1,:))./sqrt(s2old(1,:)); %alternative #2
                            %test=median(test);  %for alternative #2
                    %diagnostic(j-1,i)=test;
                %end;
            %s2old=s2sub;
        end 

        %check for variability amongst the comparison stars by comparing the variances of the
        %differential light curves with the instrumental errors. Constant stars should have 
        %standard deviations within a
        %factor of var_thresh of their instrumental errors.
        vari=median(s2(:,nearstars),1);	%instrumental errors (variance)
        var2=s2sub(1,:);	%variance of differential light curve as computed above
        ic=find(sqrt(var2./vari) < var_thresh);	 % "good" stars for comparison

        %Repeat all of the above using only stars ic as comparisons
        nearstars=nearstars(ic);
        n_nearstars=size(ic,2);


        if n_nearstars<MIN_ENSEMBLE
            warning(['EnsembleNorm: target ',int2str(i),' has fewer than ',intstr(MIN_ENSEMBLE),' comparison stars']);
        end

        %re-initialize arrays
        ci=zeros(nimages,n_nearstars); 
        diffens=ci; 
        vdifftmp=zeros(1,n_nearstars);

        %compute normalized weights using instrumental errors as first guesses
        s2sub=s2(:,nearstars);
        % norm=sum(1./s2sub,2);
        % ci = (1./s2sub)./repmat(norm,1,n_nearstars);
    % 	for j=1:n_nearstars, 
    % 		ci(:,j)=(1./s2sub(:,j))./norm; 
    % 	end;

        %iterate the weights for the final ensemble set
        for j=1:n_iterate
                %for each comparison star, construct an ensemble using the "other" stars;
                %compute differential light curve and variance of that light curve
                for k=1:n_nearstars,
                        %re-normalize the weights removing star k
                        neartmp=nearstars; 
                        neartmp(k)=[];
                        ik = 1:n_nearstars; ik(k)=[];
                        s2tmp=s2sub(:,ik);
                        % s2tmp=s2sub; 
                        % he s2tmp(:,k)=[];
                        % citmp=zeros(nimages,n_nearstars-1);
                        norm=sum(1./s2tmp,2);
                        nnorm  = repmat(norm,1,n_nearstars-1);
                        citmp = (1./s2tmp)./nnorm;
    %                     for l=1:n_nearstars-1,
    %                 		citmp(:,l)=(1./s2tmp(:,l))./norm;
    %             		end;
                        %compute ensemble that excludes star k
                        ensemble=sum(citmp.*flux(:,neartmp),2);
                        diffens(:,k)=flux(:,nearstars(k))./(ensemble./median(ensemble));
                        difftmp=diffens(:,k);
                        %compute variance (new weight) for star k
                        vdifftmp(k)=var(difftmp);
                end;

                %compute new normalized weights for all stars
                s2sub=repmat(vdifftmp,nimages,1);
                norm=sum(1./s2sub,2);
                ci = (1./s2sub)./repmat(norm,1,n_nearstars);
    %         	for k=1:n_nearstars, 
    %                 ci(:,k)=(1./s2sub(:,k))./norm; 
    % 		    end;

                %construct ensemble
                ensemble=sum(ci.*flux(:,nearstars),2);
                lcnew=flux(:,i)./(ensemble./median(ensemble));

                %convergence diagnostic test
                if (j > 1),
                    %test=sum(abs(s2sub(1,:)-s2old(1,:))); 			%alternative #1
                    test=1-sqrt(s2sub(1,:))./sqrt(s2old(1,:)); 		%alternative #2
                    test=median(test); 					%for alternative #2
                    diagnostic(j-1,i)=test;
                end;
                s2old=s2sub;
        end;

        %record final differential light curve
        relFlux(:,i)=lcnew;
        ncomp(i)=n_nearstars;
        ensSetOut{i}=nearstars;  % update ensemble list, or copy over existing list
        ensWeights{i} = ci(1,:);  % update ensemble weights, 
                                                %   ci has been repmatted to be nimages rows, only need 1

        %compute variances of differential light curves; propagates the errors in the standard 
        %way given the mathematical formulation for the ensemble.   
        s2i=s2(:,nearstars);	%instrumental variances
        s2w=s2sub;		%weights (variances of differential light curves of comparison stars)
        N=median(ensemble);
        relFluxUncert(:,i)=s2(:,i)*(N^2)./(ensemble.^2)+norm.^(-2).*sum(s2i./(s2w.^2),2).* ...
            (flux(:,i).^2)*(N^2)./(ensemble.^4);

    
%% use input ensemble instead of calculated version
    else  % use input ensemble instead of calculated version
%%       % copy over input ensemble info
       ensSetOut{i} = ensSetIn{i};
       ensWeights{i} = ensWeightsIn{i};
       
       % get the ensemble stars for target_i
        nearstars = ensSetIn{i};
        n_nearstars = length(nearstars);
                        
        % calculate uncertainties for error propogation - 
        % need to compute the variance , since the input weights are
        % normalized by the sum of the variance 
         for k=1:n_nearstars,
                    %re-normalize the weights removing star k
                    neartmp=nearstars; 
                    neartmp(k)=[];
                    s2tmp=s2sub; 
                    s2tmp(:,k)=[];
                    % citmp=zeros(nimages,n_nearstars-1);
                    norm=sum(1./s2tmp,2);
                    nnorm  = repmat(norm,1,n_nearstars-1);
                    citmp = (1./s2tmp)./nnorm;
%                     for l=1:n_nearstars-1,
%                 		citmp(:,l)=(1./s2tmp(:,l))./norm;
%             		end;
                    %compute ensemble that excludes star k
                    ensemble=sum(citmp.*flux(:,neartmp),2);
                    diffens(:,k)=flux(:,nearstars(k))./(ensemble./median(ensemble));
                    difftmp=diffens(:,k);
                    %compute variance (new weight) for star k
                    vdifftmp(k)=var(difftmp);
          end;

         % get variance matrix for all stars
         s2sub=repmat(vdifftmp,nimages,1);
                
         ci = ensWeightsIn{i};  % use input weights
         ci = repmat(ci, nimages, 1);  % duplicate weights, one set for each image
        	
        %construct ensemble
        ensemble=sum(ci.*flux(:,nearstars),2);
        N=median(ensemble);
        lcnew=flux(:,i)./(ensemble./N);
        relFlux(:,i)=lcnew;

        %%%%%% update as needed %%%%%%
        diagnostic =[];   % no diagnostic when ensemble is pre-selected
        %%%%%%%%%%%%%%%%%%%%%%
%                 %convergence diagnostic test
%                 if (j > 1),
%                     %test=sum(abs(s2sub(1,:)-s2old(1,:))); 			%alternative #1
%                     test=1-sqrt(s2sub(1,:))./sqrt(s2old(1,:)); 		%alternative #2
%                     test=median(test); 					%for alternative #2
%                     diagnostic(j-1,i)=test;
%                 end;
%                 s2old=s2sub;

        %compute variances of differential light curves; propagates the errors in the standard 
        %way given the mathematical formulation for the ensemble.   
        s2i=s2(:,nearstars);	%instrumental variances
        s2w=s2sub;		%weights (variances of differential light curves of comparison stars)
       %   N=median(ensemble);  calculated above
        relFluxUncert(:,i)=s2(:,i)*(N^2)./(ensemble.^2)+norm.^(-2).*sum(s2i./(s2w.^2),2).* ...
            (flux(:,i).^2)*(N^2)./(ensemble.^4);

    end % if updateEnsFlag
        
end;  % loop over targets (for i = 1:nTarg)

% set output arguments
% relFlux = lc;
% relFluxUncert = sqrt(s2new);

return
% save output_diffphotflux.mat HJD f lc s2 s2new ncomp cstars
