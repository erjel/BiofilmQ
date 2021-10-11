% Copyright (c) 2021 Eric Jelli (GitHub: @erjel)
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%%

function tests = test_BiofilmQ
    tests = functiontests(localfunctions);
end

function setup(testCase)
    % setup test dir
    testCase.TestData.origPath = pwd;
    testCase.TestData.tmpFolder = ['tmpFolder' datestr(now,30)];
    
    mkdir(testCase.TestData.tmpFolder)
    cd(testCase.TestData.tmpFolder)
    
    imageSize = [10, 10, 2];
    create_mock_files(imageSize)
    
    % mock eventdata
    eventdata.Indices = [1];
    
    % required parameters
    handles.mainFig = figure(2);
    handles.settings.directory = pwd();
    handles.settings.lists.files_metadata = dir('*_metadata.mat');
    handles.settings.lists.files_tif = dir('*.tif');
    handles.settings.showMsgs = false;
    
    % rebuild the GUI
    handles.axes.axes_preview = axes('Parent', handles.mainFig);
    
    handles.layout.boxes.plotCellParameters_container = handles.mainFig;
    handles.layout.boxes.axes_preview_container = handles.mainFig;
    handles.layout.tabs.invisibleTab = [];
    handles.dummy.panel = uix.VBox();
    handles.dummy.panel2 = uix.HBox('Parent', handles.dummy.panel);
    
    handles.uicontrols.checkbox = struct(...
        'displayAllChannels', uicontrol('Style', 'checkbox', 'Tag',  'displayAllChannels'), ...
        'displayAlignedImage', uicontrol('Style', 'checkbox', 'Tag',  'displayAlignedImage'), ...
        'scaleUp', uicontrol('Style', 'checkbox', 'Tag',  'scaleUp'), ...
        'imageRegistration', uicontrol('Style', 'checkbox', 'Tag',  'imageRegistration'));
    
    handles.uicontrols.edit = struct( ...
        'manualThreshold', uicontrol('Style', 'edit', 'Tag',  'manualThreshold'), ...
        'cropRange',  uicontrol('Style', 'edit', 'Tag', 'cropRange'), ...
        'I_base',  uicontrol('Style', 'edit', 'Tag', 'I_base'), ...
        'minCellInt', uicontrol('Style', 'edit', 'Tag', 'minCellInt'), ...
        'flowDirection', uicontrol('Style', 'edit', 'Tag', 'flowDirection'), ...
        'scaling_dxy', uicontrol('Style', 'edit', 'Tag', 'scaling_dxy'), ...
        'trackCellsDilatePx', uicontrol('Style', 'edit', 'Tag', 'trackCellsDilatePx'), ...
        'removeVoxelsOfSize', uicontrol('Style', 'edit', 'Tag', 'removeVoxelsOfSize'), ...
        'gridSpacing', uicontrol('Style', 'edit', 'Tag', 'gridSpacing'), ...
        'topHatSize', uicontrol('Style', 'edit', 'Tag', 'topHatSize'));
    
    handles.uicontrols.popupmenu.popupmenu_fileType = uicontrol( ...
        'Style', 'popupmenu', 'Value', 2, 'Tag', 'fileType');
    
    handles.uicontrols.text = struct( ...
        'text_fileDetails', uicontrol('Style', 'text', 'Parent', handles.dummy.panel), ...
        'text_parameterUnitConversion', uicontrol('Style', 'text'));
        
 
    handles.uitables.files = uitable();
    if usejava('awt')
        handles.java.files_javaHandle = findjobj(handles.uitables.files);
        jscrollpane = javaObjectEDT(handles.java.files_javaHandle);
        viewport    = javaObjectEDT(jscrollpane.getViewport);
        jtable      = javaObjectEDT(viewport.getView);
        handles.java.files_jtable = jtable;
    end
    
    handles.uitables.files.Data = {handles.settings.lists.files_tif.name};
    handles.tableData = [];
    
    guidata(handles.mainFig, handles);
    
    testCase.TestData.handles = handles;
    testCase.TestData.eventdata = eventdata;
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
        img = randi(2, size) - 1;
        metadata = struct([]);
        save(sprintf('test%d_metadata.mat', i), 'metadata');
        verbose = false;
        imwrite3D(img, sprintf('test%d.tif', i), 'uint8', verbose);
    end
end

%% Actual tests
%%files_Callback
function test__BiofilmQ__files_Callback__avail(testCase)
    handles = testCase.TestData.handles;
    eventdata = testCase.TestData.eventdata;
    
    BiofilmQ('files_Callback',handles.mainFig, eventdata, guidata(handles.mainFig));
