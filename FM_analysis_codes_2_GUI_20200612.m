%% MATLAB code #2 (MATLAB-based graphical application)

% This graphical application was made by Matlab app designer.
% First, open Source Image ('ZO-1.tif')
% Second, open Border Image ('modified_3.tif')
% All cell candidates are labeled by a green mask initially. Click on the erroneously segmented cells and it will turn into a red mask.
% Select Output Path and Output file name, and click the Save button.
% The selected image will be saved.

classdef RPESelection_v2 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        LeftPanel                     matlab.ui.container.Panel
        SourceImageEditFieldLabel     matlab.ui.control.Label
        SourceImageEditField          matlab.ui.control.EditField
        SelectButton1                 matlab.ui.control.Button
        OpenButton1                   matlab.ui.control.Button
        BorderImageLabel              matlab.ui.control.Label
        BorderImageEditField          matlab.ui.control.EditField
        SelectButton2                 matlab.ui.control.Button
        OpenButton2                   matlab.ui.control.Button
        OutputPathLabel               matlab.ui.control.Label
        OutputPathEditField           matlab.ui.control.EditField
        SelectButton3                 matlab.ui.control.Button
        ShowMaskSwitchLabel           matlab.ui.control.Label
        ShowMaskSwitch                matlab.ui.control.Switch
        AutoRemoveSwitchLabel         matlab.ui.control.Label
        AutoRemoveSwitch              matlab.ui.control.Switch
        CenterPanel                   matlab.ui.container.Panel
        UIAxes                        matlab.ui.control.UIAxes
        RightPanel                    matlab.ui.container.Panel
        UpperBoundEditFieldLabel      matlab.ui.control.Label
        UpperBoundEditField           matlab.ui.control.NumericEditField
        LowerBoundEditFieldLabel      matlab.ui.control.Label
        LowerBoundEditField           matlab.ui.control.NumericEditField
        UpdateButton                  matlab.ui.control.Button
        OutputFileNameEditFieldLabel  matlab.ui.control.Label
        OutputFileNameEditField       matlab.ui.control.EditField
        SaveAsButtonGroup             matlab.ui.container.ButtonGroup
        BorderButton                  matlab.ui.control.RadioButton
        CellRegionButton              matlab.ui.control.RadioButton
        SaveButton                    matlab.ui.control.Button
        RedButton                     matlab.ui.control.StateButton
        GreenButton                   matlab.ui.control.StateButton
        ChangeMaskLabel               matlab.ui.control.Label
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
        twoPanelWidth = 768;
    end

    
    properties (Access = private)
        SourceImage
        GrayImage
        BorderImage
        PixelIdxList
        LabelMap
        RegionNum
        RegionArea
        SelectFlag
        BoundaryIdx
        ToolBar
        UpperBound
        LowerBound
        MouseClicked
        ClickedPosition
        SettingState
    end
    
    methods (Access = private)
        
        function ResetBorderInfo(app)
            app.BorderImage = [];
            app.PixelIdxList = [];
            app.LabelMap = [];
            app.RegionNum = [];
            app.RegionArea = [];
            app.SelectFlag = [];
            app.BoundaryIdx = [];
        end
        
        function idxSet = FindBoundaryIdx(app)
            [~, i] = max(app.RegionArea);
            bgIdx = app.PixelIdxList{i};
            bg = zeros(size(app.BorderImage), 'logical');
            bg(bgIdx) = 1;
            se = strel('diamond', 2);
            boundary = imdilate(bg, se);
            boundary = boundary & ~bg;
            boundaryIdx = find(boundary);
            IsMember = @(x) ~isempty(find(ismember(x, boundaryIdx), 1));
            Flags = cellfun(IsMember, app.PixelIdxList);
            idxSet = find(Flags);
            idxSet = [idxSet i];
        end
        
        function ResetUIAxes(app)
            delete(app.UIAxes);
            app.UIAxes = uiaxes(app.CenterPanel);
            title(app.UIAxes, '');
            xlabel(app.UIAxes, '');
            ylabel(app.UIAxes, '');
            app.UIAxes.Visible = 'off';
            app.UIAxes.Position = [5 5 451 481];
            app.ToolBar = axtoolbar(app.UIAxes, {'pan', 'zoomin', 'zoomout', 'restoreview'});
        end
        
        function RefreshPlot(app)
            if isempty(app.SourceImage)
                ResetUIAxes(app);
                return;
            end
            
            if isempty(app.BorderImage) || ~app.ShowMaskSwitch.Value
                imshow(app.GrayImage, 'Parent', app.UIAxes);
            else
                greeMask = app.SelectFlag;
                redMask = app.LabelMap ~= 0 & ~app.SelectFlag;
                im = app.GrayImage;
                im = labeloverlay(im, greeMask, 'Colormap', [0 1 0], 'Transparency', 0.8);
                im = labeloverlay(im, redMask, 'Colormap', [1 0 0], 'Transparency', 0.8);
                imshow(im, 'Parent', app.UIAxes);
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.SourceImage = [];
            app.GrayImage = [];
            app.UpperBound = app.UpperBoundEditField.Value;
            app.LowerBound = app.LowerBoundEditField.Value;
            app.MouseClicked = 0;
            app.ClickedPosition = [];
            app.SettingState = -1;
            ResetBorderInfo(app);
            
            set(app.ShowMaskSwitch, 'ItemsData', [0 1]);
            set(app.AutoRemoveSwitch, 'ItemsData', [0 1]);
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 3x1 grid
                app.GridLayout.RowHeight = {491, 491, 491};
                app.GridLayout.ColumnWidth = {'1x'};
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = 1;
                app.LeftPanel.Layout.Row = 2;
                app.LeftPanel.Layout.Column = 1;
                app.RightPanel.Layout.Row = 3;
                app.RightPanel.Layout.Column = 1;
            elseif (currentFigureWidth > app.onePanelWidth && currentFigureWidth <= app.twoPanelWidth)
                % Change to a 2x2 grid
                app.GridLayout.RowHeight = {491, 491};
                app.GridLayout.ColumnWidth = {'1x', '1x'};
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = [1,2];
                app.LeftPanel.Layout.Row = 2;
                app.LeftPanel.Layout.Column = 1;
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 2;
            else
                % Change to a 1x3 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {220, '1x', 246};
                app.LeftPanel.Layout.Row = 1;
                app.LeftPanel.Layout.Column = 1;
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = 2;
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 3;
            end
        end

        % Button pushed function: SelectButton1
        function SelectButton1Pushed(app, event)
            [file, path] = uigetfile('*.*');
            if ~isequal(file, 0)
                app.SourceImageEditField.Value = fullfile(path, file);
            end
            figure(app.UIFigure);
        end

        % Button pushed function: OpenButton1
        function OpenButton1Pushed(app, event)
            ResetUIAxes(app);
            
            try
                app.SourceImage = imread(app.SourceImageEditField.Value);
            catch
                app.SourceImage = [];
                app.GrayImage = [];
                RefreshPlot(app);
                uialert(app.UIFigure, 'Cannot open image!', 'Error');
                return;
            end
            
            if ndims(app.SourceImage) == 3
                app.GrayImage = repmat(app.SourceImage(:, :, 2), [1 1 3]);
            elseif ndims(app.SourceImage) == 2
                app.GrayImage = repmat(app.SourceImage, [1 1 3]);
            else
                app.SourceImage = [];
                app.GrayImage = [];
                uialert(app.UIFigure, 'Incorrect image format!', 'Error');
            end
            
            RefreshPlot(app);
        end

        % Button pushed function: SelectButton2
        function SelectButton2Pushed(app, event)
            [file, path] = uigetfile('*.*');
            if ~isequal(file, 0)
                app.BorderImageEditField.Value = fullfile(path, file);
            end
            figure(app.UIFigure);
        end

        % Button pushed function: OpenButton2
        function OpenButton2Pushed(app, event)
            try
                app.BorderImage = imread(app.BorderImageEditField.Value);
            catch
                ResetBorderInfo(app);
                uialert(app.UIFigure, 'Cannot open image!', 'Error');
                RefreshPlot(app);
                return;
            end
            
            if ndims(app.BorderImage) ~= 2
                ResetBorderInfo(app);
                uialert(app.UIFigure, 'Border should be binary!', 'Error');
                RefreshPlot(app);
                return;
            end
            
            if ~islogical(app.BorderImage)
