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

package gov.nasa.kepler.dr.gap;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.dr.dispatch.DispatchException;
import gov.nasa.kepler.dr.dispatch.Reader;
import gov.nasa.kepler.dr.gapreport.CadenceTypeXB;
import gov.nasa.kepler.dr.gapreport.ChannelXB;
import gov.nasa.kepler.dr.gapreport.CollateralPixelListXB;
import gov.nasa.kepler.dr.gapreport.CollateralPixelXB;
import gov.nasa.kepler.dr.gapreport.GapReportDocument;
import gov.nasa.kepler.dr.gapreport.GapReportXB;
import gov.nasa.kepler.dr.gapreport.MissingTypeXB;
import gov.nasa.kepler.dr.gapreport.TargetListXB;
import gov.nasa.kepler.dr.gapreport.TargetPixelXB;
import gov.nasa.kepler.dr.gapreport.TargetXB;
import gov.nasa.kepler.hibernate.dr.GapCadence;
import gov.nasa.kepler.hibernate.dr.GapChannel;
import gov.nasa.kepler.hibernate.dr.GapCollateralPixel;
import gov.nasa.kepler.hibernate.dr.GapPixel;
import gov.nasa.kepler.hibernate.dr.GapTarget;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import java.io.FileReader;
import java.util.ArrayList;
import java.util.List;

import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlOptions;

/**
 * Reads gap reports.
 * 
 * @author Miles Cote
 * 
 */
public class GapReportReader implements Reader<GapReport> {

    private final FileReader fileReader;

    public GapReportReader(FileReader fileReader) {
        this.fileReader = fileReader;
    }

    @Override
    public GapReport read() {
        List<GapCadence> gapCadences = newArrayList();
        List<GapChannel> gapChannels = newArrayList();
        List<GapTarget> gapTargets = newArrayList();
        List<GapPixel> gapPixels = newArrayList();
        List<GapCollateralPixel> gapCollateralPixels = newArrayList();

        GapReportDocument doc;
        try {
            doc = GapReportDocument.Factory.parse(fileReader);
        } catch (Throwable e) {
            throw new IllegalArgumentException("Unable to parse.", e);
        }

        XmlOptions xmlOptions = new XmlOptions();
        List<XmlError> errors = new ArrayList<XmlError>();
        xmlOptions.setErrorListener(errors);
        if (!doc.validate(xmlOptions)) {
            throw new DispatchException("XML validation error.  " + errors);
        }

        GapReportXB gapReport = doc.getGapReport();

        int cadenceNumber = gapReport.getCadenceNumber();

        CadenceTypeXB.Enum cadenceTypeEnum = gapReport.getCadence();

        CadenceType cadenceType;
        if (cadenceTypeEnum == CadenceTypeXB.LONG) {
            cadenceType = CadenceType.LONG;
        } else if (cadenceTypeEnum == CadenceTypeXB.SHORT) {
            cadenceType = CadenceType.SHORT;
        } else {
            throw new DispatchException("Unknown cadence type: "
                + cadenceTypeEnum);
        }

        // Cadences.
        MissingTypeXB.Enum cadenceMissing = gapReport.getMissing();
        if (cadenceMissing == MissingTypeXB.ALL) {
            // Store a GapCadence.
            GapCadence gapCadence = new GapCadence(cadenceNumber, cadenceType);
            gapCadences.add(gapCadence);
        }

        // Channels.
        ChannelXB[] missingChannels = gapReport.getChannelArray();

        for (ChannelXB channel : missingChannels) {
            int ccdModule = channel.getModule();
            int ccdOutput = channel.getOutput();
            MissingTypeXB.Enum channelMissingType = channel.getMissing();

            if (channelMissingType == MissingTypeXB.ALL) {
                // Just store a GapChannel.
                GapChannel gapChannel = new GapChannel(cadenceNumber,
                    cadenceType, ccdModule, ccdOutput);

                gapChannels.add(gapChannel);
            } else if (channelMissingType == MissingTypeXB.PART) {

                // science-targets
                if (channel.isSetScienceTargets()) {
                    switch (cadenceType) {
                        case LONG:
                            processTargetList(channel.getScienceTargets(),
                                cadenceNumber, cadenceType, ccdModule,
                                ccdOutput, TargetType.LONG_CADENCE, gapTargets,
                                gapPixels);
                            break;
                        case SHORT:
                            processTargetList(channel.getScienceTargets(),
                                cadenceNumber, cadenceType, ccdModule,
                                ccdOutput, TargetType.SHORT_CADENCE,
                                gapTargets, gapPixels);
                            break;
                    }
                }

                // background-targets
                if (channel.isSetBackgroundTargets()) {
                    processTargetList(channel.getBackgroundTargets(),
                        cadenceNumber, cadenceType, ccdModule, ccdOutput,
                        TargetType.BACKGROUND, gapTargets, gapPixels);
                }

                // black-pixels
                if (channel.isSetBlackLevelPixels()) {
                    processCollateralList(channel.getBlackLevelPixels(),
                        cadenceNumber, cadenceType, ccdModule, ccdOutput,
                        CollateralType.BLACK_LEVEL, gapCollateralPixels);
                }

                // masked-pixels (aka, masked smear)
                if (channel.isSetMaskedPixels()) {
                    processCollateralList(channel.getMaskedPixels(),
                        cadenceNumber, cadenceType, ccdModule, ccdOutput,
                        CollateralType.MASKED_SMEAR, gapCollateralPixels);
                }

                // virtual-pixels (aka, virtual smear)
                if (channel.isSetVirtualSmearPixels()) {
                    processCollateralList(channel.getVirtualSmearPixels(),
                        cadenceNumber, cadenceType, ccdModule, ccdOutput,
                        CollateralType.VIRTUAL_SMEAR, gapCollateralPixels);
                }

                // black-masked-pixels
                if (channel.isSetBlackMaskedPixels()) {
                    processCollateralList(channel.getBlackMaskedPixels(),
                        cadenceNumber, cadenceType, ccdModule, ccdOutput,
                        CollateralType.BLACK_MASKED, gapCollateralPixels);
                }

                // black-virtual-pixels
                if (channel.isSetBlackVirtualPixels()) {
                    processCollateralList(channel.getBlackVirtualPixels(),
                        cadenceNumber, cadenceType, ccdModule, ccdOutput,
                        CollateralType.BLACK_VIRTUAL, gapCollateralPixels);
                }
            } else {
                throw new DispatchException("Unknown channel missing type: "
                    + channelMissingType);
            }
        }

        return new GapReport(gapCadences, gapChannels, gapTargets, gapPixels,
            gapCollateralPixels);
    }

