clear all; close all; clc;
% ImgDir='image/'; % directory to test images, this variable will be provided  to your car detection program 
ResDir='detections_val/detections/';  % result directory, where your write out your detection results
AnnDir='detections_val/label/'; % annotation directory, used to check the detection results
%%
min_score=0; % minimum score from detection process, set by yourself
max_score=1; % maximum score from detection process, set by yourself
%% draw PR curve
ov_detected=0.5;
Results=dir(fullfile(ResDir,'*.txt'));
num=1;
for threshold=max_score:-0.01:min_score
num_TrueDetection=0;    
num_detected=0;
num_Recall=0;
num_dcrecall=0;
num_GroundTruth=0;    
for i=1:length(Results)
    % load detection results & scores
     fid=fopen(strcat(ResDir,Results(i).name));
     line=fgetl(fid);
     k=1;
     boxes=[];
     while ~(line==-1)
         ss=regexp(line,' ','split');
         if strcmp(ss{1},'Car')%考虑类别
             class(k)=1;
         boxes(k,1)=str2num(ss{2});
         boxes(k,2)=str2num(ss{3});
         boxes(k,3)=str2num(ss{4});
         boxes(k,4)=str2num(ss{5});
         scores(k)=str2num(ss{6});
         k=k+1;
         end
         line=fgetl(fid);
         
     end
     fclose(fid);
     [num_boxes,~]=size(boxes);

   % load ground truths  
     fid=fopen(strcat(AnnDir,Results(i).name));
       line=fgetl(fid);
       flag1=0;
       flag2=0;
       bbgt_DontCare=[];
       bbgt_car=[];
       while ~(line==-1)
         ss=regexp(line,' ','split');
         if strcmp(ss{1},'DontCare')
             xmin=str2num(ss{2});
             ymin=str2num(ss{3});
             xmax=str2num(ss{4});
             ymax=str2num(ss{5});
             if flag1==0
             bbgt_DontCare=[xmin,ymin,xmax,ymax];
             flag1=1;
             else
             bbgt_DontCare=[bbgt_DontCare;[xmin,ymin,xmax,ymax]];
             end
         else
             xmin=str2num(ss{2});
             ymin=str2num(ss{3});
             xmax=str2num(ss{4});
             ymax=str2num(ss{5});
             if strcmp(ss{1},'Car')
                    bbgt_class=1;
                if flag2==0
                    bbgt_car=[xmin,ymin,xmax,ymax];
                    flag2=1;
                else
                bbgt_car=[bbgt_car;[xmin,ymin,xmax,ymax]];
                end
             end             
         end
         line=fgetl(fid);
       end
     fclose(fid);
     [num_gt,~]=size(bbgt_car);
     [num_dc,~]=size(bbgt_DontCare);
     num_GroundTruth=num_GroundTruth+num_gt;
     
     % sort out detections of DontCare
     k=1;
     k_dc=1;
     temp_boxes=[];
     temp_scores=[];
     temp_class=[];
     temp_dcbox=[];
     temp_dcscores=[];
     flag_dcrecall=zeros(num_dc,1);
     for x=1:num_boxes
         bb=boxes(x,1:4);
         ov_max=0;
        for j=1:num_dc
        bbgt=bbgt_DontCare(j,1:4);   
        bi=[max(bb(1),bbgt(1))  max(bb(2),bbgt(2))  min(bb(3),bbgt(3))  min(bb(4),bbgt(4))];
        iw=bi(3)-bi(1)+1;
        ih=bi(4)-bi(2)+1;
        if iw>0 & ih>0
            % compute overlap as area of intersection / area of union
            ua=(bb(3)-bb(1)+1)*(bb(4)-bb(2)+1)+...
               (bbgt(3)-bbgt(1)+1)*(bbgt(4)-bbgt(2)+1)-...
               iw*ih;
            current_ov=iw*ih/ua;
            if current_ov>ov_detected
                flag_dcrecall(j)=1; 
            end
            ov_max=max(ov_max,current_ov);
        end         
        end
           if ov_max<ov_detected
               temp_boxes(k,1:4)=bb;
               temp_scores(k)=scores(x);
               temp_class(k)=class(k);%考虑类别
               k=k+1;
           else
               temp_dcbox(k_dc,1:4)=bb;
               temp_dcscores(k_dc)=scores(x);
               k_dc=k_dc+1;
           end
     end
     boxes=temp_boxes;
     scores=temp_scores;
     class=temp_class;
     dcbox=temp_dcbox;
     dcscores=temp_dcscores;
     clear temp_boxes temp_scores temp_class
     clear temp_dcbox temp_dcsocres

     
     % calculate detection PR
     num_detected=num_detected+sum(scores>threshold)+sum(dcscores>threshold);
     [num_boxes,~]=size(boxes);
     flag_recall=zeros(num_gt,1);
     for k=1:num_boxes
         if scores(k)>threshold
         bb=boxes(k,1:4);
         ov_max=0;
        for j=1:num_gt
        bbgt=bbgt_car(j,1:4);   
        bi=[max(bb(1),bbgt(1))  max(bb(2),bbgt(2))  min(bb(3),bbgt(3))  min(bb(4),bbgt(4))];
        iw=bi(3)-bi(1)+1;
        ih=bi(4)-bi(2)+1;
         if iw>0 & ih>0
            % compute overlap as area of intersection / area of union
            ua=(bb(3)-bb(1)+1)*(bb(4)-bb(2)+1)+...
               (bbgt(3)-bbgt(1)+1)*(bbgt(4)-bbgt(2)+1)-...
               iw*ih;
            current_ov=iw*ih/ua;
            if current_ov>ov_detected
                flag_recall(j)=1; 
            end
            ov_max=max(ov_max,current_ov);
         end     
        end
          if ov_max>ov_detected
              num_TrueDetection=num_TrueDetection+1;
          end
        end
     end
     
     num_TrueDetection=num_TrueDetection+sum(dcscores>threshold);
     num_Recall=num_Recall+sum(flag_recall>0);
     num_dcrecall=num_dcrecall+sum(flag_dcrecall>0);
     clear boxes scores;
     clear dcboxes dcscores
end
  if num_detected>0
     precision(num)=num_TrueDetection/num_detected;
     recall(num)=(num_Recall+num_dcrecall)/(num_GroundTruth+num_dcrecall);
     num=num+1;
  end
   
  clear boxes scores;
end

figure, title('Precision Recall Curve'),
plot(recall,precision),xlim([0,1]),ylim([0,1]),ylabel('precision'),xlabel('recall');

%% Area under PR 
area=0;
for i=1:length(recall)
    if i==1
        area=(1+precision(1))*recall(1)/2;
    else
    area=area+(precision(i-1)+precision(i))*(recall(i)-recall(i-1))/2;
    end
end
disp(strcat('Area under PR curve = ',num2str(area)));