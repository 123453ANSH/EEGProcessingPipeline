%FILENAME ='C:\Users\Ansh Verma\Documents\UCSF General\Toyota_whole_EEG\FinalEEGFileUI.txt' %specify your path - ansh's asus laptop - windows
FILENAME = '/Users/ajsimon/Desktop/AnshMatlabEEGdata/Toyota_whole_EEG/FinalEEGFileUI.txt' %specify your path - aj's mac - os
%Macintosh HD? ? ?Users? ? ?ajsimon? ? ?Documents? ? ?Repositories? ? ?NS_EEG_preprocessing_MATLAB?


DELIMITER = '\t';  %tab delimited if it's a txt file

formatSpec = '%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%s%s%[^\n\r]'; 

%for each line, put the type as indicated, last statement unique to file conversion
%row 25 - string bc NaN - but actually a number - so number is in string? 
%no idea what the above thing is..%[^\n\r]..find out! 


startRow = 1;
fileID = fopen(FILENAME,'r');  %read in .txt file

textscan(fileID, '%[^\n\r]',startRow,'ReturnOnError',false);
dataArray = textscan(fileID, formatSpec,'Delimiter',DELIMITER,'EmptyValue',NaN,'ReturnOnError',false);

fclose(fileID);


%transposing EEG data rows to EEGdata var
EEGdata = transpose(dataArray{1,4}); 
for i=5:23
    EEGdata = [EEGdata;transpose(dataArray{1,i})];
end 

%converting to milliseconds 
TimeStamp_vals = transpose(dataArray{1,2});
TimeStampLength = length(TimeStamp_vals);
for i=1:TimeStampLength
    TimeStamp_vals(i) = ((TimeStamp_vals(i))/1000);
end  

%
b = dataArray{1,25};
MarkerText1 = [];
Latency =[]; 
Duration = [];
d = length(b); 
g = b{1};  
for i=1:d
   bo =strcmp(b{i},g); 
    if bo == false
        %b{i};
        
        MarkerText1 =[MarkerText1;b(i)]; 
        Latency = [Latency;TimeStamp_vals(1,i)];
        Duration = [Duration;.001];
    end 
end
MarkerText = struct('type',MarkerText1,'latency',1,'duration',1); 
for i=1:length(MarkerText1)
   
    MarkerText(i).latency = Latency(i); 
    MarkerText(i).duration =  Duration(i);
end

%MarkerText.type = [MarkerText.type;MarkerText1(i))];

%scalar structure, indicate index, then pick row/field


%MarkerText.type = transpose(MarkerText.type);
%MarkerText.latency = transpose(MarkerText.latency);
%MarkerText.duration = transpose(MarkerText.duration);
%MarkerText.latency = Latency; 
%'latency',Latency,'duration', Duration ); 


LiveMarker = transpose(dataArray{1,24});
LiveMarkerIndex = [];
LiveMarkerLen = length(LiveMarker); 
reference = LiveMarker{1}; 
for i=1:LiveMarkerLen
   check =strcmp(LiveMarker{i},reference);
   if check == false
        LiveMarkerIndex = [LiveMarkerIndex;i]; 
        %provides index values where Markertext/LiveMarker have values
    end 
end

eeglab 

EEG = pop_loadset('template.set'); %add path so don't need to manually add to matlab path

tempmatrix = EEG.chanlocs; 
locs = ["CP5","Oz", "CP1", "F3", "CP2", "F4", "CP6", "AFz", "FC6", "F8", "P4", "C4", "Fp2", "C2", "P3", "FC5", "F7", "C3", "FC1", "Fp1"];
EEG.chanlocs = [];
%disp(length(locs))
%disp(size(locs))
for i=1:length(locs)
    %disp(locs(i)); 
   for g=1:length(tempmatrix) %takes longer matrix demension, which we want (vertical)
      %disp('yay')
     % disp(tempmatrix(g))
     check =strcmp(locs(i), tempmatrix(g).labels ); 
     if check
        % disp('yay')
         EEG.chanlocs = [EEG.chanlocs;tempmatrix(g)]; 
     end
   end
end
EEG.chanlocs = transpose(EEG.chanlocs);
EEG.times = [] ;
EEG.times = TimeStamp_vals;
EEG.data = [];
EEG.data = EEGdata;
EEG.event = []  ;
EEG.event = MarkerText; %three different "spreadsheets" instead of 1, but backend should be same?
[colnum,rownum] = size(EEGdata); 
EEG.nbchan = colnum; 
EEG.pnts = rownum; 
EEG.srate = EEG.pnts/(TimeStamp_vals(1,rownum)); 
EEG.xmax = TimeStamp_vals(1,rownum); 

EEG.icaact = [];
EEG.icawinv = [] ;
EEG.icasphere = [] ;
EEG.icaweights = [];
EEG.icachansind = [] ;

%() not suppose to give val, just cell, but did give val in this case 
% maybe {} not supported bc its a "double" not a "matrix" - but cant matrix
% be of any type??? double,etc?
%can srate be a double 


pop_saveset(EEG,'/Users/ajsimon/Desktop/AnshMatlabEEGdata/ToyotaEEGData' );
disp('done');



% gives error number of collumns cannot be divided? -- smth to do with 20
 % collumns instead of 64 maybe 
 
%  EEG = pop_loadset('ToyotaEEGdata.set'); %showing some errors, but still loaded?
  % template = pop_loadset('templateorig.set');



%LiveMarker = transpose(dataArray{1,24});
%MarkerText = transpose(dataArray{1,25}); 
%using MarkerText as this has numbers 
%making struct as it is like this in template file
%MarkerText = struct('MarkerIndicator', MarkerText); 
%every nonvalue cell has [] in it....ok?


