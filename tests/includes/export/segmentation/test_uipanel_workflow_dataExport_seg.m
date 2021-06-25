function tests = test_uipanel_workflow_dataExport_seg
    tests = functiontests(localfunctions);
end

%% Overloaded test setup functions
function setup(testCase)
    % setup test dir
    testCase.TestData.origPath = pwd;
    testCase.TestData.tmpFolder = ['tmpFolder' datestr(now,30)];
    mkdir(testCase.TestData.tmpFolder)
    cd(testCase.TestData.tmpFolder)
    
    % required parameters
    handles.mainFig = figure(2);
    handles.settings.lists.files_cells = dir('*_data.mat');
    handles.uicontrols.edit.action_imageRange.String = '1:2';
    handles.settings.directory = testCase.TestData.tmpFolder;
    
    % boilerplate handles for output
    handles.uitables.files = uitable();
    handles.java.files_javaHandle = findjobj(handles.uitables.files);
    jscrollpane = javaObjectEDT(handles.java.files_javaHandle);
    viewport    = javaObjectEDT(jscrollpane.getViewport);
    jtable      = javaObjectEDT(viewport.getView);
    handles.java.files_jtable = jtable;
    
    handles.uicontrols.listbox.listbox_status = uicontrol('Style', 'text');
    
    % populate boilerplate handles
    handles.uitables.files.Data = {handles.settings.lists.files_cells.name};
    
    guidata(handles.mainFig, handles);
    
    testCase.TestData.handles = handles;
end

function teardown(testCase)
    cd(testCase.TestData.origPath)
    rmdir(testCase.TestData.tmpFolder, 's')
    
    open_figures = findall(groot,'Type','figure');
    for i = 1:numel(open_figures)
        close(open_figures(i))
    end
end

%% Custom helper function
function create_mock_files(size)
    % create mock files
    for i = str2num('1:2')
        seg_img = randi(2, size) - 1;
        objects = conncomp(seg_img);
        objects.stats = regionprops(objects);
        saveObjects(sprintf('test%d_data.mat', i), objects, 'all', 'init');
    end
end

%% Actual tests
function test_emptydir(testCase)
    handles = testCase.TestData.handles;

    test = true;
    panel = uipanel_workflow_dataExport_seg(handles, test);

    panel.Children.Children(1).Children.Callback([], [])
end

function test_simple_2D(testCase)
    imageSize = [10, 10];
    create_mock_files(imageSize)
    
    handles = testCase.TestData.handles;

    test = true;
    panel = uipanel_workflow_dataExport_seg(handles, test);

    panel.Children.Children(1).Children.Callback([], [])
end

function test_simple_3D(testCase)
    imageSize = [10, 10, 10];
    create_mock_files(imageSize)

    handles = testCase.TestData.handles;

    test = true;
    panel = uipanel_workflow_dataExport_seg(handles, test);

    panel.Children.Children(1).Children.Callback([], [])
end