function tppInputStruct = encircledEnergy(tppInputStruct,varargin)

%	function tppInputStruct = encircledEnergy(tppInputStruct,varargin)
%	
%   This function computes the encircled energy metric for each long
%   cadence in the input structure. It operates on a single module output 
%   for up to one quarter (3 months) of data. The eeRadius is the radius in
%   pixels from a typical target centroid which encloses a user selectable 
%   fraction of the stellar flux. The encircled energy metric, its 
%   uncertainty, fit coefficeints and the associated covariance matrix and
%   the Akieke Information Criteria metric are returned as a time series. 
%   A list of cadence data gaps where there was no solution is also
%   returned. 
%
%   INPUT:  eeTempStruct   (as defined below as 'TEMPORARY DATA STRUCTURE')
%           --------    OR    --------------
%           tppInputStruct
%                   .targetStarStruct()
%                   .encircledEnergyStruct
%                       .polyOrder              int
%                       .eeFraction             float
%                   ---- optional inputs ----
%                       .EE_TARGET_LABEL        string
%                       .MAX_TARGETS            int
%                       .MAX_PIXELS             int
%                       .SEED_RADIUS            float
%                       .MAX_POLY_ORDER         int
%                       .AIC_FRACTION           float
%                       .TARGET_P_ORDER         int
%                       .MAX_RADIUS             float
%                   varargin(1)     = polyOrder;int             
%                   varargin(2)     = eeFraction;float[0:1]     
%                   varargin(3)     = plotOn;boolean            
%
%   OUTPUT: tppInputStruct  = Same tppInputStruct from input plus ...
%                  .encircledEnergyStruct
%                        .eeRadius       = # of cadences x 1;float
%                        .CeeRadius      = # of cadences x 1;float
%                        .polyCoeff      = # of cadences x 1 cell array; nx1; float
%                        .Cpolycoeff     = # of cadences x 1 cell array; nxn; float
%                        .AIC            = # of cadences x 1;float
%                        .eeDataGap      = # of gaps x 1;int
%                        .numEETargets   = # of cadences x 1;int
%
%   See file header for I/O and Function details.
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

%%   FUNCTION OVERVIEW
%   The distances from the target centroids are normalized over all targets simultaneously while the pixel data are normalized
%   on a per target basis. This normalized pixel data as a function of normalized radius is expected to fit a constrained
%   polynomial of order polyOrder + 2, outlined in the DERIVATIVE METHOD (see below). The polynomial fit to the normalized 
%   pixel data is then integrated and the normalized radius at which the integrated pixel data is equal to eeFraction 
%   (typically 0.95) is estimated using an interative search. The uncertainties in the input pixel data are propagated assuming
%   the transformations are locally linear.
%
%     1)  Check input data for necessary fields
%     2)  Build temporary data structure and load constants
%     3)  Determine optimal polynomial order (if option selected)
%     4)  Calculate encircled energy for each cadence
%             a- Stack data in arrays (repackage data)
%             b- Check data validity (e.g. > 0, real, no NaNs, symmetric covariance)
%             c- Normalize and order data
%                 - Normalize radius data over all targets
%                 - Normalize pixel data per target
%                   - Use expected flux from input if available, otherwise fit pixel data to low order 
%                     polynomial and integrate
%                 - Sort data by pixel radius from their respective target centroid
%                 - Renormalize pixel data over all targets together (fine tune normalization)
%                   - Remove outliers
%             d- Fit pixel data to a constrained polynomial using lscov.m
%             e- Integrate the resulting polynomial and determine eeRadius using fzero.m
%             f- Propagate the covariance of the polynomial coeffecients to a covariance in the eeRadius per KADN-26185
%             g- Flag data gaps for cadences where eeRadius could not be calculated 
%     5)  Return calculated values in sub struct of input structure
%

