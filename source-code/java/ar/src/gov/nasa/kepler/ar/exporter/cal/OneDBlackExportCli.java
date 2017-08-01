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

package gov.nasa.kepler.ar.exporter.cal;

import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.base.Preconditions.checkState;
import gov.nasa.kepler.ar.exporter.cal.AbstractBlackExportCli.CadenceRange;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.hibernate.cal.BlackAlgorithm;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.mc.blob.BlobOperations;

import java.io.File;

/**
 * Application to extract 1D Black files from the File Store and write them to
 * a specified directory. 
 * First start the File Store service.
 * Invoke as
 * "runjava export-1dblack quarter data-release-number time-stamp output-directory-pathname"
 * , where quarter is an int in [0,17], data-release-number is a positive int,
 * time-stamp is a Date formatted as this.timeStampFormat, and
 * output-directory-pathname is the pathname of an existing directory.
 * 
 * @author Lee Brownston
 *
 */
public class OneDBlackExportCli extends AbstractBlackExportCli {

    /** The usage message. */
    private static final String USAGE_MESSAGE =
        "Usage: runjava export-1dblack quarter data-release-number time-stamp output-directory-pathname";

    /** {@inheritDoc} */
    @Override
    protected String blobFilename(int module, int output) {
        final String result = "kplr" + this.timeStampString + "-q"
            + String.format("%02d", this.quarter) + "-"
            + String.format("%02d", module) + String.format("%1d", output)
            + "-dr" + String.format("%02d", this.dataReleaseNumber)
            + "_1dblack.mat";
        // Postcondition result.length = 4 + 11 + 2 + 2 + 1 + 2 + 1 + 3 + 2 + 12
        return result;
    }

    /** {@inheritDoc} */
    @Override
    protected void exportOneBlob(int module, int output) {
        final CadenceRange cadenceRange = quarterToCadenceRange(quarter);
        checkNotNull(cadenceRange, "Invalid quarter");
        final long startCadence = cadenceRange.start;
        final long endCadence = cadenceRange.end;
        
        // For now, hard-code it to handle long cadences only.
        // If short cadences are required, the Cadence Range could specify
        // CadenceType
        final CadenceType cadenceType = CadenceType.LONG;
        final BlackAlgorithm blackAlgorithm =
            getBlackAlgorithm(module, output, startCadence, endCadence);
        // If UNDEFINED, there is nothing to export
        // If DYNABLACK, the black algorithm results are out of date
        if ((blackAlgorithm == BlackAlgorithm.EXP_1D_BLACK) ||
            (blackAlgorithm == BlackAlgorithm.POLYNOMIAL_1D_BLACK)) {
            final BlobOperations blobOperations =
                new BlobOperations(outputDirectory);
            BlobSeries<String> blobSeries = 
                blobOperations.retrieveCalOneDBlackFitBlobFileSeries(
                    module, output, cadenceType, (int)startCadence, (int)endCadence);
            writeBlobSeries(module, output, blobSeries);
        }
    }
    
    /** {@inheritDoc} */
    @Override
    protected String usageMessage() {
        return USAGE_MESSAGE;
    }
    
    /**
     * Entry point for command-line invocation.
     * 
     * @param args the command-line arguments
     */
    public static void main(String[] args) {
        final OneDBlackExportCli oneDBlackExportCli = new OneDBlackExportCli();
        oneDBlackExportCli.export(args);
    }

}
