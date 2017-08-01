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

import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.HuffmanEntry;
import gov.nasa.kepler.hibernate.gar.HuffmanTable;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.List;

public class SbtRetrieveHuffmanTable extends AbstractSbt {
    public static final String SDF_FILE_NAME = "/tmp/sbt-retrieve-huffman-table.sdf";
    private static final boolean REQUIRES_DATABASE = true;
    private static final boolean REQUIRES_FILESTORE = true;

    public static class HuffmanTableContainer implements Persistable {
        float theoreticalCompressionRate;
        float effectiveCompressionRate;
        String[] bitstrings;
        long[] histogramEntries;
        
        public HuffmanTableContainer(HuffmanTable huffmanTable) {
            bitstrings = new String[huffmanTable.getEntries().size()];
            histogramEntries = new long[huffmanTable.getEntries().size()];
        }
        
        public void setFields(HuffmanTable huffmanTable) {
            this.theoreticalCompressionRate = huffmanTable.getTheoreticalCompressionRate();
            this.effectiveCompressionRate = huffmanTable.getEffectiveCompressionRate();
            
            List<HuffmanEntry> entries = huffmanTable.getEntries();
            for (int ii = 0; ii < entries.size(); ++ii) {
                HuffmanEntry entry = entries.get(ii);
                bitstrings[ii] = entry.getBitstring();
                histogramEntries[ii] = entry.getMasterHistogramEntry();
            }
        }
    }

    public SbtRetrieveHuffmanTable() {
        super(REQUIRES_DATABASE, REQUIRES_FILESTORE);
    }
           
    public String retrieveHuffmanTable(int tableId) throws Exception {
        if (! validateDatastores()) {
            return "";
        }
        
        DatabaseService dbService = DatabaseServiceFactory.getInstance();
        CompressionCrud compressionCrud = new CompressionCrud(dbService);

        HuffmanTable huffmanTable = compressionCrud.retrieveUplinkedHuffmanTable(tableId);
        HuffmanTableContainer container = new HuffmanTableContainer(huffmanTable);
        container.setFields(huffmanTable);
        
        return makeSdf(container, SDF_FILE_NAME);
    }
    /**
     * @param args
     * @throws Exception 
     */
    public static void main(String[] args) throws Exception {
        SbtRetrieveHuffmanTable sbt = new SbtRetrieveHuffmanTable();
        sbt.retrieveHuffmanTable(170);
        sbt.retrieveHuffmanTable(200);
    }

}
