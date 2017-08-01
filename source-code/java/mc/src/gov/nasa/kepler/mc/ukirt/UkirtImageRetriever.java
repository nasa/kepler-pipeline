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

package gov.nasa.kepler.mc.ukirt;

import gov.nasa.kepler.common.UsageException;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dv.DvCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectParameter;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TimeZone;
import java.util.TreeSet;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.cli.PosixParser;
import org.apache.commons.compress.compressors.CompressorException;
import org.apache.commons.compress.compressors.CompressorInputStream;
import org.apache.commons.compress.compressors.CompressorStreamFactory;
import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.CookieStore;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.protocol.ClientContext;
import org.apache.http.entity.mime.HttpMultipartMode;
import org.apache.http.entity.mime.MultipartEntity;
import org.apache.http.entity.mime.content.FileBody;
import org.apache.http.entity.mime.content.StringBody;
import org.apache.http.impl.client.BasicCookieStore;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.protocol.BasicHttpContext;
import org.apache.http.protocol.HttpContext;
import org.apache.http.util.EntityUtils;

public class UkirtImageRetriever {

    private static final Log log = LogFactory.getLog(UkirtImageRetriever.class);

    private static final String UKIRT_FITS_FILENAME = "kplr%s-%09d_ukirt.fits";
    private static final String UKIRT_INPUT_FILENAME = "ukirt-input-%s.txt";
    private static final String UKIRT_NOTIFICATION_FILENAME = "kplr%s_uinm.xml";
    private static final String FORM_ACTION = "form action=";
    private static final String LOGIN_PAGE_URL = "http://surveys.roe.ac.uk/wsa/login.html";
    private static final String MULTI_IMAGE_URL = "http://surveys.roe.ac.uk:8080/wsa/MultiGetImage";
    private static final String A_HREF = "a href=";
    private static final String WGET = "wget \"";
    private static final String OBJ_NAME = "objName=";
    private static final String INPUT_FORMAT = "%.7f %.7f %09d";
    private static final String CONVERSION_SCRIPT = "convert-ds9-fits-to-png.sh";
    private static final String SHELL_COMMAND = "/bin/sh";
    public static final String DATE_FORMAT = "yyyyDDDHHmmss";
    private static final int MAX_IMAGE_COUNT = 5000;

    private static boolean debug;

    private TargetSelectionCrud targetSelectionCrud = null;
    private CelestialObjectOperations celestialObjectOperations = null;
    private UkirtImageRetrieverOptions options = null;

    public static void main(String[] args) {

        Options commandLineOptions = new Options();
        commandLineOptions.addOption("a", "ds9-args", true,
            "Ds9 command line args");
        commandLineOptions.addOption("b", "ds9-binary", true,
            "Full path to ds9 executable");
        commandLineOptions.addOption("c", "custom-target-processing-enabled",
            false, "Enables custom target processing");
        commandLineOptions.addOption("d", "debug", false,
            "Print stack traces as appropriate");
        commandLineOptions.addOption("e", "end-kepler-id", true,
            "Ending KeplerId");
        commandLineOptions.addOption("g", "sky-group-id", true, "Sky group Id");
        commandLineOptions.addOption("i", "image-size", true,
            "Image size in arcmin");
        commandLineOptions.addOption("k", "kepler-id-list", true,
            "File containing a list of keplerIds");
        commandLineOptions.addOption("o", "output-dir", true,
            "Output directory for PNGs");
        commandLineOptions.addOption("s", "start-kepler-id", true,
            "Starting KeplerId");
        commandLineOptions.addOption("t", "target-list-name", true,
            "Limit to the targets on the given list (can be specified more than once)");
        commandLineOptions.addOption("w", "working-dir", true, String.format(
            "Working directory for intermediate files (default is %s)",
            UkirtImageRetrieverOptions.DEFAULT_WORKING_DIRECTORY));

        try {
            CommandLine cmds = new PosixParser().parse(commandLineOptions, args);

            UkirtImageRetrieverOptions options = UkirtImageRetriever.retrieveOptions(cmds);

            DateFormat dateFormatter = new SimpleDateFormat(DATE_FORMAT);
            dateFormatter.setTimeZone(TimeZone.getTimeZone("UTC"));

            for (int skyGroupId : options.getSkyGroupIds()) {
                String formattedDate = dateFormatter.format(new Date());

                List<String> fitsFiles = new UkirtImageRetriever(
                    new TargetSelectionCrud(), new CelestialObjectOperations(
                        new ModelMetadataRetrieverLatest(),
                        !options.isCustomTargetProcessingEnabled()), options).retrieve(
                    formattedDate, skyGroupId);

                if (fitsFiles.size() > 0) {
                    String[] commandArray = buildConversionCommand(options,
                        SHELL_COMMAND, fitsFiles, formattedDate);

                    Process process = Runtime.getRuntime()
                        .exec(commandArray, null, options.getWorkingDir());
                    
                    Thread stderrLogger = new Thread(new StreamLogger(
                        process.getErrorStream()));
                    stderrLogger.start();
                    
                    Thread stdoutLogger = new Thread(new StreamLogger(
                        process.getInputStream()));
                    stdoutLogger.start();
                    
                    process.waitFor();
                    stderrLogger.join();
                    stdoutLogger.join();
                }
            }

        } catch (ParseException e) {
            System.err.println(e.getMessage());
            usage(commandLineOptions);
        } catch (NumberFormatException e) {
            System.err.println("Bad number in argument: " + e.getMessage());
            usage(commandLineOptions);
        } catch (UsageException e) {
            System.err.println(e.getMessage());
            usage(commandLineOptions);
        } catch (Exception e) {
            System.err.println(e.getMessage());
            if (debug) {
                e.printStackTrace();
            }
            System.exit(1);
        }
    }

