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

package gov.nasa.kepler.systest;

import gov.nasa.spiffy.common.io.FileUtil;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

/**
 * @author Miles Cote
 * 
 */
public class TriggerFileGenerator {

    private static File dir;

    public static void main(String[] args) throws IOException {
        dir = new File("/path/to/trigger_files");
        FileUtil.cleanDir(dir);

        for (int i = 1; i <= 42; i++) {
            generateTriggerFile(i);
        }
    }

    private static void generateTriggerFile(int index) throws IOException {
        String i = String.format("%02d", index);

        BufferedWriter writer = new BufferedWriter(new FileWriter(new File(dir,
            "trigger-pdc-KSOP-1213_TC" + i + ".xml")));

        writer.write(""
            + "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
            + "<con:pipelineConfiguration databaseUrl=\"\" databaseUser=\"\" xmlns:con=\"http://kepler.nasa.gov/pi/configuration\">\n"
            + "<triggers>\n" + "  <trigger name=\"PDC_KSOP-1213_TC"
            + i
            + "\" instancePriority=\"5\" pipelineName=\"PHOTOMETRY_LC_TC"
            + i
            + "\">\n"
            + "    <pipelineParameter name=\"moduleOutputLists (2.1 and 7.3 only)\" classname=\"gov.nasa.kepler.common.pi.ModuleOutputListsParameters\"/>\n"
            + "    <pipelineParameter name=\"cadenceRange (Q10)\" classname=\"gov.nasa.kepler.common.pi.CadenceRangeParameters\"/>\n"
            + "    <pipelineParameter name=\"cadenceType (LC)\" classname=\"gov.nasa.kepler.common.pi.CadenceTypePipelineParameters\"/>\n"
            + "    <pipelineParameter name=\"ancillary\" classname=\"gov.nasa.kepler.common.pi.AncillaryPipelineParameters\"/>\n"
            + "    <pipelineParameter name=\"ancillaryDesignMatrix (LC)\" classname=\"gov.nasa.kepler.common.pi.AncillaryDesignMatrixParameters\"/>\n"
            + "    <pipelineParameter name=\"ancillaryEngineering\" classname=\"gov.nasa.kepler.common.pi.AncillaryEngineeringParameters\"/>\n"
            + "    <pipelineParameter name=\"bandSplitting (TC-"
            + i
            + ")\" classname=\"gov.nasa.kepler.pdc.BandSplittingParameters\"/>\n"
            + "    <pipelineParameter name=\"customTarget\" classname=\"gov.nasa.kepler.mc.CustomTargetParameters\"/>\n"
            + "    <pipelineParameter name=\"discontinuity\" classname=\"gov.nasa.kepler.mc.DiscontinuityParameters\"/>\n"
            + "    <pipelineParameter name=\"fluxType\" classname=\"gov.nasa.kepler.common.pi.FluxTypeParameters\"/>\n"
            + "    <pipelineParameter name=\"gapFill\" classname=\"gov.nasa.kepler.mc.GapFillModuleParameters\"/>\n"
            + "    <pipelineParameter name=\"goodnessMetric\" classname=\"gov.nasa.kepler.pdc.PdcGoodnessMetricParameters\"/>\n"
            + "    <pipelineParameter name=\"pdcHarmonicsIdentification (LC)\" classname=\"gov.nasa.kepler.pdc.PdcHarmonicsIdentificationParameters\"/>\n"
            + "    <pipelineParameter name=\"pdcMap (TC-"
            + i
            + ")\" classname=\"gov.nasa.kepler.pdc.PdcMapParameters\"/>\n"
            + "    <pipelineParameter name=\"pdc (bandSplittingEnabled)\" classname=\"gov.nasa.kepler.pdc.PdcModuleParameters\"/>\n"
            + "    <pipelineParameter name=\"pseudoTargetList\" classname=\"gov.nasa.kepler.mc.PseudoTargetListParameters\"/>\n"
            + "    <pipelineParameter name=\"saturationSegment (LC)\" classname=\"gov.nasa.kepler.common.SaturationSegmentModuleParameters\"/>\n"
            + "    <pipelineParameter name=\"spsdDetection\" classname=\"gov.nasa.kepler.pdc.SpsdDetectionParameters\"/>\n"
            + "    <pipelineParameter name=\"spsdDetector\" classname=\"gov.nasa.kepler.pdc.SpsdDetectorParameters\"/>\n"
            + "    <pipelineParameter name=\"spsdRemoval\" classname=\"gov.nasa.kepler.pdc.SpsdRemovalParameters\"/>\n"
            + "    <node moduleName=\"pdc\" nodePath=\"0\"/>\n"
            + "  </trigger>                                     \n"
            + "</triggers>                                      \n"
            + "<pipelines>                                      \n"
            + "  <pipeline name=\"PHOTOMETRY_LC_TC"
            + i
            + "\" description=\"description\" rootNodeIds=\"1\">\n"
            + "    <node moduleName=\"pdc\" startNewUow=\"true\" uowGeneratorClass=\"gov.nasa.kepler.mc.uow.ModOutCadenceUowTaskGenerator\" nodeId=\"1\" childNodeIds=\"\"/>\n"
            + "  </pipeline>                                    \n"
            + "</pipelines>                                     \n"
            + "<modules>                                        \n"
            + "</modules>                                       \n"
            + "</con:pipelineConfiguration>\n");

        writer.close();
    }

}
