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

import gov.nasa.kepler.common.pi.PlannedPhotometerConfigParameters;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.TransactionWrapper;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.TadReport;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import java.util.List;

public class TargetListSetUplinker {

    private String targetListSetName;
    private PlannedPhotometerConfigParameters photometerConfigParams;

    public TargetListSetUplinker(String targetListSetName,
        PlannedPhotometerConfigParameters photometerConfigParams) {
        this.targetListSetName = targetListSetName;
        this.photometerConfigParams = photometerConfigParams;
    }

    public void uplink() throws Exception {
        // Uplink target and mask tables.
        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
        TargetListSet tls = targetSelectionCrud.retrieveTargetListSet(targetListSetName);

        // get TargetTable externalId.
        int targetTableExternalId = 0;
        switch (tls.getType()) {
            case LONG_CADENCE:
                targetTableExternalId = photometerConfigParams.getLctExternalId();
                break;
            case SHORT_CADENCE:
                targetTableExternalId = photometerConfigParams.getSctExternalId();
                break;
            case REFERENCE_PIXEL:
                targetTableExternalId = photometerConfigParams.getRptExternalId();
                break;
        }

        TargetTable targetTable = tls.getTargetTable();

        targetTable.setExternalId(targetTableExternalId);
        targetTable.setState(gov.nasa.kepler.hibernate.gar.ExportTable.State.UPLINKED);

        MaskTable maskTable = targetTable.getMaskTable();
        maskTable.setExternalId(photometerConfigParams.getTadExternalId());
        maskTable.setState(gov.nasa.kepler.hibernate.gar.ExportTable.State.UPLINKED);

        // Uplink background if it's an lc tls.
        if (tls.getType() == TargetType.LONG_CADENCE) {
            TargetTable backgroundTable = tls.getBackgroundTable();

            TadReport backgroundReport = backgroundTable.getTadReport();
            if (backgroundReport != null) {
                List<String> bgErrors = backgroundReport.getErrors();
                if (!bgErrors.isEmpty()) {
                    throw new Exception(
                        "the background table must not have errors before uplinking.  backgroundTableId = "
                            + backgroundTable.getId() + ", errors = " + bgErrors);
                }
            }

            backgroundTable.setExternalId(photometerConfigParams.getBgpExternalId());
            backgroundTable.setState(gov.nasa.kepler.hibernate.gar.ExportTable.State.UPLINKED);

            MaskTable backgroundMaskTable = backgroundTable.getMaskTable();
            backgroundMaskTable.setExternalId(photometerConfigParams.getBadExternalId());
            backgroundMaskTable.setState(gov.nasa.kepler.hibernate.gar.ExportTable.State.UPLINKED);
        }

        // uplink the TLS itself
        tls.setState(gov.nasa.kepler.hibernate.gar.ExportTable.State.UPLINKED);
    }

    /**
     * Expects a single parameter (table id) that will be used for all 7 table
     * ids in the photometer config.
     * 
     * @param args
     */
    public static void main(String[] args) {
        if (args.length != 2) {
            System.err.println("USAGE: tls-uplink TLSNAME EXTERNALID");
            System.err.println("  example: tls-uplink q1-lc 130");
            System.exit(-1);
        }

        final String tlsName = args[0];
        String externalIdStr = args[1];
        int externalId = -1;

        externalId = Integer.parseInt(externalIdStr);

        final PlannedPhotometerConfigParameters photometerConfig = new PlannedPhotometerConfigParameters(
            externalId, externalId, externalId, externalId, externalId,
            externalId, externalId);

        TransactionWrapper.run(new Runnable() {
            @Override
            public void run() {
                TargetListSetUplinker uplinker = new TargetListSetUplinker(
                    tlsName, photometerConfig);
                try {
                    uplinker.uplink();
                } catch (Exception e) {
                    throw new IllegalArgumentException("Unable to uplink.", e);
                }
            }
        });
    }

}
