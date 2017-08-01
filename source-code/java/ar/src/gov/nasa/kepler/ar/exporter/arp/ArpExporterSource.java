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

package gov.nasa.kepler.ar.exporter.arp;

import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.hibernate.dr.DataAnomaly;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.mc.SciencePixelOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;

import java.io.File;
import java.util.Collection;
import java.util.Date;
import java.util.List;


/**
 * Data source for ARP exporter.
 * 
 * @author Sean McCauliff
 *
 */
public interface ArpExporterSource {
    int skyGroup();

    int season();

    int quarter();

    long pipelineTaskId();

    /**
     * 
     * @return a constant non-null date
     */
    Date generatedAt();

    int dataReleaseNumber();

    int ccdOutput();

    int ccdModule();
    
    /**
     * 
     * @return an existing non-null directory
     */
    File exportDir();

    /**
     * 
     * @return a non-null timestamp that is incorporated into the exported file name.
     */
    String fileTimestamp();
    
    int startCadence();
    
    int endCadence();

    String programName();

    String subversionUrl();

    String subversionRevision();
    
    /**
     * Return the ARP target for this module/output.
     * @return This may return null if this mod/out does not have a target with 
     * the ARTIFACT_REMOVAL label.
     */
    ObservedTarget arpObservedTarget();

    SciencePixelOperations sciencePixelOps();

    FileStoreClient fileStoreClient();

    double startMidMjd();

    double endMidMjd();

    MjdToCadence mjdToCadence();

    List<DataAnomaly> dataAnomalies();
    
    TimestampSeries cadenceTimes();

    /**
     * The external target table id.
     * @return
     */
    int targetTableId();

    double readNoiseE();

    int meanBlack();

    double gainEPerCount();

    Collection<ConfigMap> configMaps();
    
    /**
     * @return A valid K2 campaign number when processing K2 data else this can return an undefined
     *  value.
     */
    int k2Campaign();
    
    /**
     * Rolling band pulse durations in units of long cadence.
     * @return non-null.
     */
    int[] rollingBandPulseDurationsLc();

}
