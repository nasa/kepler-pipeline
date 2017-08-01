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

import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.cm.KicOverride;
import gov.nasa.kepler.hibernate.cm.KicOverrideModel;
import gov.nasa.kepler.hibernate.dr.DataAnomaly;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.pi.OriginatorsModelRegistryChecker;

import java.io.File;
import java.util.Collection;
import java.util.Date;
import java.util.List;

/**
 * Exporter source for single and multi-quarter exporters.
 * 
 * @author Sean McCauliff
 *
 */
public interface BaseExporterSource {

    /**
     * 
     * @return this should return the same, non-null value every time it is called.
     */
    Date generatedAt();
    
    /**
     * 
     * @return non-null
     */
    File exportDirectory();
    
    CadenceType cadenceType();

    int startCadence();
    
    int endCadence();
    
    /**
     * The count of the number of cadences; end - start + 1.
     * @return a positive integer
     */
    int cadenceCount();
    
    /**
     * Per KSOC-1111, {@link CelestialObjectOperations} can be used here, now that
     * data accountability for {@link KicOverride}s has been implemented.
     * Modifications from the {@link KicOverrideModel} are desired. 
     * @return non-null
     */
    List<CelestialObject> celestialObjects();
    
    /**
     * The name of the program exporting the files.
     * 
     * @return A non-null, non-empty value.
     */
    String programName();
    
    /**
     * 
     * @return If the data release is not known then this should return -1.
     */
    int dataReleaseNumber();

    /**
     * This is the pipeline task id of the exporter task itself. If the exporter
     * is not being run from within a pipeline task then this should return -1.
     * 
     * @return -1 or pipeline instance number
     */
    long pipelineTaskId();
    
    /**
     * The first cadence of this TimestampSeries should be startCadence() the
     * last cadence should be endCadence().  The start cadence and end cadence
     * should be defined; not gapped.
     * 
     * @return non-null
     */
    TimestampSeries timestampSeries();
    
    /**
     * 
     * @return non-null
     */
    MjdToCadence mjdToCadence();
    
    /**
     * Config maps for the time interval covered by [startCadence,endCadence]
     * 
     * @return
     */
    Collection<ConfigMap> configMaps();
    
    /**
     * 
     * @return non-null
     */
    FileStoreClient fsClient();

    OriginatorsModelRegistryChecker originatorsModelRegistryChecker();
    
    /**
     * 
     * @return non-null
     */
    List<DataAnomaly> anomalies();

}
