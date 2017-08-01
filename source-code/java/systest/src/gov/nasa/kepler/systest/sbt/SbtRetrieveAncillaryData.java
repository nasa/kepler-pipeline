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

package gov.nasa.kepler.systest.sbt;

import gov.nasa.kepler.common.AncillaryEngineeringData;
import gov.nasa.kepler.common.AncillaryPipelineData;
import gov.nasa.kepler.common.TicToc;
import gov.nasa.kepler.hibernate.dr.AncillaryDictionaryCrud;
import gov.nasa.kepler.hibernate.dr.AncillaryDictionaryMnemonic;
import gov.nasa.kepler.mc.ancillary.AncillaryOperations;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;

public class SbtRetrieveAncillaryData extends AbstractSbt {
    
    private static final String SDF_FILE_NAME = "/tmp/sbt-retrieve-ancillary-data.sdf";
    private static final boolean REQUIRES_DATABASE = true;
    private static final boolean REQUIRES_FILESTORE = true;
    
    private static final double LOW_MJD = 0.0;
    private static final double HIGH_MJD = 70000.0;
    
    public static class AncillaryContainer implements Persistable {
        public List<AncillaryEngineeringData> engineering;
        public List<AncillaryPipelineData> pipeline;
        
        public AncillaryContainer(List<AncillaryEngineeringData> ancillaryEngineeringData, List<AncillaryPipelineData> pipelineEngineeringData) {
            this.engineering = ancillaryEngineeringData;
            this.pipeline = pipelineEngineeringData;
        }
    }

    public SbtRetrieveAncillaryData() {
        super(REQUIRES_DATABASE, REQUIRES_FILESTORE);
    }

    public String retrieveAncillaryData(String[] mnemonics, double startMjd, double endMjd) throws Exception {
        if (! validateDatastores()) {
            return "";
        }
        
        TicToc.tic("Retrieving available data ranges...");

        AncillaryOperations ancillaryOperations = new AncillaryOperations();
        
        List<AncillaryEngineeringData> engineeringData = ancillaryOperations.retrieveAncillaryEngineeringData(mnemonics, startMjd, endMjd);
        List<AncillaryPipelineData> pipelineData = ancillaryOperations.retrieveAncillaryPipelineData(mnemonics, startMjd, endMjd);
        AncillaryContainer ancillaryContainer = new AncillaryContainer(engineeringData, pipelineData);
        
        TicToc.toc();
        
        return makeSdf(ancillaryContainer, SDF_FILE_NAME);
    }
    
    public String retrieveAncillaryData(double startMjd, double endMjd) throws Exception {
        String[] allMnemonics = retrieveAllMnemonics();
        return retrieveAncillaryData(allMnemonics, startMjd, endMjd);
    }

    public String retrieveAncillaryData(String[] mnemonics) throws Exception {
        return retrieveAncillaryData(mnemonics, LOW_MJD, HIGH_MJD);
    }
    
    public String retrieveAncillaryData() throws Exception {
        return retrieveAncillaryData(LOW_MJD, HIGH_MJD);
    }
    
    private String[] retrieveAllMnemonics() {
        AncillaryDictionaryCrud ancillaryDictionaryCrud = new AncillaryDictionaryCrud();
        List<AncillaryDictionaryMnemonic> ancillaryDictionary = ancillaryDictionaryCrud.retrieveAncillaryDictionary();
        
        List<String> mnemonics = new ArrayList<String>();
        for (AncillaryDictionaryMnemonic ancillaryDictionaryMnemonic : ancillaryDictionary) {
            mnemonics.add(ancillaryDictionaryMnemonic.getMnemonic());
        }
        return mnemonics.toArray(new String[0]);
    }
        
    @SuppressWarnings("unused")
    public static void main(String[] args) throws Exception {
        
        String[] mnemonics = { "NN2XTWT2PWST" };
        SbtRetrieveAncillaryData sbt = new SbtRetrieveAncillaryData();
        
//        String path1 = sbt.retrieveAncillaryData();
        String path2 = sbt.retrieveAncillaryData(mnemonics);
        String path3 = sbt.retrieveAncillaryData(mnemonics, 55006.0, 55037.0);
        String path4 = sbt.retrieveAncillaryData(55006.0, 55037.0);
    }
}