    public static String[] buildConversionCommand(
        UkirtImageRetrieverOptions options, String shellCommand,
        List<String> fitsFiles, String formattedDate) throws IOException {

        String script = UkirtImageRetriever.generateConvertDs9FitsToPngScript(
            options, formattedDate);
        List<String> commandList = new ArrayList<String>(fitsFiles.size() + 2);
        if (shellCommand != null && shellCommand.length() > 0) {
            commandList.add(shellCommand);
        }
        commandList.add(script);
        commandList.addAll(fitsFiles);
        String[] commandArray = commandList.toArray(new String[commandList.size()]);

        return commandArray;
    }

    private static class StreamLogger implements Runnable {

        private InputStream stream;

        public StreamLogger(InputStream stream) {
            this.stream = stream;
        }

        @Override
        public void run() {
            try {
                BufferedReader stdout = new BufferedReader(
                    new InputStreamReader(stream));
                try {
                    String message = stdout.readLine();
                    while (message != null) {
                        log.info(message);
                        message = stdout.readLine();
                    }
                } finally {
                    FileUtil.close(stdout);
                }
            } catch (IOException ioe) {
            }
        }
    }

    private static UkirtImageRetrieverOptions retrieveOptions(CommandLine cmds) {

        UkirtImageRetrieverOptions options = new UkirtImageRetrieverOptions();
        if (cmds.hasOption("custom-target-processing-enabled")) {
            options.setCustomTargetProcessingEnabled(true);
        }
        if (cmds.hasOption("ds9-args")) {
            options.setDs9CommandLineArgs(cmds.getOptionValue("ds9-args"));
        }
        if (cmds.hasOption("ds9-binary")) {
            options.setDs9Executable(cmds.getOptionValue("ds9-binary"));
        }
        if (cmds.hasOption("end-kepler-id")) {
            options.setEndKeplerId(Integer.valueOf(cmds.getOptionValue("end-kepler-id")));
        }
        if (cmds.hasOption("image-size")) {
            options.setImageSize(Float.valueOf(cmds.getOptionValue("image-size")));
        }
        if (cmds.hasOption("kepler-id-list")) {
            File list = new File(cmds.getOptionValue("kepler-id-list"));
            if (!list.isFile()) {
                throw new UsageException(cmds.getOptionValue("kepler-id-list")
                    + " is not a file");
            }
            if (!list.canRead()) {
                throw new UsageException(cmds.getOptionValue("kepler-id-list")
                    + " is not readable");
            }
            options.setKeplerIdList(list);
        }
        if (cmds.hasOption("output-dir")) {
            options.setOutputDir(cmds.getOptionValue("output-dir"));
        }
        if (cmds.hasOption("sky-group-id")) {
            options.setSkyGroupIds(getSkyGroupIds(cmds.getOptionValues("sky-group-id")));
        }
        if (cmds.hasOption("start-kepler-id")) {
            options.setStartKeplerId(Integer.valueOf(cmds.getOptionValue("start-kepler-id")));
        }
        if (cmds.hasOption("target-list-name")) {
            options.setTargetListNames(cmds.getOptionValues("target-list-name"));
        }
        if (cmds.hasOption("working-dir")) {
            options.setWorkingDir(new File(cmds.getOptionValue("working-dir")));
        }
        if (cmds.hasOption("debug")) {
            debug = true;
        }

        return options;
    }

