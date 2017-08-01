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

import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.TransactionWrapper;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

public class TargetListSetUnUplinker {

    private String targetListSetName;

    public TargetListSetUnUplinker(String targetListSetName) {
        this.targetListSetName = targetListSetName;
    }

    public void unUplink() throws Exception {
        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
        TargetListSet tls = targetSelectionCrud.retrieveTargetListSet(targetListSetName);

        if (tls == null) {
            throw new IllegalArgumentException(
                "The targetListSet needs to exist in the database.\n  tlsName: "
                    + targetListSetName);
        }

        TargetTable targetTable = tls.getTargetTable();

        targetTable.setState(gov.nasa.kepler.hibernate.gar.ExportTable.State.LOCKED);

        if (tls.getType() == TargetType.LONG_CADENCE) {
            MaskTable maskTable = targetTable.getMaskTable();
            maskTable.setState(gov.nasa.kepler.hibernate.gar.ExportTable.State.LOCKED);

            TargetTable backgroundTable = tls.getBackgroundTable();
            backgroundTable.setState(gov.nasa.kepler.hibernate.gar.ExportTable.State.LOCKED);

            MaskTable backgroundMaskTable = backgroundTable.getMaskTable();
            backgroundMaskTable.setState(gov.nasa.kepler.hibernate.gar.ExportTable.State.LOCKED);
        }

        // un-uplink the TLS itself
        tls.setState(gov.nasa.kepler.hibernate.gar.ExportTable.State.LOCKED);
    }

    public static void main(String[] args) {
        if (args.length != 1) {
            System.err.println("USAGE: tls-uplink TLSNAME");
            System.err.println("  example: tls-uplink q1-lc");
            System.exit(-1);
        }

        final String tlsName = args[0];

        TransactionWrapper.run(new Runnable() {
            @Override
            public void run() {
                TargetListSetUnUplinker unUplinker = new TargetListSetUnUplinker(
                    tlsName);
                try {
                    unUplinker.unUplink();
                } catch (Exception e) {
                    throw new IllegalArgumentException("Unable to un-uplink.",
                        e);
                }
            }
        });
    }

}