%%  DETAILED I/O
%	INPUT:  Valid tppInputStruct with the following fields:
%           tppInputStruct
%                .encircledEnergyStruct
%                   .polyOrder           = order of polynomial fit; polyOrder = -1 invokes automatic polynomial order
%                                          determination; int
%                   .eeFraction          = float
%                   -------------------- (optional) -----------------------
%                   .EE_TARGET_LABEL   = label in tppInputStruct denoting target to be used for encircled enegry; string
%                   .MAX_TARGETS       = maximum number of targets to process; int
%                   .MAX_PIXELS        = maximum number of pixels per target; int
%                   .SEED_RADIUS       = start fzero search at SEED_RADIUS; float [0,1]
%                   .MAX_POLY_ORDER    = allowed maximum polynomial order; int
%                   .MIN_POLY_ORDER    = allowed minimum polynomial order; int
%                   .AIC_FRACTION      = fraction of cadecences used in automatic polynomial order determination; float  
%                   .TARGET_P_ORDER    = polynomial order used to normalize pixel data on a per target basis; int 
%                   .MAX_RADIUS        = radius from target centroid (in pixels) used as normalization factor. 
%                                        Setting = 0 envokes dynamic normalization.
%                    -------------------- (optional) -----------------------
%                .targetStarStruct()
%                    .labels           = cell array of labels
%                    .expectedFlux     = expected flux from this target; float
%                    .rowCentroid      = computed centroid row
%                    .colCentroid      = computed centroid column
%                    .gapList          = # of gaps x 1 array containing the indices of cadence gaps at the target-level 
%                    .pixelTimeSeriesStruct() = structure for each pixel in target with the following fields
%                        .timeSeries     = # of cadences x 1 array containing pixel brightness time series in electrons
%                        .uncertainties  = # of cadences x 1 array containing pixel uncertainty time series
%                        .row            = row of this pixel
%                        .column         = column of this pixel
%                        .gapList        = # of gaps x 1 array containing the indices of cadence gaps at the pixel-level
%
%           VARIABLE INPUT ARGUMENTS
%           varargin(1) =   If available, polyOrder, order of polynomial used in eeRadius fit. 
%                           If polyOrder = -1 --> invoke polynomial order selection is based on minimizing
%                           the AIC metric for a randomly selected AIC_FRACTION of cadences, then apply that
%                           polyOrder to all other cadences
%           varargin(2) =   If available, eeFraction == fraction of total encircled energy included within eeRadius
%           varargin(3) =   If available, plotOn --> boolean to turn on plots during processing; 1 == turn plots on
%
%   OUTPUT: Same structure that was input with the following fields added:
%           tppInputStruct
%                .encircledEnergyStruct = structure with the following fields
%                    .eeRadius              = # of cadences x 1 array containing encircled energy radius in pixels
%                    .CeeRadius             = # of cadences x 1 array containing encircled energy radius uncertainty
%                    .polyCoeff             = # of cadences x 1 cell array containing polynomial q(x) coeffecients
%                    .Cpolycoeff            = # of cadences x 1 cell array containing polynomial q(x) covariance matrix
%     
%                    .AIC                   = # of cadences x 1 array containing the Akaike Information
%                                             Criterion of the polynomial fit. 
%                                             See http://en.wikipedia.org/wiki/Akaike_information_criterion
%                    .eeDataGap             = # of gaps x 1 array containing indices of cadences where valid encircled
%                                             energy data is not available
%                    .numEETargets          = # of cadences x 1 containing number of valid encircled energy targets

