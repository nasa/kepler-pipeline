%Script that reads in all the ccdImage variables from Steve's generated
%ETEM files from 2008-03-27
%Expected 84 arrays
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


%Module 2
load ffi_m2o1.mat ccdImageCR;
mod2_out1=ccdImageCR;
load ffi_m2o2.mat ccdImageCR;
mod2_out2=ccdImageCR;
load ffi_m2o3.mat ccdImageCR;
mod2_out3=ccdImageCR;
load ffi_m2o4.mat ccdImageCR;
mod2_out4=ccdImageCR;

%Module 3
load ffi_m3o1.mat ccdImageCR;
mod3_out1=ccdImageCR;
load ffi_m3o2.mat ccdImageCR;
mod3_out2=ccdImageCR;
load ffi_m3o3.mat ccdImageCR;
mod3_out3=ccdImageCR;
load ffi_m3o4.mat ccdImageCR;
mod3_out4=ccdImageCR;

%Module 4
load ffi_m4o1.mat ccdImageCR;
mod4_out1=ccdImageCR;
load ffi_m4o2.mat ccdImageCR;
mod4_out2=ccdImageCR;
load ffi_m4o3.mat ccdImageCR;
mod4_out3=ccdImageCR;
load ffi_m4o4.mat ccdImageCR;
mod4_out4=ccdImageCR;

%Module 6
load ffi_m6o1.mat ccdImageCR;
mod6_out1=ccdImageCR;
load ffi_m6o2.mat ccdImageCR;
mod6_out2=ccdImageCR;
load ffi_m6o3.mat ccdImageCR;
mod6_out3=ccdImageCR;
load ffi_m6o4.mat ccdImageCR;
mod6_out4=ccdImageCR;

%Module 7
load ffi_m7o1.mat ccdImageCR;
mod7_out1=ccdImageCR;
load ffi_m7o2.mat ccdImageCR;
mod7_out2=ccdImageCR;
load ffi_m7o3.mat ccdImageCR;
mod7_out3=ccdImageCR;
load ffi_m7o4.mat ccdImageCR;
mod7_out4=ccdImageCR;

%Module 8
load ffi_m8o1.mat ccdImageCR;
mod8_out1=ccdImageCR;
load ffi_m8o2.mat ccdImageCR;
mod8_out2=ccdImageCR;
load ffi_m8o3.mat ccdImageCR;
mod8_out3=ccdImageCR;
load ffi_m8o4.mat ccdImageCR;
mod8_out4=ccdImageCR;

%Module 9
load ffi_m9o1.mat ccdImageCR;
mod9_out1=ccdImageCR;
load ffi_m9o2.mat ccdImageCR;
mod9_out2=ccdImageCR;
load ffi_m9o3.mat ccdImageCR;
mod9_out3=ccdImageCR;
load ffi_m9o4.mat ccdImageCR;
mod9_out4=ccdImageCR;

%Module 10
load ffi_m10o1.mat ccdImageCR;
mod10_out1=ccdImageCR;
load ffi_m10o2.mat ccdImageCR;
mod10_out2=ccdImageCR;
load ffi_m10o3.mat ccdImageCR;
mod10_out3=ccdImageCR;
load ffi_m10o4.mat ccdImageCR;
mod10_out4=ccdImageCR;

%Module 11
load ffi_m11o1.mat ccdImageCR;
mod11_out1=ccdImageCR;
load ffi_m11o2.mat ccdImageCR;
mod11_out2=ccdImageCR;
load ffi_m11o3.mat ccdImageCR;
mod11_out3=ccdImageCR;
load ffi_m11o4.mat ccdImageCR;
mod11_out4=ccdImageCR;

%Module 12
load ffi_m12o1.mat ccdImageCR;
mod12_out1=ccdImageCR;
load ffi_m12o2.mat ccdImageCR;
mod12_out2=ccdImageCR;
load ffi_m12o3.mat ccdImageCR;
mod12_out3=ccdImageCR;
load ffi_m12o4.mat ccdImageCR;
mod12_out4=ccdImageCR;

