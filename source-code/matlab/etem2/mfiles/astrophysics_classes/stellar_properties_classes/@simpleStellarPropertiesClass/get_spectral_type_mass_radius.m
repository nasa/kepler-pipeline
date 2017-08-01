function stellarPropertiesStruct = get_spectral_type_mass_radius(...
    simpleStellarPropertiesObject, stellarPropertiesStruct)
% function stellarPropertiesStruct = get_spectral_type_mass_radius(...
%     simpleStellarPropertiesObject, stellarPropertiesStruct)
%
% ported from Natalie's TableLookup.m 
%
% Function to convert effective temperature to a spectral type using the
% data tables in "Allen's Astrophysical Quantities", 4th edition, editor:
% Arthur Cox, AIP Press, 2000. Tables for luminosity classes I, III, and V
% are tabulated here.  An estimate of the logg value can be given as input
% in order to determine which table is most appropriate.  If no information
% about the surface gravity is known, a value greater than or equal to 4.0 
% can be given as input.  This will automatically cause the program to use 
% the tables for Main Sequence stars.
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

% Cubic spline interpolation is used for temperatures
% confined by the data tables.  Linear extrapolation is used for temperatures
% outside the range included in the data tables.  An error is reported if
% the linear extrapolation yields spectral types earlier than O0 or later than
% M9.
%
% Future improvements to be made: 1) if sig_t is smaller than the uncertainty
% given in the data tables, than the latter should supercede the former in 
% calculating spectralClassUncertainty.  2) an error ellipse should be constructed when deciding
% which luminosity class should be assumed (using uncertainties in logg and
% 
% spectral type (derived from teff and sig_t)).  Currently, the code simply 
% interpolates in logg using the surface gravity/spectral type tables and 
% compares the model logg to that provided as input.  No consideration of
% the
% uncertainty in effective temperature is currently made. The luminosity class
% that is returned should be viewed with caution until these improvements
% are made. 
%
%
% INPUT
%	stellarPropertiesStruct: structure that must contain the following
%	fields:
%   .logSurfaceGravity log of the surface gravity at the star's surface in
%       cgs
%   .effectiveTemperature the effective temperature of the star in Kelvin
%   optional: 
%   .effectiveTemperatureUncertainty Error estimate for effective
%       temperature [Kelvin]
%
% OUTPUT
%   the following fields are added to stellarPropertiesStruct:
%     .spectralType Spectral class where OBAFGKM = 1234567, respectively
%     .spectralSubType Spectral sub type (1-9)
%     .luminosityClass luminosity class as a number
%     .spectralClassString = Spectral type (including subclass) expressed
%           as string
%     .spectralClassUncertainty Uncertainty in spectral type expressed in number of
%           subclasses
%     .starRadius stellar radius in units of solar radius
%     .starMass stellar mass in units of solar mass
%     .status = status;




%	spectralType		Spectral class where OBAFGKM = 1234567, respectively
%	spectralSubType	Spectral sub type (1-9)
%	SpType		Spectral type (including subclass) expressed as string
%	spectralClassUncertainty		Uncertainty expressed in number of subclasses

%29-Mar:  supressed all warning messages- NMB

stellarPropertiesStruct

teff = stellarPropertiesStruct.effectiveTemperature;
logg = stellarPropertiesStruct.logSurfaceGravity;
sig_t = stellarPropertiesStruct.effectiveTemperatureUncertainty;

stellarPropertiesStruct.massUnits = 'solarMass';
stellarPropertiesStruct.radiusUnits = 'solarRadius';

logGOfSun=4.44;

[specTypeAndEffTemp,specTypeAndLogG,radius,mass]=GetTable;

status=0;

spT_table=specTypeAndEffTemp(:,1);  %Complete list of spectral types, expressed numerically, from Teff table
spG_table=specTypeAndLogG(:,1);  %Complete list of spectral type, expressed numerically, logg table
spR_table=radius(:,1); %from radius table
spM_table=mass(:,1);  %from mass table

%Grab effective temperatures for Main Sequence Stars
tV_table=specTypeAndEffTemp(:,2); sigV_table=specTypeAndEffTemp(:,3);
ii=find(specTypeAndEffTemp(:,2) ~= -99);
spTV_table=spT_table(ii); tV_table=tV_table(ii); sigV_table=sigV_table(ii);

