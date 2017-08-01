function [Xnew, CXnew] = do_transformation(tStruct, X, Y, Cx, Cy, varargin)
%
% function Xnew = do_transformation(tStruct, X, Y, Cx, Cy, varargin )
%
% Perform the one of a standard set of transformations on the input data.
%
% INPUT:    tStruct             =   transformation generation input struct containing
%                                   transformation type and additional generation data
%           X                   =   column vector X input data
%           Y                   =   column vector Y input data
%           Cx                  =   covariance matrix Cx input data
%           Cy                  =   covariance matrix Cy input data
%           varargin            =   varargin{1} == [xIndices]
%                                   List of primitive indices that make up X. Used to trim scaling vector to
%                                   proper dimesion and elements for example.
%                               =   varargin{2} == mode 
%                                   mode = 0 --> propagate both X and Cx (default)
%                                   mode = 1 --> propagate X, Cx == 0
%                               
%
% OUTPUT:   Xnew                =   result of transformation Xnew = M * [X;Y]
%           CXnew               =   result of Jacobian transformation CXnew = J * [Cx, 0; 0, Cy] * J' 
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



% check variable input arguments
mode = 0;
iX = (1:length(X))';
if(nargin>5)
    if(~isempty(varargin{1}) )
        iX = varargin{1};
        iX = iX(:);
    end
    if(nargin>6)
        if(varargin{2}==1)
            mode = 1;
            CXnew = [];
        end
    end
end

% get transform disable level from structure if available
if(~isfield(tStruct,'disableLevel') || isempty(tStruct.disableLevel))
    disableLevel = 0;
else
    disableLevel = tStruct.disableLevel;
end
do_x = [0,1];       % disableLevel in which T*x is enabled
do_Cx = [0,2];      % disableLevel in which T*Cx*T' is enabled

type = tStruct.transformType;

% ----------------------------------------------------------- 
switch type
    case 'scale'
        scale = tStruct.transformParamStruct.scaleORweight;
        if( any(ismember(disableLevel,do_x)) )
            Xnew = X .* scale;                                           % Xnew = (scale.*I) * X
        else
            Xnew = X;
        end
        if(~mode)                                                             
            if( any(ismember(disableLevel,do_Cx)) ) 
                CXnew = Cx .* (scale^2);                                  % CXnew = (scale.*I) * Cx * (scale.*I)'
            else
                CXnew = Cx;
            end
        end
% ----------------------------------------------------------- 
    case 'scaleV'
        if( length(X) ~= length(iX) )
            msgString = ['Input Error: ',mfilename,':Transform type *',type,...
                '* requires equal length input vectors.'];
            error(msgString);
        end
        V = tStruct.transformParamStruct.scaleORweight;
        if(ischar(V))
            V = eval(V);
        end
        V = V(iX);
        V = V(:);
        if( any(ismember(disableLevel,do_x)) )
            Xnew = X .* V;                                                % Xnew  = D(V)*X = V.*X
        else
            Xnew = X;
        end    
        if(~mode)
            if( any(ismember(disableLevel,do_Cx)) ) 
                CXnew = scalecol(V,scalerow(V,Cx));                       % CXnew = D(V)*Cx*D(V)'
            else
                CXnew = Cx;
            end    
        end
% -----------------------------------------------------------     
    case 'addV'                                                        
        if( length(X) ~= length(Y) )
            msgString = ['Input Error: ',mfilename,':Transform type *',type,...
                '* requires equal length input vectors.'];
            error(msgString);
        end
        if( any(ismember(disableLevel,do_x)) )
            Xnew = X + Y;                                                   % Xnew = [I I]*[X;Y] = X+Y
        else
            Xnew = X;
        end
        if(~mode)
            if( any(ismember(disableLevel,do_Cx)) ) 
                CXnew = Cx + Cy;                                            % CXnew = [I I]*[Cx,0;0,Cy]*[I I]' = Cx+Cy
            else
                CXnew = Cx;
            end 
        end
% -----------------------------------------------------------        
     case 'diffV'
        if( length(X) ~= length(Y) )
            msgString = ['Input Error: ',mfilename,':Transform type *',type,...
                '* requires equal length input vectors.'];
            error(msgString);
        end
        if( any(ismember(disableLevel,do_x)) )
            Xnew = X - Y;                                                   % Xnew = [I -I]*[X;Y] = X-Y
        else
            Xnew = X;
        end
        if(~mode)
            if( any(ismember(disableLevel,do_Cx)) ) 
                CXnew = Cx + Cy;                                            % CXnew = [I -I]*[Cx,0;0,Cy]*[I -I]' = Cx+Cy
            else
                CXnew = Cx;
            end
        end

