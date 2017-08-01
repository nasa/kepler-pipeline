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

package gov.nasa.kepler.mc.histogram;

import gov.nasa.kepler.common.FitsUtils;
import gov.nasa.kepler.fs.api.BlobResult;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.dr.HistogramLog;
import gov.nasa.kepler.hibernate.dr.HistogramLogCrud;
import gov.nasa.kepler.hibernate.gar.ExportTable;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.ByteArrayInputStream;
import java.util.ArrayList;
import java.util.List;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.BinaryTableHDU;
import nom.tam.fits.Fits;

/**
 * This class contains business logic for compression histograms.
 * 
 * @author Miles Cote
 * 
 */
public class HistogramOperations {

    private HistogramLogCrud histogramCrud;

    public HistogramOperations() {
        histogramCrud = new HistogramLogCrud(
            DatabaseServiceFactory.getInstance());
    }

    public List<HistogramStruct> retrieveHistograms(int longCadenceStart,
        int longCadenceEnd) {
        try {
            List<HistogramStruct> histogramStructs = new ArrayList<HistogramStruct>();

            for (HistogramLog histogram : histogramCrud.retrieveHistograms(
                longCadenceStart, longCadenceEnd)) {
                FileStoreClient fsClient = FileStoreClientFactory.getInstance();
                BlobResult result = fsClient.readBlob(DrFsIdFactory.getFile(
                    DispatcherType.HISTOGRAM, histogram.getFileLog()
                        .getFilename()));

                Fits fits = new Fits(new ByteArrayInputStream(result.data()));
                fits.read();

                // Read FITS header fields.
                BasicHDU basicHDU = fits.getHDU(0);
                int cadenceStart = FitsUtils.getHeaderIntValueChecked(
                    basicHDU.getHeader(),
                    HistogramLog.HDR_CADENCE_START_KEYWORD);
                int cadenceEnd = FitsUtils.getHeaderIntValueChecked(
                    basicHDU.getHeader(), HistogramLog.HDR_CADENCE_END_KEYWORD);

                BinaryTableHDU binaryTableHDU = (BinaryTableHDU) fits.getHDU(1);
                int[] histogramArray = (int[]) binaryTableHDU.getColumn(0);

                histogramStructs.add(new HistogramStruct(cadenceStart,
                    cadenceEnd, histogramArray, ExportTable.INVALID_EXTERNAL_ID));
            }

            return histogramStructs;
        } catch (Exception e) {
            throw new PipelineException("Unable to retrieve histograms.", e);
        }
    }

    void setHistogramCrud(HistogramLogCrud histogramCrud) {
        this.histogramCrud = histogramCrud;
    }

}
