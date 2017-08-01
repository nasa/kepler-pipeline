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

package gov.nasa.kepler.hibernate.tad;

import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.TransactionWrapper;
import gov.nasa.spiffy.common.pi.PipelineException;

public class SupplementalTargetListSetSetter {

    private final TargetSelectionCrud targetSelectionCrud;

    public SupplementalTargetListSetSetter(
        TargetSelectionCrud targetSelectionCrud) {
        this.targetSelectionCrud = targetSelectionCrud;
    }

    public void set(String origTlsName, String suppTlsName) {
        TargetListSet origTls = targetSelectionCrud.retrieveTargetListSet(origTlsName);
        if (origTls == null) {
            throw new IllegalArgumentException(
                "The origTls must exist in the database.\n  origTlsName: "
                    + origTlsName);
        }

        TargetListSet suppTls = targetSelectionCrud.retrieveTargetListSet(suppTlsName);
        if (suppTls == null) {
            throw new IllegalArgumentException(
                "The suppTls must exist in the database.\n  suppTlsName: "
                    + suppTlsName);
        }

        TargetTable oldTargetTable = origTls.getTargetTable();
        TargetTable newTargetTable = suppTls.getTargetTable();

        if (oldTargetTable.getObservingSeason() != newTargetTable.getObservingSeason()) {
            throw new PipelineException(
                "oldTargetTable and newTargetTable must have the same observing season.\n  oldObservingSeason: "
                    + oldTargetTable.getObservingSeason()
                    + "\n  newObservingSeason: "
                    + newTargetTable.getObservingSeason());
        }

        origTls.setSupplementalTls(suppTls);
    }

    public static void main(String[] args) {
        if (args.length != 2) {
            System.err.println("USAGE: set-supplemental-target-list-set ORIG_TLS_NAME SUPP_TLS_NAME");
            System.err.println("EXAMPLE: set-supplemental-target-list-set quarter1_spring2009_lc_v2 quarter1_spring2009_lc_v2_supp_v2");
            System.exit(-1);
        }

        final String origTlsName = args[0];
        final String suppTlsName = args[1];

        TransactionWrapper.run(new Runnable() {
            @Override
            public void run() {
                SupplementalTargetListSetSetter setter = new SupplementalTargetListSetSetter(
                    new TargetSelectionCrud());
                setter.set(origTlsName, suppTlsName);
            }
        });
    }

}
