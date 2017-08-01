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


#include "CoaController.h"

#include "libcoa.h"

#include <iostream>

#define _DEBUG_DISPLAY 1

CoaController::CoaController(){
}

CoaController::~CoaController(){
}


int CoaController::doScience( CoaInputs& inputs, CoaOutputs& outputs ){

	// Call application and library initialization. Perform this 
	// initialization before calling any API functions or
	// Compiler-generated libraries. 
	// mclInitializeApplication returns a Boolean status code. 
	// A return value of true indicates successful initialization, and false indicates failure.
	
	// mclInitializeApplication allows you to Set the global MCR options.
	// They apply equally to all MCR instances. You must Set these options before 
	// creating your first MCR instance.
	// These functions are necessary because some MCR options such as whether or not to start Java, 
	// the location of the MCR itself, whether or not to use the MATLAB JIT feature, and so on, 
	// are Set when the first MCR instance starts and cannot be changed by subsequent instances of the MCR.		
	// always use this code for failure to initialize the application
		
	if (!mclInitializeApplication(NULL,0)) 
	{
		outputs.errorCode = 2000;
		outputs.errorText = "TAD CSCI:CoaController::doScience - could not initialize mclInitializeApplication ";
		std::cerr << outputs.errorText << std::endl;
		return outputs.errorCode;
	}
#if _DEBUG_DISPLAY
	std::cout << "completed mclInitializeApplication" << std::endl;
#endif

	if( !libcoaInitialize() )
	{
		outputs.errorCode = 2001;
		outputs.errorText = "TAD CSCI:CoaController::doScience - could not initialize librequantization library ";
		std::cerr << outputs.errorText << std::endl;
		return outputs.errorCode;
	}

#if _DEBUG_DISPLAY
	std::cout << "completed libcoaInitialize" << std::endl;
#endif
	try{
		computeOptimalApertures(inputs, outputs);
		outputs.errorCode = 0;
		outputs.errorText = "TAD CSCI:CoaController::doScience - SUCCESS";
	}catch (const mwException& e){
		outputs.errorCode = 2002;
		outputs.errorText = "TAD CSCI:CoaController::doScience - computeOptimalApertures method failed\n ";
		outputs.errorText.append(e.what());
		std::cerr << outputs.errorText << std::endl;
		return outputs.errorCode;
	}catch (...){
		outputs.errorCode = 9999;
		outputs.errorText = "TAD CSCI:CoaController::doScience - generateRequantizationTable method failed\n ";
		outputs.errorText.append("Unexpected error thrown");
		std::cerr << outputs.errorText << std::endl;
		return outputs.errorCode;
	}

	// Call the application and library termination routine
	libcoaTerminate();

	mclTerminateApplication();
	return 0;
}

