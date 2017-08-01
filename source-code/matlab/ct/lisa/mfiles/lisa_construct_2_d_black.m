function lisa_construct_2_d_black( lisa2DBlackInputStruct, requestedTemperature )
%
% lisa_construct_2_d_black -- construct a 2-D black via the LISA process
%
% lisa_construct_2_d_black( lisa2DBlackInputStruct ) combines a set of temperature
%    coefficients (in DN/read/degC) with a set of temperature-independent black values to
%    produce a projected 2-D black at a given temperature, including uncertainty
%    propagation.  The inputs are as follows:
%
%    lisa2DBlackInputStruct:  structure with the following fields:
%    
%       dcOffsetFileDir:           directory for the files of DC offset values
%       tempCoefficientFileDir:    directory for the file of temperature coefficients
%       tempCoefficientFileName:   name of the temperature coefficient mat file
%       clockStateMaskDir:         directory of clock state mask FITS file
%       clockStateMaskFile:        file name of clock state mask FITS file
%       channelList:               list of channel numbers (1-84) to compute
%       twoDBlackFileDir:          directory for deposition of outputs
%       dcOffsetTemperature:       temperature (in degC) at which the DC offsets were
%                                  measured
%       scaleErrorsWithMse:        flag indicating that estimated uncertainties in the
%                                  temperature coefficients should be scaled by
%                                  sqrt(weighted MSE), or should not be.
%
%    requestedTemperature:  scalar, temperature at which the 2-d black is to be determined
%
% lisa_construct_2_d_black proceeds to produce files for the 2-d black estimation, which
%    are saved to the location in lisa2DBlackInputStruct.twoDBlackFileDir.  It also
%    produces figures showing the image of the 2-d black and the estimated uncertainty on
%    same, which are also saved to the same directory (in a figures subdir).
%
% Version date:  2009-March-24.
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

% Modification History:
%
%=========================================================================================

% parameter definition -- serial transfer pixels have a value of 96 in the crosstalk map

  fgsSerialPixelValue = 96 ;

% compute deltaT, the temperature offset between requested and the temperature of the DC
% values

  deltaT = requestedTemperature - lisa2DBlackInputStruct.dcOffsetTemperature ;
  
% construct some local variables

  dcOffsetFileDir = lisa2DBlackInputStruct.dcOffsetFileDir ;
  clockStateMaskFile = lisa2DBlackInputStruct.clockStateMaskFile ;
  twoDBlackFileDir = lisa2DBlackInputStruct.twoDBlackFileDir ;
  figureDir = [twoDBlackFileDir,'/figures'] ;
  scaleErrorsWithMse = lisa2DBlackInputStruct.scaleErrorsWithMse ;
  
% load the thermal coefficient structure -- the struct should be "lisaOutputStructArray"

  load( fullfile( lisa2DBlackInputStruct.tempCoefficientFileDir, ...
                  lisa2DBlackInputStruct.tempCoefficientFileName ) ) ;
  
% obtain the clock state mask

  currentDir = pwd ;
  cd( lisa2DBlackInputStruct.clockStateMaskDir ) ;
  xTalkOutputStruct = read_crosstalk_fits_file( clockStateMaskFile ) ;
  cd(currentDir) ;
    
% loop over requested module outputs

  for iChannel = lisa2DBlackInputStruct.channelList
          
      [ccdModule,ccdOutput] = convert_to_module_output(iChannel) ;
          
%     load the DC component of the model from its file -- the filename is given by
%     "twoDBlack_" followed by channel #

      twoDBlackFilename = ['twoDBlack_',num2str(iChannel),'.mat'] ;
      load( fullfile( dcOffsetFileDir, twoDBlackFilename ) ) ;
          
%     extract the DC component and its uncertainty and store them in local variables

      projected2DBlack = twoDBlack.blacks ;
      sigmaProjected2DBlack = twoDBlack.deltaBlacks ;
          
%     tile the FGS crosstalk pixel thermal effects onto the pixels according to the
%     pixel map

      [projected2DBlack, sigmaProjected2DBlack] = tile_pixel_families_onto_black( ...
          projected2DBlack, sigmaProjected2DBlack, ...
          xTalkOutputStruct.fgsXtalkIndexImage, ...
          xTalkOutputStruct.fgsParallelPixelValues, ...
          lisaOutputStructArray(iChannel).parallelPixelFamily, ...
          deltaT, scaleErrorsWithMse ) ;
          
      [projected2DBlack, sigmaProjected2DBlack] = tile_pixel_families_onto_black( ...
          projected2DBlack, sigmaProjected2DBlack, ...
          xTalkOutputStruct.fgsXtalkIndexImage, ...
          xTalkOutputStruct.fgsFramePixelValues, ...
          lisaOutputStructArray(iChannel).frameTransferPixelFamily, ...
          deltaT, scaleErrorsWithMse ) ;
          
      [projected2DBlack, sigmaProjected2DBlack] = tile_pixel_families_onto_black( ...
          projected2DBlack, sigmaProjected2DBlack, ...
          xTalkOutputStruct.fgsXtalkIndexImage, ...
          fgsSerialPixelValue, ...
          lisaOutputStructArray(iChannel).serialPixelFamily, ...
          deltaT, scaleErrorsWithMse ) ;
          
