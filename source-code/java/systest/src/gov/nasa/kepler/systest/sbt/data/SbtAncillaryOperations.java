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

package gov.nasa.kepler.systest.sbt.data;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.common.AncillaryData;
import gov.nasa.kepler.common.AncillaryEngineeringData;
import gov.nasa.kepler.common.AncillaryPipelineData;
import gov.nasa.kepler.common.pi.AncillaryEngineeringParameters;
import gov.nasa.kepler.common.pi.AncillaryPipelineParameters;
import gov.nasa.kepler.mc.ancillary.AncillaryOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;

import java.util.List;

/**
 * This class retrieves {@link AncillaryData}.
 * 
 * @author Miles Cote
 * 
 */
public class SbtAncillaryOperations {

    private final AncillaryOperations ancillaryOperations;

    public SbtAncillaryOperations(AncillaryOperations ancillaryOperations) {
        this.ancillaryOperations = ancillaryOperations;
    }

    public List<SbtAncillaryEngineeringGroup> retrieveSbtAncillaryEngineeringGroups(
        List<SbtParameterGroup> sbtParameterGroups, MjdToCadence mjdToCadence) {
        List<SbtAncillaryEngineeringGroup> sbtAncillaryEngineeringGroups = newArrayList();
        for (SbtParameterGroup sbtParameterGroup : sbtParameterGroups) {
            if (sbtParameterGroup.getName()
                .equals(AncillaryEngineeringParameters.class.getSimpleName())) {
                for (SbtParameterMap sbtParameterMap : sbtParameterGroup.getParameterMaps()) {
                    AncillaryEngineeringParameters ancillaryEngineeringParameters = new AncillaryEngineeringParameters();
                    for (SbtParameterMapEntry entry : sbtParameterMap.getEntries()) {
                        String[] strings = entry.getValue()
                            .split(",");
                        if (entry.getName()
                            .equals("mnemonics")) {
                            ancillaryEngineeringParameters.setMnemonics(strings);
                        } else if (entry.getName()
                            .equals("interactions")) {
                            ancillaryEngineeringParameters.setInteractions(strings);
                        } else if (entry.getName()
                            .equals("modelOrders")) {
                            ancillaryEngineeringParameters.setModelOrders(getIntArray(strings));
                        } else if (entry.getName()
                            .equals("quantizationLevels")) {
                            ancillaryEngineeringParameters.setQuantizationLevels(getFloatArray(strings));
                        } else if (entry.getName()
                            .equals("intrinsicUncertainties")) {
                            ancillaryEngineeringParameters.setIntrinsicUncertainties(getFloatArray(strings));
                        }
                    }

                    int startCadence = sbtParameterMap.getStartCadence();
                    int endCadence = sbtParameterMap.getEndCadence();

                    double startMjd = mjdToCadence.cadenceToMjd(startCadence);
                    double endMjd = mjdToCadence.cadenceToMjd(endCadence);

                    List<AncillaryEngineeringData> ancillaryEngineeringData = ancillaryOperations.retrieveAncillaryEngineeringData(
                        ancillaryEngineeringParameters.getMnemonics(),
                        startMjd, endMjd);

                    sbtAncillaryEngineeringGroups.add(new SbtAncillaryEngineeringGroup(
                        startCadence, endCadence,
                        ancillaryEngineeringParameters,
                        ancillaryEngineeringData));
                }
            }
        }

        return sbtAncillaryEngineeringGroups;
    }

    public List<SbtAncillaryPipelineGroup> retrieveSbtAncillaryPipelineGroups(
        List<SbtParameterGroup> sbtParameterGroups, MjdToCadence mjdToCadence) {
        List<SbtAncillaryPipelineGroup> sbtAncillaryPipelineGroups = newArrayList();
        for (SbtParameterGroup sbtParameterGroup : sbtParameterGroups) {
            if (sbtParameterGroup.getName()
                .equals(AncillaryPipelineParameters.class.getSimpleName())) {
                for (SbtParameterMap sbtParameterMap : sbtParameterGroup.getParameterMaps()) {
                    AncillaryPipelineParameters ancillaryPipelineParameters = new AncillaryPipelineParameters();
                    for (SbtParameterMapEntry entry : sbtParameterMap.getEntries()) {
                        String[] strings = entry.getValue()
                            .split(",");
                        if (entry.getName()
                            .equals("mnemonics")) {
                            ancillaryPipelineParameters.setMnemonics(strings);
                        } else if (entry.getName()
                            .equals("interactions")) {
                            ancillaryPipelineParameters.setInteractions(strings);
                        } else if (entry.getName()
                            .equals("modelOrders")) {
                            ancillaryPipelineParameters.setModelOrders(getIntArray(strings));
                        }
                    }

                    int startCadence = sbtParameterMap.getStartCadence();
                    int endCadence = sbtParameterMap.getEndCadence();

                    double startMjd = mjdToCadence.cadenceToMjd(startCadence);
                    double endMjd = mjdToCadence.cadenceToMjd(endCadence);

                    List<AncillaryPipelineData> ancillaryPipelineData = ancillaryOperations.retrieveAncillaryPipelineData(
                        ancillaryPipelineParameters.getMnemonics(), startMjd,
                        endMjd);

                    sbtAncillaryPipelineGroups.add(new SbtAncillaryPipelineGroup(
                        startCadence, endCadence, ancillaryPipelineParameters,
                        ancillaryPipelineData));
                }
            }
        }

        return sbtAncillaryPipelineGroups;
    }

    private int[] getIntArray(String[] strings) {
        int[] ints = new int[strings.length];
        for (int i = 0; i < strings.length; i++) {
            ints[i] = Integer.parseInt(strings[i]);
        }

        return ints;
    }

    private float[] getFloatArray(String[] strings) {
        float[] floats = new float[strings.length];
        for (int i = 0; i < strings.length; i++) {
            floats[i] = Float.parseFloat(strings[i]);
        }

        return floats;
    }

}