    private static Collection<Integer> getSkyGroupIds(String[] skyGroupIdItems) {
        Set<Integer> skyGroupIds = new HashSet<Integer>();

        for (String skyGroupIdItem : skyGroupIdItems) {
            int index = skyGroupIdItem.indexOf('-');
            if (index != -1) {
                String[] items = skyGroupIdItem.split("[\\-]");
                if (items.length != 2) {
                    throw new UsageException("invalid sky group: "
                        + skyGroupIdItem);
                }
                int lowerBound = Integer.valueOf(items[0]);
                int upperBound = Integer.valueOf(items[1]);
                if (upperBound < lowerBound || lowerBound < 1
                    || upperBound > 84) {
                    throw new UsageException("invalid sky group: "
                        + skyGroupIdItem);
                }
                for (int i = lowerBound; i <= upperBound; i++) {
                    skyGroupIds.add(Integer.valueOf(i));
                }
            } else {
                skyGroupIds.add(Integer.valueOf(skyGroupIdItem));
            }
        }

        return skyGroupIds;
    }

    private static void usage(Options options) {
        HelpFormatter formatter = new HelpFormatter();
        System.err.println();
        formatter.printHelp(new PrintWriter(System.err, true), 80,
            "UkirtImageRetriever [options]", "", options, 2, 4, "");
        System.exit(1);
    }

    public UkirtImageRetriever(TargetSelectionCrud targetSelectionCrud,
        CelestialObjectOperations celestialObjectOperations,
        UkirtImageRetrieverOptions options) {

        this.targetSelectionCrud = targetSelectionCrud;
        this.celestialObjectOperations = celestialObjectOperations;
        this.options = options;
        validate(options);
    }

    private void validate(UkirtImageRetrieverOptions options) {

        if (options.getKeplerIdList() == null) {
            if (!options.getSkyGroupIds()
                .isEmpty()) {
                for (Integer skyGroupId : options.getSkyGroupIds()) {
                    if (skyGroupId < 1 || skyGroupId > 84) {
                        throw new UsageException("invalid skygroup specified: "
                            + skyGroupId);
                    }
                }
            }
            if (options.getTargetListNames().length == 0) {
                throw new UsageException("no target list specified");
            }
        }
    }

    public List<String> retrieve(String formattedDate, int skyGroupId)
        throws ClientProtocolException, IOException {

        List<String> inputs = retrieveImageInputs(skyGroupId);
        List<String> outputs = new ArrayList<String>(inputs.size());

        if (inputs.size() > 0) {
            if (!options.getWorkingDir()
                .exists()) {
                options.getWorkingDir()
                    .mkdirs();
            }
            File inputFile = new File(options.getWorkingDir(), String.format(
                UKIRT_INPUT_FILENAME, formattedDate));
            generateImageRequestFile(inputFile, inputs);

            HttpClient httpclient = new DefaultHttpClient();
            HttpContext localContext = new BasicHttpContext();
            CookieStore cookieStore = new BasicCookieStore();
            localContext.setAttribute(ClientContext.COOKIE_STORE, cookieStore);

            String loginRequest = getLoginRequest(httpclient, localContext);
            postLoginRequest(httpclient, localContext, loginRequest);

            String wgetRequest = postMultiImageRequest(httpclient,
                localContext, inputFile);

            Map<Integer, String> keplerIdToImageRequest = getImageRequests(
                httpclient, localContext, wgetRequest);

            for (int keplerId : keplerIdToImageRequest.keySet()) {
                String imageRequest = keplerIdToImageRequest.get(keplerId);
                String filename = String.format(UKIRT_FITS_FILENAME,
                    formattedDate, keplerId);
                getImage(httpclient, localContext, imageRequest,
                    options.getWorkingDir(), filename);
                outputs.add(filename);
            }
        }

        return outputs;
    }

