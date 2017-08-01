function [M, J] = make_transformation_matrix(tStruct, X, Y, varargin )

% function [M, J] = make_transformation_matrix(tStruct, X, Y, varargin)
%
% Create the transformation matrix for one of a standard set of transformations.
%
% INPUT:    tStruct             =   matrix generation input struct containing
%                                   transformation type and additional transformation 
%                                   generation data
%           X, Y                =   column vector of input data
%           varargin            = mode = varargin{1}. Controls which data to propagate
%                                 mode = 0 --> propagate both x and Cx (default)
%                                 mode = 1 --> propagate x, Cx == []
%
% OUTPUT:   M                   =   transformation matrix; f([X;Y]), [X;Y] = vector
%                                   of input data
%           J                   =   Jacobian matrix of the transformation: df([X;Y])/d[X;Y]
%
% NOTE: USE SPARSE MATRIX REPRESENTATION WHENEVER POSSIBLE
%
% 
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

% check for mode input
mode = 0;
if(nargin>3)
    if(varargin{1}==1)
        mode = 1;
    end
end


% TEMP - select all indices
iX = [1:length(X)]'; %#ok<NBRAK>
X_primitiveSize = length(X);

type = tStruct.transformType;

switch type
    case 'scale'                                                        % M = scale .* I
        scale           = tStruct.transformParamStruct.scaleORweight;
        lengthX         = length(X);
        M = scale.*sparse(1:lengthX, 1:lengthX, 1);
        if(mode)
            J = [];
        else
            J = M;
        end
% -----------------------------------------------------------        
    case 'scaleV'                                                       % M = D(w)
        w               = tStruct.transformParamStruct.scaleORweight;
        if(ischar(w))
            w = eval(w);
            w = w(:);
        end
        lengthX         = length(X);
        M = sparse(1:lengthX, 1:lengthX, w );
        if(mode)
            J = [];
        else
            J = M;
        end
% -----------------------------------------------------------        
    case 'addV'                                                         % M = [I , I]
        if( length(X) ~= length(Y) )
            msgString = ['Input Error: ',mfilename,':Transform type *',type,...
                '* requires equal length input vectors.'];
            error(msgString);
        end        
        lengthX = length(X);
        M = [ sparse(1:lengthX, 1:lengthX, 1), sparse(1:lengthX, 1:lengthX, 1) ];
        if(mode)
            J = [];
        else
            J = M;
        end
% -----------------------------------------------------------        
     case 'diffV'                                                       % M = [I , -I]
        if( length(X) ~= length(Y) )
            msgString = ['Input Error: ',mfilename,':Transform type *',type,...
                '* requires equal length input vectors.'];
            error(msgString);
        end        
        lengthX = length(X);
        M = [ sparse(1:lengthX, 1:lengthX, 1), -sparse(1:lengthX, 1:lengthX, 1) ];
        if(mode)
            J = [];
        else
            J = M;
        end
% -----------------------------------------------------------          
    case 'multV'                                                        % M = (1/2) * [ D(v2) , D(v1) ] 
        if( length(X) ~= length(Y) )
            msgString = ['Input Error: ',mfilename,':Transform type *',type,...
                '* requires equal length input vectors.'];
            error(msgString);
        end        
        lengthX = length(X);
        M = 0.5 .* [ sparse(1:lengthX, 1:lengthX, Y), sparse(1:lengthX, 1:lengthX, X) ];
        if(mode)
            J = [];
        else
            J = 2.*M;
        end
% -----------------------------------------------------------        
    case 'divV'                                                         % M = (1/2) * [ D(1/v2) , D(v1/v2^2) ] 
        if( length(X) ~= length(Y) )
            msgString = ['Input Error: ',mfilename,':Transform type *',type,...
                '* requires equal length input vectors.'];
            error(msgString);
        end        
        lengthX = length(X);
        M = 0.5 .* [ sparse(1:lengthX, 1:lengthX, 1./ Y), sparse(1:lengthX, 1:lengthX, X./(Y.^2)) ];
        if(mode)
            J = [];
        else
            J = [ sparse(1:lengthX, 1:lengthX, 1./ Y), -sparse(1:lengthX, 1:lengthX, X./(Y.^2)) ];
        end