%     display the projected black and the projected uncertainty as images on 1 figure, and
%     save them -- note that we need to scale the black image to leave out the first
%     column (start-of-line ringing), and flyers have to be managed in scaling as well; 
%     the RMS image scaling has to use median scaling to filter out outliers in general 

      if (exist('thisFigure') && ishandle(thisFigure))
          close(thisFigure) ;
      end
      figure('position',[100 100 600 800]) ;
      thisFigure = gcf ;
      subplot(2,1,1)
      sortedProjected2DBlack = sort(projected2DBlack(:)) ;
      minScale = sortedProjected2DBlack(floor(0.01*length(sortedProjected2DBlack))) ; 
      maxScale = sortedProjected2DBlack(floor(0.99*length(sortedProjected2DBlack))) ;
      imagesc(projected2DBlack,[minScale maxScale]) ;
      set(gca,'YDir','normal') ;
      colormap hot
      colorbar
      title(['Projected 2D Black mod ',num2str(ccdModule),' out ', ...
          num2str(ccdOutput),' at ',num2str(requestedTemperature),' degC']) ;
      subplot(2,1,2) 
      minScale = min(sigmaProjected2DBlack(:)) ;
      maxScale = median(sigmaProjected2DBlack(:)) + 10*mad(sigmaProjected2DBlack(:),1) ;
      imagesc(sigmaProjected2DBlack,[minScale maxScale]) ;
      set(gca,'YDir','normal') ;
      colormap hot ;
      colorbar ;
      title(['Projected Error in 2D Black mod ',num2str(ccdModule),' out ', ...
          num2str(ccdOutput),' at ',num2str(requestedTemperature),' degC']) ;
      saveas(thisFigure,[figureDir,'/projected2Dblack_m',num2str(ccdModule,'%02d'), ...
          '_o',num2str(ccdOutput),'.fig']) ;
      pause(10) ;
          
%     construct a data structure with all the information in it and save it

      twoDBlackStruct.module = ccdModule ;
      twoDBlackStruct.output = ccdOutput ;
      twoDBlackStruct.requestedTemperature = requestedTemperature ;
      twoDBlackStruct.projected2DBlack = projected2DBlack ;
      twoDBlackStruct.sigmaProjected2DBlack = sigmaProjected2DBlack ;

      structFileName = ['twoDBlackStruct_m',num2str(ccdModule,'%02d'), ...
          '_o',num2str(ccdOutput,'%d'),'.mat'] ;
      save( fullfile(twoDBlackFileDir,structFileName), 'twoDBlackStruct' ) ;
          
  end % loop over channels
          
return

% and that's it!

%
%
%

%=========================================================================================

% subfunction which performs the actual tiling operation

function [projected2DBlack, sigmaProjected2DBlack] = tile_pixel_families_onto_black( ...
          projected2DBlack, sigmaProjected2DBlack, ...
          fgsXtalkIndexImage, ...
          fgsXtalkValueVector, ...
          pixelFamilyStruct, ...
          deltaT, scaleErrorsWithMse ) 
      
% convert the projected 2-d black sigmas to variances

  varianceProjected2DBlack = sigmaProjected2DBlack.^2 ;
  
% convert from images to vectors

  varianceProjected2DBlack = varianceProjected2DBlack(:) ;
  projected2DBlack = projected2DBlack(:) ;
  fgsXtalkIndexImage = fgsXtalkIndexImage(:) ;
      
% loop over the pixel families -- there may be some vectorizable way to do this, but I'm
% too stupid to figure out what it is!

  for iPixel = 1:length(pixelFamilyStruct)
      
%     find all of the pixels which correspond to the family which is referenced

      thisPixelFamilyIndex = fgsXtalkValueVector(iPixel) ;
      pixelPointer = find(fgsXtalkIndexImage == thisPixelFamilyIndex) ;
      
%     apply the temperature coefficient to the 2-D blacks

      projected2DBlack(pixelPointer) = projected2DBlack(pixelPointer) + ...
          deltaT * pixelFamilyStruct(iPixel).meanTemperatureCoefficient ;
      
%     apply the additional variance term

      thisPixelFamilyVariance = pixelFamilyStruct(iPixel).sigmaMeanTemperatureCoefficient^2 ;
      if ( scaleErrorsWithMse )
          thisPixelFamilyVariance = thisPixelFamilyVariance * ...
              pixelFamilyStruct(iPixel).weightedMse ;
      end
      varianceProjected2DBlack(pixelPointer) = varianceProjected2DBlack(pixelPointer) ...
          + thisPixelFamilyVariance * deltaT^2 ;
      
  end % loop over pixel family types
  
% convert the vectors back to images, and the variance back to a sigma

  projected2DBlack = reshape(projected2DBlack, size(sigmaProjected2DBlack) ) ;
  sigmaProjected2DBlack = reshape( sqrt(varianceProjected2DBlack), ...
      size(sigmaProjected2DBlack) ) ;
  
return

% and that's it!

%
%
%
