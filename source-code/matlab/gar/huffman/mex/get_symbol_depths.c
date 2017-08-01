/* ------------------------------------------------------------------------------ 
/*   MEX file name: get_symbol_depths.c 
/* ------------------------------------------------------------------------------ 
/*   Computational function: 
/*   void  get_symbol_depths(struct level *levelStruct, int
/*   *symbolFrequencies, int *symbolDepths, int *nActiveLeaves, int
/*   maximumCodeWordLength, int nSymbols)
/* ------------------------------------------------------------------------------ 
/*   This function searches through the active leaves of the tree list in
/*   each level (levelStruct[j].treesList, j <= maximumCodeWordLength) for
/*   each symbol to compute the code word length of each symbol. 
/*
/*   There are (number of symbols x number of active leaves in each level x
/*   maximumCodeWordLength) iterations involved. 
/*
/*   For Kepler, number of symbols which need to be Huffman encoded = 2^17
/*   (number of active leaves in each level x number of levels ( = maximum
/*   codeword length) ) = (2^18)-1 
/*
/*   Hence the total number of iterations  = (2^17) x (2^18 -1) ~ 35 billion
/*   Each iteration does two integer equality checking and two integer
/*   increments.
/*   
/*   This function is computationally intensive because of the number of
/*   iterations involved.
/* ------------------------------------------------------------------------------ 
/*   Gateway function: 
/*   void mexFunction( int nlhs,	mxArray	*plhs[], int nrhs, const mxArray
/*   *prhs[] )
/* ------------------------------------------------------------------------------ 
/*   mexFunction - Entry point from Matlab. This gateway function receives
/*   inputs from MATLAB which are in double and turns them into integers
/*   when appropriate and invokes the computational function
/*   "get_symbol_depths".
/*
/*   The plhs[] and prhs[] parameters are vectors that contain pointers to
/*   each left-hand side (output) variable and each right-hand side (input)
/*   variable, respectively. 
/*   Accordingly, plhs[0] contains a pointer to the first left-hand side
/*   argument, plhs[1] contains a pointer to the second left-hand side
/*   argument, and so on. Likewise, prhs[0] contains a pointer to the first
/*   right-hand side argument, prhs[1] points to the second, and so on. 
/*
/*   nlhs - number	of left hand side arguments (outputs) 
/*   plhs[0] contains a pointer to the first left-hand side (outputs)
/*   argument which is symbolDepths computed by the get_symbol_depths
/*   function.
/*  
/*   nrhs - number	of right hand side arguments (inputs)
/*   prhs[0]	 contains pointer to levelStruct which is an array of MATLAB
/*   structure which is	described below: 
/*   levelStruct(1)
/*  	 treesList:	 [16384x1 double] 
/*       nodeType:	 [16384x1 logical]
/*       packagePedigree:	 []
/*       nActiveLeaves:	 0
/*   prhs[1] contains pointer to the double array symbolFrequencies 
/*   prhs[2] contains a pointer to the scalar maximumCodeWordLength
 *
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
/* ------------------------------------------------------------------------------ */

#include "mex.h"
#include "matrix.h"

struct level
{
    double *treesList;
    int	   nLengthTreesList;
    bool   *nodeType;
    double *packagePedigree;
    int	nLengthPackagePedigree;
    double	nActiveLeaves;
};

/*----------------------------------------------------------------------------*/
void  get_symbol_depths(struct level *levelStruct, int *symbolFrequencies, int *symbolDepths, 
int *nActiveLeaves, int maximumCodeWordLength, int nSymbols)
{
    int	i, j, k;
    int	nCount = 0;
    
    /* for each	symbol*/
    for(i =	0; i < nSymbols; i++)
    {
        /* look	in each	level*/
        for	(j = 0;	j <	maximumCodeWordLength; j++)
        {
            /* there could be duplicate	symbol frequencies,	symbol frequencies might match package values*/
            nCount = 0;

            /* examine all the active nodes (leaf+package) in each tree for the occurrence of ith symbol*/
            for(k =	0; k < nActiveLeaves[j]; k++)
            {
                if(!levelStruct[j].nodeType[k]){
                    ++nCount;
                    /* typecast	to int before checking for equality*/
                    if((int)levelStruct[j].treesList[k]	== symbolFrequencies[i]){
                        /* increment depth only	if the corresponding node is a leaf	(a symbol)*/
                        if(nCount == i+1){
                            ++symbolDepths[i];
                        }
                    }
                }
            }
        }
    }
}
/*---------------------------------------------------------------------------------------------------*/
/*This algorithm is a continuation of apply_package_merge_algorithm and we
/* continue from where we left off. 
/* Define the active leaves to be the leaves of the first (2n-2) trees of
/* the last list. Extracting the codeword length for each symbol from
/* HUFFMAN_CODEWORD_LENGTH_LIMIT lists in levelStruct is achieved by
/* processing these active leaves - each active leaf corresponds to exactly
/* one of the original symbols. Every time the i-th symbol is found in the
/* active leaves of each list, increment its codeword length by1. By
/* examining all the active leaves in each list, codeword length for each
/* and every symbol is computed.
/*
/* References:
/* [1] L. L. Larmore and D. S. Hirschberg, �A fast algorithm for optimal
/* length-limited Huffman codes,� J. Assoc. Comput. Mach., vol. 37, no.
/* 3, pp. 464�473, July 1990.
/* [2] J. Katajainen, A. Moffat, and A. Turpin, �A fast and space-economical
/* algorithm for length-limited coding,�  Lecture Notes In Computer
/* Science; Vol. 1004 Proceedings of the 6th International Symposium on
/* Algorithms and Computation Pages: 12 - 21 Year of Publication: 1995
/* ISBN:3-540-60573-8
/* 
/* 
/* Inputs: 
/*       (1) levelStruct (an array of structures)
/*           For example, levelStruct(1) has the following fields:
/*                      treesList: [15x1 double]
/*                        nodeType: [15x1 logical]
/*                 packagePedigree: [6x4 double]
/*                   nActiveLeaves: 0
/*       (2) symbolFrequencies - a vector of length = length of the
/*       histogramsInEffect (refer to huffman_code_matlab_controller.m)
/*       (3) HUFFMAN_CODEWORD_LENGTH_LIMIT - another constant defined in the
/*       Focal Plane Characterization CSCI with a value of 24 corresponding to
/*       the limit imposed by the Flight Segment on the table format for storing
/*       variable length Huffman codewords
/* 
/* Output: symbolDepths - a vector of length  nSymbols containing the
/* codeword lengths of symbols.
*/
/*---------------------------------------------------------------------------------------------------*/

