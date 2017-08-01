function [lc,f,s2,s2new,ncomp,cstars,diagnostic] = diffphot(fn,star1,starn,n_near,var_thresh,n_iterate)

%[lc,f,s2,s2new,ncomp,cstars] = diffphot(fn,star1,starn,n_near) 
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

%INPUT
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

%N. Batalha (July 2005)


%Load data arrays.  
load(fn);

%Convergence diagnostic array
diagnostic=zeros(n_iterate-1,starn-star1+1);

%CCD-specific parameters required for computations 
gain=3.55;	%used to convert ADU to electron counts
npix=121; 	%important for computing total readnoise contribution to noise budget
readnoise=21;	%given here in electrons per pixel

nstars=size(f,2);	%number of stars in array
nimages=size(f,1);

%Initialize arrays
lc=zeros(nimages,nstars); s2new=lc; 
ncomp=zeros(1,nstars);
cstars=cell(1,nstars);

%convert all relevant quantities to units of electrons; make errors absolute, not relative
f=f.*gain;
bg=bg.*gain;
sf=sqrt(sf2);
sf=sf.*f;   			%convert relative error to absolute error
sbg=sqrt(sbg2);
sbg=sbg.*f;
srn=readnoise*sqrt(npix);	%note: this might not be accurate for Kepler

%compute total instrumental noise for all observations; will be used to compute first
%estimate of weighting factors
s2=sbg.^2+sf.^2+srn.^2;		%total variance
 
%loop through all stars
for i=star1:starn,
    	disp(i);
	%Initialize arrays
	n_nearstars=n_near;
	vari=zeros(1,n_nearstars); var2=vari;
	%find nearest stars
	dist=sqrt((x0-x0(i)).^2+(y0-y0(i)).^2);
	[di,ii]=sort(dist);
	nearstars=ii(2:n_nearstars+1);	%indices of closest stars

	%compute normalized weights using instrumental errors as first guesses
	s2sub=s2(:,nearstars);
	norm=sum(1./s2sub,2);	%normalization factor
	for j=1:n_nearstars, 
		ci(:,j)=(1./s2sub(:,j))./norm; 	%normalized weights for each comparison star
	end;

	%iterate the weights
	for j=1:n_iterate
		%for each comparison star, construct an ensemble using the "other" stars;
		%compute differential light curve and variance of that light curve
		for k=1:n_nearstars,
			%re-normalize the weights removing star k
			neartmp=nearstars; neartmp(:,k)=[];
			s2tmp=s2sub; s2tmp(:,k)=[];
			norm=sum(1./s2tmp,2);
			for l=1:n_nearstars-1,
				citmp(:,l)=(1./s2tmp(:,l))./norm; 
			end;
			%compute ensemble that excludes star k
			ensemble=sum(citmp.*f(:,neartmp),2); 
			diffens(:,k)=f(:,nearstars(k))./(ensemble./median(ensemble)); 
			difftmp=diffens(:,k);
			%compute variance (new weight) for star k
			vdifftmp(k)=var(difftmp); 
		end;

		%compute new normalized weights for all stars
		s2sub=repmat(vdifftmp,nimages,1);
		norm=sum(1./s2sub,2);
		for k=1:n_nearstars, ci(:,k)=(1./s2sub(:,k))./norm; end

		%convergence diagnostic test; Can be uncommented for additional testing
		%if (j > 1),
		        %test=sum(abs(s2sub(1,:)-s2old(1,:)));	%alternative #1
                        %test=1-sqrt(s2sub(1,:))./sqrt(s2old(1,:)); %alternative #2
                        %test=median(test);  %for alternative #2
		        %diagnostic(j-1,i)=test;
        	%end;
		%s2old=s2sub;
	end;

	%check for variability amongst the comparison stars by comparing the variances of the
	%differential light curves with the instrumental errors. Constant stars should have 
	%standard deviations within a
	%factor of var_thresh of their instrumental errors.
	vari=median(s2(:,nearstars),1);	%instrumental errors (variance)
	var2=s2sub(1,:);	%variance of differential light curve as computed above
	ic=find(sqrt(var2./vari) < var_thresh);	
  
	%Repeat all of the above using only stars ic as comparisons
	nearstars=nearstars(ic);
	n_nearstars=size(ic,2);
    
	%re-initialize arrays
	ci=zeros(nimages,n_nearstars); diffens=ci; vdifftmp=zeros(1,n_nearstars);

	%compute normalized weights using instrumental errors as first guesses
	s2sub=s2(:,nearstars);
	norm=sum(1./s2sub,2);
	for j=1:n_nearstars, 
		ci(:,j)=(1./s2sub(:,j))./norm; 
	end;
    
	%iterate the weights
	for j=1:n_iterate
        	%for each comparison star, construct an ensemble using the "other" stars;
        	%compute differential light curve and variance of that light curve
        	for k=1:n_nearstars,
            		%re-normalize the weights removing star k
            		neartmp=nearstars; neartmp(:,k)=[];
            		s2tmp=s2sub; s2tmp(:,k)=[];
            		citmp=zeros(nimages,n_nearstars-1);
            		norm=sum(1./s2tmp,2);
            		for l=1:n_nearstars-1,
                		citmp(:,l)=(1./s2tmp(:,l))./norm;
            		end;
            		%compute ensemble that excludes star k
            		ensemble=sum(citmp.*f(:,neartmp),2);
            		diffens(:,k)=f(:,nearstars(k))./(ensemble./median(ensemble));
            		difftmp=diffens(:,k);
            		%compute variance (new weight) for star k
            		vdifftmp(k)=var(difftmp);
        	end;
        
        	%compute new normalized weights for all stars
        	s2sub=repmat(vdifftmp,nimages,1);
        	norm=sum(1./s2sub,2);
        	for k=1:n_nearstars, 
			ci(:,k)=(1./s2sub(:,k))./norm; 
		end;
        
        	%construct ensemble
        	ensemble=sum(ci.*f(:,nearstars),2);
        	lcnew=f(:,i)./(ensemble./median(ensemble));
        
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
	lc(:,i)=lcnew;
	ncomp(i)=n_nearstars;
	cstars{i}=nearstars;

	%compute variances of differential light curves; propagates the errors in the standard 
	%way given the mathematical formulation for the ensemble.   
	s2i=s2(:,nearstars);	%instrumental variances
	s2w=s2sub;		%weights (variances of differential light curves of comparison stars)
	N=median(ensemble);
	s2new(:,i)=s2(:,i)*(N^2)./(ensemble.^2)+norm.^(-2).*sum(s2i./(s2w.^2),2).* ...
		(f(:,i).^2)*(N^2)./(ensemble.^4);
end;
save output_diffphotflux.mat HJD f lc s2 s2new ncomp cstars