%Grab effective temperatures for Giants
tIII_table=specTypeAndEffTemp(:,6); sigIII_table=specTypeAndEffTemp(:,7);
ii=find(specTypeAndEffTemp(:,6) ~= -99);
spTIII_table=spT_table(ii); tIII_table=tIII_table(ii); sigIII_table=sigIII_table(ii);

%Grab effective temperatures for Supergiants
tI_table=specTypeAndEffTemp(:,8); sigI_table=specTypeAndEffTemp(:,9);
ii=find(specTypeAndEffTemp(:,8) ~= -99);
spTI_table=spT_table(ii); tI_table=tI_table(ii); sigI_table=sigI_table(ii);

%Grab surface gravities of Main Sequence Stars and convert to absolute quantities
gV_table=specTypeAndLogG(:,2);
ii=find(specTypeAndLogG(:,2) ~= -99);
spGV_table=spG_table(ii); gV_table=gV_table(ii)+logGOfSun; 

%Grab surface gravities of Giants and convert to absolute quantities.
gIII_table=specTypeAndLogG(:,3);
ii=find(specTypeAndLogG(:,3) ~= -99);
spGIII_table=spG_table(ii); gIII_table=gIII_table(ii)+logGOfSun;

%Grab surface gravities of Supergiants and convert to absolute quantities.
gI_table=specTypeAndLogG(:,4);
ii=find(specTypeAndLogG(:,4) ~= -99);
spGI_table=spG_table(ii); gI_table=gI_table(ii)+logGOfSun;

%Grab mass and radii of Main Sequence Stars 
rV_table=radius(:,2);
ii=find(radius(:,2) ~= -99);
spRV_table=spR_table(ii); rV_table=rV_table(ii);
mV_table=mass(:,2);
ii=find(mass(:,2) ~= -99);
spMV_table=spM_table(ii); mV_table=mV_table(ii);

%Grab mass and radii of Giants 
rIII_table=radius(:,3);
ii=find(radius(:,3) ~= -99);
spRIII_table=spR_table(ii); rIII_table=rIII_table(ii);
mIII_table=mass(:,3);
ii=find(mass(:,3) ~= -99);
spMIII_table=spM_table(ii); mIII_table=mIII_table(ii);

%Grab surface gravities of Supergiants and convert to absolute quantities.
rI_table=radius(:,4);
ii=find(radius(:,4) ~= -99);
spRI_table=spR_table(ii); rI_table=rI_table(ii);
mI_table=mass(:,4);
ii=find(mass(:,4) ~= -99);
spMI_table=spM_table(ii); mI_table=mI_table(ii);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine a rough estimate of the spectral type using the effective temperature tables
% for Main Sequence Stars.

%Cubic spline interpolation (or linear extrapolation)
teff
size(tV_table)
if (teff >= min(tV_table) && teff <= max(tV_table))
	spt=interp1(tV_table,spTV_table,teff,'spline');
else
	spt=interp1(tV_table,spTV_table,teff,'linear','extrap');
end

if (spt < 10)
	spectralType=spt;
    spectralSubType=NaN;
    luminosityClass=NaN;
    spectralClassString='null';
    spectralClassUncertainty=NaN;
    starRadius=NaN;
    starMass=NaN;
	status=2;
	%warning('Effective temperature too high');
    stellarPropertiesStruct.spectralType = spectralType;
    stellarPropertiesStruct.spectralSubType = spectralSubType;
    stellarPropertiesStruct.luminosityClass = luminosityClass;
    stellarPropertiesStruct.spectralClassString = spectralClassString;
    stellarPropertiesStruct.spectralClassUncertainty = spectralClassUncertainty;
    stellarPropertiesStruct.radius = starRadius;
    stellarPropertiesStruct.mass = starMass;
    stellarPropertiesStruct.status = status;
	return;
end

