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

package gov.nasa.kepler.ar.exporter.primary;

import gov.nasa.kepler.common.FitsConstants.ObservingMode;

import java.util.Date;

/**
 * The information needed to render a primary FITS header for many different files.
 * @author Sean McCauliff
 *
 */
public interface BasePrimaryHeaderSource {

    /**
     * The kepler id for the object being described in the output file.
     * Due to the ordering of the keywords in the file this still needs to be
     * here.  Sorry.
     * @return  If -1 is returned then this header is not about any particular
     * kepler id.  Else this should return a valid kepler id.
     */
    int keplerId();
    
    
    /**
     * The subversion revision number of the program used to generate this
     * data.
     * @return non-null and non-empty
     */
    String subversionRevision();
    
    /**
     * The URL used to checkout the source of the program that is generating
     * these files.
     * 
     * @return non-null and non-empty
     */
    String subversionUrl();
    
    /** If this is a class name then it should just be the simple name
     * not the fully qualified name.
     * 
     * @return non-null and non-empty
     */
    String programName();
    
    /**
     * The pipeline task id that is generating the file.
     * @return
     */
    long pipelineTaskId();
    
    int ccdModule();
    
    int ccdOutput();
   
    int ccdChannel();
    
    /**
     * 
     * @return This may be null.
     */
    Integer skyGroup();
    
    /**
     * This should return a valid data release number during an actual production
     * export.
     * 
     * @return
     */
    int dataReleaseNumber();
    
    /**
     * The kepler quarter for the data being described in this file.  The data
     * in the file may not cross quarter boundries.
     * @return
     */
    int quarter();
    
    /**
     * The observing season for the data being described in this file.
     * @return
     */
    int season();
    
    /**
     * 
     * @return non-null
     */
    ObservingMode observingMode();
    
    /**
     * Target's right ascension in degrees.
     * @return  This may be a NaN in order to indicate the RA of a target is not
     * known.
     */
    double raDegrees();
    
    /**
     * This is used in the file creation date and the CHECKSUM and DATASUM 
     * keyword comments.  This should return the same value if called multiple
     * times.
     * @return
     */
    Date generatedAt();
    
    /**
     * K2 campaign number.
     * @return The K2 campaign number or some negative number if we don't know it.
     */
    int k2Campaign();
    
    /**
     * 
     * @return true if this is K2 else returns false. 
     */
    boolean isK2Target();


    /**
     * 
     * @return the external target table identifier associated with this data.
     * If -1 is returned then the formatter should not emit a keyword
     * with this value.
     */
    int targetTableId();
    
    /**
     * The NEXTEND keyword value.
     * @return A non-negative integer.
     */
    int extensionHduCount();
}
