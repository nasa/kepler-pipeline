function [output]=poly_fit_w_error(data,poly_degree)

%   Perform polynomial fit of degree poly_degree on the ydata given xdata
%   and return the coefficient estimates and one sigma (68%) confidence
%   interval error bars.
%   If all errors are non-zero a weighted fit is performed and the errors are
%   propagated to the output coefficients.
%   If any one of the errors is zero a standard un-weighted fit is
%   performed and the errors on the output coeffecients are estimated from
%   the residuals.
%
%   input:  data        =   nx3 array - col1 = x-data (i.e. time vector)
%                                       col2 = y-data (i.e. squid voltage)
%                                       col3 = error on y-data
%           poly_degree =   non-negative integer - polynomial degree of fit
%
%   output: output      =   (poly_degree + 1) x 2 array - col1 = parameter estimate
%                                                         col2 = one sigma error on estimate
%                           (Row number - 1) = order coeffecient. e.g. constant term is row 1
%                                                                      1st power is row 2
%                                                                      etc.
%
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

%%   Check size of input

if (length(data(:,2))<poly_degree)
    output=[];
    return
end

confidence_level=.84;                                   %   confidence level to use for Student-t distribution
                                                        %   Note that the MATLAB x=tinv(P,n) function returns the number of SD such that the cumulative
                                                        %   probability from -inf to x = P. Further note that 0.84 = 0.68+(1-0.68)/2
                                                        %   So entering a confidence level of 0.84 in tinv() will actually give the 1 sigma or
                                                        %   68% confidence interval.
%%   Build polynomial model from xdata

M=[ones(length(data(:,1)),1)];
for i=1:poly_degree
    M=[M,data(:,1).^i];
end

%%   check for zero error
zero_check=find(data(:,3)==0, 1);
%%   do weighted fit
if(isempty(zero_check)==1)                                   
    
    err=diag(1./data(:,3).^2);      %   create diagonal weight matrix
    P=pinv(M'*err*M);
    
    estimate=P*(M'*err*data(:,2));  %   calculate weighted estimates
    var_temp=diag(P);               %   calculate error on estimates   
%%   do standard fit
else 
	estimate=M\data(:,2);
	
	%   calculate residuals to fit
	fit=M*estimate;    
	resid=data(:,2)-fit;
	resid_bar=mean(resid);
	mean_sq_resid=sum((resid-resid_bar).^2)/(length(resid));
        
	%   calculate variance of fitted parameters
	var_temp=diag(pinv(M'*M)).*mean_sq_resid;

end
    
%%   
%   calculate one sigma confidence bounds for each fitted parameter using
%   student-t factor to correct for finite number of data points
t_factor=tinv(confidence_level,length(data(:,2)));
one_sigma=t_factor.*sqrt(var_temp);

%   build output
output=[estimate,one_sigma];
