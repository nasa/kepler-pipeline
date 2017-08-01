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
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.fc.ReadNoiseModel;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.RequantTable;
import gov.nasa.kepler.hibernate.tad.TargetTable;

import java.util.List;

public class ParametersUsedInCalibration {

    private double cachedGain = Double.NaN;
    private double cachedReadNoise = Double.NaN;
    
    private final ReadNoiseOperations readNoiseOps;
    private final GainOperations gainOps;
    private final TargetTable targetTable;
    private final CompressionCrud compressionCrud;
    private final double startMjd;
    private final double endMjd;
    private final int ccdModule;
    private final int ccdOutput;
    

    public ParametersUsedInCalibration(ReadNoiseOperations readNoiseOps,
        GainOperations gainOps, TargetTable targetTable,
        CompressionCrud compressionCrud, double startMjd, double endMjd,
        int ccdModule, int ccdOutput) {

        this.readNoiseOps = readNoiseOps;
        this.gainOps = gainOps;
        this.targetTable = targetTable;
        this.compressionCrud = compressionCrud;
        this.startMjd = startMjd;
        this.endMjd = endMjd;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
    }

    public int meanBlackValue() {
        List<RequantTable> requantTables =
            compressionCrud.retrieveRequantTable(targetTable);
        if (requantTables.size() != 1) {
            throw new IllegalStateException("Expected one requantization table, but found " + requantTables.size());
        }
        return requantTables.get(0).getMeanBlackValue(ccdModule, ccdOutput);
    }

    public double readNoiseE() {
        if (!Double.isNaN(cachedReadNoise)) {
            return cachedReadNoise;
        }
        
        ReadNoiseModel readNoiseModel =
            readNoiseOps.retrieveReadNoiseModel(startMjd, endMjd);

        if (readNoiseModel.size() != 1 ) {
            throw new IllegalStateException("Expected only one read noise model, but found "
                + readNoiseModel.size());
        }
        
        
        double readNoiseDN = readNoiseModel.getConstants()[0][FcConstants.getChannelNumber(ccdModule, ccdOutput) - 1];
        cachedReadNoise = gainE() * readNoiseDN;
        return cachedReadNoise;
    }
    

    public double gainE() {
        if (!Double.isNaN(cachedGain)) {
            return cachedGain;
        }
        
        //This shouldn't change between target tables.
            GainModel gainModel = gainOps.retrieveGainModel(startMjd, endMjd);
            if (gainModel.size() != 1) {
                throw new IllegalStateException("Expected only one gain model.");
            }
            cachedGain = gainModel.getConstants()[0][FcConstants.getChannelNumber(ccdModule, ccdOutput) - 1];
            return cachedGain;
    }

    
    
}