% -----------------------------------------------------------          
    case 'multV'                                                                % Xnew  =(1/2)*[D(Y),D(X)]*[X;Y] = X.*Y
        if( length(X) ~= length(Y) )                                            % CXnew =[D(Y),D(X)]*[Cx,0;0,Cy]*[D(Y),D(X)]'
            msgString = ['Input Error: ',mfilename,':Transform type *',type,... %       = D(Y)*Cx*D(Y)' + D(X)*Cy*D(X)'
                '* requires equal length input vectors.'];
            error(msgString);
        end
        if( any(ismember(disableLevel,do_x)) )
            Xnew = X .* Y;
        else
            Xnew = X;
        end
        if(~mode)
            if( any(ismember(disableLevel,do_Cx)) )
                CXnew = scalecol(Y,scalerow(Y,Cx)) + scalecol(X,scalerow(X,Cy));    
            else
                CXnew = Cx;
            end
        end                                                                     
% -----------------------------------------------------------        
    case 'divV'                                                                 % Xnew = (1/2)*[D(1/Y), D(X/Y^2)]*[X;Y]
        if( length(X) ~= length(Y) )                                            % CXnew  =[D(1/Y),D(X/Y.^2)]*[Cx,0;0,Cy]*[D(1/Y),D(X/Y.^2)]'
            msgString = ['Input Error: ',mfilename,':Transform type *',type,... %       = D(1/Y)*Cx*D(1/Y)' + D(X/Y^2)*Cy*D(X/Y^2)'
                '* requires equal length input vectors.'];
            error(msgString);
        end        
        if( any(ismember(disableLevel,do_x)) )
            Xnew = X ./ Y;   
        else
            Xnew = X;
        end
        if(~mode)
            if( any(ismember(disableLevel,do_Cx)) )
                CXnew = scalecol(1./Y,scalerow(1./Y,Cx)) + scalecol(-X./(Y.^2),scalerow(-X./(Y.^2),Cy));   
            else
                CXnew = Cx;
            end
        end                                                                     
% -----------------------------------------------------------                 
    case 'wSum'                                                         % Xnew = [w]*[X] = sum(w.*X)
        w = tStruct.transformParamStruct.scaleORweight;                 % CXnew = [w]*Cx*[w]' = sum(w.*X)
        if(ischar(w))
            w = eval(w);
        end
        w = w(iX);
        % make sure weight is row vector
        w = w(:)'; 
        
        if( any(ismember(disableLevel,do_x)) )
            Xnew = w * X;
        else
            Xnew = X;
        end
        if(~mode)
            if( any(ismember(disableLevel,do_Cx)) )
                CXnew = w * Cx * w';
            else
                CXnew = Cx;
            end
        end