    private String extractImageRequest(String wgetCommand) {
        String imageRequest = null;

        int beginIndex = wgetCommand.indexOf(WGET);
        if (beginIndex != -1) {
            beginIndex += WGET.length();
            int endIndex = wgetCommand.indexOf('\"', beginIndex);
            if (endIndex != -1) {
                imageRequest = wgetCommand.substring(beginIndex, endIndex);
            }
        }

        return imageRequest;
    }

    private String getLoginRequest(HttpClient httpClient,
        HttpContext localContext) throws IOException, ClientProtocolException {
        HttpGet httpGet = new HttpGet(LOGIN_PAGE_URL);
        HttpResponse httpResponse = httpClient.execute(httpGet, localContext);
        String request = null;
        BufferedReader reader = null;
        try {
            log.debug("========= Request  ========");
            log.debug(httpGet.getRequestLine());
            log.debug("========= Response ========");
            log.debug(httpResponse.getStatusLine());
            HttpEntity loginEntity = httpResponse.getEntity();
            InputStream inputStream = loginEntity.getContent();
            reader = new BufferedReader(new InputStreamReader(inputStream));
            String loginLine = reader.readLine();
            while (loginLine != null) {
                int beginIndex = loginLine.indexOf(FORM_ACTION);
                if (beginIndex != -1) {
                    beginIndex += FORM_ACTION.length() + 1;
                    int endIndex = loginLine.indexOf('\"', beginIndex);
                    request = loginLine.substring(beginIndex, endIndex);
                    log.debug("loginRequest: " + request);
                    break;
                }
                loginLine = reader.readLine();
            }
            EntityUtils.consume(loginEntity);
        } finally {
            FileUtil.close(reader);
            httpGet.releaseConnection();
        }

        return request;
    }

    private void postLoginRequest(HttpClient httpClient,
        HttpContext localContext, String loginRequest)
        throws UnsupportedEncodingException, IOException,
        ClientProtocolException {

        HttpPost httpPost = new HttpPost(loginRequest);
        List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>();
        nameValuePairs.add(new BasicNameValuePair("user", "WSERV4"));
        nameValuePairs.add(new BasicNameValuePair("passwd", "public"));
        nameValuePairs.add(new BasicNameValuePair("community", " "));
        nameValuePairs.add(new BasicNameValuePair("community2", "nonSurvey"));
        httpPost.setEntity(new UrlEncodedFormEntity(nameValuePairs));
        HttpResponse httpResponse = httpClient.execute(httpPost, localContext);
        try {
            log.debug("========= Request  ========");
            log.debug(httpPost.getRequestLine());
            log.debug("========= Response ========");
            log.debug(httpResponse.getStatusLine());
            HttpEntity loginEntity = httpResponse.getEntity();
            EntityUtils.consume(loginEntity);
        } finally {
            httpPost.releaseConnection();
        }
    }