end

function test__BiofilmQ__files_Callback__preview_avail(testCase)
    handles = testCase.TestData.handles;
    eventdata = testCase.TestData.eventdata;

    BiofilmQ('files_Callback',handles.mainFig, eventdata, guidata(handles.mainFig));
    
    verifyNotEmpty(testCase, handles.axes.axes_preview.Children)
end    

%%pushbutton_pre_selectCropRegion_Callback
function test__BiofilmQ__pushbutton_pre_selectCropRegion_Callback__missing_file_index(testCase)
    imageSize = [10, 10, 2];
    create_mock_files(imageSize)

    % required parameters
    handles.mainFig = figure(2);
    handles.settings.directory = pwd();
    handles.settings.selectedFile = 2;
    handles.settings.lists.files_tif = dir('*.tif');
    handles.settings.metadataGlobal = {};
    handles.settings.showMsgs = false;
    
    
    handles.uitables.files = uitable();
    if usejava('awt')
        handles.java.files_javaHandle = findjobj(handles.uitables.files);
        jscrollpane = javaObjectEDT(handles.java.files_javaHandle);
        viewport    = javaObjectEDT(jscrollpane.getViewport);
        jtable      = javaObjectEDT(viewport.getView);
        handles.java.files_jtable = jtable;
    end
    
    % rebuild the GUI
    handles.uicontrols.checkbox = struct( ...
        'fixedOutputSize', uicontrol( ...
            'Style', 'checkbox', 'Tag',  'fixedOutputSize'), ...
        'cropRangeInterpolated', uicontrol( ...
            'Style', 'checkbox', 'Tag',  'cropRangeInterpolated'), ...
        'imageRegistration', uicontrol( ...
            'Style', 'checkbox', 'Tag',  'imageRegistration') ...
    );

    handles.uicontrols.edit = struct( ...
        'cropRange', uicontrol( ...
            'Style', 'edit', 'Tag',  'cropRange'), ...
        'registrationReferenceCropping',  uicontrol( ...
            'Style', 'edit', 'Tag', 'registrationReferenceCropping') ...
    );

    verifyError( ...
        testCase, ...
        @() BiofilmQ('pushbutton_pre_selectCropRegion_Callback',handles.mainFig, [], guidata(handles.mainFig)), ...
        'pushbutton_pre_selectCropRegion_Callback:undefinedInput');

end

function test__BiofilmQ__pushbutton_pre_selectCropRegion_Callback__avail(testCase)   
    imageSize = [10, 10, 2];
    create_mock_files(imageSize)

    % required parameters
    handles.mainFig = figure(2);
    handles.settings.directory = pwd();
    handles.settings.selectedFile = 2;
    handles.settings.lists.files_tif = dir('*.tif');
    handles.settings.lists.files_metadata = dir('*_metadata.mat');
    handles.settings.metadataGlobal = {};
    handles.settings.showMsgs = false;
    
    
    handles.uitables.files = uitable('Data', magic(4)); % need to fill it with fake data
    if usejava('awt')
        handles.java.files_javaHandle = findjobj(handles.uitables.files);
        jscrollpane = javaObjectEDT(handles.java.files_javaHandle);
        viewport    = javaObjectEDT(jscrollpane.getViewport);
        jtable      = javaObjectEDT(viewport.getView);
        handles.java.files_jtable = jtable;
        handles.java.files_jtable.changeSelection(handles.settings.selectedFile - 1,0,0,0);
    end
    
    disp(handles.java.files_jtable.getSelectedRow()+1)
    
    % rebuild the GUI
    handles.uicontrols.checkbox = struct( ...
        'fixedOutputSize', uicontrol( ...
            'Style', 'checkbox', 'Tag',  'fixedOutputSize'), ...
        'cropRangeInterpolated', uicontrol( ...
            'Style', 'checkbox', 'Tag',  'cropRangeInterpolated'), ...
        'imageRegistration', uicontrol( ...
            'Style', 'checkbox', 'Tag',  'imageRegistration') ...
    );

    handles.uicontrols.edit = struct( ...
        'cropRange', uicontrol( ...
            'Style', 'edit', 'Tag',  'cropRange'), ...
        'registrationReferenceCropping',  uicontrol( ...
            'Style', 'edit', 'Tag', 'registrationReferenceCropping') ...
    );

    guidata(handles.mainFig, handles);
    
    BiofilmQ('pushbutton_pre_selectCropRegion_Callback',handles.mainFig, [], guidata(handles.mainFig));
    
end
