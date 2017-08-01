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

package gov.nasa.kepler.soc;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Maps.newHashMap;
import static com.google.common.collect.Sets.newHashSet;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.fs.api.BlobResult;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.dr.PixelTimeSeriesReader;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.pmrf.PmrfOperations;

import java.util.List;
import java.util.Map;

/**
 * Retrieves pixels.
 * 
 * @author Miles Cote
 * 
 */
public class PixelRetriever {

    private final LogCrud logCrud;
    private final FileStoreClient fileStoreClient;
    private final CadenceType cadenceType;
    private final DispatcherType dispatcherType;
    private final DataSetType dataSetType;
    private final int cadenceNumber;

    public PixelRetriever(LogCrud logCrud, FileStoreClient fileStoreClient,
        CadenceType cadenceType, DispatcherType dispatcherType,
        DataSetType dataSetType, int cadenceNumber) {
        this.logCrud = logCrud;
        this.fileStoreClient = fileStoreClient;
        this.cadenceType = cadenceType;
        this.dispatcherType = dispatcherType;
        this.dataSetType = dataSetType;
        this.cadenceNumber = cadenceNumber;
    }

    public ImportedPixels retrieve() {
        List<PixelLog> pixelLogs = logCrud.retrievePixelLog(
            cadenceType.intValue(), dataSetType, cadenceNumber, cadenceNumber);
        if (pixelLogs.size() != 1) {
            throw new IllegalArgumentException(
                "pixelLogs.size must be equal to 1." + "\n  pixelLogs.size: "
                    + pixelLogs.size());
        }

        PixelLog pixelLog = pixelLogs.get(0);

        BlobResult blobResult = fileStoreClient.readBlob(DrFsIdFactory.getPixelFitsHeaderFile(pixelLog.getFitsFilename()));

        List<List<IntTimeSeries>> timeSeriesLists = createTimeSeriesLists(pixelLog);

        return new ImportedPixels(pixelLog, blobResult.data(), timeSeriesLists);
    }

    private List<List<IntTimeSeries>> createTimeSeriesLists(PixelLog pixelLog) {
        TargetType targetType = null;
        if (dataSetType.equals(DataSetType.Background)) {
            targetType = TargetType.BACKGROUND;
        } else {
            targetType = TargetType.valueOf(cadenceType);
        }

        short targetTableId;
        switch (targetType) {
            case LONG_CADENCE:
                targetTableId = pixelLog.getLcTargetTableId();
                break;
            case SHORT_CADENCE:
                targetTableId = pixelLog.getScTargetTableId();
                break;
            case BACKGROUND:
                targetTableId = pixelLog.getBackTargetTableId();
                break;
            default:
                throw new IllegalArgumentException("Unexpected type: "
                    + targetType);
        }

        TargetCrud targetCrud = new TargetCrud();
        TargetTable targetTable = targetCrud.retrieveUplinkedTargetTable(
            targetTableId, targetType);

        List<List<IntTimeSeries>> timeSeriesLists = newArrayList();
        for (int channel = 1; channel <= FcConstants.MODULE_OUTPUTS; channel++) {
            int ccdModule = FcConstants.getModuleOutput(channel).left;
            int ccdOutput = FcConstants.getModuleOutput(channel).right;

            List<FsId> fsIdList = null;
            if (dataSetType.equals(DataSetType.Collateral)) {
                PmrfOperations pmrfOperations = new PmrfOperations();
                fsIdList = pmrfOperations.getCollateralPixelFsIds(cadenceType,
                    targetTable.getExternalId(), ccdModule, ccdOutput);
            } else {
                fsIdList = getFsIdList(targetType, targetCrud, targetTable,
                    ccdModule, ccdOutput);
            }

            List<FsId> fsIdListWithoutDuplicates = newArrayList(newHashSet(fsIdList));
            PixelTimeSeriesReader pixelTimeSeriesReader = PixelTimeSeriesReaderFactory.create(
                dispatcherType, dataSetType, ccdModule, ccdOutput);
            IntTimeSeries[] intTimeSeriesArray = pixelTimeSeriesReader.readTimeSeriesAsInt(
                fsIdListWithoutDuplicates.toArray(new FsId[0]), cadenceNumber,
                cadenceNumber);

            Map<FsId, IntTimeSeries> fsIdToTimeSeries = newHashMap();
            for (int i = 0; i < intTimeSeriesArray.length; i++) {
                if (intTimeSeriesArray[i].exists()) {
                    fsIdToTimeSeries.put(fsIdListWithoutDuplicates.get(i),
                        intTimeSeriesArray[i]);
                }
            }

            List<IntTimeSeries> timeSeriesList = newArrayList();
            for (FsId fsId : fsIdList) {
                IntTimeSeries timeSeries = fsIdToTimeSeries.get(fsId);
                if (timeSeries != null) {
                    timeSeriesList.add(timeSeries);
                }
            }

            timeSeriesLists.add(timeSeriesList);
        }

        return timeSeriesLists;
    }

    private List<FsId> getFsIdList(TargetType targetType,
        TargetCrud targetCrud, TargetTable targetTable, int ccdModule,
        int ccdOutput) {
        List<FsId> fsIdList = newArrayList();
        for (TargetDefinition targetDefinition : targetCrud.retrieveTargetDefinitions(
            targetTable, ccdModule, ccdOutput)) {
            int startRow = targetDefinition.getReferenceRow();
            int startColumn = targetDefinition.getReferenceColumn();
            for (Offset offset : targetDefinition.getMask()
                .getOffsets()) {
                int row = startRow + offset.getRow();
                int column = startColumn + offset.getColumn();
                Pixel pixel = buildPixel(targetType, ccdModule, ccdOutput, row,
                    column, true);
                fsIdList.add(pixel.getFsId());
            }
        }

        return fsIdList;
    }

    private Pixel buildPixel(TargetType targetType, int ccdModule,
        int ccdOutput, int row, int column, boolean inOptimalAperture) {
        FsId fsId = DrFsIdFactory.getSciencePixelTimeSeries(
            DrFsIdFactory.TimeSeriesType.ORIG, targetType, ccdModule,
            ccdOutput, row, column);
        return new Pixel(row, column, fsId, inOptimalAperture);
    }

}