%% TEMPORARY DATA STRUCTURE DEFINTION
%  
%   Input data is repackaged into the following temporary structure for use in this function using the function
%   generate_eeTempStruct_from_tppInputStruct. This is a reordering from multiple arrays of pixel time series to 
%   a time series of pixel arrays for each target.
%
%   eeTempStruct             = structure with the following fields
%       .targetStar()        = # of encircled energy targets x 1 array of structures with the following fields:
%           .expectedFlux       = expected flux from this target; float
%           .gapList()          = # of gaps x 1 int containing the indices of cadence gaps at the target-level
%           .cadence()          = # of cadences x 1 array of structures with the following fields:
%               .pixFlux            = # of pixels x 1 float 
%               .Cpixflux           = # of pixels x 1 float (OR cell array of # of pixels x # of pixels float)
%               .radius             = # of pixels x 1 float
%               .row                = # of pixels x 1 int
%               .col                = # of pixels x 1 int
%               .gapFlag            = # of pixels x 1 boolean indicating cadence gaps at the pixel-level, 1==gap, 0==no gap
%       .encircledEnergyStruct  = structure with the following fields
%            .polyOrder             = polynomial order of q(x) used in constrained fit; int [0,MAX_POLY_ORDER]
%            .eeFraction            = fraction of encircled energy included at eeRadius; float [0,1]
%            .EE_TARGET_LABEL       = label in tppInputStruct denoting target to be used for encircled enegry; string
%            .MAX_TARGETS           = maximum number of targets to process; int
%            .MAX_PIXELS            = maximum number of pixels per target; int
%            .SEED_RADIUS           = start fzero search at SEED_RADIUS; float [0,1]
%            .MAX_POLY_ORDER        = allowed maximum polynomial order; int
%            .MIN_POLY_ORDER        = allowed minimum polynomial order; int
%            .AIC_FRACTION          = fraction of cadecences used in automatic polynomial order determination; float   
%            .TARGET_P_ORDER        = polynomial order used to normalize pixel data on a per target basis; int 
%            .MAX_RADIUS            = radius from target centroid (in pixels) used as normalization factor. Setting = 0 envokes
%                                     dynamic normalization

%% DETAILED FIT METHOD
%  
%   THE DERIVATIVE METHOD
%   The assumed form of the integrated normalized pixel data as a function of normalized radius from the target 
%   centroids is:
%
%   p(x) = (2x - x^2) + x(x-1)^2*q(x)
% 	Subject to constraints:	 p(1)=1, p(0)=p'(1)=0
%                   where:   q(x) = polynomial of degree polyOrder 
%
%   The DERIVATIVE METHOD determines the polynomial q(x) from a weighted least squares fit of the pixel data ( p'(x) ) to the 
%   derivative of assumed integrated form:
%   
%   p'(x) = 2*(1 - x) + [(x - 1)^2 + 2x(x - 1)]q(x) + [x(x - 1)^2]q'(x)
%   
%   The constraints from the integrated level are included automatically by the form of the equation for p'(x).
%   Note that the equation for p'(x) can be re-cast in the following form:
%   Let:    y        = p'(x) - 2*(1 - x)
%           m1Factor = (x - 1).^2 + 2x(x - 1)
%           m2Factor = x(x - 1)^2
%           M1       = [ x.^n    ,      x.^(n-1), ..., x , 1]
%           M2       = [nx.^(n-1), (n-1)x.^(n-2), ..., 1 , 0]
%
%   Then:   y        =  ( m1Factor x M1 + m2Factor x M2 ) * [qn, q(n-1), ... , q0]'
%
%   where x     == scaling of each column of the subsequent matrix by the m*Factor column vector
%         *     == usual MATLAB matrix multiplication
%         n     == q polynomial order  
%         qi's  == q polynomial coeffecients, i=[0:n]
%
%   Also note that the original equation for the integrated normalized pixel data as a function of normalized radius can 
%   now be written as:  z = m2Factor x M1 * [qn, q(n-1), ... , q0]', where z == p(x) - (2x - x^2)
%   The form of this design matrix (M1) and prefactor (m2factor) may be
%   used later when propagating the parameter covariance to the uncertainty in encircled energy radius.



%% 1) CHECK INPUT DATA FOR NECESSARY FIELDS and 2) BUILD TEMPORARY DATA STRUCTURE AND LOAD CONSTANTS

%disp(mfilename('fullpath'));

arglist = cell2mat(varargin);
[eeTempStruct, errorFlag] = generate_eeTempStruct_from_tppInputStruct(tppInputStruct,arglist);
if(errorFlag == 1)
    errString = 'Error in input data structure';
    msgString = ['PA:',mfilename,':generate_eeTempStruct_from_tppInputStruct:tppInputStruct incomplete'];
    error( msgString, errString );