    private String postMultiImageRequest(HttpClient httpclient,
        HttpContext localContext, File coordinatesFile)
        throws UnsupportedEncodingException, IOException,
        ClientProtocolException {
        HttpPost httpPost = new HttpPost(MULTI_IMAGE_URL);
        MultipartEntity uploadEntity = new MultipartEntity(
            HttpMultipartMode.BROWSER_COMPATIBLE);
        uploadEntity.addPart("database", new StringBody("WSERV4v20101019"));
        uploadEntity.addPart("band", new StringBody("J"));
        uploadEntity.addPart("idPresent", new StringBody("noID"));
        uploadEntity.addPart("userX",
            new StringBody(String.format("%.4f", options.getImageSize())));
        uploadEntity.addPart("crossHair", new StringBody("n"));
        uploadEntity.addPart("mode", new StringBody("wget"));
        FileBody requestList = new FileBody(coordinatesFile, "text/plain");
        uploadEntity.addPart("uploadFile", requestList);
        httpPost.setEntity(uploadEntity);
        HttpResponse httpResponse = httpclient.execute(httpPost, localContext);
        String wgetRequest = null;
        BufferedReader reader = null;
        try {
            log.debug("========= Request  ========");
            log.debug(httpPost.getRequestLine());
            log.debug("========= Response ========");
            log.debug(httpResponse.getStatusLine());
            HttpEntity multiImageEntity = httpResponse.getEntity();
            InputStream inputStream = multiImageEntity.getContent();
            reader = new BufferedReader(new InputStreamReader(inputStream));
            String multiImageLine = reader.readLine();
            while (multiImageLine != null) {
                int beginIndex = multiImageLine.indexOf(A_HREF);
                if (beginIndex != -1) {
                    beginIndex += A_HREF.length() + 1;
                    int endIndex = multiImageLine.indexOf('\"', beginIndex);
                    wgetRequest = multiImageLine.substring(beginIndex, endIndex);
                    log.debug("wgetRequest: " + wgetRequest);
                    break;
                }
                multiImageLine = reader.readLine();
            }
            EntityUtils.consume(multiImageEntity);
        } finally {
            FileUtil.close(reader);
            httpPost.releaseConnection();
        }

        return wgetRequest;
    }

    private Map<Integer, String> getImageRequests(HttpClient httpclient,
        HttpContext localContext, String wgetRequest) throws IOException,
        ClientProtocolException {
        HttpGet httpGetWget = new HttpGet(wgetRequest);
        HttpResponse responseWget = httpclient.execute(httpGetWget,
            localContext);
        Map<Integer, String> keplerIdToImageRequest = new HashMap<Integer, String>();
        BufferedReader reader = null;
        try {
            log.debug("========= Request  ========");
            log.debug(httpGetWget.getRequestLine());
            log.debug("========= Response ========");
            log.debug(responseWget.getStatusLine());
            HttpEntity wgetEntity = responseWget.getEntity();
            InputStream inputStream = wgetEntity.getContent();
            reader = new BufferedReader(new InputStreamReader(inputStream));
            String wgetLine = reader.readLine();
            while (wgetLine != null) {
                int beginIndex = wgetLine.indexOf(OBJ_NAME);
                if (beginIndex != -1) {
                    beginIndex += OBJ_NAME.length();
                    int endIndex = wgetLine.indexOf(':', beginIndex);
                    String objName = wgetLine.substring(beginIndex, endIndex);
                    int keplerId = Integer.valueOf(objName);
                    log.debug("keplerId: " + keplerId);

                    String imageRequest = extractImageRequest(wgetLine);
                    if (imageRequest == null) {
                        log.warn(String.format(
                            "Image not available for keplerId %09d: %s",
                            keplerId, wgetLine));
                        wgetLine = reader.readLine();
                        continue;
                    }
                    keplerIdToImageRequest.put(keplerId, imageRequest);
                } else {
                    log.error(String.format("Unexpected wget line: \"%s\"",
                        wgetLine));
                }
                wgetLine = reader.readLine();
            }
            EntityUtils.consume(wgetEntity);
        } finally {
            FileUtil.close(reader);
            httpGetWget.releaseConnection();
        }

        return keplerIdToImageRequest;
    }

