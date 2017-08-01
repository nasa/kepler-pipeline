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

package gov.nasa.kepler.ar.exporter;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.fc.flatfield.FlatFieldOperations;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.os.MemInfo;
import gov.nasa.spiffy.common.os.OperatingSystemType;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import nom.tam.fits.FitsException;

/**
 * Exports the Combined (large scale and small scale flat field) model as a
 * FITS image.
 * 
 * @author Sean McCauliff
 *
 */
public class CombinedFlatFieldExporter {
    
    private static final Log log = LogFactory.getLog(CombinedFlatFieldExporter.class);
    private static final OperatingSystemType operatingSystemType = OperatingSystemType.getInstance();

    private final FlatFieldOperations ffOp;
    private MemInfo memInfo = null;
    
    public CombinedFlatFieldExporter(FlatFieldOperations  ffOp) {
        this.ffOp = ffOp;
        try {
            memInfo  = operatingSystemType.getMemInfo();
        } catch (Exception e) {
        }
    }
    
    
    /**
     * 
     * @param outputDir
     * @throws PipelineException 
     * @throws IOException 
     * @throws FitsException 
     */
    public void export(File outputDir) 
        throws FitsException, IOException {
        
        FileUtil.mkdirs(outputDir);
        
        double[] imageTimes = ffOp.retrieveSmallFlatFieldImageTimes();
        Arrays.sort(imageTimes);
        FileNameFormatter fnameFormatter = new FileNameFormatter();
        for (double mjd : imageTimes) {  
            String fname = fnameFormatter.combinedFlatField(mjd);
            File outputFile = new File(outputDir,fname);
            exportForTime(mjd, outputFile);
        }
    }
    
    private void exportForTime(double mjd, File outputFile) 
        throws FitsException, IOException {
        
        CombinedFlatFieldFits cFff = new CombinedFlatFieldFits(outputFile.getName(), mjd);
        
        for (int module : FcConstants.modulesList) {
            for (int output : FcConstants.outputsList) {

                if (memInfo  != null) {
                    memInfo .logMemoryUsage(log);
                }
                float[][] combinedFlatField = ffOp.retrieveFlatField(module, output, mjd);
                cFff.addModuleOutput(combinedFlatField, module, output);
            }
        }
        
        cFff.write(outputFile);
 
    }
    
    
}