% -----------------------------------------------------------                 
    case 'wSum'                                                          % M = [w1, w2, ..., wn]
        w = tStruct.transformParamStruct.scaleORweight;
        if(ischar(w))
            w = eval(w);
        end
        % make sure weights are row vector
        w = w(:)';        
        % transformation is 1-D matrix
        M = sparse(w);
        if(mode)
            J = [];
        else
            J = M;
        end
% -----------------------------------------------------------        
    case 'wMean'                                                          % M = (1/n)[w1, w2, ..., wn]
        w = tStruct.transformParamStruct.scaleORweight;
        if(ischar(w))
            w = eval(w);
        end
        % make weights a row vector
        w = w(:)';        
        % transformation is 1-D matrix and normalize
        M = sparse(w)./length(w);
        if(mode)
            J = [];
        else
            J = M;
        end
% -----------------------------------------------------------                 
    case 'bin'                                                          % M = BIN(v)
        bins = tStruct.transformParamStruct.binSizes;             % size of each bin
        if(ischar(bins))
            bins = eval(bins);
        end
        % first build the entire matrix        
        M = spalloc(length(bins),sum(bins),sum(bins));
        binIndex = 1;
        for i = 1:length(bins)
            M(i, binIndex:binIndex + bins(i) - 1 ) = 1;                     %#ok<*SPRIX>
            binIndex = binIndex + bins(i);
        end                
        % then select only the indices needed
        M = M(:,iX);
        if(mode)
            J = [];
        else
            J = M;
        end
% -----------------------------------------------------------                    
    case 'lsPolyFit'                                                          % 
        
        % table this one for now 
% -----------------------------------------------------------                
    case 'wPoly'                                                              % 
        polyOrder = tStruct.transformParamStruct.polyOrder;
        w = tStruct.transformParamStruct.scaleORweight;
        if(ischar(w))
            w = eval(w);
            w=w(:);
        end
        indVariable = tStruct.transformParamStruct.polyXvector;
        if(ischar(indVariable))
            indVariable = eval(indVariable);
            indVariable=indVariable(:);
        end
        % build polynomial design matrix        
        M = zeros(length(indVariable), polyOrder + 1);
        for i = 1: polyOrder + 1
            M(:,i) = indVariable.^(polyOrder + 1 - i);
        end        
        % weight rows by scaling column-wise with w
        M = scalecol(w, M); 
        if(mode)
            J = [];
        else
            J = M;
        end