void mexFunction( int nlhs,	mxArray	*plhs[], int nrhs, const mxArray  *prhs[] )
{
    
    mxArray     *tmp;
    int         i, j,  jstruct ;
    int         nInputStructArrayElements, nInputFields,	nSymbols;
    double      *symbolFrequencies, *symbolDepths;
    
    int         *symbolFrequenciesInteger, *symbolDepthsInteger, *nActiveLeavesInteger;
    int         maximumCodeWordLengthInteger;
    
    double      maximumCodeWordLength;
    struct level *levelStruct;
    
    
    /* basic check for correct number and type of arguments 
    /*(mexErrMsgTxt	breaks you out of the MEX-file.)*/

    if (nrhs !=	3)
        mexErrMsgTxt("Two inputs required.");
    if (nlhs !=	1)
        mexErrMsgTxt("One output required.");
    
    /* First: Validate all the arguments as	1xn	structures*/
    for	(i = 0;	i <	nrhs; i++){
        if (i == 0){
            if (!mxIsStruct(prhs[i]))
                mexErrMsgTxt("First	argument must be a structure");
        }else{
            if (!mxIsDouble(prhs[i]))
                mexErrMsgTxt("Second argument must be an array of double");
        }
    }
    
    /*[symbolDepths] =	 get_symbol_depths(levelStruct,	symbolFrequencies,	MAX_CODE_LENGTH);*/
    
    /* get input arguments*/
    nInputFields = mxGetNumberOfFields(prhs[0]);
    nInputStructArrayElements =	mxGetNumberOfElements(prhs[0]);
    
    symbolFrequencies =	mxGetPr(prhs[1]);
    nSymbols = mxGetM(prhs[1]);
    maximumCodeWordLength =	mxGetScalar(prhs[2]);
    
    /* allocate	nInputStructArrayElements of struct* here*/
    levelStruct	= mxCalloc(nInputStructArrayElements, sizeof( struct level));
    nActiveLeavesInteger = mxCalloc(nInputStructArrayElements, sizeof(int));
    
    for(jstruct	= 0; jstruct < nInputStructArrayElements; jstruct++)
    {
        /* no need to allocate memory
        /* copy	the	pointers of	structure fields*/
        tmp	= mxGetField(prhs[0], jstruct, "treesList");
        levelStruct[jstruct].treesList = mxGetPr(tmp);
        
        /*	get	the	number of rows*/
        levelStruct[jstruct].nLengthTreesList =	mxGetM(tmp); 
        
        tmp	= mxGetField(prhs[0], jstruct, "nodeType");
        levelStruct[jstruct].nodeType =	(bool *) mxGetPr(tmp);
        
        tmp	= mxGetField(prhs[0], jstruct, "packagePedigree");
        levelStruct[jstruct].packagePedigree = mxGetPr(tmp);
        
        /* get the number of rows, columns fixed at 4
        /* never used in the computational function get_symbol_depths*/
        levelStruct[jstruct].nLengthPackagePedigree	= mxGetM(tmp);
        
        tmp	= mxGetField(prhs[0], jstruct, "nActiveLeaves");
        levelStruct[jstruct].nActiveLeaves = mxGetScalar(tmp);
        
        /* need to convert to integer array inorder toavois type casting it to int a  billion times
        /* speeds up the compuation*/
        nActiveLeavesInteger[jstruct] =	(int)levelStruct[jstruct].nActiveLeaves;     
    }
    
    symbolFrequenciesInteger = mxCalloc(nSymbols, sizeof(int));
    maximumCodeWordLengthInteger = (int)maximumCodeWordLength;
    symbolDepthsInteger	= mxCalloc(nSymbols, sizeof(int));
    
    
    /* need to convert to integer array inorder to avoid type casting it to int a  billion times
    /* speeds up the compuation*/
    for(j =	0; j < nSymbols; j++){
        symbolFrequenciesInteger[j]	= (int)	symbolFrequencies[j];
    }
    
    
    /* Create a	C pointer to a copy	of the output matrix.*/
    plhs[0]	= mxCreateDoubleMatrix(nSymbols,1, mxREAL);
    
    /* Set the output pointer to symbolDepths*/
    symbolDepths = mxGetPr(plhs[0]);
    
    
    get_symbol_depths(levelStruct, symbolFrequenciesInteger, symbolDepthsInteger, nActiveLeavesInteger,	maximumCodeWordLengthInteger, nSymbols);
    
    /*copy back	symbolDepthsInteger	to symbolDepths to return to MATLAB*/
    for(j =	0; j < nSymbols; j++){
        symbolDepths[j]	= (double) symbolDepthsInteger[j];
    }
    
    /* free mxCalloc allocated memory*/
    mxFree(levelStruct);
    mxFree(symbolFrequenciesInteger);
    mxFree(symbolDepthsInteger);
}
