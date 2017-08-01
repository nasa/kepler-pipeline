/*
 * Copyright 2017 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 * 
 * This file is available under the terms of the NASA Open Source Agreement
 * (NOSA). You should have received a copy of this agreement with the
 * Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
 * 
 * No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
 * WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
 * INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
 * WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
 * INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
 * FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
 * TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
 * CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
 * OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
 * OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
 * FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
 * REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
 * AND DISTRIBUTES IT "AS IS."
 *
 * Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
 * AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
 * SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
 * THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
 * EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
 * PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
 * SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
 * STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
 * PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
 * REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
 * TERMINATION OF THIS AGREEMENT.
 */


#include "CalController.h"

#include "libcal.h"

#include <iostream>
#include <vector>

CalController::CalController(){
}

CalController::~CalController(){
}

int CalController::doScience(CalInputs& inputs, CalOutputs& outputs) {

    // Call application and library initialization. Perform this 
    // initialization before calling any API functions or
    // Compiler-generated libraries.
    if (!mclInitializeApplication(NULL,0)){
        std::cerr << "could not initialize the application properly"
            << std::endl;
        return -1;
    }

    if( !libcalInitialize() ){
        std::cerr << "could not initialize the library properly"
            << std::endl;
        return -1;
    }

	int nCadences = inputs.pixelValue.size();
    int nPixels   = inputs.pixelValue[0].size();
    int nSmears   = inputs.maskSmearValue[0].size();
        
    float* allPixelsArray           = new float[nCadences*nPixels];
    float* allMaskedSmearArray      = new float[nCadences*nSmears];
    float* allVirtualSmearArray     = new float[nCadences*nSmears];
    float *allCalibratedPixelsArray = new float[nCadences*nPixels];

    try{

        // Convert the input vector data into arrays:
        //
        for (    int iTime = 0; iTime < nCadences; ++iTime) {
        	// Get pixels:
        	for (int iPix  = 0; iPix  < nPixels;   ++iPix) {
        		allPixelsArray[iTime*nCadences+iPix] = inputs.pixelValue[iTime][iPix];
	        }
	        // Get smears:
	        for (int iSmear = 0; iSmear < nSmears;   ++iSmear) {
        		allMaskedSmearArray[ iTime*nCadences+iSmear] = inputs.maskSmearValue[   iTime][iSmear];
        		allVirtualSmearArray[iTime*nCadences+iSmear] = inputs.virtualSmearValue[iTime][iSmear];
        	}    
        }
        

        // create inputs with the correct sizes and dimensions:
        //
		mwArray _crCorrectionFlag(          1,         1,       mxDOUBLE_CLASS, mxREAL);
		mwArray _nonlinearityCorrectionFlag(1,         1,       mxDOUBLE_CLASS, mxREAL);
		mwArray _flatFieldCorrectionFlag(   1,         1,       mxDOUBLE_CLASS, mxREAL);
        mwArray _pixelValue(                nCadences, nPixels, mxDOUBLE_CLASS, mxREAL);
        mwArray _pixelRow(                  nPixels,   1,       mxDOUBLE_CLASS, mxREAL);
        mwArray _pixelColumn(               nPixels,   1,       mxDOUBLE_CLASS, mxREAL);
		mwArray _maskedSmearValue(          nCadences, nSmears, mxDOUBLE_CLASS, mxREAL);
        mwArray _maskedSmearColumn(         nSmears,   1,       mxDOUBLE_CLASS, mxREAL);
        mwArray _virtualSmearValue(         nCadences, nSmears, mxDOUBLE_CLASS, mxREAL);
        mwArray _virtualSmearColumn(        nSmears,   1,       mxDOUBLE_CLASS, mxREAL);
        mwArray _linearity(                 nCadences, 5,       mxDOUBLE_CLASS, mxREAL); // 5 is a guess
        mwArray _flatField(                 nCadences, nPixels, mxDOUBLE_CLASS, mxREAL);
        mwArray _ccdModule(                 1,         1,       mxDOUBLE_CLASS, mxREAL);
		mwArray _ccdOutput(                 1,         1,       mxDOUBLE_CLASS, mxREAL);
		mwArray _startCadence(              1,         1,       mxDOUBLE_CLASS, mxREAL);
		mwArray _endCadence(                1,         1,       mxDOUBLE_CLASS, mxREAL);
		mwArray _cadenceType(               1,         1,       mxDOUBLE_CLASS, mxREAL);
		mwArray _crThreshold(               1,         1,       mxDOUBLE_CLASS, mxREAL);
		
                
        // populate input matricies:
        //
        _pixelValue.SetData(        allPixelsArray,                  nPixels);
        _pixelRow.SetData(          &inputs.pixelRow[0],             inputs.pixelRow.size());
        _pixelColumn.SetData(       &inputs.pixelColumn[0],          inputs.pixelColumn.size());
        _maskedSmearValue.SetData(  allMaskedSmearArray,             nSmears);
        _maskedSmearColumn.SetData( &inputs.smearColumn[0],          inputs.smearColumn.size());
        _virtualSmearValue.SetData( allVirtualSmearArray,            nSmears);
        _virtualSmearColumn.SetData(&inputs.smearColumn[0],          inputs.smearColumn.size());
        _linearity.SetData(         &inputs.linearity[0][0],         inputs.linearity.size());
        _flatField.SetData(         &inputs.flatField[0][0],         inputs.flatField.size());
        _ccdModule.SetData(         &inputs.ccdModule,               1);
        _ccdOutput.SetData(         &inputs.ccdOutput,               1);
        
		// populate input scalars:
        //
		_startCadence               = inputs.cadenceStart;
        _endCadence                 = inputs.cadenceEnd;
        _cadenceType                = inputs.cadenceType;
        _crThreshold                = inputs.crThreshold;
        _crCorrectionFlag           = inputs.crCorrectionFlag;
		_nonlinearityCorrectionFlag = inputs.linearityCorrectionFlag;
		_flatFieldCorrectionFlag    = inputs.flatFieldCorrectionFlag;
		
        // create outputs
        //
        mwArray _calibratedPixelValue;
        mwArray _collateralCosmicRayCorrectionValue;
        mwArray _collateralCosmicRayRow;
        mwArray _collateralCosmicRayColumn;        
		
        // invoke MATLAB function
        //
        cal_module(
            // number of outputs 
            3,

            //outputs    
            _calibratedPixelValue,
            _collateralCosmicRayCorrectionValue,
            _collateralCosmicRayRow,

	        //inputs
	        _crCorrectionFlag,
			_nonlinearityCorrectionFlag,
			_flatFieldCorrectionFlag,
            _pixelValue,
            _pixelRow,
            _pixelColumn,
            _maskedSmearValue,
            _maskedSmearColumn, 
            _virtualSmearValue,
            _virtualSmearColumn, 
            _linearity,
            _flatField,
            _ccdModule,
            _ccdOutput,
            _startCadence,
            _endCadence, 
            _cadenceType, 
            _crThreshold
        );

        // store outputs
        //
        std::vector< std::vector< float >  > allCalibratedPixels = outputs.pixelValue;
        int nn = 0;
        for     (int ii = 0; ii < nCadences;  ++ii) {
        	for (int jj = 0; jj < nPixels;    ++jj) {
        		allCalibratedPixelsArray[nn++] = allCalibratedPixels[ii][jj]; 
        	}
        }
                
        _calibratedPixelValue.GetData(              allCalibratedPixelsArray,                     nCadences*nPixels);
        _collateralCosmicRayCorrectionValue.GetData(&outputs.crCleanedMaskSmearPixelValue[0][0],  outputs.crCleanedMaskSmearPixelValue.size());
        _collateralCosmicRayRow.GetData(            &outputs.crCleanedMaskSmearPixelColumn[0][0], outputs.crCleanedMaskSmearPixelColumn.size());
    } catch (const mwException& e){
        std::cerr << e.what() << std::endl;
        return -2;
    }catch (...){
        std::cerr << "Unexpected error thrown" << std::endl;
        return -3;
    }
    
    delete allPixelsArray;
    delete allMaskedSmearArray;
    delete allVirtualSmearArray;
    delete allCalibratedPixelsArray;

    // Call the application and library termination routine
    libcalTerminate();


  
    mclTerminateApplication();
    return 0;
}