if (spt > 79)
	spectralType=spt;
    spectralSubType=NaN;
    luminosityClass=NaN;
    spectralClassString='null';
    spectralClassUncertainty=NaN;
    starRadius=NaN;
    starMass=NaN;
	status=1;
	%warning('Effective temperature too low');
    stellarPropertiesStruct.spectralType = spectralType;
    stellarPropertiesStruct.spectralSubType = spectralSubType;
    stellarPropertiesStruct.luminosityClass = luminosityClass;
    stellarPropertiesStruct.spectralClassString = spectralClassString;
    stellarPropertiesStruct.spectralClassUncertainty = spectralClassUncertainty;
    stellarPropertiesStruct.radius = starRadius;
    stellarPropertiesStruct.mass = starMass;
    stellarPropertiesStruct.status = status;
	return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Use surface gravity and effective temperature estimate to define luminosity class

if (logg >= 4.0) 
	ttable=tV_table;
	stable=spTV_table;
	rtable=rV_table;
	mtable=mV_table;
        sp_rtable=spRV_table;
        sp_mtable=spMV_table;
	%fprintf(1,'Luminosity Class V assumed.\n');
	lclass='V';
	luminosityClass=5;
	if (spt >= min(spGV_table) && spt <= max(spGV_table))
        gtestV=interp1(spGV_table,gV_table,spt,'spline');
    else
        gtestV=interp1(spGV_table,gV_table,spt,'linear','extrap');
    end
	mindiff=abs(gtestV-logg);
else
	%compute logg using table for MS stars
	if (spt >= min(spGV_table) && spt <= max(spGV_table))
		gtestV=interp1(spGV_table,gV_table,spt,'spline'); 
	else
		gtestV=interp1(spGV_table,gV_table,spt,'linear','extrap');
	end

	%compute logg using table for supergiants
	if (spt >= min(spGI_table) && spt <= max(spGI_table))
		gtestI=interp1(spGI_table,gI_table,spt,'spline');
	else
		gtestI=interp1(spGI_table,gI_table,spt,'linear','extrap');
	end

	%compute logg using table for giants
	if (spt >= 50 && spt <= max(spGIII_table))
		gtestIII=interp1(spGIII_table,gIII_table,spt,'spline');
	elseif (spt >= 45 && spt < 50)
		gtestIII=interp1(spGIII_table,gIII_table,spt,'linear','extrap');
	elseif (spt > max(spGIII_table))
		gtestIII=interp1(spGIII_table,gIII_table,spt,'linear','extrap');
	elseif (spt >= min(spGIII_table) && spt <= 15)
		gtestIII=interp1(spGIII_table,gIII_table,spt,'spline');
	else
		gtestIII=100;
	end
	
	diff=[abs(gtestV-logg),abs(gtestIII-logg),abs(gtestI-logg)];
	[mindiff,ii]=min(diff);
	if (ii == 1)
		ttable=tV_table;
		stable=spTV_table;
		rtable=rV_table;
		mtable=mV_table;
		sp_rtable=spRV_table;
		sp_mtable=spMV_table;
		%fprintf(1,'Luminosity Class V assumed.\n');
		lclass='V';
		luminosityClass=5;
	elseif (ii == 2)
		ttable=tIII_table;
		stable=spTIII_table;
		rtable=rIII_table;
                mtable=mIII_table;
                sp_rtable=spRIII_table;
                sp_mtable=spMIII_table;
		%fprintf(1,'Luminosity Class III assumed.\n');
		lclass='III';
		luminosityClass=3;
	else
		ttable=tI_table;
		stable=spTI_table;
		rtable=rI_table;
                mtable=mI_table;
                sp_rtable=spRI_table;
                sp_mtable=spMI_table;
		%fprintf(1,'Luminosity Class I assumed.\n');
		lclass='I';
		luminosityClass=1;
	end
end
if (mindiff >= 1.0)
	%warning('Surface gravity unexpected for the given temperature.')
	status=3;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Repeat temperature determination using the appropriate table based on luminosity class
% calculation
%Determine mass and radius in the same way

%Cubic spline interpolation (or linear extrapolation)
if (teff >= min(ttable) && teff <= max(ttable))
        spt=interp1(ttable,stable,teff,'spline');
	starRadius=interp1(sp_rtable,rtable,spt,'spline');
	starMass=interp1(sp_mtable,mtable,spt,'spline');