int CoaController::computeOptimalApertures( CoaInputs& inputs, CoaOutputs& outputs ){
	int entryNum;

#if _DEBUG_DISPLAY
	std::cout << "inside doScience" << std::endl;
#endif

	//-----------------------------------------------------------------------------------
	// create input Matlab mwArrays
	//-----------------------------------------------------------------------------------
	// create input mwArrays
	// scalar objects
	mwArray _ccdModule(1,1, mxDOUBLE_CLASS, mxREAL);
	mwArray _ccdOutput(1,1, mxDOUBLE_CLASS, mxREAL);
	mwArray _duration(1,1, mxDOUBLE_CLASS, mxREAL);
	mwArray _computeOptimalsForAllKicPeers(1,1, mxDOUBLE_CLASS, mxREAL);
	mwArray _debug(1,1, mxDOUBLE_CLASS, mxREAL);
	mwArray _wellCapacity(1,1, mxDOUBLE_CLASS, mxREAL);
	mwArray _saturationSpillUpFraction(1,1, mxDOUBLE_CLASS, mxREAL);
	mwArray _flux12(1,1, mxDOUBLE_CLASS, mxREAL);
	mwArray _longCadenceTime(1, 1, mxDOUBLE_CLASS, mxREAL);
	mwArray _integrationTime(1, 1, mxDOUBLE_CLASS, mxREAL);
	mwArray _transferTime(1, 1, mxDOUBLE_CLASS, mxREAL);
	mwArray _exposuresPerLongCadence(1, 1, mxDOUBLE_CLASS, mxREAL);
	mwArray _parallelCte(1, 1, mxDOUBLE_CLASS, mxREAL);
	mwArray _serialCte(1, 1, mxDOUBLE_CLASS, mxREAL);
	mwArray _readNoiseSquared(1, 1, mxDOUBLE_CLASS, mxREAL);
	mwArray _quantizationNoiseSquared(1, 1, mxDOUBLE_CLASS, mxREAL);
	
	mwArray _dvaMeshEdgeBuffer(1, 1, mxDOUBLE_CLASS, mxREAL);
	mwArray _dvaMeshOrder(1, 1, mxDOUBLE_CLASS, mxREAL);
	mwArray _nDvaMeshRows(1, 1, mxDOUBLE_CLASS, mxREAL);
	mwArray _nDvaMeshCols(1, 1, mxDOUBLE_CLASS, mxREAL);
	mwArray _nOutputBufferPix(1, 1, mxDOUBLE_CLASS, mxREAL);
	mwArray _nStarImageRows(1, 1, mxDOUBLE_CLASS, mxREAL);
	mwArray _nStarImageCols(1, 1, mxDOUBLE_CLASS, mxREAL);
	mwArray _starChunkLength(1, 1, mxDOUBLE_CLASS, mxREAL);
	// string object
	mwArray _startTime(1, inputs.startTime.size(), mxCHAR_CLASS);

#if _DEBUG_DISPLAY
	std::cout << "allocated mwArrays" << std::endl;
#endif
	
	double short_duration = 1.0;
	// now populate that data with the input objects
	_ccdModule.SetData(&inputs.ccdModule,1);
	_ccdOutput.SetData(&inputs.ccdOutput,1);
	_duration.SetData(&inputs.duration,1);
//	_duration.SetData(&short_duration,1);
	int _computeOptimalsForAllKic = (int) inputs.computeOptimalsForAllKicPeers;
	_computeOptimalsForAllKicPeers.SetData(&_computeOptimalsForAllKic,1);
	_debug.SetData(&inputs.debug,1);
	
	_wellCapacity.SetData(&inputs.wellCapacity,1);
	_saturationSpillUpFraction.SetData(&inputs.saturationSpillUpFraction,1);
	_flux12.SetData(&inputs.flux12,1);
	_longCadenceTime.SetData(&inputs.longCadenceTime,1);
	_integrationTime.SetData(&inputs.integrationTime,1);
	_transferTime.SetData(&inputs.transferTime,1);
	_exposuresPerLongCadence.SetData(&inputs.exposuresPerLongCadence,1);
	_parallelCte.SetData(&inputs.parallelCte,1);
	_serialCte.SetData(&inputs.serialCte,1);
	_readNoiseSquared.SetData(&inputs.readNoiseSquared,1);
	_quantizationNoiseSquared.SetData(&inputs.quantizationNoiseSquared,1);
	
	_dvaMeshEdgeBuffer.SetData(&inputs.dvaMeshEdgeBuffer,1);
	_dvaMeshOrder.SetData(&inputs.dvaMeshOrder,1);
	_nDvaMeshRows.SetData(&inputs.nDvaMeshRows,1);
	_nDvaMeshCols.SetData(&inputs.nDvaMeshCols,1);
	_nOutputBufferPix.SetData(&inputs.nOutputBufferPix,1);
	_nStarImageRows.SetData(&inputs.nStarImageRows,1);
	_nStarImageCols.SetData(&inputs.nStarImageCols,1);
	_starChunkLength.SetData(&inputs.starChunkLength,1);
	
#if _DEBUG_DISPLAY
	std::cout << "set scalar values" << std::endl;
#endif
	
	// string object
	_startTime.SetData(&inputs.startTime[0],inputs.startTime.size());	
	
#if _DEBUG_DISPLAY
	std::cout << "set string values to " << inputs.startTime << std::endl;
#endif

	//-----------------------------------------------------------------------------------
	// create array of KIC structures
	//-----------------------------------------------------------------------------------

	// we need to create an array of matlab structures, each entry of which has the following
	// fields from the input array of structures.
	// happily the inputs and matlab structures are parallel in this case.
	const char* _kicInputDataFields[] =
		{ "KICID", 
			"RA",
			"dec",
			"magnitude",
		};
		
	// get the number of entries in the input array
	int nKicEntries = inputs.kicPeers.size();
//	int nKicEntries = 10;
	
	// allocate the mwArray for the require matlab structure
	mwArray _kicStruct(1, nKicEntries, sizeof(_kicInputDataFields)/sizeof(char*), 
		_kicInputDataFields);
		
	// fill the matlab structure from the inputs one entry at a time
	for (int kicEntry=0; kicEntry<nKicEntries; kicEntry++) {
		// first allocate the scalar mwArrays for this entries' field
		mwArray _kicID(1, 1, mxDOUBLE_CLASS, mxREAL);
		mwArray _RA(1, 1, mxDOUBLE_CLASS, mxREAL);
		mwArray _dec(1, 1, mxDOUBLE_CLASS, mxREAL);
		mwArray _magnitude(1, 1, mxDOUBLE_CLASS, mxREAL);

		// fill those mwArrays from the inputs
		_kicID.SetData(&inputs.kicPeers[kicEntry].kicId,1);
		_RA.SetData(&inputs.kicPeers[kicEntry].ra,1);
		_dec.SetData(&inputs.kicPeers[kicEntry].dec,1);
		_magnitude.SetData(&inputs.kicPeers[kicEntry].magnitude,1);

		// set the matlab mwArray structure entries from the scalar mwArray objects
		// use .Clone() to make sure it's a copy, not a reference
		_kicStruct("KICID",1,kicEntry+1) = _kicID.Clone();
		_kicStruct("RA",1,kicEntry+1) = _RA.Clone();
		_kicStruct("dec",1,kicEntry+1) = _dec.Clone();
		_kicStruct("magnitude",1,kicEntry+1) = _magnitude.Clone();
	}
	
#if _DEBUG_DISPLAY
	std::cout << "built _kicStruct" << _kicStruct << std::endl;
#endif
	
 	//-----------------------------------------------------------------------------------
	// create the input target list
	//-----------------------------------------------------------------------------------
	// fill in the 1 x n matlab array of target kepler IDs from the input structure  array coaTargetPeers
	// which has the field .keplerId.  In this case the data structures are not parallel and we
	// need to assemble a matlab array by pulling the .keplerId field from the input structure
	// array.
	
	// get the number of indices in the input array
	int nTargets = inputs.coaTargetPeers.size();
	// create a temporary 1 x n array for storing the target id list
	int *inputTargetList = new int[nTargets];
	// fill in the temporary array
	for (int t=0; t<nTargets; t++) {
		inputTargetList[t] = inputs.coaTargetPeers[t].keplerId;
	}
	// create the matlab 1 x n mwArray 
	mwArray _targetKeplerIDList(1,nTargets, mxDOUBLE_CLASS, mxREAL);
	// fill in the mwArray using the temporary array
	_targetKeplerIDList.SetData(inputTargetList,nTargets);
	
	delete inputTargetList;
#if _DEBUG_DISPLAY
	std::cout << "built _targetKeplerIDList" << std::endl;
#endif

	//-----------------------------------------------------------------------------------
	//-----------------------------------------------------------------------------------
	// the following three sections create matlab structures, each of which contain several
	// scalar fields as described by the char* arrays at the start of each section
	//-----------------------------------------------------------------------------------
	//-----------------------------------------------------------------------------------

	//-----------------------------------------------------------------------------------
	// create input pixel model structure
	//-----------------------------------------------------------------------------------
	const char* _pixelModelInputDataFields[] =
		{ "wellCapacity", 
			"saturationSpillUpFraction",
			"flux12",
			"longCadenceTime",
			"integrationTime",
			"transferTime",
			"exposuresPerLongCadence",
			"parallelCTE",
			"serialCTE",
			"readNoiseSquared",
			"quantizationNoiseSquared",
		};

	mwArray _pixelModelStruct(1, 1, sizeof(_pixelModelInputDataFields)/sizeof(char*), 
		_pixelModelInputDataFields);
		
	_pixelModelStruct("wellCapacity",1,1) = _wellCapacity;
	_pixelModelStruct("saturationSpillUpFraction",1,1) = _saturationSpillUpFraction;
	_pixelModelStruct("flux12",1,1) = _flux12;
	_pixelModelStruct("longCadenceTime",1,1) = _longCadenceTime;
	_pixelModelStruct("integrationTime",1,1) = _integrationTime;
	_pixelModelStruct("transferTime",1,1) = _transferTime;
	_pixelModelStruct("exposuresPerLongCadence",1,1) = _exposuresPerLongCadence;
	_pixelModelStruct("parallelCTE",1,1) = _parallelCte;
	_pixelModelStruct("serialCTE",1,1) = _serialCte;
	_pixelModelStruct("readNoiseSquared",1,1) = _readNoiseSquared;
	_pixelModelStruct("quantizationNoiseSquared",1,1) = _quantizationNoiseSquared;
	
#if _DEBUG_DISPLAY
	std::cout << "built _pixelModelStruct" << _pixelModelStruct << std::endl;
#endif

	//-----------------------------------------------------------------------------------
	// create input configuration structure
	//-----------------------------------------------------------------------------------
	const char* _configurationInputDataFields[] =
		{ "dvaMeshEdgeBuffer", 
			"dvaMeshOrder",
			"nDvaMeshRows",
			"nDvaMeshCols",
			"nOutputBufferPix",
			"nStarImageRows",
			"nStarImageCols",
			"StarChunkLength",
		};

	mwArray _configurationStruct(1, 1, sizeof(_configurationInputDataFields)/sizeof(char*), 
		_configurationInputDataFields);
		
	_configurationStruct("dvaMeshEdgeBuffer",1,1) = _dvaMeshEdgeBuffer;
	_configurationStruct("dvaMeshOrder",1,1) = _dvaMeshOrder;
	_configurationStruct("nDvaMeshRows",1,1) = _nDvaMeshRows;
	_configurationStruct("nDvaMeshCols",1,1) = _nDvaMeshCols;
	_configurationStruct("nOutputBufferPix",1,1) = _nOutputBufferPix;
	_configurationStruct("nStarImageRows",1,1) = _nStarImageRows;
	_configurationStruct("nStarImageCols",1,1) = _nStarImageCols;
	_configurationStruct("StarChunkLength",1,1) = _starChunkLength;	

#if _DEBUG_DISPLAY
	std::cout << "built _configurationStruct" << _configurationStruct << std::endl;
#endif

	//-----------------------------------------------------------------------------------
	// create coa input data structure
	//-----------------------------------------------------------------------------------
	const char* _coaInputDataFields[] =
		{ "KICEntryDataStruct", 
			"targetKeplerIDList",
			"pixelModelStruct",
			"coaConfigurationStruct",
			"startTimeString",
			"duration",
			"module",
			"output",
			"debug",
		};

	mwArray coaInputStruct(1, 1, sizeof(_coaInputDataFields)/sizeof(char*), 
		_coaInputDataFields);
		
	coaInputStruct("KICEntryDataStruct",1,1) = _kicStruct;
	coaInputStruct("targetKeplerIDList",1,1) = _targetKeplerIDList;
	coaInputStruct("pixelModelStruct",1,1) = _pixelModelStruct;
	coaInputStruct("coaConfigurationStruct",1,1) = _configurationStruct;
	coaInputStruct("startTimeString",1,1) = _startTime;
	coaInputStruct("duration",1,1) = _duration;
	coaInputStruct("module",1,1) = _ccdModule;
	coaInputStruct("output",1,1) = _ccdOutput;
	coaInputStruct("debug",1,1) = _debug;
	
#if _DEBUG_DISPLAY
	std::cout << "built coaInputStruct" << coaInputStruct << std::endl;
#endif

	//-----------------------------------------------------------------------------------
	// create coa output structure
	//-----------------------------------------------------------------------------------
	// define the high-level structure
	const char* _coaResultsDataFields[] =
		{ "targetImages", 
			"errorStruct"
		};
	mwArray coaResultsStruct(1, 1, sizeof(_coaResultsDataFields)/sizeof(char*), 
		_coaResultsDataFields);

	//-----------------------------------------------------------------------------------
	//-----------------------------------------------------------------------------------
	//-----------------------------------------------------------------------------------
	// call COA matlab controller
	//-----------------------------------------------------------------------------------
	//-----------------------------------------------------------------------------------
	//-----------------------------------------------------------------------------------
	
	// 1 corresponds to number of output arguments
	coa_matlab_controller(1, coaResultsStruct, coaInputStruct);
	
	//-----------------------------------------------------------------------------------
	// create coa output structure
	//
	// we are expecting a coaResultsStruct with the following structure ("()" denotes array):
	//
	// coaResultStruct (structure)
	//		.completeOutputImage (2D array) 
	//		.minRow 
	//		.maxRow
	//		.maxCol 
	//		.targetImages() (array of structures)
	//			.SNR
	//			.crowdingMetric
	//			.referencePixel (1 x 2 array)
	//			.targetDefinitionStruct() (array of structures)
	//				.offset() (array of structures)
	//					.row
	//					.column
	//		.errorStruct (empty if there was no error)
	//-----------------------------------------------------------------------------------

	int _numFields = coaResultsStruct.NumberOfFields();
#if _DEBUG_DISPLAY
	std::cout << "# of fields in return struct is " << _numFields << std::endl;
#endif
	for (int f=0; f<_numFields; f++) {
		const char *_fname = coaResultsStruct.GetFieldName(f);
#if _DEBUG_DISPLAY
		std::cout << _fname << std::endl;		
#endif
		if (!strcmp(_fname, "errorStruct")) {
		// the error handling in this conditional will go away soon in favor of a string returned from matlab
			mwArray _errorStruct = coaResultsStruct("errorStruct", 1, 1);
			int _numErrorFields = _errorStruct.NumberOfFields();
#if _DEBUG_DISPLAY
			std::cout << "# of fields in _errorStruct is " << _numErrorFields << std::endl;
#endif
			if (_numErrorFields == 3) {
				mwArray errMessage = _errorStruct("message", 1, 1);
				mwArray errIdentifier = _errorStruct("identifier", 1, 1);
				std::cout << "Error message:" << std::endl;		
				std::cout << errMessage << std::endl;		
				std::cout << "Error identifier: " 
					<< errIdentifier << std::endl;		
				mwArray _errorStackStruct = _errorStruct("stack", 1, 1);
				int numErrorStackLevels = _errorStackStruct.NumberOfElements();
				std::cout << "# of levels in the error stack is " << numErrorStackLevels << std::endl;
				for (int s=1; s<=numErrorStackLevels; s++) {
					mwArray _errorStackFileName = _errorStackStruct("file", s, 1);		
					mwArray _errorStackFunctionName = _errorStackStruct("name", s, 1);		
					mwArray _errorStackLine = _errorStackStruct("line", s, 1);		
					std::cout << "Stack level " << s << ": Error in file" << std::endl;
					std::cout << _errorStackFileName << std::endl;
					std::cout << "in function " << _errorStackFunctionName 
						<< " at line " << _errorStackLine << std::endl;
				} // end display of error stack
			}
		} // end "errorStruct"
		else if (!strcmp(_fname, "targetImages")) {
			// targetImages on the matlab side maps to optimalAperturePeers on the C++ side
			// get the targetImages structure into an mwArray object
			mwArray _targetDataStruct = coaResultsStruct("targetImages", 1, 1);
			// get the number of entries in the targetImages array of structures
			int _numTargetImages = _targetDataStruct.NumberOfElements();
			// for each element fill in the output object
			for (int t=1; t<=_numTargetImages; t++) {
				// construct an individual OptimalAperturePeer object which will be pushed into 
				// the output array
				OptimalAperturePeer _thisTarget;
				
				// fill in the scalar values
				_thisTarget.signalToNoiseRatio = (double) _targetDataStruct("SNR", 1, t);
				_thisTarget.crowdingMetric = (double) _targetDataStruct("crowdingMetric", 1, t);
				// referencePixel from matlab is a 1 x 2 vector, the output is two separate fields
				// first move the matlab vector into an mwArray
				mwArray _referencePixel = _targetDataStruct("referencePixel", 1, t);
				// get the individual elements
				_thisTarget.referenceRow = (int) _referencePixel(1,1);
				_thisTarget.referenceColumn = (int) _referencePixel(1,2);
				// TAD does not compute badPixelCount for now
				_thisTarget.badPixelCount = 0;
				// fill in the optimalAperturePeers array from the matlab targetDefinitionStruct
				mwArray _targetDefinitionStruct = _targetDataStruct("targetDefinitionStruct", 1, t);
				// the matlab targetDefinitionStruct contains an offset structure array
				mwArray _offsetStruct = _targetDefinitionStruct("offset", 1, 1);
				// get the number of offsets in the offset structure array = number of pixels in aperture
				int _numOffsets = _offsetStruct.NumberOfElements();
				// the next line may not be necessary but we're being careful
				_thisTarget.pixels.clear();
				// move each element of the offset array into the pixels array of the temporary OptimalAperturePeer
				// object
				for (int p=1; p<=_numOffsets; p++) {
					// create a temporary AperturePixelPeer to push into the OptimalAperturePeer object
					AperturePixelPeer _pix;
					// set the row and column offsets for the pth offset
					_pix.rowOffset = _offsetStruct("row", 1, p);
					_pix.columnOffset = _offsetStruct("column", 1, p);
					// push temporary AperturePixelPeer into the pixels array
					_thisTarget.pixels.push_back(_pix);
				} // end loop through offsets
				// push temporary OptimalAperturePeer into the optimalAperturePeers array
				outputs.optimalAperturePeers.push_back(_thisTarget);
			} // end loop through target images
#if _DEBUG_DISPLAY
			// check a random target
			int _numTestOffsets = outputs.optimalAperturePeers[10].pixels.size();
			std::cout << "target 10 has " << _numTestOffsets << " offsets:" << std::endl;
			for (int i=0; i<_numTestOffsets; i++) {
				std::cout << "row " << outputs.optimalAperturePeers[10].pixels[i].rowOffset << ", column " 
					<< outputs.optimalAperturePeers[10].pixels[i].columnOffset << std::endl;
			}
#endif
		} // end "targetImages"
		else if (!strcmp(_fname, "completeOutputImage")) {
			// fill the outputs.image.moduleOutputImage object from the 2D matlab array completeOutputImage

			// get the image array into an mwArray
			// (temporary megapixel image, no heap size threat)
			mwArray _image = coaResultsStruct("completeOutputImage", 1, 1); 
#if _DEBUG_DISPLAY
			int _numDimensions = _image.NumberOfDimensions();
			std::cout << "image has " << _numDimensions << " dimensions" << std::endl;
#endif
			// get the number of row and columns in the matlab array
			mwArray _imageSize = _image.GetDimensions();
			int _numRows = _imageSize(1,1);
			int _numCols = _imageSize(1,2);
#if _DEBUG_DISPLAY
			std::cout << "image size is " << _numRows << " x " << _numCols << " = " << _imageSize << std::endl;
#endif
			// since the output moduleOutputImage is of type vector <vector <double>>
			// with the inner index being column number, we create a row at a time and fill the 
			// outer index with that row
			// temporary storage for each row, made one at a time
			std::vector<double> _rowData;
			for (int row=1; row<=_numRows; row++) {
				_rowData.clear(); // clear out previous values
				for (int column=1; column<=_numCols; column++) {
					// push each individual pixel into the row vector
					_rowData.push_back(_image(row, column));
				}
				// now push the row vector into the moduleOutputImage
				outputs.image.moduleOutputImage.push_back(_rowData);
			}			
#if _DEBUG_DISPLAY
			std::cout << "pixel 460, 723 = " << outputs.image.moduleOutputImage[460][723] << std::endl;
			std::cout << "pixel 125, 834 = " << outputs.image.moduleOutputImage[125][834] << std::endl;
			std::cout << "pixel 632, 264 = " << outputs.image.moduleOutputImage[632][264] << std::endl;
			std::cout << "image size = " << outputs.image.moduleOutputImage.size() << " " 
				<< outputs.image.moduleOutputImage[100].size() << std::endl;
#endif
		} // end "completeOutputImage"
		else if (!strcmp(_fname, "minRow")) {
			// put the scalar minRow into the outputs.image object etc.
			outputs.image.lineStartRow = (float) coaResultsStruct("minRow", 1, 1); 
		} else if (!strcmp(_fname, "maxRow")) {
			outputs.image.lineEndRow = (float) coaResultsStruct("maxRow", 1, 1); 
		} else if (!strcmp(_fname, "minCol")) {
			outputs.image.lineStartCol = (float) coaResultsStruct("minCol", 1, 1); 
		} else if (!strcmp(_fname, "maxCol")) {
			outputs.image.lineEndCol = (float) coaResultsStruct("maxCol", 1, 1); 
#if _DEBUG_DISPLAY
			std::cout << "targets bounding box is " << outputs.image.lineStartRow << " " << outputs.image.lineEndRow
				<< " " << outputs.image.lineStartCol << " " << outputs.image.lineEndCol << std::endl;
#endif
		} else {
			std::cout << "unrecognized field  " << _fname << " in coaResultsStruct" << std::endl;
		}
	}
	
	
	return 0;
	//-----------------------------------------------------------------------

}