    private void getImage(HttpClient httpclient, HttpContext localContext,
        String imageRequest, File workingDir, String filename)
        throws IOException, ClientProtocolException {

        HttpGet httpGetImage = new HttpGet(imageRequest);
        HttpResponse responseImage = httpclient.execute(httpGetImage,
            localContext);
        BufferedInputStream imageStream = null;
        BufferedOutputStream imageFile = null;
        try {
            log.debug("========= Request  ========");
            log.debug(httpGetImage.getRequestLine());
            log.debug("========= Response ========");
            log.debug(responseImage.getStatusLine());
            HttpEntity imageEntity = responseImage.getEntity();
            imageStream = new BufferedInputStream(imageEntity.getContent());
            CompressorInputStream compressorInputStream = null;
            try {
                compressorInputStream = new CompressorStreamFactory().createCompressorInputStream(imageStream);
            } catch (CompressorException e) {
                throw new PipelineException(
                    "Received an unexpected exception while creating compressor input stream",
                    e);
            }
            File file = new File(workingDir, filename);
            imageFile = new BufferedOutputStream(
                FileUtils.openOutputStream(file));

            byte[] buffer = new byte[8192];
            int bytesRead = compressorInputStream.read(buffer);
            while (bytesRead != -1) {
                imageFile.write(buffer, 0, bytesRead);
                bytesRead = compressorInputStream.read(buffer);
            }
            log.info("Created " + file.getPath());
            EntityUtils.consume(imageEntity);
        } finally {
            FileUtil.close(imageStream);
            FileUtil.close(imageFile);
            httpGetImage.releaseConnection();
        }
    }

    private List<String> retrieveImageInputs(int skyGroupId) throws IOException {

        List<Integer> allKeplerIdsList = new ArrayList<Integer>();
        if (options.getKeplerIdList() != null) {
            allKeplerIdsList = readKeplerIdsFromFile(options.getKeplerIdList());
        } else {
            allKeplerIdsList = targetSelectionCrud.retrieveKeplerIdsForTargetListName(
                Arrays.asList(options.getTargetListNames()), skyGroupId,
                options.getStartKeplerId(), options.getEndKeplerId());
        }

        log.info(String.format("    skyGroupId: %d", skyGroupId));
        log.info(String.format(" startKeplerId: %d", options.getStartKeplerId()));
        log.info(String.format("   endKeplerId: %d", options.getEndKeplerId()));
        for (int i = 0; i < options.getTargetListNames().length; i++) {
            log.info(String.format("targetListName: %s",
                options.getTargetListNames()[i]));
        }

        List<Integer> imageKeplerIdsList = new DvCrud().retrieveKeplerIdsForUkirtImages(
            Arrays.asList(options.getTargetListNames()), skyGroupId,
            options.getStartKeplerId(), options.getEndKeplerId());

        Set<Integer> allKeplerIdsSet = new TreeSet<Integer>(allKeplerIdsList);
        Set<Integer> imageKeplerIdsSet = new TreeSet<Integer>(
            imageKeplerIdsList);

        log.info(String.format("There are %d total kepler ids",
            allKeplerIdsList.size()));

        allKeplerIdsSet.removeAll(imageKeplerIdsSet);

        log.info(String.format("There are %d kepler ids w/o images",
            allKeplerIdsSet.size()));

        List<String> entries = new ArrayList<String>();
        if (allKeplerIdsSet.size() > 0) {

            List<CelestialObjectParameters> celestialObjectParametersList = celestialObjectOperations.retrieveCelestialObjectParameters(new ArrayList<Integer>(
                allKeplerIdsSet));

            Map<Integer, CelestialObjectParameters> keplerIdToCelestialObjectParameters = new LinkedHashMap<Integer, CelestialObjectParameters>();
            for (CelestialObjectParameters celestialObjectParameters : celestialObjectParametersList) {
                if (celestialObjectParameters != null) {
                    keplerIdToCelestialObjectParameters.put(
                        celestialObjectParameters.getKeplerId(),
                        celestialObjectParameters);
                }
            }

            for (int keplerId : allKeplerIdsSet) {
                CelestialObjectParameters parameters = keplerIdToCelestialObjectParameters.get(keplerId);
                if (parameters == null) {
                    log.warn(String.format(
                        "No celestial object found for kepler id %d", keplerId));
                    continue;
                }

                CelestialObjectParameter raParameter = parameters.getRa();
                CelestialObjectParameter decParameter = parameters.getDec();

                if (Double.isNaN(raParameter.getValue())) {
                    log.warn(String.format("RA value for %d keplerId is NaN",
                        keplerId));
                    continue;
                }
                if (Double.isNaN(decParameter.getValue())) {
                    log.warn(String.format("Dec value for %d keplerId is NaN",
                        keplerId));
                    continue;
                }

                entries.add(String.format(INPUT_FORMAT,
                    raParameter.getValue() * 360.0 / 24.0,
                    decParameter.getValue(), keplerId));
            }

            if (entries.size() > MAX_IMAGE_COUNT) {
                List<String> reducedEntries = new ArrayList<String>(
                    entries.size());
                for (int i = 0; i < MAX_IMAGE_COUNT; i++) {
                    reducedEntries.add(entries.get(i));
                }
                entries = reducedEntries;
            }
        }

        log.debug(String.format("There are %d image request entries",
            entries.size()));
        return entries;
    }

