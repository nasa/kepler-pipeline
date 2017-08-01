 function self = test_retrieve_kicModOutMjdgetMag(self)
%mdj is for q3 and month 1
% Kamal Uddin
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
tic;

display('test_retrieve_kicModOutMjdgetMag');

display(datestr(now()));

mod=7;
out=2;
% mjd=55092.71;
get_chars=1;
      test_inputs
     fprintf('mjdStartq0 is %f, mjdEndq0 is %f, mjdStartq1 is %f, mjdEndq1 is %f, mjdStartq2 is %f, mjdEndq2 is %f,mjdStartq3 is %f, mjdEndq3 is %f, mjdStartq4 is %f, mjdEndq4 is %f, mjdStartq5 is %f, mjdEndq5 is %f, mjdStartq6 is %f, mjdEndq6 is %f, q0targetListSetName is %s, q1targetListSetName is %s, q2targetListSetName is %s, q3targetListSetName is %s, q4targetListSetName is %s, q5targetListSetName is %s, q6targetListSetName is %s, startCadenceq0 is %d, endCadenceqq0 is %d,startCadenceq1 is %f, endCadenceqq1 is %d, startCadenceq2 is %d, endCadenceqq2 is %d, startCadenceq3 is %d, endCadenceqq3 is %d,  startCadenceq4 is %d, endCadenceq4 is %d, startCadenceq5 is %d, endCadenceqq5 is %d, startCadenceq6 is %d, endCadenceqq6 is %d \n', ...  
               mjdStartq0, mjdEndq0, mjdStartq1, mjdEndq1, mjdStartq2, mjdEndq2, mjdStartq3, mjdEndq3, mjdStartq4, mjdEndq4,mjdStartq5, mjdEndq5,mjdStartq6, mjdEndq6,q0targetListSetName,q1targetListSetName,q2targetListSetName, q3targetListSetName, q4targetListSetName,q5targetListSetName, q6targetListSetName, startCadenceq0 , endCadenceq0, startCadenceq1, endCadenceq1, startCadenceq2 , endCadenceq3, startCadenceq4 , endCadenceq4, startCadenceq5 , endCadenceq5,  startCadenceq6 , endCadenceq6);

 %value of get_raw_data is either 0 or 1

kic = retrieve_kics(mod,out,mjdStartq1,'get_chars'); 



      
if (isempty(kic))
    assert(1, 0, 'The retrieved KIC is empty.');
end

  


toc;
clear kic;
display('*********Done*******');
end  
  