%	plot(sp_rtable,rtable,'-*'); hold on; plot(spt,starRadius,'g+');
%	figure(2); plot(sp_mtable,mtable,'-*'); hold on; plot(spt,starMass,'g+');
else
        spt=interp1(ttable,stable,teff,'linear','extrap');
	starRadius=interp1(sp_rtable,rtable,spt,'linear','extrap');
        starMass=interp1(sp_mtable,mtable,spt,'linear','extrap');
%	plot(sp_rtable,rtable,'-*'); hold on; plot(spt,starRadius,'g+');
%	figure(2); plot(sp_mtable,mtable,'-*'); hold on; plot(spt,starMass,'g+');
end
 
if (spt < 10)
	spectralType=spt;
    spectralSubType=NaN;
    luminosityClass=NaN;
    spectralClassString='null';
    spectralClassUncertainty=NaN;
    starRadius=NaN;
    starMass=NaN;
        %warning('Effective temperature too high');
    stellarPropertiesStruct.spectralType = spectralType;
    stellarPropertiesStruct.spectralSubType = spectralSubType;
    stellarPropertiesStruct.luminosityClass = luminosityClass;
    stellarPropertiesStruct.spectralClassString = spectralClassString;
    stellarPropertiesStruct.spectralClassUncertainty = spectralClassUncertainty;
    stellarPropertiesStruct.radius = starRadius;
    stellarPropertiesStruct.mass = starMass;
    stellarPropertiesStruct.status = status;
	return;
end
 
if (spt > 79)
	spectralType=spt;
    spectralSubType=NaN;
    luminosityClass=NaN;
    spectralClassString='null';
    spectralClassUncertainty=NaN;
    starRadius=NaN;
    starMass=NaN;
        %warning('Effective temperature too low');
    stellarPropertiesStruct.spectralType = spectralType;
    stellarPropertiesStruct.spectralSubType = spectralSubType;
    stellarPropertiesStruct.luminosityClass = luminosityClass;
    stellarPropertiesStruct.spectralClassString = spectralClassString;
    stellarPropertiesStruct.spectralClassUncertainty = spectralClassUncertainty;
    stellarPropertiesStruct.radius = starRadius;
    stellarPropertiesStruct.mass = starMass;
    stellarPropertiesStruct.status = status;
	return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepare output

%Convert to type and sub-type integers
spt_int=round(spt);
spectralType=floor(spt/10);
spectralSubType=spt_int-spectralType*10;
if (spectralSubType == 10)
	spectralType=spectralType+1;
	spectralSubType=0;
end

%Convert to string
type=['O','B','A','F','G','K','M'];
spectralClassString=[type(spectralType),int2str(spectralSubType),lclass];

%If error estimate has been given as input, then compute range of acceptable
%spectral types.
if ~isempty(sig_t);
    tefflo=teff-sig_t;
    teffhi=teff+sig_t;
    if (teffhi <= max(ttable))
        spthi=interp1(ttable,stable,teffhi,'spline');
    else
        spthi=interp1(ttable,stable,teffhi,'linear','extrap');
    end

    if (tefflo >= min(ttable))
        sptlo=interp1(ttable,stable,tefflo,'spline');
    else
        sptlo=interp1(ttable,stable,tefflo,'linear','extrap');
    end

    spectralClassUncertainty=round(abs((spthi-sptlo)/2.));
end

stellarPropertiesStruct.spectralType = spectralType;
stellarPropertiesStruct.spectralSubType = spectralSubType;
stellarPropertiesStruct.luminosityClass = luminosityClass;
stellarPropertiesStruct.spectralClassString = spectralClassString;
stellarPropertiesStruct.spectralClassUncertainty = spectralClassUncertainty;
stellarPropertiesStruct.radius = starRadius;
stellarPropertiesStruct.mass = starMass;
stellarPropertiesStruct.status = status;


