/*
 * Copyright 2017 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 * 
 * NASA acknowledges the SETI Institute's primary role in authoring and
 * producing the Kepler Data Processing Pipeline under Cooperative
 * Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
 * NNX11AI14A, NNX13AD01A & NNX13AD16A.
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

#include "HuffmanController.h"

#include "libhuffman.h"

#include <iostream>

HuffmanController::HuffmanController(){
}

HuffmanController::~HuffmanController(){
}

int HuffmanController::doScience( HuffmanInputs& inputs, HuffmanOutputs& outputs ){
//
//	// Call application and library initialization. Perform this 
//	// initialization before calling any API functions or
//	// Compiler-generated libraries. 
//	// mclInitializeApplication returns a Boolean status code. 
//	// A return value of true indicates successful initialization, and false indicates failure.
//	
//
//	
//	// mclInitializeApplication allows you to set the global MCR options.
//	// They apply equally to all MCR instances. You must set these options before 
//	// creating your first MCR instance.
//	// These functions are necessary because some MCR options such as whether or not to start Java, 
//	// the location of the MCR itself, whether or not to use the MATLAB JIT feature, and so on, 
//	// are set when the first MCR instance starts and cannot be changed by subsequent instances of the MCR.		
//	// always use this code for failure to initialize the application
//		
//	if (!mclInitializeApplication(NULL,0)) 
//	{
//		outputs.errorCode = 2000;
//		outputs.errorText = "GAR CSCI:HuffmanController::doScience - could not initialize mclInitializeApplication ";
//		std::cerr << outputs.errorText << std::endl;
//		return outputs.errorCode;
//	}
//
//	if( !libhuffmanInitialize() )
//	{
//		outputs.errorCode = 2001;
//		outputs.errorText = "GAR CSCI:HuffmanController::doScience - could not initialize libhuffman library ";
//		std::cerr << outputs.errorText << std::endl;
//		return outputs.errorCode;
//	}
//
//	try
//	{
//		generateHuffmanTable(inputs, outputs);
//		outputs.errorCode = 0;
//		outputs.errorText = "GAR CSCI:HuffmanController::doScience - SUCCESS";
//	}
//	catch (const mwException& e)
//	{
//		outputs.errorCode = 2002;
//		outputs.errorText = "GAR CSCI:HuffmanController::doScience - generateHuffmanTable method failed\n ";
//		outputs.errorText.append(e.what());
//		std::cerr << outputs.errorText << std::endl;
//		return outputs.errorCode;
//	}
//	catch (...)
//	{
//		outputs.errorCode = 9999;
//		outputs.errorText = "GAR CSCI:HuffmanController::doScience - generateHuffmanTable method failed\n ";
//		outputs.errorText.append("Unexpected error thrown");
//		std::cerr << outputs.errorText << std::endl;
//		return outputs.errorCode;
//	}     
//	// Call the application and library termination routine
//	libhuffmanTerminate();
//
//	mclTerminateApplication();
//	return outputs.errorCode;

}
//int HuffmanController::generateHuffmanTable( HuffmanInputs& inputs, HuffmanOutputs& outputs ){
//	
//	//-----------------------------------------------------------------------------------
//	// copy input parameters from inputs object to C++ primitive data types
//	//-----------------------------------------------------------------------------------
//	
//	
//	int _iNumberOfContacts = inputs.histograms.size(); // number of columns in the histograms 2d array
//	int _iLengthOfHuffmanTable = inputs.histograms[0].size(); // number of rows in the histograms 2d array
//	
//	// when length limited Huffman table is generated for the first time, there will be no prior histograms.
//	// inputs.lastHistogramReceived will be NULL
//	int _iLengthOfLastHistogram;
//	if(&inputs.lastHistogramReceived[0] == NULL){
//	 	_iLengthOfLastHistogram = 0;
//	}
//	else{
//		_iLengthOfLastHistogram = inputs.lastHistogramReceived.size();
//	}
//	 
//
//	std::cout << "Number of contacts: " << _iNumberOfContacts << std::endl;
//	std::cout << "Length  of histogram table: " << _iLengthOfHuffmanTable << std::endl;
//	
//	
//	// convert all std::vector arrays to C type arrays 
//	// mwArray.SetData can convert data type to double
// 	// declaring a 2D array and allocationg memory for each row/column does not
// 	// gurantee contiguous memory locations for the entire 2d array
// 	// force contiguous memory for columns by turning the 2D array into 1D
//	int *_histograms2D =  new int[_iLengthOfHuffmanTable *_iNumberOfContacts];
//
//	for(int j = 0; j < _iNumberOfContacts; j++){
//		for(int i = 0; i < _iLengthOfHuffmanTable; i++){
//			_histograms2D[j*_iLengthOfHuffmanTable + i] = inputs.histograms[j][i];
//		}
//	}
//	
//
//	// from "The C++ Standard Library" by N.M. Josuttis
//	// The C++ standard library does not clearly state whether the elements of 
//	// a vector are required to be in continguous memory; however, it is the intention 
//	// that this is guaranteed. This guarantee has some important consequences. It means that
//	// you could use a vector in all cases in which you could use a dynamic array.  
//	
//
//	//-----------------------------------------------------------------------------------
//	// create input Matlab mwArrays
//	//-----------------------------------------------------------------------------------
//	// create input mwArrays
//	mwArray _histogramsInEffect(_iLengthOfHuffmanTable, _iNumberOfContacts, mxDOUBLE_CLASS, mxREAL);
//	mwArray _lastHistogram(_iLengthOfLastHistogram, 1, mxDOUBLE_CLASS, mxREAL);
//	mwArray _lastHistogramCodeWordLengths(_iLengthOfLastHistogram, 1, mxDOUBLE_CLASS, mxREAL);
//	mwArray _lengthOfHuffmanTable(1, 1, mxDOUBLE_CLASS, mxREAL);
//	mwArray _numberOfContacts(1, 1, mxDOUBLE_CLASS, mxREAL);
//	mwArray _debugFlag(1, 1, mxDOUBLE_CLASS, mxREAL);
//
//	//-----------------------------------------------------------------------------------
//	// copy C++ primitive data types to Matlab mwArrays
//	//-----------------------------------------------------------------------------------
//	
//	_histogramsInEffect.SetData(_histograms2D, _iLengthOfHuffmanTable*_iNumberOfContacts);
//
//	if(_iLengthOfLastHistogram > 0){
//		_lastHistogram.SetData(&(inputs.lastHistogramReceived[0]), _iLengthOfLastHistogram);
//		_lastHistogramCodeWordLengths.SetData(&(inputs.lastHistogramCodeLength[0]), _iLengthOfLastHistogram);
//	}
//	
//	_lengthOfHuffmanTable.SetData(&_iLengthOfHuffmanTable,1);
//	_numberOfContacts.SetData(&_iNumberOfContacts,1);
//	_debugFlag.SetData(&inputs.debugFlag,1);
//
//	//-----------------------------------------------------------------------------------
//	// create input Matlab structure and populate the fields
//	//-----------------------------------------------------------------------------------
//	const char* _inputFields[] = { "histogramsInEffect", "lastHistogram", "lastHistogramCodeWordLengths",
//							 "lengthOfHuffmanTable", "numberOfContacts", "debugFlag" };
//	mwArray hufffmanInputStruct(1, 1, 6, _inputFields);
//	
//	hufffmanInputStruct.Get(1,1).Set(_histogramsInEffect);
//	
//	if(_iLengthOfLastHistogram > 0){
//		hufffmanInputStruct.Get(1,2).Set(_lastHistogram);
//		hufffmanInputStruct.Get(1,3).Set(_lastHistogramCodeWordLengths);
//	}
//	
//	hufffmanInputStruct.Get(1,4).Set(_lengthOfHuffmanTable);
//	hufffmanInputStruct.Get(1,5).Set(_numberOfContacts);
//	hufffmanInputStruct.Get(1,6).Set(_debugFlag);
//	
//	//-----------------------------------------------------------------------------------
//	// create output Matlab structure
//	//-----------------------------------------------------------------------------------
//
//	const char* _outputFields[] = {"huffmanCodeStrings", "huffmanCodeLengths", "masterHistogram",
//									 "theoreticalCompressionRate", "effectiveCompressionRate",
//									"achievedCompressionRate"};
//	mwArray huffmanResultsStruct(1, 1,  6, _outputFields);
//	
//	mwArray _HUFFMAN_TABLE_LENGTH(1, 1, mxDOUBLE_CLASS, mxREAL);
//	_HUFFMAN_TABLE_LENGTH.SetData(&inputs.HUFFMAN_TABLE_LENGTH,1);
//	
//	mwArray _HUFFMAN_CODE_WORD_LENGTH_LIMIT(1, 1, mxDOUBLE_CLASS, mxREAL);
//	_HUFFMAN_CODE_WORD_LENGTH_LIMIT.SetData(&inputs.HUFFMAN_CODE_WORD_LENGTH_LIMIT,1);
//	
//	
//	// 1 corresponds to number of output arguments
//	huffman_code_matlab_controller(1, huffmanResultsStruct, hufffmanInputStruct,_HUFFMAN_TABLE_LENGTH,_HUFFMAN_CODE_WORD_LENGTH_LIMIT );
//                           
//	//-----------------------------------------------------------------------------------
//	// create output Matlab mwArrays to receive results
//	//-----------------------------------------------------------------------------------
//		
//	mwArray _huffmanCodeStrings; // will be returned as a cell array of strings
//	mwArray _huffmanCodeLengths;
//	mwArray _masterHistogram;
//	mwArray _theoreticalCompressionRate;
//	mwArray _effectiveCompressionRate;
//	mwArray _achievedCompressionRate;
//
//	
//	_huffmanCodeStrings = huffmanResultsStruct.Get("huffmanCodeStrings",1,1);
//	_huffmanCodeLengths = huffmanResultsStruct.Get("huffmanCodeLengths",1,1);
//	_masterHistogram = huffmanResultsStruct.Get("masterHistogram",1,1);
//	_theoreticalCompressionRate = huffmanResultsStruct.Get("theoreticalCompressionRate",1,1);
//	_effectiveCompressionRate = huffmanResultsStruct.Get("effectiveCompressionRate",1,1);
//	_achievedCompressionRate = huffmanResultsStruct.Get("achievedCompressionRate",1,1);
//	
//	//-----------------------------------------------------------------------------------
//	// copy results to C++ object outputs
//	//-----------------------------------------------------------------------------------
//	
//	// copy huffmanCodeStrings, an array of cell srings, from the MATLAB results structure to the C++ object 	
//    // reserve memory to avoid reallocation      
//     outputs.huffmanCodeString.reserve(_iLengthOfHuffmanTable);
//     mwArray  _matlabString;
//     std::string _stlString;
//     int _stringLength;
//	 // copy each code string into a STL string and insert it into outputs.huffmanCodeString
//     for(int j = 0; j < _iLengthOfHuffmanTable; j++){
//    	_matlabString = _huffmanCodeStrings.Get(1,j+1); // MATLAB uses 1-based indexing
//    	_stringLength = (_matlabString.ToString()).Length();
//    	_stlString.assign(( const char*)_matlabString.ToString(),0, _stringLength);        
//		if(inputs.debugFlag == 2){
//    		std::cout << _stringLength << std::endl;
//    		std::cout << _stlString << std::endl;
//		}
//    	outputs.huffmanCodeString.push_back(_stlString);	
//     }	
//	 
//    // reserve memory to avoid reallocation      
//	 outputs.huffmanCodeLength.reserve(_iLengthOfHuffmanTable);
//	 outputs.masterHistogram.reserve(_iLengthOfHuffmanTable);
//	 int _tempInt;
//     for(int j = 0; j < _iLengthOfHuffmanTable; j++){
//     	_tempInt =  (int)_huffmanCodeLengths(j+1);// MATLAB uses 1-based indexing 
//     	outputs.huffmanCodeLength.push_back(_tempInt);// do not use [j] notation 
//	    _tempInt   = (int) _masterHistogram(j+1);
//	    outputs.masterHistogram.push_back(_tempInt);
//     }
//
//	outputs.theoreticalCompressionRate = (float)_theoreticalCompressionRate;
//	outputs.effectiveCompressionRate = (float)_effectiveCompressionRate;
//	outputs.achievedCompressionRate = (float)_achievedCompressionRate;
//
//	// release allocated memory
//	delete [] _histograms2D;
//
//	return 0;
//	//-----------------------------------------------------------------------
//
//}
//
//
