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

//package gov.nasa.kepler.tad;
//
//import gov.nasa.kepler.common.FcConstants;
//import gov.nasa.kepler.common.PipelineException;
//import gov.nasa.kepler.common.Cadence.CadenceType;
//import gov.nasa.kepler.etem.BkgrndCadenceDataSet;
//import gov.nasa.kepler.etem.CollateralCadenceDataSet;
//import gov.nasa.kepler.etem.TargetCadenceDataSet;
//import gov.nasa.kepler.hibernate.cm.TargetListSet;
//import gov.nasa.kepler.hibernate.tad.Mask;
//import gov.nasa.kepler.hibernate.tad.MaskTable;
//import gov.nasa.kepler.hibernate.tad.Offset;
//import gov.nasa.kepler.hibernate.tad.TargetDefinition;
//import gov.nasa.kepler.hibernate.tad.TargetTable;
//
//import java.util.ArrayList;
//import java.util.List;
//
//public class TadToFitsLong extends AbstractTadToFits {
//
//    private String lcTargetListSetName;
//
//    public TadToFitsLong(String lcTargetListSetName, String fitsDir,
//        int startCadence, int endCadence) {
//
//        super(fitsDir, startCadence, endCadence);
//        this.lcTargetListSetName = lcTargetListSetName;
//    }
//
//    public void export(int module, int output) throws Exception {
//        exportLongCadence(module, output);
//        exportBackground(module, output);
//    }
//
//    private void exportLongCadence(int module, int output) throws Exception {
//        // Retrieve tad data.
//        TargetListSet set = targetSelectionCrud.retrieveTargetListSet(lcTargetListSetName);
//        TargetTable targetTable = set.getTargetTable();
//        MaskTable maskTable = targetTable.getMaskTable();
//        List<TargetDefinition> targetDefs = targetCrud.retrieveTargetDefinitions(
//            targetTable, module, output);
//
//        if (!targetDefs.isEmpty()) {
//            for (int cadenceNumber = startCadence; cadenceNumber <= endCadence; cadenceNumber++) {
//                // Generate target data.
//                TargetCadenceDataSet targetDataSet = new TargetCadenceDataSet(
//                    fitsDir, CadenceType.LONG, cadenceNumber, module, output, 0, 0);
//                for (TargetDefinition targetDef : targetDefs) {
//                    Mask mask = targetDef.getMask();
//                    for (Offset offset : mask.getOffsets()) {
//                        short absRow = (short) (targetDef.getReferenceRow() + offset.getRow());
//                        short absCol = (short) (targetDef.getReferenceColumn() + offset.getColumn());
//                        targetDataSet.addRow(TARGET_RAW_PIXEL_VALUE,
//                            TARGET_CAL_PIXEL_VALUE);
//                    }
//                }
//                targetDataSet.save();
//
//                // Generate collateral data.
//                List<Integer> rows = new ArrayList<Integer>();
//                for (int row = FcConstants.nMaskedSmear; row < FcConstants.nMaskedSmear
//                    + FcConstants.nRowsImaging; row++) {
//                    rows.add(row);
//                }
//
//                List<Integer> cols = new ArrayList<Integer>();
//                for (int col = FcConstants.nLeadingBlack; col < FcConstants.nLeadingBlack
//                    + FcConstants.nColsImaging; col++) {
//                    cols.add(col);
//                }
//
//                if (!targetDefs.isEmpty()) {
//                    CollateralCadenceDataSet collateralDataSet = new CollateralCadenceDataSet(
//                        fitsDir, CadenceType.LONG, cadenceNumber, module,
//                        output, 0, 0);
//                    exportCollateral(collateralDataSet, rows, cols);
//                    collateralDataSet.save();
//                }
//            }
//        }
//    }
//
//    private void exportBackground(int module, int output) throws Exception {
//        // Retrieve tad data.
//        TargetListSet set = targetSelectionCrud.retrieveTargetListSet(lcTargetListSetName);
//        TargetTable targetTable = set.getBackgroundTable();
//        MaskTable maskTable = targetTable.getMaskTable();
//        List<TargetDefinition> targetDefs = targetCrud.retrieveTargetDefinitions(
//            targetTable, module, output);
//
//        if (!targetDefs.isEmpty()) {
//            for (int cadenceNumber = startCadence; cadenceNumber <= endCadence; cadenceNumber++) {
//                BkgrndCadenceDataSet dataSet = null; //new BkgrndCadenceDataSet(fitsDir, CadenceType.LONG, cadenceNumber, module, output, 0, 0);
//                for (TargetDefinition targetDef : targetDefs) {
//                    Mask mask = targetDef.getMask();
//                    for (Offset offset : mask.getOffsets()) {
//                        short absRow = (short) (targetDef.getReferenceRow() + offset.getRow());
//                        short absCol = (short) (targetDef.getReferenceColumn() + offset.getColumn());
//                        dataSet.addRow(BG_RAW_PIXEL_VALUE, BG_CAL_PIXEL_VALUE);
//                    }
//                }
//                dataSet.save();
//            }
//        }
//    }
//
//}
