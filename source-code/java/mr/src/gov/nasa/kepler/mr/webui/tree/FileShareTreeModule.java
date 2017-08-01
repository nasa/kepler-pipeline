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

import gov.nasa.kepler.mr.users.pi.Permissions;

import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.openedit.OpenEditException;
import com.openedit.WebPageRequest;
import com.openedit.page.PageAction;
import com.openedit.users.User;
import com.openedit.webui.tree.BaseTreeRenderer;
import com.openedit.webui.tree.DefaultWebTreeNode;
import com.openedit.webui.tree.RepositoryTreeModel;
import com.openedit.webui.tree.RepositoryTreeNode;
import com.openedit.webui.tree.TreeModule;
import com.openedit.webui.tree.WebTree;
import com.openedit.webui.tree.WebTreeModel;
import com.openedit.webui.tree.WebTreeNodeTreeRenderer;

/**
 * This class is used as the Java code portion of the MR web site's file share
 * tree. It extends and overrides OpenEdit's TreeModule class. This
 * implementation presents the file share tree to users, but limits what is
 * visible based on the user's permissions.
 * 
 * @author jbrittain
 */
public class FileShareTreeModule extends TreeModule {

    /**
     * Logger for this class
     */
    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(FileShareTreeModule.class);

    private static final String SLASH = "/";
    private static final String UNDERSCORE = "_";
    private static final String ROOT = "root";
    private static final String PARAM_TREE_ID = "treeid";
    private static final String CONFIG_EXCLUDES = "excludes";
    private static final String CONFIG_FRIENDLY_NAMES = "friendlyNames";
    private static final String CONFIG_TREE_NAME = "tree-name";
    private static final String CONFIG_WEB_TREE_NAME = "WebTreeName";
    private static final String CONFIG_URL_PREFIX = "url-prefix";
    private static final String PAGE_ATTRIBUTE_HOME = "home";
    private static final String PAGE_ATTRIBUTE_PAGE_MANAGER = "pageManager";

    // Group Directories
    private static final String GROUP_DIR_SO = "SO";
    private static final String GROUP_DIR_MMO = "MMO";
    private static final String GROUP_DIR_SOC = "SOC";
    private static final String GROUP_DIR_SWG = "SWG";
    private static final String GROUP_DIR_FOWG = "FOWG";
    private static final String GROUP_DIR_MOC = "MOC";
    private static final String GROUP_DIR_FPC = "FPC";
    private static final String GROUP_DIR_DMC = "DMC";

    protected String contextPath;

    /**
     * This method initializes the FileShareTree.
     * 
     * @param webPageRequest
     * @throws OpenEditException
     */
    @Override
    public WebTree getTree(WebPageRequest webPageRequest)
        throws OpenEditException {
        String treeid = webPageRequest.getRequestParameter(PARAM_TREE_ID);
        String name = findValue(CONFIG_TREE_NAME, webPageRequest);
        if (name == null) {
            name = findValue(CONFIG_WEB_TREE_NAME, webPageRequest); // legacy
        }
        if (treeid == null) {
            treeid = name + UNDERSCORE + webPageRequest.getUserName();
        }
        WebTree webTree = (WebTree) webPageRequest.getSessionValue(treeid);

        if (webTree == null && name != null) {
            // The root is applicable to our model only
            PageAction inAction = webPageRequest.getCurrentAction();
            String root = null;
            if (inAction.getConfig() != null) {
                // This might not be set.
                root = inAction.getConfig()
                    .getChildValue(ROOT);
            }
            RepositoryTreeModel model = null;

            if (root == null || root.equals(SLASH)) {
                model = new RepositoryTreeModel(
                    getPageManager().getRepository());
            } else {

                model = new RepositoryTreeModel(
                    getPageManager().getRepository(), root);
            }

            getPageManager().addPageAccessListener(model);

            webTree = new WebTree(model);
            webTree.setName(name);
            webTree.setId(treeid);

            // set up the renderer.
            WebTreeNodeTreeRenderer renderero = new WebTreeNodeTreeRenderer(
                webTree);
            String prefix = inAction.getConfig()
                .getChildValue(CONFIG_URL_PREFIX);
            if (prefix != null) {
                renderero.setUrlPrefix(prefix);
            }
            String friendly = inAction.getConfig()
                .getChildValue(CONFIG_FRIENDLY_NAMES);
            if (friendly != null) {
                renderero.setFriendlyNames(Boolean.valueOf(friendly)
                    .booleanValue());
            }
            String home = (String) webPageRequest.getPageValue(PAGE_ATTRIBUTE_HOME);
            renderero.setHome(home);

            webTree.setTreeRenderer(renderero);

            webPageRequest.putSessionValue(treeid, webTree);
        }
        if (webTree != null) {
            WebTreeModel model = webTree.getModel();
            customizeTreeNodes(model, webPageRequest);
            PageAction inAction = webPageRequest.getCurrentAction();
            removeExcludes(inAction, webTree);

            webPageRequest.putPageValue(PAGE_ATTRIBUTE_PAGE_MANAGER,
                getPageManager());
            webPageRequest.putPageValue(name, webTree);
        }
        return webTree;
    }