    private List<Integer> readKeplerIdsFromFile(File file) throws IOException {

        List<Integer> keplerIds = new ArrayList<Integer>();
        BufferedReader reader = new BufferedReader(new FileReader(file));
        try {
            String line = reader.readLine();
            while (line != null) {
                keplerIds.add(Integer.valueOf(line));
                line = reader.readLine();
            }
        } finally {
            FileUtil.close(reader);
        }

        return keplerIds;
    }

    private void generateImageRequestFile(File file, List<String> entries)
        throws IOException {

        BufferedWriter writer = new BufferedWriter(new FileWriter(file));
        try {
            for (String entry : entries) {
                writer.append(entry);
                writer.newLine();
            }
        } finally {
            FileUtil.close(writer);
        }
    }

    public static String generateConvertDs9FitsToPngScript(
        UkirtImageRetrieverOptions options, String formattedDate)
        throws IOException {

        File notificationFile = new File(options.getWorkingDir(),
            String.format(UKIRT_NOTIFICATION_FILENAME, formattedDate));
        StringBuffer scriptBuffer = new StringBuffer(1024);
        scriptBuffer.append(String.format("#!%s\n", SHELL_COMMAND));
        scriptBuffer.append(String.format("ds9=\"%s\"\n",
            options.getDs9Executable()));
        scriptBuffer.append(String.format("nmFile=\"%s\"\n",
            notificationFile.getPath()));
        scriptBuffer.append(String.format("outputDir=\"%s\"\n",
            options.getOutputDir()));
        scriptBuffer.append("\n");
        scriptBuffer.append("rm -f $nmFile\n");
        scriptBuffer.append("echo '<?xml version=\"1.0\" encoding=\"UTF-8\"?>' >> $nmFile\n");
        scriptBuffer.append("echo '<nm:data_product_message xmlns:nm=\"http://kepler.nasa.gov/nm\">' >> $nmFile\n");
        scriptBuffer.append("echo '<message_type>UINM</message_type>' >> $nmFile\n");
        scriptBuffer.append("printf \"<identifier>%s</identifier>\\n\" `basename $nmFile` >> $nmFile\n");
        scriptBuffer.append("echo '<file_list>' >> $nmFile\n");
        scriptBuffer.append("\n");
        scriptBuffer.append("mkdir -p $outputDir\n");
        scriptBuffer.append("for fits in \"${@}\"\n");
        scriptBuffer.append("do\n");
        scriptBuffer.append("    echo $fits\n");
        scriptBuffer.append("    png=`basename $fits .fits`.png\n");
        scriptBuffer.append("    $ds9 $fits \\\n");
        scriptBuffer.append("        -cd $outputDir \\\n");
        scriptBuffer.append(String.format("        %s \\\n",
            options.getDs9CommandLineArgs()));
        scriptBuffer.append("        -saveimage png $png \\\n");
        scriptBuffer.append("        -exit \n");
        scriptBuffer.append("    printf \"    <file>\\n\\t<filename>%s</filename>\" $png >> $nmFile\n");
        scriptBuffer.append("    printf \"\\n\\t<size>%s</size>\\n    </file>\\n\" `ls -l $outputDir/$png | awk '{print $5}'`>> $nmFile\n");
        scriptBuffer.append("done\n");
        scriptBuffer.append("printf '</file_list>\\n</nm:data_product_message>\\n' >> $nmFile\n");
        scriptBuffer.append("mv $nmFile $outputDir\n");

        BufferedWriter writer = new BufferedWriter(new FileWriter(new File(
            options.getWorkingDir(), CONVERSION_SCRIPT)));
        try {
            writer.write(scriptBuffer.toString());
        } finally {
            FileUtil.close(writer);
        }

        return CONVERSION_SCRIPT;
    }
}