%                 thresh = graythresh(app.BorderImage);
%                 app.BorderImage = im2bw(app.BorderImage, thresh);
                app.BorderImage = imbinarize(int8(app.BorderImage));
            end
            
            cc = bwconncomp(app.BorderImage, 4);
            app.PixelIdxList = cc.PixelIdxList;
            app.LabelMap = zeros(size(app.BorderImage), 'int32');
            app.RegionArea = cellfun(@numel, app.PixelIdxList);
            app.RegionNum = size(app.RegionArea, 2);
            app.SelectFlag = zeros(size(app.BorderImage), 'logical');
            app.BoundaryIdx = FindBoundaryIdx(app);
            for i = 1:app.RegionNum
                app.LabelMap(app.PixelIdxList{i}) = i;
                if app.RegionArea(i) > app.LowerBound && app.RegionArea(i) < app.UpperBound && ...
                        ~ismember(i, app.BoundaryIdx)
                    app.SelectFlag(app.PixelIdxList{i}) = 1;
                end
            end
            
            RefreshPlot(app);
        end

        % Button pushed function: SelectButton3
        function SelectButton3Pushed(app, event)
            dir = uigetdir;
            if ~isequal(dir, 0)
                app.OutputPathEditField.Value = dir;
            end
            figure(app.UIFigure);
        end

        % Value changed function: ShowMaskSwitch
        function ShowMaskSwitchValueChanged(app, event)
            RefreshPlot(app);
        end

        % Value changed function: AutoRemoveSwitch
        function AutoRemoveSwitchValueChanged(app, event)
            if ~isempty(app.BorderImage)
                if app.AutoRemoveSwitch.Value
                    app.BoundaryIdx = FindBoundaryIdx(app);
                else
                    app.BoundaryIdx = [];
                end
                RefreshPlot(app);
            end
        end

        % Window button down function: UIFigure
        function UIFigureWindowButtonDown(app, event)
            if ~isempty(app.BorderImage) && app.ShowMaskSwitch.Value && app.SettingState > -1
                coord = get(app.UIAxes, 'CurrentPoint');
                row = int32(coord(1, 2));
                col = int32(coord(1, 1));
                OnAxes =  row < size(app.BorderImage, 1) && col < size(app.BorderImage, 2) && ...
                    col > app.UIAxes.XLim(1) && col < app.UIAxes.XLim(2) && ...
                    row > app.UIAxes.YLim(1) && row < app.UIAxes.YLim(2);
                if OnAxes && ~app.MouseClicked
                    app.MouseClicked = 1;
                    app.ClickedPosition = [row col];
                end
            else
                app.MouseClicked = 0;
                app.ClickedPosition = [];
            end
        end

        % Window button up function: UIFigure
        function UIFigureWindowButtonUp(app, event)
            if ~isempty(app.BorderImage) && app.ShowMaskSwitch.Value && app.SettingState > -1
                coord = get(app.UIAxes, 'CurrentPoint');
                row = int32(coord(1, 2));
                col = int32(coord(1, 1));
                OnAxes =  row < size(app.BorderImage, 1) && col < size(app.BorderImage, 2) && ...
                    col > app.UIAxes.XLim(1) && col < app.UIAxes.XLim(2) && ...
                    row > app.UIAxes.YLim(1) && row < app.UIAxes.YLim(2);
                if OnAxes && app.MouseClicked
                    row = [app.ClickedPosition(1), row];
                    col = [app.ClickedPosition(2), col];
                    row = sort(row);
                    col = sort(col);
                    roi = app.LabelMap(row(1):row(2), col(1):col(2));
                    labels = unique(nonzeros(roi));
                    for i = 1:size(labels, 1)
                        app.SelectFlag(app.PixelIdxList{labels(i)}) = app.SettingState;
                    end
                    RefreshPlot(app);
                end
            end
            
            app.MouseClicked = 0;
            app.ClickedPosition = [];
        end

        % Button pushed function: UpdateButton
        function UpdateButtonPushed(app, event)
            if ~isempty(app.BorderImage)
                app.UpperBound = app.UpperBoundEditField.Value;
                app.LowerBound = app.LowerBoundEditField.Value;
                if isempty(app.UpperBound)
                    app.UpperBound = Inf;
                end
                if isempty(app.LowerBound)
                    app.LowerBound = 0;
                end
                
                for i = 1:app.RegionNum
                    if app.RegionArea(i) > app.LowerBound && app.RegionArea(i) < app.UpperBound && ...
                            ~ismember(i, app.BoundaryIdx)
                        app.SelectFlag(app.PixelIdxList{i}) = 1;
                    else
                        app.SelectFlag(app.PixelIdxList{i}) = 0;
                    end
                end
                
                RefreshPlot(app);
            end
        end

        % Value changed function: RedButton
        function RedButtonValueChanged(app, event)
            if app.RedButton.Value == 0
                app.SettingState = -1;
            else
                app.SettingState = 0;
                app.GreenButton.Value = 0;
                btnArray = app.ToolBar.Children;
                for i = 1:size(btnArray, 1)
                    if strcmp(btnArray(i).Type, 'toolbarstatebutton')
                        if strcmp(btnArray(i).Value, 'on')
                            e = btnArray(i);
                            d = struct;
                            d.Source = e;
                            d.Axes = app.UIAxes;
                            d.EvenName = 'ValueChanged';
                            d.Value = 'off';
                            d.PreviousValue = 'on';
                            feval(btnArray(i).ValueChangedFcn,e,d);
                        end
                    end
                end
            end
        end

        % Value changed function: GreenButton
        function GreenButtonValueChanged(app, event)
            if app.GreenButton.Value == 0
                app.SettingState = -1;
            else
                app.SettingState = 1;
                app.RedButton.Value = 0;
                btnArray = app.ToolBar.Children;
                for i = 1:size(btnArray, 1)
                    if strcmp(btnArray(i).Type, 'toolbarstatebutton')
                        if strcmp(btnArray(i).Value, 'on')
                            e = btnArray(i);
                            d = struct;
                            d.Source = e;
                            d.Axes = app.UIAxes;
                            d.EvenName = 'ValueChanged';
                            d.Value = 'off';
                            d.PreviousValue = 'on';
                            feval(btnArray(i).ValueChangedFcn,e,d);
                        end
                    end
                end
            end
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
            if ~isempty(app.BorderImage)
                path = fullfile(app.OutputPathEditField.Value, app.OutputFileNameEditField.Value);
                if strcmp(app.SaveAsButtonGroup.SelectedObject.Text, 'Border')
                    se = strel('diamond', 1);
                    border = imdilate(app.SelectFlag, se);
                    border = border & ~app.SelectFlag;
                    border = 255 * uint8(border);
                    imwrite(border, path);
                elseif strcmp(app.SaveAsButtonGroup.SelectedObject.Text, 'Cell Region')
                    region = 255 * uint8(app.SelectFlag);
                    imwrite(region, path);
                end
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 927 491];
            app.UIFigure.Name = 'UI Figure';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);
            app.UIFigure.WindowButtonDownFcn = createCallbackFcn(app, @UIFigureWindowButtonDown, true);
            app.UIFigure.WindowButtonUpFcn = createCallbackFcn(app, @UIFigureWindowButtonUp, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {220, '1x', 246};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create SourceImageEditFieldLabel
            app.SourceImageEditFieldLabel = uilabel(app.LeftPanel);
            app.SourceImageEditFieldLabel.Position = [17 452 80 22];
            app.SourceImageEditFieldLabel.Text = 'Source Image';

            % Create SourceImageEditField
            app.SourceImageEditField = uieditfield(app.LeftPanel, 'text');
            app.SourceImageEditField.Position = [17 431 186 22];

            % Create SelectButton1
            app.SelectButton1 = uibutton(app.LeftPanel, 'push');
            app.SelectButton1.ButtonPushedFcn = createCallbackFcn(app, @SelectButton1Pushed, true);
            app.SelectButton1.Position = [17 396 85 22];
            app.SelectButton1.Text = 'Select';

            % Create OpenButton1
            app.OpenButton1 = uibutton(app.LeftPanel, 'push');
            app.OpenButton1.ButtonPushedFcn = createCallbackFcn(app, @OpenButton1Pushed, true);
            app.OpenButton1.Position = [118 396 85 22];
            app.OpenButton1.Text = 'Open';

            % Create BorderImageLabel
            app.BorderImageLabel = uilabel(app.LeftPanel);
            app.BorderImageLabel.Position = [17 353 78 22];
            app.BorderImageLabel.Text = 'Border Image';

            % Create BorderImageEditField
            app.BorderImageEditField = uieditfield(app.LeftPanel, 'text');
            app.BorderImageEditField.Position = [17 332 186 22];

            % Create SelectButton2
            app.SelectButton2 = uibutton(app.LeftPanel, 'push');
            app.SelectButton2.ButtonPushedFcn = createCallbackFcn(app, @SelectButton2Pushed, true);
            app.SelectButton2.Position = [17 297 85 22];
            app.SelectButton2.Text = 'Select';

            % Create OpenButton2
            app.OpenButton2 = uibutton(app.LeftPanel, 'push');
            app.OpenButton2.ButtonPushedFcn = createCallbackFcn(app, @OpenButton2Pushed, true);
            app.OpenButton2.Position = [118 297 85 22];
            app.OpenButton2.Text = 'Open';

            % Create OutputPathLabel
            app.OutputPathLabel = uilabel(app.LeftPanel);
            app.OutputPathLabel.Position = [17 254 70 22];
            app.OutputPathLabel.Text = 'Output Path';

            % Create OutputPathEditField
            app.OutputPathEditField = uieditfield(app.LeftPanel, 'text');
            app.OutputPathEditField.Position = [17 233 186 22];

            % Create SelectButton3
            app.SelectButton3 = uibutton(app.LeftPanel, 'push');
            app.SelectButton3.ButtonPushedFcn = createCallbackFcn(app, @SelectButton3Pushed, true);
            app.SelectButton3.Position = [17 198 85 22];
            app.SelectButton3.Text = 'Select';

            % Create ShowMaskSwitchLabel
            app.ShowMaskSwitchLabel = uilabel(app.LeftPanel);
            app.ShowMaskSwitchLabel.Position = [17 59 68 22];
            app.ShowMaskSwitchLabel.Text = 'Show Mask';

            % Create ShowMaskSwitch
            app.ShowMaskSwitch = uiswitch(app.LeftPanel, 'slider');
            app.ShowMaskSwitch.ValueChangedFcn = createCallbackFcn(app, @ShowMaskSwitchValueChanged, true);
            app.ShowMaskSwitch.Position = [130 60 45 20];
            app.ShowMaskSwitch.Value = 'On';

            % Create AutoRemoveSwitchLabel
            app.AutoRemoveSwitchLabel = uilabel(app.LeftPanel);
            app.AutoRemoveSwitchLabel.Position = [17 25 78 22];
            app.AutoRemoveSwitchLabel.Text = 'Auto Remove';

            % Create AutoRemoveSwitch
            app.AutoRemoveSwitch = uiswitch(app.LeftPanel, 'slider');
            app.AutoRemoveSwitch.ValueChangedFcn = createCallbackFcn(app, @AutoRemoveSwitchValueChanged, true);
            app.AutoRemoveSwitch.Position = [130 26 45 20];
            app.AutoRemoveSwitch.Value = 'On';

            % Create CenterPanel
            app.CenterPanel = uipanel(app.GridLayout);
            app.CenterPanel.Layout.Row = 1;
            app.CenterPanel.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.CenterPanel);
            title(app.UIAxes, '')
            xlabel(app.UIAxes, '')
            ylabel(app.UIAxes, '')
            app.UIAxes.Visible = 'off';
            app.UIAxes.Position = [5 5 451 481];

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 3;

            % Create UpperBoundEditFieldLabel
            app.UpperBoundEditFieldLabel = uilabel(app.RightPanel);
            app.UpperBoundEditFieldLabel.Position = [21 452 76 22];
            app.UpperBoundEditFieldLabel.Text = 'Upper Bound';

            % Create UpperBoundEditField
            app.UpperBoundEditField = uieditfield(app.RightPanel, 'numeric');
            app.UpperBoundEditField.HorizontalAlignment = 'left';
            app.UpperBoundEditField.Position = [21 431 76 22];
            app.UpperBoundEditField.Value = 1000;

            % Create LowerBoundEditFieldLabel
            app.LowerBoundEditFieldLabel = uilabel(app.RightPanel);
            app.LowerBoundEditFieldLabel.Position = [131 452 76 22];
            app.LowerBoundEditFieldLabel.Text = 'Lower Bound';

            % Create LowerBoundEditField
            app.LowerBoundEditField = uieditfield(app.RightPanel, 'numeric');
            app.LowerBoundEditField.HorizontalAlignment = 'left';
            app.LowerBoundEditField.Position = [131 431 76 22];
            app.LowerBoundEditField.Value = 10;

            % Create UpdateButton
            app.UpdateButton = uibutton(app.RightPanel, 'push');
            app.UpdateButton.ButtonPushedFcn = createCallbackFcn(app, @UpdateButtonPushed, true);
            app.UpdateButton.Position = [64 396 100 22];
            app.UpdateButton.Text = 'Update';

            % Create OutputFileNameEditFieldLabel
            app.OutputFileNameEditFieldLabel = uilabel(app.RightPanel);
            app.OutputFileNameEditFieldLabel.Position = [21 254 100 22];
            app.OutputFileNameEditFieldLabel.Text = 'Output File Name';

            % Create OutputFileNameEditField
            app.OutputFileNameEditField = uieditfield(app.RightPanel, 'text');
            app.OutputFileNameEditField.Position = [21 233 186 22];
            app.OutputFileNameEditField.Value = 'result.tif';

            % Create SaveAsButtonGroup
            app.SaveAsButtonGroup = uibuttongroup(app.RightPanel);
            app.SaveAsButtonGroup.Title = 'Save As';
            app.SaveAsButtonGroup.Position = [21 149 186 71];

            % Create BorderButton
            app.BorderButton = uiradiobutton(app.SaveAsButtonGroup);
            app.BorderButton.Text = 'Border';
            app.BorderButton.Position = [11 25 58 22];
            app.BorderButton.Value = true;

            % Create CellRegionButton
            app.CellRegionButton = uiradiobutton(app.SaveAsButtonGroup);
            app.CellRegionButton.Text = 'Cell Region';
            app.CellRegionButton.Position = [11 3 84 22];

            % Create SaveButton
            app.SaveButton = uibutton(app.RightPanel, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.Position = [21 103 100 22];
            app.SaveButton.Text = 'Save';

            % Create RedButton
            app.RedButton = uibutton(app.RightPanel, 'state');
            app.RedButton.ValueChangedFcn = createCallbackFcn(app, @RedButtonValueChanged, true);
            app.RedButton.Text = 'Red';
            app.RedButton.Position = [19 311 90 22];

            % Create GreenButton
            app.GreenButton = uibutton(app.RightPanel, 'state');
            app.GreenButton.ValueChangedFcn = createCallbackFcn(app, @GreenButtonValueChanged, true);
            app.GreenButton.Text = 'Green';
            app.GreenButton.Position = [115 311 90 22];

            % Create ChangeMaskLabel
            app.ChangeMaskLabel = uilabel(app.RightPanel);
            app.ChangeMaskLabel.Position = [19 337 80 22];
            app.ChangeMaskLabel.Text = 'Change Mask';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = RPESelection_v2

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end