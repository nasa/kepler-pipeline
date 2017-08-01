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

package gov.nasa.kepler.pi.metrics.report;

import java.awt.image.BufferedImage;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;

import org.jfree.chart.JFreeChart;

import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Image;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;

/**
 * Thin wrapper around iText & JFreeChart
 * 
 * @author tklaus
 *
 */
public class PdfRenderer {

    private Document pdfDocument;
    private PdfWriter pdfWriter;

    public static final Font titleFont = FontFactory.getFont(FontFactory.HELVETICA, 24, Font.BOLD);
    public static final Font h1Font = FontFactory.getFont(FontFactory.HELVETICA, 14, Font.BOLD);
    public static final Font h2Font = FontFactory.getFont(FontFactory.HELVETICA, 12, Font.BOLD);
    public static final Font bodyFont = FontFactory.getFont(FontFactory.HELVETICA, 10, Font.NORMAL);
    public static final Font bodyBoldFont = FontFactory.getFont(FontFactory.HELVETICA, 10, Font.BOLD);
    public static final Font bodyMonoFont = FontFactory.getFont(FontFactory.COURIER, 10, Font.NORMAL);

    private boolean portrait;
    
    public PdfRenderer(File outputFile) throws Exception {
        this(outputFile, true);
    }

    public PdfRenderer(File outputFile, boolean portrait) throws Exception{
        this.portrait = portrait;
        
        if(portrait){
            pdfDocument = new Document(PageSize.LETTER);
        }else{
            pdfDocument = new Document(PageSize.LETTER.rotate());
        }

        FileOutputStream pdfFos = new FileOutputStream(outputFile);
        BufferedOutputStream pdfBos = new BufferedOutputStream(pdfFos);
    
        pdfWriter = PdfWriter.getInstance(pdfDocument, pdfBos);
        pdfDocument.open();
    }

    public void close(){
        // release resources
        pdfDocument.close();
        pdfDocument = null;
        pdfWriter.close();
    }

    /**
     * Render the chart to the document.
     * 
     * @param chart
     * @param width
     * @param height
     * @throws Exception
     */
    public void printChart(JFreeChart chart, int width, int height) throws Exception{
        BufferedImage bufferedImage = chart.createBufferedImage(width, height);
        Image image = Image.getInstance(pdfWriter, bufferedImage, 1.0f);        
        pdfDocument.add(image);
    }
    
    /**
     * Render the chart to the next cell of the specified {@link PdfPTable}
     * 
     * @param table
     * @param chart
     * @param width
     * @param height
     * @throws Exception
     */
    public void printChart(PdfPTable table, JFreeChart chart, int width, int height) throws Exception{
        BufferedImage bufferedImage = chart.createBufferedImage(width, height);
        Image image = Image.getInstance(pdfWriter, bufferedImage, 1.0f);        
        table.addCell(image);
    }
    
    public void println() throws Exception{
        printText(" ");
    }
    
    public void printText(String text) throws Exception{
        printText(text,bodyFont);
    }
        
    public void printText(String text, Font font) throws Exception{
        Paragraph p = new Paragraph(text, font);
        if(font == titleFont){
            p.setAlignment(Element.ALIGN_CENTER);
        }
        pdfDocument.add(p);
    }

    public void newPage() {
        pdfDocument.newPage();
    }

    public void add(Element element) throws DocumentException {
        pdfDocument.add(element);
    }

    public boolean isPortrait() {
        return portrait;
    }
}