function [spectralTypeAndEffectiveTemp,logG,radius,mass] = GetTable
%
% T1_V, T1_III, and T1_I and associated uncertainties are taken from Table 7.6
% p.151 of Astrophysical Quantities.  These are the values used here
% to compute the spectral type.  The uncertainties are not yet utilized.  In
% the future, they should supercede the uncertainty estimate given as input if
% that value is smaller than the accuracy of the MK calibration in the table
% below (Tsig).  The tabulations here are obtained by averaging together the
% results of many different studies and reviews on the subject.  Table is 
% specific to main sequence stars.
%
% T2 is taken from Table 15.7, p. 388, of Astrophysical Quantities.  These
% values are not used for determination of spectral type.  They are included here
% for reference only and/or future use.  These numbers are derived from several 
% sources, including the Landolt-Bornstein tables (Schmidt-Kaler 1982), making 
% averages where appropriate.  The studies appear to be somewhat dated compared 
% to those used to construct Teff1.  Table is specific to main sequence stars. 
%
% T3:  these are the tabulations given in Landolt-Bornstein (Schmidt-Kaler 1982).
% They are better sampled at some spectral types.  The numbers are only included here
% for reference and/or future use/study. Table is specific to main sequence stars.
%
% T1(III) is from Table 7.7 of Astrophysical Quantities (same as above, but for giants)
%
% type:     O=1, B=2, A=3, F=4, G=5, K=6, M=7
% subtype:  0,1,2,3,4,5,6,7,8,9
% SpT=type*10+subtype
%
%	SpT   T1_V  T1Vsig   T2_V    T3_V T1_III T1IIIsig  T1_I T1Isig
spectralTypeAndEffectiveTemp = [	
        10     -99    -99     -99     -99    -99     -99    -99   -99
	11     -99    -99     -99     -99    -99     -99    -99   -99
	12     -99    -99     -99     -99    -99     -99    -99   -99
	13     -99    -99     -99   52500    -99     -99    -99   -99
	14     -99    -99     -99   48000    -99     -99    -99   -99
	15     -99    -99   42000   44500    -99     -99    -99   -99
	16     -99    -99     -99   41000    -99     -99    -99   -99
	17     -99    -99     -99   38000    -99     -99    -99   -99
	18     -99    -99     -99   35800    -99     -99    -99   -99
	19   35900   1000   34000   33000    -99     -99  32500  1000
	20   31500   1000   30000   30000    -99     -99  26000  1000
	21   25600   1000     -99   25400    -99     -99  20700  1000
	22   22300   1000   20900   22000    -99     -99  17800  1000
	23   19000    250     -99   18700    -99     -99  15600   250
	24   17200    250     -99     -99    -99     -99  13900   250
	25   15400    250   15200   15400    -99     -99  13400   250
	26   14100    250     -99   14000    -99     -99  12700   250
	27   13000    250     -99   13000    -99     -99  12000   250
	28   11800    250   11400   11900    -99     -99  11200   250
	29   10700    250     -99   10500    -99     -99  10500   250
	30    9480    100    9790    9520    -99     -99   9730   200
	31     -99    -99     -99    9230    -99     -99   9230   200
	32    8810    100    9000    8970    -99     -99   9080   200
	33     -99    -99     -99    8720    -99     -99    -99   -99
	34     -99    -99     -99     -99    -99     -99    -99   -99
	35    8160    100    8180    8200    -99     -99   8510   200
	36     -99    -99     -99     -99    -99     -99    -99   -99
	37    7930    100     -99    7850    -99     -99    -99   -99
	38     -99    -99     -99    7580    -99     -99    -99   -99
	39     -99    -99     -99     -99    -99     -99    -99   -99
	40    7020    100    7300    7200    -99     -99   7700   200
	41     -99    -99     -99     -99    -99     -99    -99   -99
	42    6750    100    7000    6890    -99     -99   7170   200
	43     -99    -99     -99     -99    -99     -99    -99   -99
	44     -99    -99     -99     -99    -99     -99    -99   -99
	45    6530    100    6650    6440    -99     -99   6640   200
	46     -99    -99     -99     -99    -99     -99    -99   -99
	47    6240    100     -99     -99    -99     -99    -99   -99
	48     -99    -99    6250    6200    -99     -99   6100   200
	49     -99    -99     -99     -99    -99     -99    -99   -99
	50    5930    100    5940    6030   5910      50   5510   200
	51     -99    -99     -99     -99    -99     -99    -99   -99
	52    5830    100    5790    5860    -99     -99    -99   -99
	53     -99    -99     -99     -99    -99     -99   4980   200
	54    5740    100     -99     -99   5190      50    -99   -99
	55     -99    -99    5560    5770    -99     -99    -99   -99
	56    5620    100     -99     -99   5050      50    -99   -99
	57     -99    -99     -99     -99    -99     -99    -99   -99
	58     -99    -99    5310    5570   4960      50   4590   200
	59     -99    -99     -99     -99    -99     -99    -99   -99
	60    5240    100    5150    5250   4810      50   4420   200
	61     -99    -99     -99    5080   4610      50   4330   200
	62    5010    100    4830    4900   4500      50   4260   200
	63     -99    -99     -99    4730   4320      50   4130   200
	64    4560    100     -99    4590   4080      50    -99   -99
	65    4340    100    4410    4350   3980      50   3850   200
	66     -99    -99     -99     -99    -99     -99    -99   -99
	67    4040    100     -99    4060    -99     -99    -99   -99
	68     -99    -99     -99     -99    -99     -99    -99   -99
	69     -99    -99     -99     -99    -99     -99    -99   -99
	70    3800    100    3840    3850   3820      70   3650   200
	71    3680    100     -99    3720   3780      70   3550   200
	72    3530    100    3520    3580   3710      70   3450   200
	73    3380    100     -99    3470   3630      70   3200   200
	74    3180    100     -99    3370   3560      70   2980   200
	75    3030    100    3170    3240   3420      70    -99   -99
	76    2850    100     -99    3050   3250      70    -99   -99
	77     -99    -99     -99    2940    -99     -99    -99   -99
	78     -99    -99     -99    2640    -99     -99    -99   -99
	79     -99    -99     -99     -99    -99     -99    -99   -99
];