% -----------------------------------------------------------        
    case 'wMean'                                                        % Xnew = (1/n)[w]*[X] = mean(w.*X)
        w = tStruct.transformParamStruct.scaleORweight;                 % CXnew = (1/n^2)[w]*[Cx]*[w]' = (1/n^2)(w*X*w')
        if(ischar(w))
            w = eval(w);
        end
        w = w(iX);
        
        if( any(ismember(disableLevel,do_x)) )
            Xnew = mean(w .* X);
        else
            Xnew = X;
        end
        if(~mode)
            if( any(ismember(disableLevel,do_Cx)) )
                % make sure weight is row vector
                w = w(:)'; 
                CXnew = (w * Cx * w')./(length(X).^2);
            else
                CXnew = Cx;
            end
        end
% -----------------------------------------------------------                 
    case 'bin'                                                          % Xnew = [BIN(v)]*X
        bins = tStruct.transformParamStruct.binSizes;                   % CXnew = [BIN(v)]*X*[BIN(v)]'
        if(ischar(bins))
            bins = eval(bins);
        end
        % first build the entire matrix        
        M = spalloc(length(bins),sum(bins),sum(bins));
        binIndex = 1;
        for i = 1:length(bins)
            M(i, binIndex:binIndex + bins(i) - 1 ) = 1;                  %#ok<*SPRIX>
            binIndex = binIndex + bins(i);
        end                
        % then select only the indices needed
        M = M(:,iX);
        
        if( any(ismember(disableLevel,do_x)) )
            Xnew = M * X;
        else
            Xnew = X;
        end
        if(~mode)
            if( any(ismember(disableLevel,do_Cx)) )
                CXnew = M * Cx * M';
            else
                CXnew = Cx;
            end
        end
% -----------------------------------------------------------                    
    case 'lsPolyFit' 
        
        % table this one for now 
% -----------------------------------------------------------                
    case 'wPoly'
        polyOrder = tStruct.transformParamStruct.polyOrder;
        w = tStruct.transformParamStruct.scaleORweight;
        if(ischar(w))
            w = eval(w);
        end

        w = w(:);
        
        indVariable = tStruct.transformParamStruct.polyXvector;
        if(ischar(indVariable))
            indVariable = eval(indVariable);
            indVariable = indVariable(:);
        end
        % build polynomial design matrix        
        M = zeros(length(indVariable), polyOrder + 1);
        for i = 1: polyOrder + 1
            M(:,i) = indVariable.^(polyOrder + 1 - i);
        end        
        % weight rows by scaling column-wise with w
        M = scalecol(w, M); 
        
        if( any(ismember(disableLevel,do_x)) )
            Xnew = M * X;
        else
            Xnew = X;
        end
        if(~mode)
            if( any(ismember(disableLevel,do_Cx)) )
                CXnew = M * Cx * M';
            else
                CXnew = Cx;
            end
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
        xInd = tStruct.transformParamStruct.polyXvector;
        
        % convert string input if necessary
        if( ischar(K) )
            K = eval(K);
        end        
        if( ischar(xInd) )
            xInd = eval(xInd);
        end 

        % build design matrix
        M = exp( colvec(xInd) * (1./rowvec(K)) );
        
        if( any(ismember(disableLevel,do_x)) )
            Xnew = M * X;
        else
            Xnew = X;
        end
        if(~mode)
            if( any(ismember(disableLevel,do_Cx)) )
                CXnew = M * Cx * M';
            else
                CXnew = Cx;
            end
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
        Klong       = tStruct.transformParamStruct.scaleORweight(1);
        Kshort      = tStruct.transformParamStruct.scaleORweight(2);
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
        
        % make sure x and mSmearRows are column vectors
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
        
        if( any(ismember(disableLevel,do_x)) )
            Xnew = M * X;
        else
            Xnew = X;
        end
        if(~mode)
            if( any(ismember(disableLevel,do_Cx)) )
                CXnew = M * Cx * M';
            else
                CXnew = Cx;
            end
        end
% -----------------------------------------------------------        
    case 'filter'
        b = tStruct.transformParamStruct.filterCoeffs_b;
        a = tStruct.transformParamStruct.filterCoeffs_a;        
        
% Old code builds full convolution matrix - update to use filter function
% 6/3/08
%         % generate impulse response over original domain
%         imp = impz( b, a, X_primitiveSize );        
%         % build full design matrix M such that M * x = conv( imp, x)
%         M = sparse(convmtx(imp, X_primitiveSize ) );        
%         % select only columns and rows corresponding to indices
%         M = M( iX, iX);
        
        % note that M * x = filter(b,a,x) with M defined as the convolution
        % matrix above. Since x can be a matrix, filter(b,a,Cx) = M * Cx and
        % [filter(b,a,Cx')]' = Cx * M'.
        % Then M * Cx * M' can be written as filter(b,a,[filter(b,a,Cx')]')
        
        
        if( any(ismember(disableLevel,do_x)) )
            Xnew = filter(b,a,X);
        else
            Xnew = X;
        end
        
        % 
        if(~mode)
            if( any(ismember(disableLevel,do_Cx)) )
                if(issparse(Cx))
                    Cx = full(Cx);
                end
                CXnew = filter(b,a,filter(b,a,Cx')');
            else
                CXnew = Cx;
            end
        end
% --------------------------------------------------------------
	case 'FCmodelScale'
%         modelCallString = tStruct.transformParamStruct.FCmodelCall;
%         
%         % do nothing for now
%         w = eval(modelCallString); %#ok<NASGU>
%         
%         M = sparse(iX, iX, 1);
%         
%         Xnew = M * X;
%         if(~mode)
%             CXnew = M * Cx * M';
%         end
% -----------------------------------------------------------        
    case 'FCmodelAdd'
%         modelCallString = tStruct.transformParamStruct.FCmodelCall;      
%         
%         % do nothing for now
%         w = eval(modelCallString); %#ok<NASGU>
%         
%         M = sparse(iX, iX, 1);
%         
%         Xnew = M * X;
%         if(~mode)
%             CXnew = M * Cx * M';
%         end
% -----------------------------------------------------------        
    case 'userM'
        M = tStruct.transformParamStruct.userM;
        if(ischar(M))
            M = eval(tStruct.transformParamStruct.userM);
        end
        
        tempiX = (1:length(X))';
        
        M = M(:,tempiX);
        
      
%        M = M(iX,:);
    
        if( any(ismember(disableLevel,do_x)) )
            Xnew = M * X;
        else
            Xnew = X;
        end
        
        if(~mode)
            if( any(ismember(disableLevel,do_Cx)) )
                CXnew = M * Cx * M';
            else
                CXnew = Cx;
            end
        end
% -----------------------------------------------------------        
    case 'selectIndex'
        iSelect = tStruct.transformParamStruct.xIndices;
        if(ischar(iSelect))
            iSelect = int32(eval(iSelect));
        end
        iSelect = iSelect(:);
        % Find the all elements of iSelect in iX
        % Note that iX is allowed to have repeated values
        validIndices = ismember(iSelect, iX);        
        iSelect = iSelect(validIndices);        
        
        if( any(ismember(disableLevel,do_x)) )
            Xnew = X(iSelect,:);
        else
            Xnew = X;
        end
        
        if(~mode)
            if( any(ismember(disableLevel,do_Cx)) )
                CXnew = Cx(iSelect,iSelect);
            else
                CXnew = Cx;
            end
        end
% -----------------------------------------------------------           
    case 'concatRows'
        if( any(ismember(disableLevel,do_x)) )
            Xnew = [X;Y];
        else
            Xnew = X;
        end
        
        if(~mode)
            if( any(ismember(disableLevel,do_Cx)) )
                CXnew = blkdiag(Cx,Cy);
            else
                CXnew = Cx;
            end
        end
% -----------------------------------------------------------           
    case 'fillRows'
        iSelect = tStruct.transformParamStruct.xIndices;
        if(ischar(iSelect))
            iSelect = int32(eval(iSelect));
        end
        
        iSelect = iSelect(:);
        % find the indices of iSelect in iX
        validIndices = ismember(iSelect, iX);        
        iSelect = iSelect(validIndices);  
                
        Xnew = X;
        if( any(ismember(disableLevel,do_x)) )
            Xnew(iSelect,:) = Y;
        end
        
        if(~mode)
            CXnew = Cx;
            if( any(ismember(disableLevel,do_Cx)) )
                CXnew(iSelect,iSelect) = Cy;
            end
        end
% -----------------------------------------------------------               
    case {'interpLinear', 'interpNearest'}
        if ( strcmp(type, 'interpLinear') )
            METHOD = 'linear';
        else
            METHOD = 'nearest';
        end
        
        % set up indices
        originalIndices = tStruct.transformParamStruct.xIndices;
        if ( ischar(originalIndices) )
            originalIndices = eval(originalIndices);
        end
        originalIndices = originalIndices(iX);
        originalIndices = originalIndices(:);
        
        interpIndices = tStruct.transformParamStruct.polyXvector;
        if ( ischar(interpIndices) )
            interpIndices = eval(interpIndices);
        end
        interpIndices = interpIndices(:);
        
        originalIndices = double(originalIndices);
        interpIndices = double(interpIndices);
     
        
        % perform transform on X and CX if enough data exists to interpolate
        % otherwise copy X and Cx identically to the new indices
        if length(X) > 1
            Xnew = interp1(originalIndices,X,interpIndices,METHOD,'extrap');
            
            
            % perform Jacobian transform on Cx. Note:  J * Cx * J' = J * (J * Cx')'
            % In this case the J = T since T is not a function of the data it
            % is operating on. It is only the incoming and outgoing indices.
            if(~mode)
                if( any(ismember(disableLevel,do_Cx)) )
                    CXnew = interp1(originalIndices,...
                        interp1(originalIndices,Cx',interpIndices,METHOD,'extrap')',...
                        interpIndices,METHOD,'extrap');
                else
                    CXnew = Cx;
                end
            end
            
        else
            if ~isempty(X)
                Xnew(1:length(interpIndices)) = X;
                CXnew(1:length(interpIndices),1:length(interpIndices)) = Cx;
            else
                Xnew = [];
                CXnew = [];
            end
        end
% -----------------------------------------------------------  
    case 'eye'
        Xnew = X;
        if(~mode)
            CXnew = Cx;
        end
% -----------------------------------------------------------        
    otherwise
        disp('Transformation type not available');
end




% % sparsify covariance matrix if not already sparse
% if(~mode)
%     if(~issparse(CXnew))
%         CXnew = sparse(CXnew);
%     end
% end


%             1) scale          ==   scale data by a constant                                  z = c .* x      
%             2) scaleV         ==   scale data by a constant vector                           z = v .* x                       
%             3) addV           ==   add two variable vectors                                  z = x + y    
%             4) diffV          ==   add two variable vectors                                  z = x - y    
%             5) multV          ==   multiply two variable vectors                             z = x .* y
%             6) divV           ==   divide two variable vectors                               z = x ./ y
%             7) wSum           ==   weighted sum of a variable vector                         z = sum(w .* x)
%             8) wMean          ==   weighted mean of a variable vector                        z = mean(sum(w .* x)) 
%             9) bin            ==   bin the elements of a variable vector                     z(i) = sum( x(j:k) )
%             10)lsPolyFit     ==   least squares polynomial fit                               [p, Cp] = lscov(y, x, Cy) 
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