% -------------------------------------------------------------------         
    case 'expSum'
        % Functional form:
        % Sum of exponentials with different time constants.
        % z = sum( Ai * e^( x./Ki ) = T * A
        % Where:
        % K = vector of decay constants         == inputData{1}
        % x = vector of independent variables   == inputData{2}
        %
        % A = incoming fitted parameters w/associated covariance
        
        % unpack parameters
        K = tStruct.transformParamStruct.polyOrder;
        x = tStruct.transformParamStruct.polyXvector;
        
        % convert string input if necessary
        if( ischar(K) )
            K = eval(K);
        end        
        if( ischar(x) )
            x = eval(x);
        end 

        % build design matrix
        M = exp( colvec(x) * (1./rowvec(K)) );
       
        if(mode)
            J = [];
        else
            J = M;
        end
% -----------------------------------------------------------
   case 'custom01_calFitted1DBlack'
        % Functional form:
        % Sum of linear + two exponentials(~select indices) + linear(select indices)
        % z = T * A
        %
        % Where:
        % T = [ 1 .* double(~mSmearSelect);
        %      ( x - (R - mod(R,2))/2 ) ./ ( (R - mod(R,2))/2 ) .* double(~mSmearSelect);
        %      exp(-( x-B ) / Klong) .* double(~mSmearSelect);
        %      exp(-( x-B ) / Kshort) .* double(~mSmearSelect); 
        %      double(mSmearSelect);
        %      ( x .* double(mSmearSelect) - mean( x(mSmearRows).*double(mSmearSelect(mSmearRows)) ) .* double(mSmearSelect)]     
        %    
        %    x = 1:R        == black collateral rows (one-based)
        %    B              == start of science rows (one-based)
        %    Klong          == long decayy constant
        %    Kshort         == short decay constant
        %    mSmearRows     == list of masked smear rows used
        %    mSearSelect    == logical array indicating rows <= maxSmearRow
        %
        % Assign inputs to existing parameter names (some don't really match the meaning of the parameter, but they are just names):
        % inputData{1}  == [Klong, Kshort]              == scaleORweight
        % inputData{2}  == x                            == polyXvector
        % inputData{3}  == mSmearRows                   == xIndices
        % inputData{4}  == B                            == filterCoeffs_b
        % inputData{5}  == maxSmearRow                  == filterCoeffs_a
        
        % unpack parameters    
        Klong       = tStruct.transformParamStruct.scaleORWeight(1);
        Kshort      = tStruct.transformParamStruct.scaleORWeight(2);
        x           = tStruct.transformParamStruct.polyXvector;
        mSmearRows  = tStruct.transformParamStruct.xIndices;
        B           = tStruct.transformParamStruct.filterCoeffs_b;
        maxSmearRow = tStruct.transformParamStruct.filterCoeffs_a;
        
        % convert string input if necessary
        if( ischar(x) )
            x = eval(x);
        end        
        if( ischar(mSmearRows) )
            mSmearRows = eval(mSmearRows);
        end 
        
        % make sure vectors are columns
        x = colvec(x);
        mSmearRows = colvec(mSmearRows);
        
        % set up intermediate parameters
        R = max(x);
        mSmearSelect = x <= maxSmearRow;
        
        % build design matrix
        M = [ ones(length(x),1) .* double(~mSmearSelect), ...
             ( x - (R - mod(R,2))/2 ) ./ ( (R - mod(R,2))/2 ) .* double(~mSmearSelect), ...
             exp(-( x-B ) / Klong) .* double(~mSmearSelect), ...
             exp(-( x-B ) / Kshort) .* double(~mSmearSelect), ... 
             double(mSmearSelect), ...
             ( x .* double(mSmearSelect) - mean( x(mSmearRows).*double(mSmearSelect(mSmearRows)) ) ) .* double(mSmearSelect)];
        
        if(mode)
            J = [];
        else
            J = M;
        end
% -----------------------------------------------------------        
    case 'filter'                                                             % 
        b = tStruct.transformParamStruct.filterCoeffs_b;
        a = tStruct.transformParamStruct.filterCoeffs_a;        
        % generate impulse response over original domain
        imp = impz( b, a, X_primitiveSize );        
        % build full design matrix M such that M * x = conv( imp, x)
        M = sparse(convmtx(imp, X_primitiveSize ) );        
        % select only columns and rows corresponding to indices
        M = M( iX, iX);
        if(mode)
            J = [];
        else
            J = M;
        end
% -----------------------------------------------------------                
	case 'FCmodelScale'                                                       % 
        modelCallString = tStruct.transformParamStruct.FCmodelCall;
        
        % do nothing for now
        w = eval(modelCallString); %#ok<NASGU>
        
        M = sparse(iX, iX, 1);
        if(mode)
            J = [];
        else
            J = M;
        end
% -----------------------------------------------------------        
    case 'FCmodelAdd'                                                         % 
        modelCallString = tStruct.transformParamStruct.FCmodelCall;      
        
        % do nothing for now
        w = eval(modelCallString); %#ok<NASGU>
        
        M = sparse(iX, iX, 1);
        if(mode)
            J = [];
        else
            J = M;
        end
% -----------------------------------------------------------        
    case 'userM'                                                              % 
        if(ischar(tStruct.transformParamStruct.userM))
            M = eval(tStruct.transformParamStruct.userM);
        else
            M = tStruct.transformParamStruct.userM;
        end
        if(mode)
            J = [];
        else
            J = M;
        end
% -----------------------------------------------------------        
    case 'selectIndex'
        if(ischar(tStruct.transformParamStruct.xIndices))
            iSelect = int16(eval(tStruct.transformParamStruct.xIndices));
        else
            iSelect = tStruct.transformParamStruct.xIndices;
        end
        M = spalloc(length(iSelect),size(X,1),length(iSelect));
        for i=1:length(iSelect)
            M(i,iSelect(i)) = 1;
        end        
        if(mode)
            J = [];
        else
            J = M;
        end
% -----------------------------------------------------------   
    case 'concatRows'
        M = speye(size(X,1)+size(Y,1));
 
        if(mode)
            J = [];
        else
            J = M;
        end
% -----------------------------------------------------------
    case 'fillRows'
        
        if(ischar(tStruct.transformParamStruct.xIndices))
            iSelect = int16(eval(tStruct.transformParamStruct.xIndices));
        else
            iSelect = tStruct.transformParamStruct.xIndices;
        end
        M = spalloc(size(X,1),size(X,1)+size(Y,1),size(X,1)+size(Y,1));
        M(1:size(X,1),1:size(X,1)) = speye(size(X,1));
        for i=1:length(iSelect)
            M(iSelect(i),iSelect(i)) = 0;
            M(iSelect(i),size(X,1)+i) = 1;
        end        
        if(mode)
            J = [];
        else
            J = M;
        end
% -----------------------------------------------------------   
%     NOT IMPLEMENTED IN MATRIX FORM
%     case 'interpLinear'
% ----------------------------------------------------------- 
%     NOT IMPLEMENTED IN MATRIX FORM
%     case 'interpNearest'
% ----------------------------------------------------------- 
    case 'eye'
        M = speye(length(iX));
        if(mode)
            J = [];
        else
            J = M;
        end
% -----------------------------------------------------------        
    otherwise
        disp('Transformation type not available');
end


%             1) scale          ==   scale data by a constant                                  z = c .* x      
%             2) scaleV         ==   scale data by a constant vector                           z = v .* x                       
%             3) addV           ==   add two variable vectors                                  z = x + y    
%             4) diffV          ==   add two variable vectors                                  z = x - y    
%             5) multV          ==   multiply two variable vectors                             z = x .* y
%             6) divV           ==   divide two variable vectors                               z = x ./ y
%             7) wSum           ==   weighted sum of a variable vector                         z = sum(w .* x)
%             8) wMean          ==   weighted mean of a variable vector                        z = mean(sum(w .* x)) 
%             9) bin            ==   bin the elements of a variable vector                     z(i) = sum( x(j:k) )
%             10) lsPolyFit     ==   least squares polynomial fit                              [p, Cp] = lscov(y, x, Cy) 
%             11)wPoly          ==   apply a weighted polynomial design matrix                 z = scalecol( w, M) * x
%             12)filter         ==   filter input data (x) using filter(b,a,x)                 z = filter(b, a, x)
%             13)FCmodelScale   ==   apply scaling model from Fc models                        z = Mmodel * x
%             14)FCmodelAdd     ==   apply additive model from Fc models                       z = Mmodel + x
%             15)userM          ==   user defined matrix transformation                        z = M * x
%             16)selectIndex    ==   select subset of incoming data based                      z = x(index,:)
%             17)concatRows     ==   concatenate input row-wise                                z = [x; y]
%             18)fillRows       ==   fill rows in x at index with rows of y                    z = x; x(index) = y                              
%             19)clearVar       ==   clear transformation record for variableName          
%             20)clearAll       ==   clear transformation record for all variableNames
%             21)eye            ==   indentity transformation                                  z = I * x 
%             22)expSum         ==   sum of exponentials                                       z = sum( Ai * e ^ (x/Ki) )
%             23)custom01_calFitted1DBlack == 1d Black two-exponential fit                     z = T * A