    private void removeExcludes(PageAction action, WebTree webTree) {

        WebTreeModel model = webTree.getModel();
        BaseTreeRenderer renderer = (BaseTreeRenderer) webTree.getTreeRenderer();
        RepositoryTreeModel repositoryModel = (RepositoryTreeModel) model;
        String ignore = action.getConfig()
            .getChildValue(CONFIG_EXCLUDES);
        if (ignore != null) {
            String[] types = ignore.split(",");
            for (String element : types) {
                String exclude = element.trim();
                repositoryModel.ignore(exclude);
                removeNodeByName((RepositoryTreeNode) model.getRoot(),
                    renderer, exclude);
            }
        }
    }

    private void removeNodeByName(RepositoryTreeNode node,
        BaseTreeRenderer renderer, String nodeName) {

        @SuppressWarnings("rawtypes")
        List children = node.getChildren();
        Object[] childNodes = children.toArray();
        for (Object element : childNodes) {
            RepositoryTreeNode childNode = (RepositoryTreeNode) element;
            if (childNode.getName()
                .equals(nodeName)) {
                deleteNode(childNode);
                continue;
            }
            removeNodeByName(childNode, renderer, nodeName);
        }
    }

    protected void customizeTreeNodes(WebTreeModel model,
        WebPageRequest webPageRequest) {

        RepositoryTreeNode rootNode = (RepositoryTreeNode) model.getRoot();
        User user = webPageRequest.getUser();
        deleteNodeIfNoPermission(GROUP_DIR_SO, user, rootNode);
        deleteNodeIfNoPermission(GROUP_DIR_MMO, user, rootNode);
        deleteNodeIfNoPermission(GROUP_DIR_SOC, user, rootNode);
        deleteNodeIfNoPermission(GROUP_DIR_SWG, user, rootNode);
        deleteNodeIfNoPermission(GROUP_DIR_FOWG, user, rootNode);
        deleteNodeIfNoPermission(GROUP_DIR_SWG, user, rootNode);
        deleteNodeIfNoPermission(GROUP_DIR_MOC, user, rootNode);
        deleteNodeIfNoPermission(GROUP_DIR_FPC, user, rootNode);
        deleteNodeIfNoPermission(GROUP_DIR_DMC, user, rootNode);
    }

    protected void deleteNodeIfNoPermission(String nodeName, User user,
        RepositoryTreeNode rootNode) {

        String permissionName = (Permissions.PERM_MR_PREFIX + nodeName).toLowerCase();
        if (!user.hasPermission(permissionName)
            && !user.hasPermission(Permissions.ADMINISTRATION)) {
            deleteNode(rootNode.getChild(nodeName));
        }
    }

    protected void deleteNode(RepositoryTreeNode node) {
        if (node != null) {
            DefaultWebTreeNode parent = node.getParent();
            @SuppressWarnings("rawtypes")
            List nodes = parent.getChildren();
            nodes.remove(node);
            node.setParent(null);
        }
    }

    protected String getRealPath(RepositoryTreeNode node) {
        return contextPath + SLASH + node.getURL();
    }

}
