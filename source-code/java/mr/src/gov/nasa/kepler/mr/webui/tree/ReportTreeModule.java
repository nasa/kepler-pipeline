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

package gov.nasa.kepler.mr.webui.tree;

import static gov.nasa.kepler.mr.scriptlet.AlertsScriptlet.REPORT_NAME_ALERTS;
import static gov.nasa.kepler.mr.scriptlet.AlertsScriptlet.REPORT_TITLE_ALERTS;
import static gov.nasa.kepler.mr.scriptlet.BadPixelsScriptlet.REPORT_NAME_BAD_PIXELS;
import static gov.nasa.kepler.mr.scriptlet.BadPixelsScriptlet.REPORT_TITLE_BAD_PIXELS;
import static gov.nasa.kepler.mr.scriptlet.ConfigMapScriptlet.REPORT_NAME_CONFIG_MAP;
import static gov.nasa.kepler.mr.scriptlet.ConfigMapScriptlet.REPORT_TITLE_CONFIG_MAP;
import static gov.nasa.kepler.mr.scriptlet.DataCompressionScriptlet.REPORT_NAME_DATA_COMPRESSION;
import static gov.nasa.kepler.mr.scriptlet.DataCompressionScriptlet.REPORT_TITLE_DATA_COMPRESSION;
import static gov.nasa.kepler.mr.scriptlet.DataGapScriptlet.REPORT_NAME_DATA_GAP;
import static gov.nasa.kepler.mr.scriptlet.DataGapScriptlet.REPORT_TITLE_DATA_GAP;
import static gov.nasa.kepler.mr.scriptlet.DrScriptlet.REPORT_NAME_DR_SUMMARY;
import static gov.nasa.kepler.mr.scriptlet.DrScriptlet.REPORT_TITLE_DR_SUMMARY;
import static gov.nasa.kepler.mr.scriptlet.FcScriptlet.REPORT_NAME_FC;
import static gov.nasa.kepler.mr.scriptlet.FcScriptlet.REPORT_TITLE_FC;
import static gov.nasa.kepler.mr.scriptlet.HuffmanScriptlet.REPORT_NAME_HUFFMAN_TABLES;
import static gov.nasa.kepler.mr.scriptlet.HuffmanScriptlet.REPORT_TITLE_HUFFMAN_TABLES;
import static gov.nasa.kepler.mr.scriptlet.PipelineScriptlet.REPORT_NAME_PI_PROCESSING;
import static gov.nasa.kepler.mr.scriptlet.PipelineScriptlet.REPORT_TITLE_PI_PROCESSING;
import static gov.nasa.kepler.mr.scriptlet.RequantScriptlet.REPORT_NAME_REQUANT_TABLES;
import static gov.nasa.kepler.mr.scriptlet.RequantScriptlet.REPORT_TITLE_REQUANT_TABLES;
import static gov.nasa.kepler.mr.scriptlet.TadCcdModuleOutputScriptlet.REPORT_NAME_TAD_MODULE;
import static gov.nasa.kepler.mr.scriptlet.TadCcdModuleOutputScriptlet.REPORT_TITLE_TAD_MODULE;
import static gov.nasa.kepler.mr.scriptlet.TadScriptlet.REPORT_NAME_TAD_SUMMARY;
import static gov.nasa.kepler.mr.scriptlet.TadScriptlet.REPORT_TITLE_TAD_SUMMARY;
import static gov.nasa.kepler.mr.servlet.GenericReport.REPORT_NAME_GENERIC_REPORT;
import static gov.nasa.kepler.mr.servlet.GenericReport.REPORT_TITLE_GENERIC_REPORT;
import static gov.nasa.kepler.mr.servlet.ReportViewerServlet.REPORT_URI_BASE;
import gov.nasa.kepler.mr.users.pi.Permissions;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

import javax.servlet.ServletContext;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openedit.repository.ContentItem;
import org.openedit.repository.Repository;
import org.openedit.repository.filesystem.FileItem;

import com.openedit.OpenEditException;
import com.openedit.WebPageRequest;
import com.openedit.page.PageAction;
import com.openedit.users.User;
import com.openedit.webui.tree.DefaultWebTreeNode;
import com.openedit.webui.tree.RepositoryTreeModel;
import com.openedit.webui.tree.RepositoryTreeNode;
import com.openedit.webui.tree.TreeModule;
import com.openedit.webui.tree.WebTree;
import com.openedit.webui.tree.WebTreeNodeTreeRenderer;

/**
 * This class is used as the Java code portion of the MR web site's report file
 * tree. It extends and overrides OpenEdit's TreeModule class. This
 * implementation presents a report tree that shows the list of reports that the
 * user has permissions to view. When the user clicks on a report file, the
 * report is just-in-time generated and served if it does not already exist in
 * the report file tree, otherwise it is simply served from the already
 * generated file.
 * 
 * @author Bill Wohler
 * @author jbrittain
 */
