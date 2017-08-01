/* ------------------------------------------------------------------------------ 
/*   MEX file name: build_huffman_code_tree.c 
/* ------------------------------------------------------------------------------ 
/*   Computational function: 
/*
/*    void  build_huffman_code_tree(struct binaryNode *binaryNodesStruct,
/*    double *symbolProbabilities, int *nodeDepths, int *symbolTypes, int
/*    *nodeNumbers, int *symbolNumbers, int *sortedIndex, int nSymbols,
/*    struct tempData *tempDataStruct)
/* ------------------------------------------------------------------------------ 
/*   This function constructs the Huffman code binary tree based on the
/*   computed codeword lengths of symbols which are used to reassign
/*   probabilities of each symbol as 2^-symbolDepth.
/*   In particular, for each node (and there are nSymbols-1 nodes) the
/*   following fields are computed:
/*
/*   binaryNodesStruct(1)
/*                  nodeValue: 0.0156
/*                  nodeDepth: 6
/*       leftChildProbability: 0.0078
/*              leftChildType: 0
/*             leftChildDepth: 7
/*      rightChildProbability: 0.0078
/*             rightChildType: 0
/*            rightChildDepth: 7
/*      leftChildSymbolNumber: 1
/*     rightChildSymbolNumber: 2
/*        leftChildNodeNumber: -1
/*       rightChildNodeNumber: -1
/*           parentNodeNumber: 5 
/*   
/*   This function is computationally intensive because of the following:
/*       1. sorting of of array of length which starts from'nSymbols' in the
/*       beginning to 2 at the end 
/*       2. nSymbols x 4 x nSymbols iterations involving assignments (a[i]
/*       = b[k] )
/*
/* ------------------------------------------------------------------------------ 
/*   Gateway function: 
/*
/*   void mexFunction( int nlhs,	mxArray	*plhs[], int nrhs, const mxArray
/*   *prhs[] )
/* ------------------------------------------------------------------------------ 
/*   mexFunction - Entry point from Matlab. This gateway function receives
/*   inputs from MATLAB which are in double and turns them into integers
/*   when appropriate and invokes the computational function
/*   "build_huffman_code_tree".
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
/*   argument which is binaryNodesStruct computed by the build_huffman_code_tree
/*   function having the following fields:
/*
/*   binaryNodesStruct(1)
/*                  nodeValue: 0.0156
/*                  nodeDepth: 6
/*       leftChildProbability: 0.0078
/*              leftChildType: 0
/*             leftChildDepth: 7
/*      rightChildProbability: 0.0078
/*             rightChildType: 0
/*            rightChildDepth: 7
/*      leftChildSymbolNumber: 1
/*     rightChildSymbolNumber: 2
/*        leftChildNodeNumber: -1
/*       rightChildNodeNumber: -1
/*           parentNodeNumber: 5 
/* 
/*   nrhs - number	of right hand side arguments (inputs)
/*   prhs[0]	 contains pointer to symbolProbabilities which is a double array 
/*   containing symbol probabilities computed as 2.^-symbolDepths
/*   prhs[1] contains pointer to the double array nodeDepths, initialized to symbol depths 
/*   prhs[2] contains a pointer to the double array symbolTypes, initialized to 0
/*   prhs[3] contains a pointer to the double array nodeNumbers, initialized to -1
/*   prhs[3] contains a pointer to the double array symbolNumbers containing (1:1:nSymbols)'
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
#include <string.h>
#include "mex.h"
#include "matrix.h"
#define SWAP(a, b) iTemp = (a);(a)  =  (b);(b) = iTemp;
#define M 7


struct binaryNode
{
    double nodeValue;
    int nodeDepth;
    double leftChildProbability;
    int leftChildType;
    int leftChildDepth;
    int leftChildNodeNumber;
    int leftChildSymbolNumber;
    double rightChildProbability;
    int rightChildType;
    int rightChildDepth;
    int rightChildNodeNumber;
    int rightChildSymbolNumber;
    int parentNodeNumber;
};
struct tempData
{
    double *identicalElementsIndex;
    int *sortedIndex;
    int *iStack;
    int  *sortedIdenticalElementsIndex;
    double *tempDoubleArray;
    int *tempIntArray;
};
/*---------------------------------------------------------------------------------------------------
/*   void get_sort_index(int n, double *inputArray, int *sortIndex, int *iStack ) 
/*   This function is very similar to MATLAB's  [B,IX] = sort(A, 'ascend')
/*   and sorts the elements along different dimensions of an array, and
/*   inputArrayanges those elements in ascending order. Yet, this function is not
/*   identical to MATLAB's [B,IX] = sort(A, 'ascend') in the following
/*   respect:
/*       1.  The sorted array  B is not available
/*       2.  For elements of A with identical values, the order of these
/*           elements is *not*  preserved in the sorted list. 
/*
/*     This function is a slighltly modified version of the code indexxx.x
/*     given in  page 339 of Numerical Recipes in C. Unlike the Numerical
/*     Recipes in C version, array index starts from 0 in this function.
/*     This algorithm constructs the index table by Quicksort algorithm and
/*     is faster (by a factor of ~10) than GNU Scientific Library's
/*     gsl_heapsort_index.c and is slower than MATLAB's sort(A, 'ascend') by
/*     a factor of 2.
/*
/*   Indexes an array inputArray[0..n-1], i.e., outputs the array sortIndex[0..n-1] such
/*   that inputArray[sortIndex[j]] is in ascending order for j = 0, 1, 2, N-1. The input
/*   array inputArray is not changed.
/* 
/*---------------------------------------------------------------------------------------------------*/
void get_sort_index(int nLength, double *inputArray, int *sortIndex, int *iStack )
{
    int iGreaterIndex,  jthSortedIndex,  iLength,  jLessIndex,  kMedianIndex,  mSplitIndex = 0;
    int jStack = -1, iTemp = 0;
    double aDouble;
    iLength = (nLength-1);
    /* 0 based indexing*/
    
    for (jLessIndex = 0; jLessIndex < nLength; jLessIndex++){
        sortIndex[jLessIndex] = jLessIndex;
    }
    
    for (;;) {
        if (iLength-mSplitIndex < M) {                                                          /* insertion sort when subarray is small enough <= M elements */
            for (jLessIndex = mSplitIndex+1; jLessIndex <= iLength; jLessIndex++) {             /* pick out each element in turn   */
                jthSortedIndex =  sortIndex[jLessIndex];
                aDouble = inputArray[jthSortedIndex];
                for (iGreaterIndex = jLessIndex-1; iGreaterIndex >= mSplitIndex; iGreaterIndex--) {  /*    */
                    if (inputArray[sortIndex[iGreaterIndex]] <= aDouble) break;
                    sortIndex[iGreaterIndex+1] = sortIndex[iGreaterIndex];  /*    */
                }
                sortIndex[iGreaterIndex+1] = jthSortedIndex;
            }
            if (jStack < 0) break;
            iLength = iStack[jStack--];                                                         /* pop stack and begin a new round of partitioning   */
            mSplitIndex = iStack[jStack--];
        } else {                                                                                /*  quick sort */
            kMedianIndex = (mSplitIndex+iLength) >> 1;                                          /* choose median of left, center, and right elements as paritioning element a    */
            SWAP(sortIndex[kMedianIndex], sortIndex[mSplitIndex+1]);                            /* also rearrange so that a[mSplitIndex] <= a[mSplitIndex+1] <= a[iLength]  */
            if (inputArray[sortIndex[mSplitIndex]] > inputArray[sortIndex[iLength]]) {
                SWAP(sortIndex[mSplitIndex], sortIndex[iLength])
            }
            if (inputArray[sortIndex[mSplitIndex+1]] > inputArray[sortIndex[iLength]]) {
                SWAP(sortIndex[mSplitIndex+1], sortIndex[iLength])
            }
            if (inputArray[sortIndex[mSplitIndex]] > inputArray[sortIndex[mSplitIndex+1]]) {
                SWAP(sortIndex[mSplitIndex], sortIndex[mSplitIndex+1])
            }
            iGreaterIndex = mSplitIndex+1;                                                      /* initialize pointers for partitioning   */
            jLessIndex = iLength;
            jthSortedIndex = sortIndex[mSplitIndex+1];
            aDouble = inputArray[jthSortedIndex];                                               /* partitioning element    */
            for (;;) {                                                                          /* beginning of innermost loop   */
                do iGreaterIndex++; while (inputArray[sortIndex[iGreaterIndex]] < aDouble);     /* scan up to find element > aDouble   */
                do jLessIndex--; while (inputArray[sortIndex[jLessIndex]] > aDouble);           /* scan up to find element < aDouble   */
                if (jLessIndex < iGreaterIndex) break;                                          /* pointers crossed, partitioning is complete   */
                SWAP(sortIndex[iGreaterIndex], sortIndex[jLessIndex])                           /* exchange location index   */
            }
            sortIndex[mSplitIndex+1] = sortIndex[jLessIndex];                                   /*    */
            sortIndex[jLessIndex] = jthSortedIndex;
            jStack += 2;
            if (iLength-iGreaterIndex+1 >=  jLessIndex-mSplitIndex) {                            /*  push pointers to a large subarray on stack, process smaller subarray immediately   */
                iStack[jStack] = iLength;
                iStack[jStack-1] = iGreaterIndex;
                iLength = jLessIndex-1;
            } else {
                iStack[jStack] = jLessIndex-1;
                iStack[jStack-1] = mSplitIndex;
                mSplitIndex = iGreaterIndex;
            }
        }
    }
}
#undef M
#undef SWAP

