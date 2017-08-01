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

package gov.nasa.kepler.ar.exporter.collateral;

import java.io.File;
import java.util.Collection;
import java.util.Date;

import gov.nasa.kepler.ar.exporter.RollingBandUtils;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.hibernate.cal.BlackAlgorithm;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.pmrf.CollateralPmrfTable;

/**
 * Source information for the CollateralPixelExporter.
 * 
 * @author Sean McCauliff
 *
 */
public interface CollateralPixelExporterSource {

    int ccdModule();
    
    int ccdOutput();
    
    CadenceType cadenceType();

    int endCadence();

    int startCadence();

    CollateralPmrfTable prmfTable();

    FileStoreClient fileStoreClient();

    /** The mid point of the first cadence. */
    double startMidMjd();

    /** The mid point of the last cadence. */
    double endMidMjd();
    
    /** The start of the first cadence. */
    double startStartMjd();
    
    /** The end of the last cadence. */
    double endEndMjd();

    Collection<ConfigMap> configMaps();

    File exportDir();

    long pipelineTaskId();

    int skyGroup();

    int dataRelease();

    int quarter();

    int season();
    
    int k2Campaign();

    int meanBlack();

    double gainE();

    double readNoseE();

    MjdToCadence mjdToCadence();
    
    /**
     * 
     * @return This may return null to use a default time stamp.
     */
    String defaultFileTimestamp();
    
    Date generatedAt();

    String subversionRevision();

    String subversionUrl();

    /**
     * @return The external target table id that defines when these pixels were collected.
     */
    int targetTableId();
    
    /**
     * @return non-null
     */
    RollingBandUtils rollingBandUtils();
    
    /**
     * @return this may return null
     */
    BlackAlgorithm blackAlgorithm();
}