%
% Surface gravity measurements from Allen's Astrophysical Quantities, 4th edition
% Table 15.8 (p.389).  Measurements are differential to the Sun and expressed as
% log(g/g_sun) where log(g_sun)=4.44.  Values listed are here are the same as those 
% listed in Schmidt-Kaler 1982 (Landolt-Bornstein group 6)
%
logG=[
%    spectralClassString    V    III       I
        10 -99     -99    -99
	11 -99     -99    -99
	12 -99     -99    -99
	13  -0.3   -99    -99
	14 -99     -99    -99
	15  -0.4   -99     -1.1
	16  -0.45  -99     -1.2
	17 -99     -99    -99
	18  -0.5   -99     -1.2
	19 -99     -99    -99
	20  -0.5    -1.1   -1.6
	21 -99     -99    -99
	22 -99     -99    -99
	23  -0.5   -99    -99
	24 -99     -99    -99
	25  -0.4    -0.95  -2.0
	26 -99     -99    -99
	27 -99     -99    -99
	28  -0.4   -99    -99
	29 -99     -99    -99
	30  -0.3   -99     -2.3
	31 -99     -99    -99
	32 -99     -99    -99
	33 -99     -99    -99
	34 -99     -99    -99
	35  -0.15  -99     -2.4
	36 -99     -99    -99
	37 -99     -99    -99
	38 -99     -99    -99
	39 -99     -99    -99
	40  -0.1   -99     -2.7
	41 -99     -99    -99
	42 -99     -99    -99
	43 -99     -99    -99
	44 -99     -99    -99
	45  -0.1   -99     -3.0
	46 -99     -99    -99
	47 -99     -99    -99
	48 -99     -99    -99
	49 -99     -99    -99
	50  -0.05   -1.5   -3.1
	51 -99     -99    -99
	52 -99     -99    -99
	53 -99     -99    -99
	54 -99     -99    -99
	55   0.05   -1.9   -3.3
	56 -99     -99    -99
	57 -99     -99    -99
	58 -99     -99    -99
	59 -99     -99    -99
	60   0.05   -2.3   -3.5
	61 -99     -99    -99
	62 -99     -99    -99
	63 -99     -99    -99
	64 -99     -99    -99
	65   0.1    -2.7   -4.1
	66 -99     -99    -99
	67 -99     -99    -99
	68 -99     -99    -99
	69 -99     -99    -99
	70   0.15   -3.1   -4.3
	71 -99     -99    -99
	72   0.2   -99     -4.5
	73 -99     -99    -99
	74 -99     -99    -99
	75   0.5   -99    -99
	76 -99     -99    -99
	77 -99     -99    -99
	78   0.5   -99    -99
	79 -99     -99    -99
];