/*---------------------------------------------------------------------------------------------------
/*     void  make_sorted_index_compatible_to_matlab(int nLength, double *identicalElementsIndex, 
/*     int *sortedIdenticalElementsIndex, double *inputArray, int *sortedIndex, int *iStack)
/*
/*     This function ensures that for elements of A with identical values,
/*     the order of these elements is preserved in the sorted list. This
/*     ensures compatibility with MATLAB's sort function and alows for
/*     comparing the Huffman codewords generated in two ways by: 
/*          (1) MATLAB function 
/*          (2) MATLAB calling optimized MEX code.
/*---------------------------------------------------------------------------------------------------*/
void  make_sorted_index_compatible_to_matlab(int nLength, double *identicalElementsIndex, 
int *sortedIdenticalElementsIndex, double *inputArray, int *sortedIndex, int *iStack)
{
    
    int i, j,  k,  m = 0;
    double val1, val2;
    int nIdenticalValues;
    int n;
    n = nLength;
    
    /* locate identical elements if there are any*/
    
    for(i = 0; i < n-1; i++){
        /* take two consecutive elements*/
        val1 = inputArray[sortedIndex[i]];
        val2 = inputArray[sortedIndex[i+1]];
        j = 0;
        if(val1 == val2){
            /* val1 at this point must always be > val2 as this list is in ascending order
            /* checking for equality only..*/
            identicalElementsIndex[0] = sortedIndex[i];
            identicalElementsIndex[1] = sortedIndex[++i];
            j = 1;
            /* see if there more than two elements of the same value*/
            while ( (i < (n-1)) & (val2 == inputArray[sortedIndex[i+1]]) ){
                identicalElementsIndex[++j] = sortedIndex[++i];
            }
            
            nIdenticalValues = j+1;
            
            get_sort_index(nIdenticalValues, identicalElementsIndex, sortedIdenticalElementsIndex, iStack);
            
            
            
            for(k = 0; k < nIdenticalValues; k++){
                m = i - nIdenticalValues+1+ k;
                sortedIndex[m] = (int) identicalElementsIndex[sortedIdenticalElementsIndex[k]];
            }
        }
    }
}

