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

import gov.nasa.kepler.common.Iso8601Formatter;
import gov.nasa.kepler.hibernate.dbservice.TransactionWrapper;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.gar.HuffmanTable;
import gov.nasa.kepler.hibernate.gar.RequantTable;

import java.text.DateFormat;

public class CompressionUplinker {

    private int externalId;
    private int requantDatabaseId;
    private int huffmanDatabaseId;
    private final String startTime;
    private final String endTime;

    public CompressionUplinker(int externalId, int requantDatabaseId,
        int huffmanDatabaseId, String startTime, String endTime) {
        this.externalId = externalId;
        this.requantDatabaseId = requantDatabaseId;
        this.huffmanDatabaseId = huffmanDatabaseId;
        this.startTime = startTime;
        this.endTime = endTime;
    }

    public void uplink() throws Exception {
        CompressionCrud compressionCrud = new CompressionCrud();
        HuffmanTable huffmanTable = compressionCrud.retrieveHuffmanTable(huffmanDatabaseId);
        RequantTable requantTable = compressionCrud.retrieveRequantTable(requantDatabaseId);

        DateFormat formatter = Iso8601Formatter.dateTimeFormatter();

        huffmanTable.setExternalId(externalId);
        huffmanTable.setState(State.UPLINKED);
        huffmanTable.setPlannedStartTime(formatter.parse(startTime));
        huffmanTable.setPlannedEndTime(formatter.parse(endTime));

        requantTable.setExternalId(externalId);
        requantTable.setState(State.UPLINKED);
        requantTable.setPlannedStartTime(formatter.parse(startTime));
        requantTable.setPlannedEndTime(formatter.parse(endTime));
    }

    public static void main(String[] args) {

        if (args.length != 5) {
            System.err.println("USAGE: compression-uplink EXTERNALID REQUANTDATABASEID HUFFMANDATABASEID STARTTIME ENDTIME");
            System.err.println("  example: compression-uplink 170 27 26 2009-03-17T16:22:07Z 2009-06-17T16:22:07Z");
            System.err.println("  note: REQUANTDATABASEID is GAR_REQUANT_TABLE.ID");
            System.err.println("  note: HUFFMANDATABASEID is GAR_HUFFMAN_TABLE.ID");
            System.exit(-1);
        }

        final String externalIdStr = args[0];
        final String requantDatabaseIdStr = args[1];
        final String huffmanDatabaseIdStr = args[2];
        final String startTime = args[3];
        final String endTime = args[4];

        TransactionWrapper.run(new Runnable() {
            @Override
            public void run() {
                int externalId = Integer.parseInt(externalIdStr);
                int requantDatabaseId = Integer.parseInt(requantDatabaseIdStr);
                int huffmanDatabaseId = Integer.parseInt(huffmanDatabaseIdStr);

                CompressionUplinker uplinker = new CompressionUplinker(
                    externalId, requantDatabaseId, huffmanDatabaseId,
                    startTime, endTime);
                try {
                    uplinker.uplink();
                } catch (Exception e) {
                    throw new IllegalArgumentException("Unable to uplink.", e);
                }
            }
        });
    }

}