end

% check for empty target list, determine number of cadences
if( ~isempty(eeTempStruct.targetStar))
    numCadence = length(eeTempStruct.targetStar(1).cadence);
else
    error(['PA:',mfilename],'eeTempStruct.targetStar empty - no EE_TARGETS selected');    
end

%% 3)  AUTOMATICALLY DETERMINE OPTIMAL POLYNOMIAL ORDER IF OPTION IS SELECTED 

eeTempStruct.encircledEnergyStruct.polyOrder = find_minimum_AIC_polyorder(eeTempStruct);

%% 4)  CALCULATE ENCIRCLED ENERGY METRIC FOR EACH CADENCE

disp(['Calculating encircled energy metric for ',num2str(numCadence),' cadences...']);

% pre-allocate array space
eeRadius    = zeros(numCadence,1);              
CeeRadius   = zeros(numCadence,1);
polyCoeff   = cell(numCadence,1);
CpolyCoeff  = cell(numCadence,1);
AIC         = zeros(numCadence,1);
nTargets    = zeros(numCadence,1);
eeDataGap   = [];

firstPlotDone   = false;
close all;

for iCadence=1:numCadence

    dataStruct      = package_ee_pixel_data( iCadence, eeTempStruct );
    cadenceGapFlag  = ~valid_ee_data( dataStruct, iCadence );

    if(~cadenceGapFlag)        
        [ dataStruct, cadenceGapFlag ] = ...
            normalize_and_order_pixel_data_by_radius( dataStruct, eeTempStruct.encircledEnergyStruct );
    end
 
    if(~cadenceGapFlag) 
        [ cadenceGapFlag, M ] =...
            build_ee_design_matrix( dataStruct.radius, eeTempStruct.encircledEnergyStruct.polyOrder );        
    end

    if(~cadenceGapFlag)
        dataStruct =...
            find_eeRadius_from_polynomial_fit( M, dataStruct, eeTempStruct.encircledEnergyStruct );        
        firstPlotDone =...
            plot_fitted_data(dataStruct, eeTempStruct.encircledEnergyStruct, firstPlotDone );        
    end
    
    if( cadenceGapFlag )
        eeDataGap = [eeDataGap; iCadence];          %#ok<AGROW>
        dataStruct.q     = [];
        dataStruct.S     = [];
        dataStruct.r0    = 0;
        dataStruct.Cr0   = 0;
        dataStruct.maxR  = 1;
        dataStruct.aic   = 0;        
    end
    
    % convert to units of pixels and save results
    eeRadius(iCadence)      = dataStruct.r0  * dataStruct.maxR;
    CeeRadius(iCadence)     = dataStruct.Cr0 * dataStruct.maxR;
    polyCoeff{iCadence}     = dataStruct.q;
    CpolyCoeff{iCadence}    = dataStruct.S;
    AIC(iCadence)           = dataStruct.aic;
    nTargets(iCadence)      = dataStruct.okTarget - 1;
   
end


if(eeTempStruct.encircledEnergyStruct.PLOTS_ON)         % close plots
    close all; 
end     


%% 5) RETURN CALCULATED VALUES IN SUBSTRUCT OF INPUT STRUCTURE

% check for reasonableness - set cadence data gap where unreasonable
eeReasonGap = find(eeRadius <= 0 | CeeRadius <= 0);
eeDataGap = union(eeDataGap, eeReasonGap);

% set output
tppInputStruct.encircledEnergyStruct.eeRadius     = eeRadius(:);
tppInputStruct.encircledEnergyStruct.CeeRadius    = CeeRadius(:);
tppInputStruct.encircledEnergyStruct.polyCoeff    = polyCoeff(:);
tppInputStruct.encircledEnergyStruct.CpolyCoeff   = CpolyCoeff;
tppInputStruct.encircledEnergyStruct.AIC          = AIC(:);
tppInputStruct.encircledEnergyStruct.eeDataGap    = eeDataGap(:);
tppInputStruct.encircledEnergyStruct.numEETargets = nTargets(:);

