function draw_huffman_code_tree(huffmanEncoderObject, huffmanOutputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function draw_huffman_code_tree(huffmanEncoderObject, huffmanOutputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function draws the huffman code binary tree so the graph can serve
% as a visual check for the correctness of the algorithm and codewords
% generated.
%
% inputs: is a structure output by huffman_matlab_controller
% huffmanOutputStruct =
%            levelStruct: [1x24 struct]
%           symbolDepths: [26x1 double]
%      binaryNodesStruct: [1x25 struct]
%              sortOrder: [26x1 double]
%     huffmanCodeStrings: {26x1 cell}
%
% output: is a plot saved to the local directory as a jpg file.
%
% WARNING: It is not advisable to use this function to plot a huffman tree
% when the number of symbols/codewords > a few 10's. The plot becomes very
% crowded - unless you plan to print the jpg on a poster :))
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% 
% NASA acknowledges the SETI Institute's primary role in authoring and
% producing the Kepler Data Processing Pipeline under Cooperative
% Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
% NNX11AI14A, NNX13AD01A & NNX13AD16A.
% 
% This file is available under the terms of the NASA Open Source Agreement
% (NOSA). You should have received a copy of this agreement with the
% Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
% 
% No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
% WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
% INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
% WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
% INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
% FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
% TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
% CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
% OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
% OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
% FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
% REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
% AND DISTRIBUTES IT "AS IS."
% 
% Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
% AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
% SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
% THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
% EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
% PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
% SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
% STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
% PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
% REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
% TERMINATION OF THIS AGREEMENT.
%

% compute the coordinates of leaves and nodes
sortOrder = huffmanOutputStruct.sortOrder;
symbolFrequency = huffmanEncoderObject.histogram(sortOrder);
binaryNodesStruct = huffmanOutputStruct.binaryNodesStruct;
huffmanCodeStrings = huffmanOutputStruct.huffmanCodeStrings(sortOrder);

maxLeftChildDepth = max(cat(1,binaryNodesStruct.leftChildDepth));
maxRightChildDepth = max(cat(1,binaryNodesStruct.rightChildDepth));
maxDepth = max(maxLeftChildDepth, maxRightChildDepth);

if(length(symbolFrequency) > 2^8)

%     warning('GAR:drawHuffmanCodeTree:TooManySymbols',...
%         'GAR:drawHuffmanCodeTree:TooManySymbols: no huffman tree plot as leaves become too crowded :))');
    fprintf('\nNot plotting the huffman tree as there are too many symbols/leaves and the plot becomes too crowded :))\n');
    return;
    
end;


figure;

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition',[0 0 11 8.5 ]);

% create a grid for a full binary tree with leaves = 2^maxDepth


xmin = -1;
xmax = (2^maxDepth)+5;

ymin = -1;
ymax = maxDepth+1;
xlim([xmin xmax]);
ylim([ymin ymax]);


for j = maxDepth:-1:0

    if(j==maxDepth)
        xCoordinates = (1:2^j)';
    else
        xCoordinates = mean(reshape(xCoordinates,2,[]))';
    end
    yCoordinates   = j*ones(length(xCoordinates),1);
    plot(xCoordinates,yCoordinates, 'g.', 'Color', [.8 .8 .8]);
    xlim([xmin xmax]);
    ylim([ymin ymax]);

    set(gca,'YDir','reverse');
    hold on;

end;


nSymbols = length(huffmanCodeStrings);

