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

package gov.nasa.kepler.mr.scriptlet;

import gov.nasa.kepler.hibernate.gar.ExportTable;
import gov.nasa.kepler.hibernate.tad.TadModOutReport;
import gov.nasa.kepler.hibernate.tad.TadReport;
import gov.nasa.kepler.hibernate.tad.TargetDefinitionAndPixelCounts;
import gov.nasa.kepler.hibernate.tad.TargetTable;

import java.util.ArrayList;
import java.util.List;

import net.sf.jasperreports.engine.JRDataSource;
import net.sf.jasperreports.engine.JRScriptletException;
import net.sf.jasperreports.engine.data.JRBeanCollectionDataSource;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This is the scriptlet class for the TAD CCD Module/Output report.
 * 
 * @author Bill Wohler
 */
public class TadCcdModuleOutputScriptlet extends TadScriptlet {

    private static final Log log = LogFactory.getLog(TadCcdModuleOutputScriptlet.class);

    public static final String REPORT_NAME_TAD_MODULE = "tad-ccd-module-output";
    public static final String REPORT_TITLE_TAD_MODULE = "Target and Aperture Definitions Processing Module/Output";

    @Override
    public void afterReportInit() throws JRScriptletException {
        super.afterReportInit();

        expectModuleOutputParameter();

        log.debug(String.format("module/output=%d/%d", getCcdModule(),
            getCcdOutput()));
    }

    @Override
    public JRDataSource targetTableDataSource() throws JRScriptletException {
        if (targetTable == null || targetTable.getTadReport() == null
            || targetTable.getTadReport()
                .getModuleOutputSummary(getCcdModule(), getCcdOutput()) == null) {
            log.error("Should not be called if TAD report unavailable");
        }

        return dataSource(targetTable);
    }

    @Override
    public JRDataSource backgroundTableDataSource() throws JRScriptletException {
        // Short cadences don't have background tables, so not an error in
        // that case.

        return dataSource(backgroundTable);
    }

    /**
     * Returns a {@link JRDataSource} which wraps the {@link TadReport} for the
     * current target table.
     * 
     * @param targetTable the target table to display.
     * @return a non-{@code null} data source.
     * @throws JRScriptletException if the data source could not be created.
     */
    private JRDataSource dataSource(TargetTable targetTable)
        throws JRScriptletException {

        log.debug("Filling data source for " + targetListSet);

        List<KeyValuePair> list = new ArrayList<KeyValuePair>();
        if (targetTable == null || targetTable.getTadReport() == null) {
            return new JRBeanCollectionDataSource(list);
        }

        TadModOutReport tadReport = targetTable.getTadReport()
            .getModuleOutputSummary(getCcdModule(), getCcdOutput());
        if (tadReport == null) {
            return new JRBeanCollectionDataSource(list);
        }

        list.add(new KeyValuePair("Number of Targets Rejected by COA",
            String.format("%,d", tadReport.getRejectedByCoaTargetCount())));

        String s = NO_DATA;
        if (targetTable.getExternalId() != ExportTable.INVALID_EXTERNAL_ID) {
            s = String.format("%,d", targetTable.getExternalId());
        }
        list.add(new KeyValuePair("Target Table ID", s));
        list.add(new KeyValuePair("Target Database ID", String.format("%,d",
            targetTable.getId())));
        s = NO_DATA;
        if (targetTable.getMaskTable()
            .getExternalId() != ExportTable.INVALID_EXTERNAL_ID) {
            s = String.format("%,d", targetTable.getMaskTable()
                .getExternalId());
        }
        list.add(new KeyValuePair("Aperture Table ID", s));
        list.add(new KeyValuePair("Aperture Database ID", String.format("%,d",
            targetTable.getMaskTable()
                .getId())));

        return new JRBeanCollectionDataSource(list);
    }

    @Override
    protected TargetDefinitionAndPixelCounts getCounts(TadReport tadReport) {
        for (TadModOutReport tadModOutReport : tadReport.getModOutReports()) {
            if (tadModOutReport.getCcdModule() == getCcdModule()
                && tadModOutReport.getCcdOutput() == getCcdOutput()) {

                return tadModOutReport.getTargetDefinitionAndPixelCounts();
            }
        }

        log.error(String.format(
            "Could not find target and pixel counts for module/output %d/%d in target list set %s",
            getCcdModule(), getCcdOutput(), targetListSet));

        return null;
    }
}
