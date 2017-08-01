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

package gov.nasa.kepler.mc.fc;

import gov.nasa.kepler.fc.FlatFieldModel;
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.fc.LinearityModel;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fc.ReadNoiseModel;
import gov.nasa.kepler.fc.TwoDBlackModel;
import gov.nasa.kepler.fc.UndershootModel;
import gov.nasa.kepler.fc.flatfield.FlatFieldOperations;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.linearity.LinearityOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.fc.twodblack.TwoDBlackOperations;
import gov.nasa.kepler.fc.undershoot.UndershootOperations;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;

public class AllModelsObject implements Persistable {
    
    private static double MJD_START = 55000;
    private static double MJD_END = 56000;
    private static int CCD_MODULE = 2;
    private static int CCD_OUTPUT = 1;
    
    private FlatFieldModel flatFieldModel;
    private GainModel gainModel;
    private LinearityModel linearityModel;
    private RaDec2PixModel raDec2PixModel;
    private ReadNoiseModel readNoiseModel;
    private TwoDBlackModel twoDBlackModel;
    private UndershootModel undershootModel;

    public AllModelsObject() {
        this(MJD_START, MJD_END, CCD_MODULE, CCD_OUTPUT);
    }
    
    public AllModelsObject(double mjdStart, double mjdEnd, int module, int output) {
        flatFieldModel = new FlatFieldOperations().retrieveFlatFieldModel(mjdStart, mjdEnd, module, output);
        gainModel = new GainOperations().retrieveGainModel(mjdStart, mjdEnd);
        linearityModel = new LinearityOperations().retrieveLinearityModel(module, output, mjdStart, mjdEnd);
        raDec2PixModel = new RaDec2PixOperations().retrieveRaDec2PixModel(mjdStart, mjdEnd);
        readNoiseModel = new ReadNoiseOperations().retrieveReadNoiseModel(mjdStart, mjdEnd);
        twoDBlackModel = new TwoDBlackOperations().retrieveTwoDBlackModel(mjdStart, mjdEnd, module, output);
        undershootModel = new UndershootOperations().retrieveUndershootModel(mjdStart, mjdEnd);
    }
    
    public void serializeAllToFile(String binDir) throws Exception {
        serializeModelToFile(binDir, "flat.bin", flatFieldModel);
        serializeModelToFile(binDir, "gain.bin", gainModel);
        serializeModelToFile(binDir, "linearity.bin", linearityModel);
        serializeModelToFile(binDir, "raDec2Pix.bin", raDec2PixModel);
        serializeModelToFile(binDir, "readNoise.bin", readNoiseModel);
        serializeModelToFile(binDir, "twoDBlack.bin", twoDBlackModel);
        serializeModelToFile(binDir, "undershoot.bin", undershootModel);
    }
 
    private void serializeModelToFile(String binDir, String filename, Persistable model) throws Exception {
        File file = new File(binDir + filename);
        
        FileOutputStream fos = new FileOutputStream(file);
        DataOutputStream dos = new DataOutputStream(fos);
        BinaryPersistableOutputStream bpos = new BinaryPersistableOutputStream(dos);
        bpos.save(model);
        dos.flush();
        fos.close();
    }
}