%Module 13
load ffi_m13o1.mat ccdImageCR;
mod13_out1=ccdImageCR;
load ffi_m13o2.mat ccdImageCR;
mod13_out2=ccdImageCR;
load ffi_m13o3.mat ccdImageCR;
mod13_out3=ccdImageCR;
load ffi_m13o4.mat ccdImageCR;
mod13_out4=ccdImageCR;

%Module 14
load ffi_m14o1.mat ccdImageCR;
mod14_out1=ccdImageCR;
load ffi_m14o2.mat ccdImageCR;
mod14_out2=ccdImageCR;
load ffi_m14o3.mat ccdImageCR;
mod14_out3=ccdImageCR;
load ffi_m14o4.mat ccdImageCR;
mod14_out4=ccdImageCR;

%Module 15
load ffi_m15o1.mat ccdImageCR;
mod15_out1=ccdImageCR;
load ffi_m15o2.mat ccdImageCR;
mod15_out2=ccdImageCR;
load ffi_m15o3.mat ccdImageCR;
mod15_out3=ccdImageCR;
load ffi_m15o4.mat ccdImageCR;
mod15_out4=ccdImageCR;

%Module 16
load ffi_m16o1.mat ccdImageCR;
mod16_out1=ccdImageCR;
load ffi_m16o2.mat ccdImageCR;
mod16_out2=ccdImageCR;
load ffi_m16o3.mat ccdImageCR;
mod16_out3=ccdImageCR;
load ffi_m16o4.mat ccdImageCR;
mod16_out4=ccdImageCR;

%Module 17
load ffi_m17o1.mat ccdImageCR;
mod17_out1=ccdImageCR;
load ffi_m17o2.mat ccdImageCR;
mod17_out2=ccdImageCR;
load ffi_m17o3.mat ccdImageCR;
mod17_out3=ccdImageCR;
load ffi_m17o4.mat ccdImageCR;
mod17_out4=ccdImageCR;

%Module 18
load ffi_m18o1.mat ccdImageCR;
mod18_out1=ccdImageCR;
load ffi_m18o2.mat ccdImageCR;
mod18_out2=ccdImageCR;
load ffi_m18o3.mat ccdImageCR;
mod18_out3=ccdImageCR;
load ffi_m18o4.mat ccdImageCR;
mod18_out4=ccdImageCR;

%Module 19
load ffi_m19o1.mat ccdImageCR;
mod19_out1=ccdImageCR;
load ffi_m19o2.mat ccdImageCR;
mod19_out2=ccdImageCR;
load ffi_m19o3.mat ccdImageCR;
mod19_out3=ccdImageCR;
load ffi_m19o4.mat ccdImageCR;
mod19_out4=ccdImageCR;

%Module 20
load ffi_m20o1.mat ccdImageCR;
mod20_out1=ccdImageCR;
load ffi_m20o2.mat ccdImageCR;
mod20_out2=ccdImageCR;
load ffi_m20o3.mat ccdImageCR;
mod20_out3=ccdImageCR;
load ffi_m20o4.mat ccdImageCR;
mod20_out4=ccdImageCR;

%Module 22
load ffi_m22o1.mat ccdImageCR;
mod22_out1=ccdImageCR;
load ffi_m22o2.mat ccdImageCR;
mod22_out2=ccdImageCR;
load ffi_m22o3.mat ccdImageCR;
mod22_out3=ccdImageCR;
load ffi_m22o4.mat ccdImageCR;
mod22_out4=ccdImageCR;

%Module 23
load ffi_m23o1.mat ccdImageCR;
mod23_out1=ccdImageCR;
load ffi_m23o2.mat ccdImageCR;
mod23_out2=ccdImageCR;
load ffi_m23o3.mat ccdImageCR;
mod23_out3=ccdImageCR;
load ffi_m23o4.mat ccdImageCR;
mod23_out4=ccdImageCR;

%Module 24
load ffi_m24o1.mat ccdImageCR;
mod24_out1=ccdImageCR;
load ffi_m24o2.mat ccdImageCR;
mod24_out2=ccdImageCR;
load ffi_m24o3.mat ccdImageCR;
mod24_out3=ccdImageCR;
load ffi_m24o4.mat ccdImageCR;
mod24_out4=ccdImageCR;