    private void processTargetList(TargetListXB targetList, int cadenceNumber,
        CadenceType cadenceType, int ccdModule, int ccdOutput,
        TargetType targetTableType, List<GapTarget> gapTargets,
        List<GapPixel> gapPixels) {
        MissingTypeXB.Enum targetListMissingType = targetList.getMissing();

        if (targetListMissingType == MissingTypeXB.ALL) {
            // Just create a single GapTarget instance, with targetIndex = -1,
            // which means all targets of this type.
            GapTarget gapTarget = new GapTarget(cadenceNumber, cadenceType,
                ccdModule, ccdOutput, GapTarget.ALL_TARGETS_FLAG,
                GapTarget.ALL_TARGETS_FLAG, targetTableType);

            gapTargets.add(gapTarget);

        } else if (targetListMissingType == MissingTypeXB.PART) {

            TargetXB[] targets = targetList.getTargetArray();
            for (TargetXB target : targets) {
                MissingTypeXB.Enum targetMissingType = target.getMissing();
                int targetIndex = target.getTargetIndex();

                if (targetMissingType == MissingTypeXB.ALL) {
                    GapTarget gapTarget = new GapTarget(cadenceNumber,
                        cadenceType, ccdModule, ccdOutput,
                        target.getKeplerId(), targetIndex, targetTableType);

                    gapTargets.add(gapTarget);
                } else if (targetMissingType == MissingTypeXB.PART) {
                    // Just record the missing pixels.
                    TargetPixelXB[] pixels = target.getPixelArray();
                    for (TargetPixelXB pixel : pixels) {
                        int ccdRow = pixel.getRow();
                        int ccdColumn = pixel.getColumn();

                        GapPixel gapPixel = new GapPixel(cadenceNumber,
                            cadenceType, ccdModule, ccdOutput, targetTableType,
                            target.getKeplerId(), targetIndex, ccdRow,
                            ccdColumn);

                        gapPixels.add(gapPixel);
                    }
                } else {
                    throw new DispatchException("Unknown target missing type: "
                        + targetMissingType);
                }
            }
        } else {
            throw new DispatchException("Unknown target list missing type: "
                + targetListMissingType);
        }
    }

    private void processCollateralList(CollateralPixelListXB pixelList,
        int cadenceNumber, CadenceType cadenceType, int ccdModule,
        int ccdOutput, CollateralType collateralPixelType,
        List<GapCollateralPixel> gapCollateralPixels) {
        MissingTypeXB.Enum pixelListMissingType = pixelList.getMissing();

        if (pixelListMissingType == MissingTypeXB.ALL) {
            // Just create a single GapCollateralPixel instance, with
            // rowOrColumn = -1, which means all pixels of this type.
            GapCollateralPixel gapCollateralPixel = new GapCollateralPixel(
                cadenceNumber, cadenceType, ccdModule, ccdOutput,
                collateralPixelType, GapCollateralPixel.ALL_PIXELS_FLAG);

            gapCollateralPixels.add(gapCollateralPixel);

        } else if (pixelListMissingType == MissingTypeXB.PART) {

            CollateralPixelXB[] pixels = pixelList.getPixelArray();
            for (CollateralPixelXB pixel : pixels) {
                int rowOrColumn = pixel.getOffset();

                GapCollateralPixel gapCollateralPixel = new GapCollateralPixel(
                    cadenceNumber, cadenceType, ccdModule, ccdOutput,
                    collateralPixelType, rowOrColumn);

                gapCollateralPixels.add(gapCollateralPixel);
            }
        } else {
            throw new DispatchException("Unknown target list missing type: "
                + pixelListMissingType);
        }
    }

}
