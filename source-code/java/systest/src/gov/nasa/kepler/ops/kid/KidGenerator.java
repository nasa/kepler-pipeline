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

package gov.nasa.kepler.ops.kid;

import gov.nasa.kepler.ar.exporter.ktc.CompletedKtcEntry;
import gov.nasa.kepler.investigations.InvestigationType;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.TimeZone;

import org.apache.xmlbeans.XmlException;

/**
 * Generates a KID (Kepler Investigation Description) xml file.
 * <p>
 * The tool should export the KID file and the report as:<br>
 * kplryyyydddhhmmdd_kid.xml<br>
 * kplryyyydddhhmmdd_kidreport.txt<br>
 * where the timestamp in the file name is the time the files were created, in
 * UTC.<br>
 * 
 * @author Miles Cote
 * 
 */
public class KidGenerator {

    private final KtcReader ktcReader;
    private final InvestigationTypeListFactory investigationTypeListFactory;
    private final InvestigationsReader investigationsReader;
    private final InvestigationsWriter investigationsWriter;
    private final InvestigationsReportWriter investigationsReportWriter;
    private final List<KidRule> kidRules;

    public KidGenerator(KtcReader ktcReader,
        InvestigationTypeListFactory investigationTypeListFactory,
        InvestigationsReader investigationsReader,
        InvestigationsWriter investigationsWriter,
        InvestigationsReportWriter investigationsReportWriter,
        List<KidRule> kidRules) {
        this.ktcReader = ktcReader;
        this.investigationTypeListFactory = investigationTypeListFactory;
        this.investigationsReader = investigationsReader;
        this.investigationsWriter = investigationsWriter;
        this.investigationsReportWriter = investigationsReportWriter;
        this.kidRules = kidRules;
    }

    public Pair<File, File> generateKidFileReportFilePair(File ktcFile,
        File baseInvestigationsFile) throws IOException, XmlException {
        List<CompletedKtcEntry> ktcEntries = ktcReader.read(ktcFile);
        Map<String, List<CompletedKtcEntry>> investigationIdToKtcEntries = new LinkedHashMap<String, List<CompletedKtcEntry>>();
        for (CompletedKtcEntry ktcEntry : ktcEntries) {
            String investigationId = ktcEntry.getInvestigation();

            List<CompletedKtcEntry> investigationKtcEntries = investigationIdToKtcEntries.get(investigationId);
            if (investigationKtcEntries == null) {
                investigationKtcEntries = new ArrayList<CompletedKtcEntry>();
                investigationIdToKtcEntries.put(investigationId,
                    investigationKtcEntries);
            }

            investigationKtcEntries.add(ktcEntry);
        }

        List<InvestigationType> baseInvestigations = investigationsReader.read(baseInvestigationsFile);

        List<InvestigationType> kidInvestigations = investigationTypeListFactory.create(
            ktcEntries, baseInvestigations);

        Map<String, InvestigationType> baseInvestigationIdToBaseInvestigation = new LinkedHashMap<String, InvestigationType>();
        for (InvestigationType baseInvestigation : baseInvestigations) {
            String investigationId = baseInvestigation.getId();
            baseInvestigationIdToBaseInvestigation.put(investigationId,
                baseInvestigation);
        }

        for (KidRule kidRule : kidRules) {
            kidRule.apply(kidInvestigations, investigationIdToKtcEntries,
                baseInvestigationIdToBaseInvestigation);
        }

        File kidFile = investigationsWriter.write(kidInvestigations);

        File reportFile = investigationsReportWriter.write(kidInvestigations);

        return Pair.of(kidFile, reportFile);
    }

    public static void main(String[] args) throws IOException, XmlException {
        if (args.length != 3) {
            System.err.println("USAGE: generate-kid KTC_FILE BASE_INVESTIGATIONS_FILE CONFIG_FILE");
            System.err.println("EXAMPLE: generate-kid ~/ktc.txt ~/base-investigations.xml ~/investigations.properties");
            System.exit(-1);
        }

        String ktcFileName = args[0];
        String baseInvestigationsFileName = args[1];
        String configFileName = args[2];

        File ktcFile = new File(ktcFileName);

        File baseInvestigationsFile = new File(baseInvestigationsFileName);

        File configFile = new File(configFileName);
        Properties properties = new Properties();
        properties.load(new BufferedReader(new FileReader(configFile)));

        List<KidRule> kidRules = new ArrayList<KidRule>();
        kidRules.add(new KidRuleBaseInvestigationsExist());
        kidRules.add(new KidRuleLeader(properties));
        kidRules.add(new KidRuleTitle());
        kidRules.add(new KidRuleType());
        kidRules.add(new KidRuleAbstract());
        kidRules.add(new KidRuleCollaborators());
        kidRules.add(new KidRuleStart());
        kidRules.add(new KidRuleEnd());

        KidGenerator kidGenerator = new KidGenerator(new KtcReader(),
            new InvestigationTypeListFactory(), new InvestigationsReader(),
            new InvestigationsWriter(), new InvestigationsReportWriter(
                new CsvWriter(), new InvestigationWarningsGenerator()),
            kidRules);
        Pair<File, File> kidFileReportFilePair = kidGenerator.generateKidFileReportFilePair(
            ktcFile, baseInvestigationsFile);

        SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
        formatter.setTimeZone(TimeZone.getTimeZone("UTC"));
        String timestampString = formatter.format(new Date());

        File kidFile = new File("kplr" + timestampString + "_kid.xml");
        kidFileReportFilePair.left.renameTo(kidFile);
        System.out.println("Generated KID file: " + kidFile);

        File reportFile = new File("kplr" + timestampString + "_kidreport.txt");
        kidFileReportFilePair.right.renameTo(reportFile);
        System.out.println("Generated report file: " + reportFile);

        System.exit(0);
    }

}