for j=1:nSymbols

    symbolString = char(huffmanCodeStrings(j));
    nLengthOfSymbolString = length(symbolString);



    parentNodeXCoordinate = ((2^maxDepth)/2)+0.5;
    parentNodeYCoordinate = 0;

    nodeXCoordinates = zeros(nLengthOfSymbolString,2);
    nodeYCoordinates = zeros(nLengthOfSymbolString,2);

    for k = 1:nLengthOfSymbolString

        if(str2double(symbolString(k)) == 1) %  right node
            childNodeXCoordinate = parentNodeXCoordinate + 2^(maxDepth-1-k);
            childNodeYCoordinate = parentNodeYCoordinate + 1;
        else % left node
            childNodeXCoordinate = parentNodeXCoordinate - 2^(maxDepth-1-k);
            childNodeYCoordinate = parentNodeYCoordinate + 1;
        end;

        xdata = [parentNodeXCoordinate childNodeXCoordinate];
        ydata = [parentNodeYCoordinate childNodeYCoordinate];
        line('Xdata', xdata, 'Ydata', ydata,'Color','b','LineWidth',2)
        hold on;
        parentNodeXCoordinate = childNodeXCoordinate;
        parentNodeYCoordinate = childNodeYCoordinate;

        % save the coordinates
        nodeXCoordinates(k,:) = xdata;
        nodeYCoordinates(k,:) = ydata;

        plot([xdata(1) xdata(1)], [ydata(1) ydata(1)], 'rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',5);
        plot([xdata(2) xdata(2)], [ydata(2) ydata(2)], 'rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',5);

    end;



    for k = nLengthOfSymbolString:-1:1

        xdata = nodeXCoordinates(k,:);
        ydata = nodeYCoordinates(k,:);
        if( k == nLengthOfSymbolString)
            plot([xdata(2) xdata(2)], [ydata(2) ydata(2)], 'bo','LineWidth',2,'MarkerEdgeColor','b','MarkerFaceColor','m','MarkerSize',7);
            % get the symbol number
            % find out whether the symbol is a left or right child
            if(str2double(symbolString(k))  == 0)
                m = find(cat(1, binaryNodesStruct.leftChildSymbolNumber) == j);
            else
                m = find(cat(1, binaryNodesStruct.rightChildSymbolNumber) == j);
            end

            %           text(xdata(2)-0.1,ydata(2)+.1,[num2str(j) ' /' num2str(round(symbolFrequency(j))) ]  ,'HorizontalAlignment','left','FontSize',6);


            probStr = sprintf('%4.3f', symbolFrequency(j)/sum(symbolFrequency));

            text(xdata(2)-0.1,ydata(2)+.1,[num2str(j) ' /' probStr ]  ,'HorizontalAlignment','left','FontSize',8);

            plot([xdata(1) xdata(1)], [ydata(1) ydata(1)], 'rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',5);
            text(xdata(1),ydata(1), ['\leftarrow' num2str(m)],'HorizontalAlignment','left', 'FontSize',8);

            % display symbolString

            if(str2double(symbolString(k))  == 0)
                text(mean(xdata)-.2, mean(ydata)+.2, symbolString(k),'HorizontalAlignment','center','BackgroundColor',[.7 .9 .7], 'FontSize',8);
            else
                text(mean(xdata)+.2, mean(ydata)+.2, symbolString(k),'HorizontalAlignment','center','BackgroundColor',[.7 .9 .7], 'FontSize',8);
            end
            parentNodeNumber = m;
        else
            % mark the nodes with square marker

            plot([xdata(2) xdata(2)], [ydata(2) ydata(2)], 'rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',5);
            text(xdata(2),ydata(2), ['\leftarrow'  num2str(parentNodeNumber)],'HorizontalAlignment','left','FontSize',8);

            parentNodeNumber = binaryNodesStruct(parentNodeNumber).parentNodeNumber;
            plot([xdata(1) xdata(1)], [ydata(1) ydata(1)], 'rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',5);
            text(xdata(1),ydata(1), ['\leftarrow' num2str(parentNodeNumber)],'HorizontalAlignment','left','FontSize',8);

            % display symbolString
            if(str2double(symbolString(k))  == 0)
                text(mean(xdata)-.3, mean(ydata), symbolString(k),'HorizontalAlignment','center','BackgroundColor',[.7 .9 .7], 'FontSize',8);
            else
                text(mean(xdata)+.3, mean(ydata), symbolString(k),'HorizontalAlignment','center','BackgroundColor',[.7 .9 .7], 'FontSize',8);
            end
        end;
    end;

end;

fileNameStr = 'HuffmanCodeTree';
paperOrientationFlag = true; % landscape mode
plot_to_file(fileNameStr, paperOrientationFlag);


return;
