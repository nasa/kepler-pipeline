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

package gov.nasa.kepler.cm;

import gov.nasa.spiffy.common.pi.PipelineException;

/**
 * An exception thrown when loading SCP data into the KIC.
 * 
 * @author Bill Wohler
 */
public class IngestScpException extends PipelineException {

    private static final long serialVersionUID = 10000L; // 1.0.0
    private int errorCount;
    private int fileCount;

    /**
     * Creates an IngestScpException with the given error count and a file count
     * of 1.
     * 
     * @param errorCount the number of errors encountered in this file
     */
    public IngestScpException(int errorCount) {
        this(errorCount, 1);
    }

    /**
     * Creates an IngestScpException with the given error count and file count.
     * 
     * @param errorCount the number of errors encountered during this load.
     * @param fileCount the number of files that contained errors.
     */
    public IngestScpException(int errorCount, int fileCount) {
        super();
        this.errorCount = errorCount;
        this.fileCount = fileCount;
    }

    /**
     * Returns the number of errors in the file or group of files.
     * 
     * @return the number of errors.
     */
    public int getErrorCount() {
        return errorCount;
    }

    /**
     * Returns the number of files that contained errors.
     * 
     * @return the number of files
     */
    public int getFileCount() {
        return fileCount;
    }

    /**
     * Returns the detail message string of this throwable.
     * 
     * @return the detail message string of this Throwable instance (which may
     * be null).
     */
    @Override
    public String getMessage() {
        StringBuilder s = new StringBuilder();
        s.append("Encountered ")
            .append(getErrorCount())
            .append(" error");
        if (getErrorCount() > 1) {
            s.append("s");
        }
        s.append(" in ")
            .append(getFileCount())
            .append(" file");
        if (getFileCount() > 1) {
            s.append("s");
        }

        return s.toString();
    }
}
