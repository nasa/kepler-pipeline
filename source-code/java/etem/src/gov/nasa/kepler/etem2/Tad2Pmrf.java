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

package gov.nasa.kepler.etem2;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.primitives.Ints.toArray;
import static com.google.common.primitives.Shorts.toArray;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.etem.CollateralPmrfFits;
import gov.nasa.kepler.etem.TargetPmrfFits;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;

import java.io.IOException;
import java.util.List;

import nom.tam.fits.FitsException;
import nom.tam.fits.Header;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public abstract class Tad2Pmrf {

    private static final Log log = LogFactory.getLog(Tad2Pmrf.class);

    protected String targetListSetName;
    protected String fitsDir;

    protected TargetSelectionCrud targetSelectionCrud;
    protected TargetCrud targetCrud;

    protected TargetListSet targetListSet;
    protected double startMjd;

    protected int scConfigId;

    protected String masterFitsPath;

    protected double secondsPerShortCadence;

    protected int shortCadencesPerLong;

    protected int compressionId;
    protected int badId;
    protected int bgpId;
    protected int tadId;
    protected int lctId;
    protected int sctId;
    protected int rptId;

    protected Tad2Pmrf(String targetListSetName, String fitsDir,
        double startMjd, int scConfigId, String masterFitsPath,
        double secondsPerShortCadence, int shortCadencesPerLong,
        int compressionId, int badId, int bgpId, int tadId, int lctId,
        int sctId, int rptId) {
        this.targetListSetName = targetListSetName;
        this.fitsDir = fitsDir;
        this.startMjd = startMjd;
        this.scConfigId = scConfigId;
        this.compressionId = compressionId;
        this.masterFitsPath = masterFitsPath;
        this.secondsPerShortCadence = secondsPerShortCadence;
        this.shortCadencesPerLong = shortCadencesPerLong;
        this.compressionId = compressionId;
        this.badId = badId;
        this.bgpId = bgpId;
        this.tadId = tadId;
        this.lctId = lctId;
        this.sctId = sctId;
        this.rptId = rptId;

        targetSelectionCrud = new TargetSelectionCrud(
            DatabaseServiceFactory.getInstance());
        targetCrud = new TargetCrud(DatabaseServiceFactory.getInstance());

        targetListSet = targetSelectionCrud.retrieveTargetListSet(targetListSetName);
    }

    public void export() throws Exception {
        TargetTable targetTable = targetListSet.getTargetTable();

        // Create masterHeadersCaches.
        List<Header> targetMasterHeaders = TargetPmrfFits.getMasterHeaders(
            masterFitsPath, targetTable.getType());
        List<Header> collateralMasterHeaders = CollateralPmrfFits.getMasterHeaders(
            masterFitsPath, targetTable.getType());

        TargetPmrfFits targetPmrfFits = new TargetPmrfFits(fitsDir,
            targetTable.getType(), startMjd, targetMasterHeaders, scConfigId,
            secondsPerShortCadence, shortCadencesPerLong, compressionId, badId,
            bgpId, tadId, lctId, sctId, rptId);

        CollateralPmrfFits collateralPmrfFits = new CollateralPmrfFits(fitsDir,
            targetTable.getType(), startMjd, collateralMasterHeaders,
            scConfigId, secondsPerShortCadence, shortCadencesPerLong,
            compressionId, badId, bgpId, tadId, lctId, sctId, rptId);

        for (int module : FcConstants.modulesList) {
            for (int output : FcConstants.outputsList) {
                log.info(module + "/" + output);
                List<TargetDefinition> targetDefs = targetCrud.retrieveTargetDefinitions(
                    targetTable, module, output);

                exportTargetDefs(targetPmrfFits, targetDefs);

                exportCollateral(collateralPmrfFits, targetDefs);
            }
        }

        targetPmrfFits.save();
        collateralPmrfFits.save();

        exportBackground();
    }

    protected void exportTargetDefs(TargetPmrfFits targetPmrfFits,
        List<TargetDefinition> targetDefs) throws FitsException, IOException {

        List<Integer> targetIdColumn = newArrayList();
        List<Short> apertureIdColumn = newArrayList();
        List<Short> rowColumn = newArrayList();
        List<Short> colColumn = newArrayList();

        for (TargetDefinition targetDef : targetDefs) {
            Mask mask = targetDef.getMask();
            for (Offset offset : mask.getOffsets()) {
                short absRow = (short) (targetDef.getReferenceRow() + offset.getRow());
                short absCol = (short) (targetDef.getReferenceColumn() + offset.getColumn());

                targetIdColumn.add(targetDef.getKeplerId());
                apertureIdColumn.add((short) mask.getIndexInTable());
                rowColumn.add(absRow);
                colColumn.add(absCol);
            }
        }

        targetPmrfFits.addColumns(toArray(targetIdColumn),
            toArray(apertureIdColumn), toArray(rowColumn), toArray(colColumn));
    }

    protected abstract void exportCollateral(
        CollateralPmrfFits collateralPmrfFits, List<TargetDefinition> targetDefs)
        throws FitsException, IOException;

    protected abstract void exportBackground() throws Exception;

}
