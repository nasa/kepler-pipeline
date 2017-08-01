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

package gov.nasa.kepler.gar.requant;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.kepler.common.utils.SerializationTest;
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.fc.ReadNoiseModel;
import gov.nasa.kepler.fc.TwoDBlackModel;
import gov.nasa.kepler.mc.gar.RequantTable;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;

import org.junit.Test;

/**
 * Tests the {@link RequantInputs} and {@link RequantOutputs} classes.
 * 
 * @author Bill Wohler
 */
public class RequantSerializationTest extends SerializationTest {

    @Override
    @Test
    public void testInputs() throws IllegalAccessException {
        super.testInputs();
    }

    @Override
    @Test
    public void testOutputs() throws IllegalAccessException {
        super.testOutputs();
    }

    @Override
    protected Persistable createInputs() {
        return new RequantInputs();
    }

    @Override
    protected Persistable createOutputs() {
        return new RequantOutputs();
    }

    @Override
    protected Persistable populateInputs(Persistable inputs) {
        RequantInputs requantInputs = (RequantInputs) inputs;

        requantInputs.setRequantModuleParameters(new RequantModuleParameters());
        requantInputs.setScConfigParameters(new PlannedSpacecraftConfigParameters());
        requantInputs.setGainModel(new GainModel(new double[] { 1.0 },
            new double[][] { { 2.0, 3.0 } }));
        requantInputs.setReadNoiseModel(new ReadNoiseModel(
            new double[] { 4.0 }, new double[][] { { 5.0, 6.0 } }));
        requantInputs.setTwoDBlackModels(new ArrayList<TwoDBlackModel>());

        return requantInputs;
    }

    @Override
    protected Persistable populateOutputs(Persistable outputs) {
        RequantOutputs requantOutputs = (RequantOutputs) outputs;

        int[] requantEntries = new int[FcConstants.REQUANT_TABLE_LENGTH];
        for (int i = 0; i < FcConstants.REQUANT_TABLE_LENGTH; i++) {
            requantEntries[i] = i;
        }
        int[] meanBlackEntries = new int[FcConstants.MODULE_OUTPUTS];
        for (int i = 0; i < FcConstants.MODULE_OUTPUTS; i++) {
            meanBlackEntries[i] = i;
        }
        RequantTable requantTable = new RequantTable();
        requantTable.setRequantEntries(requantEntries);
        requantTable.setMeanBlackEntries(meanBlackEntries);
        requantOutputs.setRequantTable(requantTable);

        return requantOutputs;
    }
}