radius=[
%    spectralClassString    V    III       I
        10 -99     -99    -99
        11 -99     -99    -99
        12 -99     -99    -99
        13  15     -99    -99
        14 -99     -99    -99
        15  12     -99     30
        16  10     -99     25
        17 -99     -99    -99
        18  8.5    -99     20
        19 -99     -99    -99
        20  7.4     15     30 
        21 -99     -99    -99
        22 -99     -99    -99
        23  4.8    -99    -99
        24 -99     -99    -99
        25  3.9     8      50 
        26 -99     -99    -99
        27 -99     -99    -99
        28  3.0    -99    -99
        29 -99     -99    -99
        30  2.4     5      60
        31 -99     -99    -99
        32 -99     -99    -99
        33 -99     -99    -99
        34 -99     -99    -99
        35  1.7    -99     60
        36 -99     -99    -99
        37 -99     -99    -99
        38 -99     -99    -99
        39 -99     -99    -99
        40  1.5    -99     80 
        41 -99     -99    -99
        42 -99     -99    -99
        43 -99     -99    -99
        44 -99     -99    -99
        45  1.3    -99    100
        46 -99     -99    -99
        47 -99     -99    -99
        48 -99     -99    -99
        49 -99     -99    -99
        50  1.1     6     120 
        51 -99     -99    -99
        52 -99     -99    -99
        53 -99     -99    -99
        54 -99     -99    -99
        55  0.92    10    150 
        56 -99     -99    -99
        57 -99     -99    -99
        58 -99     -99    -99
        59 -99     -99    -99
        60  0.85    15    200
        61 -99     -99    -99
        62 -99     -99    -99
        63 -99     -99    -99
        64 -99     -99    -99
        65  0.72    25    400
        66 -99     -99    -99
        67 -99     -99    -99
        68 -99     -99    -99
        69 -99     -99    -99
        70  0.60    40    500 
        71 -99     -99    -99
        72  0.50   -99    800
        73 -99     -99    -99
        74 -99     -99    -99
        75  0.27   -99    -99
        76 -99     -99    -99
        77 -99     -99    -99
        78  0.10   -99    -99
        79 -99     -99    -99
];

mass= [
%    spectralClassString    V    III       I
        10 -99     -99    -99
        11 -99     -99    -99
        12 -99     -99    -99
        13 120     -99    -99
        14 -99     -99    -99
        15  60     -99     70
        16  37     -99     40 
        17 -99     -99    -99
        18  23     -99     28
        19 -99     -99    -99
        20  17.5    20     25
        21 -99     -99    -99
        22 -99     -99    -99
        23  7.6    -99    -99
        24 -99     -99    -99
        25  5.9      7     20
        26 -99     -99    -99
        27 -99     -99    -99
        28  3.8    -99    -99
        29 -99     -99    -99
        30  2.9      4     16
        31 -99     -99    -99
        32 -99     -99    -99
        33 -99     -99    -99
        34 -99     -99    -99
        35  2.0    -99     13
        36 -99     -99    -99
        37 -99     -99    -99
        38 -99     -99    -99
        39 -99     -99    -99
        40  1.6    -99     12
        41 -99     -99    -99
        42 -99     -99    -99
        43 -99     -99    -99
        44 -99     -99    -99
        45  1.4    -99     10
        46 -99     -99    -99
        47 -99     -99    -99
        48 -99     -99    -99
        49 -99     -99    -99
        50  1.05     1     10
        51 -99     -99    -99
        52 -99     -99    -99
        53 -99     -99    -99
        54 -99     -99    -99
        55  0.92   1.1     12
        56 -99     -99    -99
        57 -99     -99    -99
        58 -99     -99    -99
        59 -99     -99    -99
        60  0.79   1.1     13
        61 -99     -99    -99
        62 -99     -99    -99
        63 -99     -99    -99
        64 -99     -99    -99
        65  0.67   1.2     13
        66 -99     -99    -99
        67 -99     -99    -99
        68 -99     -99    -99
        69 -99     -99    -99
        70  0.51   1.2     13
        71 -99     -99    -99
        72  0.40   -99     19
        73 -99     -99    -99
        74 -99     -99    -99
        75  0.21   -99    -99
        76 -99     -99    -99
        77 -99     -99    -99
        78  0.06   -99    -99
        79 -99     -99    -99
];