public class ReportTreeModule extends TreeModule {

    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(ReportTreeModule.class);

    private static final String ROOT = "root";
    private static final String DOT_HTML = ".html";
    private static final String DOT_PDF = ".pdf";
    private static final String PARAM_TREE_ID = "treeid";
    private static final String CONFIG_EXCLUDES = "excludes";
    private static final String CONFIG_FRIENDLY_NAMES = "friendlyNames";
    private static final String CONFIG_TREE_NAME = "tree-name";
    private static final String CONFIG_WEB_TREE_NAME = "WebTreeName";
    private static final String CONFIG_URL_PREFIX = "url-prefix";
    private static final String PAGE_ATTRIBUTE_HOME = "home";
    private static final String PAGE_ATTRIBUTE_PAGE_MANAGER = "pageManager";

    /**
     * Reports, in the order that you want them to appear in the menu. Each pair
     * contains the name of the report as it should be shown to the user in the
     * report tree and the name of the report that appears in filenames and
     * URLs.
     */
    @SuppressWarnings("unchecked")
    private static final List<Pair<String, String>> reportNames = Arrays.asList(
        Pair.of(REPORT_TITLE_PI_PROCESSING, REPORT_NAME_PI_PROCESSING),
        Pair.of(REPORT_TITLE_TAD_SUMMARY, REPORT_NAME_TAD_SUMMARY),
        Pair.of(REPORT_TITLE_TAD_MODULE, REPORT_NAME_TAD_MODULE),
        Pair.of(REPORT_TITLE_DATA_COMPRESSION, REPORT_NAME_DATA_COMPRESSION),
        Pair.of(REPORT_TITLE_HUFFMAN_TABLES, REPORT_NAME_HUFFMAN_TABLES),
        Pair.of(REPORT_TITLE_REQUANT_TABLES, REPORT_NAME_REQUANT_TABLES),
        Pair.of(REPORT_TITLE_DR_SUMMARY, REPORT_NAME_DR_SUMMARY),
        Pair.of(REPORT_TITLE_DATA_GAP, REPORT_NAME_DATA_GAP),
        Pair.of(REPORT_TITLE_BAD_PIXELS, REPORT_NAME_BAD_PIXELS),
        Pair.of(REPORT_TITLE_GENERIC_REPORT, REPORT_NAME_GENERIC_REPORT),
        Pair.of(REPORT_TITLE_ALERTS, REPORT_NAME_ALERTS),
        Pair.of(REPORT_TITLE_FC, REPORT_NAME_FC),
        Pair.of(REPORT_TITLE_CONFIG_MAP, REPORT_NAME_CONFIG_MAP));

    protected Date startDate;
    protected Date endDate;
    protected String contextPath;

    /**
     * Initializes the ReportTree.
     */
    @Override
    public WebTree getTree(WebPageRequest request) throws OpenEditException {
        String treeid = request.getRequestParameter(PARAM_TREE_ID);
        String name = findValue(CONFIG_TREE_NAME, request);
        if (name == null) {
            name = findValue(CONFIG_WEB_TREE_NAME, request);
        }
        if (treeid == null) {
            treeid = name + "_" + request.getUserName();
        }
        WebTree webTree = (WebTree) request.getSessionValue(treeid);

        if (webTree == null && name != null) {
            // The root is applicable to our model only.
            PageAction inAction = request.getCurrentAction();
            String root = null;
            if (inAction.getConfig() != null) {
                // This might not be set.
                root = inAction.getConfig()
                    .getChildValue(ROOT);
            }
            RepositoryTreeModel model = null;

            if (root == null || root.equals("/")) {
                model = new RepositoryTreeModel(
                    getPageManager().getRepository());
            } else {
                model = new RepositoryTreeModel(
                    getPageManager().getRepository(), root);
            }

            ServletContext context = request.getSession()
                .getServletContext();
            contextPath = context.getRealPath("/");
            clearTree(model);
            addReportNodes(model, request.getUser());

            getPageManager().addPageAccessListener(model);

            String ignore = inAction.getConfig()
                .getChildValue(CONFIG_EXCLUDES);
            if (ignore != null) {
                String[] types = ignore.split(",");
                for (String element : types) {
                    model.ignore(element.trim());
                    MrWebTreeNode node = (MrWebTreeNode) model.findNode(element.trim());
                    deleteNode(node);
                }
            }

            webTree = new WebTree(model);
            webTree.setName(name);
            webTree.setId(treeid);

            // set up the renderer.
            MrWebTreeRenderer renderer = new MrWebTreeRenderer(webTree);
            String prefix = inAction.getConfig()
                .getChildValue(CONFIG_URL_PREFIX);
            if (prefix != null) {
                renderer.setUrlPrefix(prefix);
            }
            String friendly = inAction.getConfig()
                .getChildValue(CONFIG_FRIENDLY_NAMES);
            if (friendly != null) {
                renderer.setFriendlyNames(Boolean.valueOf(friendly)
                    .booleanValue());
            }
            String home = (String) request.getPageValue(PAGE_ATTRIBUTE_HOME);
            renderer.setHome(home);
            webTree.setTreeRenderer(renderer);

            request.putSessionValue(treeid, webTree);
        }
        if (webTree != null) {
            request.putPageValue(PAGE_ATTRIBUTE_PAGE_MANAGER, getPageManager());
            request.putPageValue(name, webTree);
        }
        return webTree;
    }