% Transformations:
%
% 1)    Scale variable vector by a constant:        y = w * x --> f(x) =  w * [ xi ];
%               w 
%                   w
%       M =             w              = w * I ; y = M * x
%                           ..
%                               w
%       Uncertainties:                              dy = w .* dx --> df/dx = w
%               w 
%                   w
%       J =             w              = w * I ; dy = J * dx
%                           ..
%                               w
% 2)    Scale variable vector by a constant vector: y = w .* x --> f(x) = [ wi * xi ];
%               w1 
%                   w2
%       M =             w3              = D(w) ; y = M * x
%                           ..
%                               wn
%       Uncertainties:                              dy = w .* dx --> df/dx = [ wi ]
%               w1 
%                   w2
%       J =             w3              = D(w) ; dy = J * dx
%                           ..
%                               wn
% 3)    Adding two variable vetors:                 z = x + y --> f(x) = [ xi + yi ];
%               1                      1    
%                   1                      1
%       M =             1                      1            =    [ I , I ] ; z = M * [ x ; y ]
%                           ..                      ..
%                               1                      1
%       Uncertainties:                              dz = dx + dy  --> df/dx = [ I , I ]
%               1                      1    
%                   1                      1
%       J =             1                      1            =    [ I , I ] ; dz = M * [ dx ; dy ]
%                           ..                      ..
%                               1                      1
% 4)    Multiplying two variable vetors (element-by-element):   z = x .* y --> f(x) = [ xi * yi ];
%                   y1                      x1    
%                       y2                      x2
%       M = 1/2             y3                      x3          =   (1/2) * [ D(y) , D(x) ] ; z = M * [ x ; y ]
%                               ..                      ..
%                                   yn                      xn
%       Uncertainties:                                          dz = ydx + xdy  --> df/dx = [ dyi*xi + dxi*y ]
%                   y1                      x1    
%                       y2                      x2
%       J =                  y3                      x3         = [ D(y) , D(x) ] ; dz = J * [ dx ; dy ]
%                               ..                      ..
%                                   yn                      xn
% 5)    Divide two variable vetors (element-by-element):   z = x ./ y --> f(x) = [ xi / yi ];
%                   1/y1                    x1/y1^2    
%                       1/y2                    x2/y2^2
%       M = (1/2)           1/y3                    x3/y3^2         =   (1/2) * [ D(1/y) , D(x/y^2) ] ; z = M * [ x ; y ]
%                               ..                      ..
%                                   1/yn                    xn/yn^2
%       Uncertainties:                                     dz = dx + dy  --> df/dx = 
%           1/y1                -x1/y1^2    
%               1/y2                -x2/y2^2
%       J =         1/y3                -x3/y3^2          =  [ D(1/y) , D(x/y^2) ] ; dz = J * [ dx ; dy ]
%                       ..                   ..
%                           1/yn                -xn/yn^2
% 6)    Sum the elements of a variable vector weighted by a constant
%       vector:                                                        z = sum(w .* x) --> f(x) = [ wi ]' * [ xi ]
%
%       M = [ w1  w2  w3 ... wn ]  =  [ w ];  z = M * x
%
%       Uncertainties:
%
%       J = [ w1  w2  w3 ... wn ]  =  [ w ];  z = M * dx
%
%
% 7)    Mean the elements of a variable vector weighted by a constant
%       vector:                                                        z = (1/n)sum(w .* x) --> f(x) = (1/n)[ wi ]' * [ xi ]
%
%       M = (1/n)[ w1  w2  w3 ... wn ]  =  (1/n)[ w ];  z = M * x
%
%       Uncertainties:
%
%       J = (1/n)[ w1  w2  w3 ... wn ]  =  (1/n)[ w ];  z = M * dx
%
%
% 8)    Binning vector elements:  z = BIN(x) --> f(x) = sum(xi)|selected elements
%           1   1   1   1   0   0   0   0   0   0   ... 0   0   0   0   0   0    
%           0   0   0   0   1   1   1   1   0   0   ... 0   0   0   0   0   0
%       M = 0   0   0   0   0   0   0   0   1   1   ... 0   0   0   0   0   0    = [  ] ; z = M * x
%           ...                         ..                      ..
%           0   0   0   0   0   0   0   0   0   0   ... 0   0   1   1   1   1
%       Uncertainties: dz = BIN(x) dx --> 
%           1   1   1   1   0   0   0   0   0   0   ... 0   0   0   0   0   0    
%           0   0   0   0   1   1   1   1   0   0   ... 0   0   0   0   0   0
%       J = 0   0   0   0   0   0   0   0   1   1   ... 0   0   0   0   0   0    = [  ] ; dz = J * dx
%           ...                         ..                      ..
%           0   0   0   0   0   0   0   0   0   0   ... 0   0   1   1   1   1
%   
% 