/*---------------------------------------------------------------------------------------------------
/*     void sort_ascend_and_get_index(int nLength, double *inputArray, int
/*     *sortedFinalIndex, struct tempData *tempDataStruct)
/* 
/*     This function calls the get_sort_index function first to get the sorted
/*     index table and then calls make_sorted_index_compatible_to_matlab to
/*     preserve the order of elements with identical values
/*---------------------------------------------------------------------------------------------------*/
void sort_ascend_and_get_index(int nLength, double *inputArray, int *sortedFinalIndex, 
struct tempData *tempDataStruct)
{
    
    double  *identicalElementsIndex;
    int *sortedIndex, *iStack,  *sortedIdenticalElementsIndex;
    int j;
    
    
    iStack = tempDataStruct->iStack;
    sortedIndex = tempDataStruct->sortedIndex;
    
    /* Call the Numerical Recipes C function*/
    get_sort_index(nLength, inputArray, sortedIndex, iStack);
    
    identicalElementsIndex = tempDataStruct->identicalElementsIndex;
    sortedIdenticalElementsIndex = tempDataStruct->sortedIdenticalElementsIndex;
    
    make_sorted_index_compatible_to_matlab(nLength, identicalElementsIndex, sortedIdenticalElementsIndex, inputArray, sortedIndex, iStack);
    
