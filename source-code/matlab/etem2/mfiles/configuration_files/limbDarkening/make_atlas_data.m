% script to construct and save nonlinear limb darkening coefficients from
% atlas data.
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

% the data are in various text files broken up due to the size of the full
% table.  Each file contains a matrix in the form
% VT	logg	Teff	log[M/H]	U	B	V	R	I	J	H	K
% km/s	[cm/s+2]	K	[Sun]								
% where the rows are the nonlinear limb darkening coefficients a1, a2, a3,
% a4 repeating.  

clear;
def_atlas_met_m5tom3_5;
def_atlas_met_m3tom0_5;
def_atlas_met_m0_3to0;
def_atlas_met_0_1to0_5;
def_atlas_met_1to0v1;
def_atlas_met_0v4to0v8;

atlasNonlinearLimbDarkeningStruct.shortKey = ...
	{'VT', 'logg', 'Teff', 'log[M/H]', 'U', 'B', 'V', 'R', 'I', 'J', 'H', 'K'; 
     'km/s', '[cm/s+2]', 'K', '[Sun]', '', '', '', '', '', '', '', ''};
atlasNonlinearLimbDarkeningStruct.key = ...
    {'turbulent velocity (km/s)', 'logg (cm/sec+2)', ...
    'effective temperature (K)', 'metallicity: log[M/H] (sun)', ...
    'U band', 'B band', 'V band', 'R band', 'I band', 'J band', ...
    'H band', 'K band'};
atlasNonlinearLimbDarkeningStruct.turbulentVelocityIndex = 1;
atlasNonlinearLimbDarkeningStruct.logGIndex = 2;
atlasNonlinearLimbDarkeningStruct.effectiveTemperatureIndex = 3;
atlasNonlinearLimbDarkeningStruct.logMetallicityIndex = 4;
atlasNonlinearLimbDarkeningStruct.UBandIndex = 5;
atlasNonlinearLimbDarkeningStruct.BBandIndex = 6;
atlasNonlinearLimbDarkeningStruct.VBandIndex = 7;
atlasNonlinearLimbDarkeningStruct.RBandIndex = 8;
atlasNonlinearLimbDarkeningStruct.IBandIndex = 9;
atlasNonlinearLimbDarkeningStruct.JBandIndex = 10;
atlasNonlinearLimbDarkeningStruct.HBandIndex = 11;
atlasNonlinearLimbDarkeningStruct.KBandIndex = 12;

atlasNonlinearLimbDarkeningStruct.a1 = [atlas_met_m5tom3_5(1:4:end,:); ...
   atlas_met_m3tom0_5(1:4:end,:); ...
   atlas_met_m0_3to0(1:4:end,:); ...
   atlas_met_0_1to0_5(1:4:end,:); ...
   atlas_met_1to0v1(1:4:end,:); ...
   atlas_met_0v4to0v8(1:4:end,:); ...
   ];
atlasNonlinearLimbDarkeningStruct.a2 = [atlas_met_m5tom3_5(2:4:end,:); ...
   atlas_met_m3tom0_5(2:4:end,:); ...
   atlas_met_m0_3to0(2:4:end,:); ...
   atlas_met_0_1to0_5(2:4:end,:); ...
   atlas_met_1to0v1(2:4:end,:); ...
   atlas_met_0v4to0v8(2:4:end,:); ...
   ];
atlasNonlinearLimbDarkeningStruct.a3 = [atlas_met_m5tom3_5(3:4:end,:); ...
   atlas_met_m3tom0_5(3:4:end,:); ...
   atlas_met_m0_3to0(3:4:end,:); ...
   atlas_met_0_1to0_5(3:4:end,:); ...
   atlas_met_1to0v1(3:4:end,:); ...
   atlas_met_0v4to0v8(3:4:end,:); ...
   ];
atlasNonlinearLimbDarkeningStruct.a4 = [atlas_met_m5tom3_5(4:4:end,:); ...
   atlas_met_m3tom0_5(4:4:end,:); ...
   atlas_met_m0_3to0(4:4:end,:); ...
   atlas_met_0_1to0_5(4:4:end,:); ...
   atlas_met_1to0v1(4:4:end,:); ...
   atlas_met_0v4to0v8(4:4:end,:); ...
   ];
   
save atlasNonlinearLimbDarkeningData.mat atlasNonlinearLimbDarkeningStruct
