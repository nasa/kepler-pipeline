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

package gov.nasa.kepler.ar.exporter.binarytable;

import java.util.Date;

/**
 * The information needed to create a binary table header.
 * 
 * @author Sean McCauliff
 *
 */
public interface BaseBinaryTableHeaderSource {
    
    /**
     * The kepler id of the target else -1.  This is here in the super interface
     * due to some ordering restrictions
     * @return this can return null if this binary table header does not describe
     * a single target.
     */
    Integer keplerId();

  
    /**
     * The number of rows in the binary table of this file.  This is usually the
     * number of cadences.
     * @return Must be non-negative.
     */
    int nBinaryTableRows();

    int readsPerCadence();

    /**
     * 
     * @return null, if this does not apply to this header.
     */
    Integer timeSlice();

    /**
     * 
     * @return null, if this does not apply to this header.
     */
    Integer meanBlackCounts();

    Date observationStartUTC();

    Date observationEndUTC();
    
    /**
     * 
     * @return null, if this does not apply to this header.
     */
    Integer longCadenceFixedOffset();
    
    /**
     * 
     * @return null, if this does not apply to this header.
     */
    Integer shortCadenceFixedOffset();
    
    /**
     * 
     * @return null, if this does not apply to this header.
     */
    double photonAccumulationTimeSec();

    /**
     * 
     * @return null, if this does not apply to this header.
     */
    double readoutTimePerFrameSec();

    int framesPerCadence();

    /**
     * 
     * @return null, if this does not apply to this header.
     */
    double timeResolutionOfDataDays();

    /**
     * 
     * @return null, if this does not apply to this header.
     */
    Double gainEPerCount();

    /**
     * 
     * @return null, if this does not apply to this header.
     */
    Double readNoiseE();
    
    
    double scienceFrameTimeSec();
    
    
    /**
     * This is used in the file creation date and the CHECKSUM and DATASUM 
     * keyword comments.  This should return the same value if called multiple
     * times.
     * @return non-null
     */
    Date generatedAt();


    /**
     * FITS EXTNAME value.
     * @return non-null
     */
    String extensionName();

    /**
     * 
     * @return true if the background was subtracted from the data values, else
     * false.
     */
    boolean backgroundSubtracted();
    
    
 
}