    /*copy back to double array*/
    
    for (j = 0; j < nLength; j++){
        sortedFinalIndex[j] = sortedIndex[j];
    }
}
/*---------------------------------------------------------------------------------------------------*/
/* keep combining nodes at the higher level and move to lower levels
/* (appears to be the opposite of combining nodes with the lowest
/* probabilities but it essentially does the same thing)
/* original symbol probabilities have now been quantized to correspond to
/* their depths - many symbols are now going to be pegged to the same
/* probability; thus identifying the parent of a child node becomes even
/* more of a problem
/* solution:
/* need to number the binary nodes and attach the number of the child node
/* as a field to the current node to overcome this problem
/*---------------------------------------------------------------------------------------------------*/
void  build_huffman_code_tree(struct binaryNode *binaryNodesStruct, double *symbolProbabilities,
int *nodeDepths, int *symbolTypes, int *nodeNumbers, int *symbolNumbers,
int *sortedIndex, int nSymbols, struct tempData *tempDataStruct)
{
    
    int j, k;
    int nCount = 0;
    int iHeadSymbolNumber = 0, iHeadArray = 0;
    int iCurrentArrayLength = nSymbols;
    double *tempDoubleArray = tempDataStruct->tempDoubleArray;
    int *tempIntArray = tempDataStruct->tempIntArray;
    int leftChildNodeNumber, rightChildNodeNumber;
    
    
    for(j = 0; j < (nSymbols-1); j++) {
        /* need to extract two nodes that are at the same level
        /* for j = 1, first two combined are definitely leaves*/
        binaryNodesStruct[j].leftChildProbability = symbolProbabilities[iHeadArray];
        binaryNodesStruct[j].leftChildType = symbolTypes[iHeadArray]; /* lowest prob node or leaf*/
        binaryNodesStruct[j].leftChildDepth = nodeDepths[iHeadArray];
        binaryNodesStruct[j].rightChildProbability = symbolProbabilities[iHeadArray+1];
        binaryNodesStruct[j].rightChildType = symbolTypes[iHeadArray+1];
        binaryNodesStruct[j].rightChildDepth = nodeDepths[iHeadArray+1];
        binaryNodesStruct[j].nodeValue = symbolProbabilities[iHeadArray] + symbolProbabilities[iHeadArray+1];
        
        if(binaryNodesStruct[j].leftChildType){ /* a node and not a leaf*/
            binaryNodesStruct[j].leftChildNodeNumber = nodeNumbers[iHeadArray];
            binaryNodesStruct[j].leftChildSymbolNumber = -1;
        }else{
            binaryNodesStruct[j].leftChildNodeNumber = -1;
            binaryNodesStruct[j].leftChildSymbolNumber = symbolNumbers[iHeadSymbolNumber];
            ++iHeadSymbolNumber;
        }
        binaryNodesStruct[j].nodeDepth = binaryNodesStruct[j].leftChildDepth-1;
        
        
        if(binaryNodesStruct[j].rightChildType){ /* a node and not a leaf*/
            binaryNodesStruct[j].rightChildNodeNumber = nodeNumbers[iHeadArray+1];
            binaryNodesStruct[j].rightChildSymbolNumber = -1;
        }else{
            binaryNodesStruct[j].rightChildNodeNumber = -1;
            binaryNodesStruct[j].rightChildSymbolNumber = symbolNumbers[iHeadSymbolNumber];
            ++iHeadSymbolNumber;
        }
        binaryNodesStruct[j].nodeDepth = binaryNodesStruct[j].rightChildDepth-1;
        
        ++iHeadArray;
        
        symbolProbabilities[iHeadArray] = binaryNodesStruct[j].nodeValue;
        nodeDepths[iHeadArray] = binaryNodesStruct[j].nodeDepth ;
        symbolTypes[iHeadArray] = 1;
        nodeNumbers[iHeadArray] = j+1;
        
        --iCurrentArrayLength;
        
        /* sorting part*/
        sort_ascend_and_get_index(iCurrentArrayLength, &symbolProbabilities[iHeadArray], &sortedIndex[iHeadArray],tempDataStruct);
        
        /* now that sorted index is available, do the actual sorting -
        /* linear time operation
        /* use memcpy to transfer the contents before sorting
        /* Copies count bytes of src to dest. If the source and destination
        /* overlap, the behavior of memcpy is undefined. 
        /* void *memcpy( void *dest, const void *src,size_t count );*/
        
        memcpy( tempDoubleArray + iHeadArray, symbolProbabilities + iHeadArray, (nSymbols - iHeadArray)*sizeof(double) );
        
        for(k = iHeadArray; k < nSymbols; k++){
            /*copy to temp array and apply sorting index*/
            symbolProbabilities[k] = *(tempDoubleArray+iHeadArray+sortedIndex[k]);
        }
        
        /*repeat this step for the remaining arrays to be sorted..*/
        memcpy( tempIntArray + iHeadArray, nodeDepths + iHeadArray, (nSymbols - iHeadArray)*sizeof(int) );
        
        for(k = iHeadArray; k < nSymbols; k++){
            /*copy to temp array and apply sorting index*/
            nodeDepths[k] = *(tempIntArray+iHeadArray+sortedIndex[k]);
        }
        
        /*repeat this step for the remaining arrays to be sorted..*/
        memcpy( tempIntArray + iHeadArray, symbolTypes + iHeadArray, (nSymbols - iHeadArray)*sizeof(int) );
        
        for(k = iHeadArray; k < nSymbols; k++){
            /*copy to temp array and apply sorting index*/
            symbolTypes[k] = *(tempIntArray+iHeadArray+sortedIndex[k]);
        }
        
        /*repeat this step for the remaining arrays to be sorted..*/
        memcpy( tempIntArray + iHeadArray, nodeNumbers + iHeadArray, (nSymbols - iHeadArray)*sizeof(int) );
        
        for(k = iHeadArray; k < nSymbols; k++){
            /*copy to temp array and apply sorting index*/
            nodeNumbers[k] = *(tempIntArray+iHeadArray+sortedIndex[k]);
        }
    }
    
    for(j = 0; j < (nSymbols-1); j++){
        
        if(binaryNodesStruct[j].leftChildType){ /* a node and not a leaf*/
            leftChildNodeNumber = binaryNodesStruct[j].leftChildNodeNumber;
            /* 0 indexing*/
            binaryNodesStruct[leftChildNodeNumber-1].parentNodeNumber = j+1;
        }
        
        if(binaryNodesStruct[j].rightChildType){ /*a node and not a leaf*/
            rightChildNodeNumber = binaryNodesStruct[j].rightChildNodeNumber;
            binaryNodesStruct[rightChildNodeNumber-1].parentNodeNumber = j+1;
        }
    }
}
/*---------------------------------------------------------------------------------------------------*/
/* This function build the full binary tree (huffman code tree)  from the
/* symbol probabilities calculated from the the code word length for each
/* symbol (symbolProbabilities = 2.^-symbolDepths). This step is identical
/* to creating the traditional basic huffman code tree now that symbol probabilities
/* have been recomputed to ensure length limited codewords.
/*
/*
/* Inputs: (inside *prhs[])
/*           (1) symbolProbabilities - a vector nSymbols long; original
/*           symbol probabilities have now been quantized to correspond to
/*           their depths
/*           (2) nodeDepths - a vector containg the symbol codeword lengths
/*           (3) symbolTypes - a vector nSymbols long, initialized to 0
/*           (4) nodeNumbers - a vector nSymbols long, initialized to -1
/*           (5) symbolNumbers - - a vector nSymbols long, containing 1
/*           through nSymbols
/*  The input argument list identical to that used by the MEX version of
/*  this function.
/*
/* Output:  (*plhs[])
 /*     binaryNodesStruct  (an array of structures)  
/*               For example,  binaryNodesStruct(1) has the following fields:
/*                                  nodeValue: 0.2500
/*                                  nodeDepth: 2
/*                       leftChildProbability: 0.1250
/*                              leftChildType: 0
/*                             leftChildDepth: 3
/*                      rightChildProbability: 0.1250
/*                             rightChildType: 0
/*                            rightChildDepth: 3
/*                      leftChildSymbolNumber: 6
/*                     rightChildSymbolNumber: 7
/*                        leftChildNodeNumber: -1
/*                       rightChildNodeNumber: -1
/*                           parentNodeNumber: 6
/*---------------------------------------------------------------------------------------------------*/
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray  *prhs[] )
{
    
    int     j, jstruct, nSymbols;
    int     dims[2] = {1, 1 };

    double  *symbolProbabilities, *nodeDepths, *symbolTypes, *nodeNumbers, *symbolNumbers;
    double  *symbolProbabilitiesCopy;
    
    int     *nodeDepthsCopy, *symbolTypesCopy, *nodeNumbersCopy, *symbolNumbersCopy, *sortedFinalIndex;
    
    const char  *field_names[] = {"nodeValue", "nodeDepth", "leftChildProbability", "leftChildType","leftChildDepth", "rightChildProbability", "rightChildType",
    "rightChildDepth",    "leftChildSymbolNumber", "rightChildSymbolNumber", "leftChildNodeNumber", "rightChildNodeNumber", "parentNodeNumber"};
    
    mxArray *field_value;
    
    
    struct binaryNode *binaryNodesStruct;
    struct tempData  *tempDataStruct;
    
    
    /* Check for proper number of arguments.
    /* (mexErrMsgTxt breaks you out of the MEX-file.)*/
    if (nrhs != 5)
        mexErrMsgTxt("five inputs required.");
    if (nlhs != 1)
        mexErrMsgTxt("One output required.");
    
    symbolProbabilities = mxGetPr(prhs[0]);
    nSymbols = mxGetM(prhs[0]);
    nodeDepths = mxGetPr(prhs[1]);
    
    symbolTypes = mxGetPr(prhs[2]);
    nodeNumbers = mxGetPr(prhs[3]);
    symbolNumbers = mxGetPr(prhs[4]);
    
    /* allocate memory  for storing pointers*/
    binaryNodesStruct = mxCalloc(nSymbols-1, sizeof( struct binaryNode));
    tempDataStruct = mxCalloc(1, sizeof( struct tempData));
    
    for(jstruct = 0; jstruct < (nSymbols-1); jstruct++)
    {
        /* initialize structure fields*/
        binaryNodesStruct[jstruct].leftChildProbability = 0.0;
        binaryNodesStruct[jstruct].leftChildType =  -1;
        binaryNodesStruct[jstruct].leftChildDepth = -1;
        binaryNodesStruct[jstruct].nodeValue = 0.0;
        binaryNodesStruct[jstruct].nodeDepth = -1;
        binaryNodesStruct[jstruct].rightChildProbability =  0.0;
        binaryNodesStruct[jstruct].rightChildType = -1;
        binaryNodesStruct[jstruct].leftChildNodeNumber =  -1;
        binaryNodesStruct[jstruct].rightChildNodeNumber =  -1;
        binaryNodesStruct[jstruct].leftChildSymbolNumber = -1;
        binaryNodesStruct[jstruct].rightChildSymbolNumber = -1;
        binaryNodesStruct[jstruct].parentNodeNumber = -1;
    }
    
    
    /* tempDataStruct contains several arrays used as scratch memory
    /* allocate once, use many times
    /* several of the arrays are used in the sorting function*/
    tempDataStruct->iStack = mxCalloc(nSymbols, sizeof(int));
    tempDataStruct->sortedIndex = mxCalloc(nSymbols, sizeof(int));
    /* call make_compatible_to_matlab to ensure that the identical sorted elements are in their natural order
    /* allocate memory for isstack*/
    tempDataStruct->identicalElementsIndex = mxCalloc(nSymbols, sizeof(double));
    tempDataStruct->sortedIdenticalElementsIndex = mxCalloc(nSymbols, sizeof(int));
    tempDataStruct->tempDoubleArray = mxCalloc(nSymbols, sizeof(double));
    tempDataStruct->tempIntArray = mxCalloc(nSymbols, sizeof(int));
    
    sortedFinalIndex = mxCalloc(nSymbols, sizeof(int));
    
    /* IMPORTAN++++++IMPORTANT+++++++IMPORTANT++++++++++++++++++++++++++++++++++
    /* Note    Inputs to a MEX-file are constant read-only mxArrays and
    /* should not be modified. Using mxSetCell* or mxSetField* to modify the
    /* cells or fields of an argument passed from MATLAB causes
    /* unpredictable results. Copy all the arrays that are likely to be
    /* written over, since the right-hand arguments are READ-ONLY!*/
    
    symbolProbabilitiesCopy = mxCalloc(nSymbols, sizeof(double));
    nodeDepthsCopy = mxCalloc(nSymbols, sizeof(int));
    symbolTypesCopy = mxCalloc(nSymbols, sizeof(int));
    nodeNumbersCopy =  mxCalloc(nSymbols, sizeof(int));
    symbolNumbersCopy = mxCalloc(nSymbols, sizeof(int));
    
    /* copy data fron rhs to these arrays*/
    for( j = 0; j < nSymbols; j++){
        symbolProbabilitiesCopy[j] = symbolProbabilities[j];
        nodeDepthsCopy[j] = (int)nodeDepths[j];
        symbolTypesCopy[j] = (int)symbolTypes[j];
        nodeNumbersCopy[j] = (int)nodeNumbers[j];
        symbolNumbersCopy[j] = (int)symbolNumbers[j];
    }
    
    build_huffman_code_tree(binaryNodesStruct, symbolProbabilitiesCopy, nodeDepthsCopy, symbolTypesCopy,
     nodeNumbersCopy, symbolNumbersCopy, sortedFinalIndex, nSymbols, tempDataStruct);
    
    dims[1] = nSymbols-1;
    plhs[0] = mxCreateStructArray(2, dims,13, field_names);
    
    for(jstruct = 0; jstruct < (nSymbols-1); jstruct++)
    {
        /* allocate memory for every field that is set
        /* copy the pointer of just allocated memory*/
        
        field_value = mxCreateDoubleMatrix(1,1,mxREAL);
        *mxGetPr(field_value) = binaryNodesStruct[jstruct].nodeValue;
        mxSetField(plhs[0], jstruct, "nodeValue", field_value); 
        
        /* setting the pointer here, need a new pointer
        /* allocate memory for every field that is set*/
        
        field_value = mxCreateDoubleMatrix(1,1,mxREAL);
        *mxGetPr(field_value) = (double)binaryNodesStruct[jstruct].nodeDepth;
        mxSetField(plhs[0], jstruct, "nodeDepth",field_value);
        
        
        field_value = mxCreateDoubleMatrix(1,1,mxREAL);
        *mxGetPr(field_value) = binaryNodesStruct[jstruct].leftChildProbability;
        mxSetField(plhs[0], jstruct, "leftChildProbability", field_value);
        
        field_value = mxCreateDoubleMatrix(1,1,mxREAL);
        *mxGetPr(field_value) = (double)binaryNodesStruct[jstruct].leftChildType;
        mxSetField(plhs[0], jstruct, "leftChildType",field_value);
        
        field_value = mxCreateDoubleMatrix(1,1,mxREAL);
        *mxGetPr(field_value) = (double)binaryNodesStruct[jstruct].leftChildDepth;
        mxSetField(plhs[0], jstruct, "leftChildDepth", field_value);
        
        field_value = mxCreateDoubleMatrix(1,1,mxREAL);
        *mxGetPr(field_value) = (double)binaryNodesStruct[jstruct].leftChildNodeNumber;
        mxSetField(plhs[0], jstruct, "leftChildNodeNumber", field_value);
        
        field_value = mxCreateDoubleMatrix(1,1,mxREAL);
        *mxGetPr(field_value) = (double)binaryNodesStruct[jstruct].leftChildSymbolNumber;
        mxSetField(plhs[0], jstruct, "leftChildSymbolNumber", field_value);
        
        field_value = mxCreateDoubleMatrix(1,1,mxREAL);
        *mxGetPr(field_value) = binaryNodesStruct[jstruct].rightChildProbability;
        mxSetField(plhs[0], jstruct, "rightChildProbability", field_value);
        
        field_value = mxCreateDoubleMatrix(1,1,mxREAL);
        *mxGetPr(field_value) = (double)binaryNodesStruct[jstruct].rightChildType;
        mxSetField(plhs[0], jstruct, "rightChildType", field_value);
        
        field_value = mxCreateDoubleMatrix(1,1,mxREAL);
        *mxGetPr(field_value) = (double)binaryNodesStruct[jstruct].rightChildDepth;
        mxSetField(plhs[0], jstruct, "rightChildDepth", field_value);
        
        field_value = mxCreateDoubleMatrix(1,1,mxREAL);
        *mxGetPr(field_value) =(double) binaryNodesStruct[jstruct].rightChildNodeNumber;
        mxSetField(plhs[0], jstruct, "rightChildNodeNumber", field_value);
        
        field_value = mxCreateDoubleMatrix(1,1,mxREAL);
        *mxGetPr(field_value) = (double)binaryNodesStruct[jstruct].rightChildSymbolNumber;
        mxSetField(plhs[0], jstruct, "rightChildSymbolNumber", field_value);
        
        field_value = mxCreateDoubleMatrix(1,1,mxREAL);
        *mxGetPr(field_value) = (double)binaryNodesStruct[jstruct].parentNodeNumber;
        mxSetField(plhs[0], jstruct, "parentNodeNumber", field_value);
    }
    
    
    
    mxFree(tempDataStruct->iStack);
    mxFree(tempDataStruct->identicalElementsIndex);
    mxFree(tempDataStruct->sortedIdenticalElementsIndex);
    mxFree(tempDataStruct->sortedIndex);
    mxFree(tempDataStruct->tempDoubleArray);
    mxFree(tempDataStruct->tempIntArray);
    mxFree(sortedFinalIndex);
    mxFree(tempDataStruct);
    mxFree(binaryNodesStruct);
    
    
}