    protected void clearTree(RepositoryTreeModel model) {
        RepositoryTreeNode rootNode = (RepositoryTreeNode) model.getRoot();
        @SuppressWarnings("unchecked")
        List<RepositoryTreeNode> children = rootNode.getChildren();
        if (children == null) {
            return; // nothing to do
        }
        // Make copy to avoid ConcurrentModificationException.
        List<RepositoryTreeNode> repositoryTreeNodes = new ArrayList<RepositoryTreeNode>(
            children);
        for (RepositoryTreeNode repositoryTreeNode : repositoryTreeNodes) {
            deleteNode(repositoryTreeNode);
        }
    }

    protected void addReportNodes(RepositoryTreeModel model, User user) {
        RepositoryTreeNode rootNode = (RepositoryTreeNode) model.getRoot();
        rootNode.setName("");

        for (Pair<String, String> reportName : reportNames) {
            if (hasPermissionToView(user, reportName.right)) {
                MrWebTreeNode reportNode = addChildNode(reportName.left,
                    reportName.right, rootNode, getRealPath(rootNode));
                reportNode.setLeaf(true);
            }
        }
    }

    protected boolean hasPermissionToView(User user, String reportName) {
        if (user.hasPermission(Permissions.PERM_MR_PREFIX + reportName)
            || user.hasPermission(Permissions.ADMINISTRATION)) {
            return true;
        }
        return false;
    }

    protected String getRealPath(RepositoryTreeNode rootNode) {
        return contextPath + "/" + rootNode.getURL();
    }

    protected MrWebTreeNode addChildNode(String friendlyName, String nodeName,
        RepositoryTreeNode rootNode, String contextDirPath) {

        boolean isDir = true;
        if (nodeName.endsWith(DOT_HTML) || nodeName.endsWith(DOT_PDF)) {
            isDir = false;
        }
        MrWebTreeNode node = (MrWebTreeNode) rootNode.getChild(nodeName);
        if (node == null) {
            File nodeFile = new File(contextDirPath, nodeName);
            if (isDir) {
                if (!nodeFile.mkdirs()) {
                    ; // Ignore, since mkdirs returns false if directory exists.
                }
            }
            FileItem fileItem = new FileItem();
            fileItem.setFile(nodeFile);
            fileItem.setPath(REPORT_URI_BASE + "/" + nodeName);
            fileItem.setVersion(ContentItem.TYPE_ADDED);
            node = new MrWebTreeNode(rootNode.getRepository(), fileItem);
            node.setName(nodeName);
            node.setFriendlyName(friendlyName);
            rootNode.addChild(node);
        }

        return node;
    }

    protected void deleteNode(RepositoryTreeNode child) {
        if (child != null) {
            DefaultWebTreeNode parent = child.getParent();
            @SuppressWarnings("rawtypes")
            List nodes = parent.getChildren();
            nodes.remove(child);
            child.setParent(null);
        }
    }

    /**
     * A web tree renderer that returns a real friendly name for the menu item,
     * instead of one that would be fake even if it didn't throw a
     * StringIndexOutOfBoundsException.
     * 
     * @author Bill Wohler
     */
    private static class MrWebTreeRenderer extends WebTreeNodeTreeRenderer {

        public MrWebTreeRenderer(WebTree webTree) {
            super(webTree);
        }

        @Override
        public String toName(Object webTreeNode) {
            if (webTreeNode instanceof MrWebTreeNode) {
                MrWebTreeNode node = (MrWebTreeNode) webTreeNode;
                if (isFriendlyNames() && node.getFriendlyName() != null) {
                    return node.getFriendlyName();
                }
            }

            // Avoid StringIndexOutOfBoundsException.
            boolean friendlyNames = isFriendlyNames();
            setFriendlyNames(false);
            String name = super.toName(webTreeNode);
            setFriendlyNames(friendlyNames);

            return name;
        }
    }

    /**
     * A tree node with a true user-friendly name for the menu item.
     * 
     * @author Bill Wohler
     */
    private static class MrWebTreeNode extends RepositoryTreeNode {

        private String friendlyName;

        public MrWebTreeNode(Repository repository, ContentItem contentItem) {
            super(repository, contentItem);
        }

        public String getFriendlyName() {
            return friendlyName;
        }

        public void setFriendlyName(String friendlyName) {
            this.friendlyName = friendlyName;
        }
    }
}
