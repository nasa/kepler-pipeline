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

package gov.nasa.kepler.ar.exporter.dv;

import gov.nasa.kepler.ar.exporter.dv.DvResultsExporter;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.hibernate.dv.DvExternalTceModelDescription;
import gov.nasa.kepler.hibernate.dv.DvLimbDarkeningModel;
import gov.nasa.kepler.hibernate.dv.DvPlanetResults;
import gov.nasa.kepler.hibernate.dv.DvTargetResults;
import gov.nasa.kepler.hibernate.dv.DvTransitModelDescriptions;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.util.Collections;
import java.util.Date;

import org.junit.Before;
import org.junit.Test;

/**
 * @author Sean McCauliff
 * 
 */
public class DvResultsExporterTest {

    private final File outputDir = 
        new File(Filenames.BUILD_TEST, "DvResultsExporterTest");

    @Before
    public void setUp() throws Exception {
        FileUtil.mkdirs(outputDir);
    }

    @Test
    public void dvResultsExporterTest() throws Exception {
        DvTargetResults targets = new DvTargetResults.Builder(FluxType.SAP, 1,
            1, 7, new PipelineTask()).build();
        DvPlanetResults planets = new DvPlanetResults.Builder(1, 1, 7, 1,
            new PipelineTask()).fluxType(FluxType.SAP)
            .build();
        DvLimbDarkeningModel model = new DvLimbDarkeningModel.Builder(1,
            FluxType.SAP, 1, new PipelineTask()).build();
        PipelineTask pipelineTask = new PipelineTask();
        DvExternalTceModelDescription modelDescription = new DvExternalTceModelDescription(
            pipelineTask, "");
        DvTransitModelDescriptions transitModelDescriptions = new DvTransitModelDescriptions(
            pipelineTask, "", "");
        final Date timeStamp = new Date();
        DvResultsExporter exporter = new DvResultsExporter() {
            @Override
            protected Date dateFromPlanetResults(DvPlanetResults presult) {
                return timeStamp;
            }
        };

        exporter.export(Collections.singletonList(targets)
            .iterator(), Collections.singletonList(planets)
            .iterator(), Collections.singletonList(model), modelDescription,
            transitModelDescriptions, timeStamp, outputDir);

    }
}
