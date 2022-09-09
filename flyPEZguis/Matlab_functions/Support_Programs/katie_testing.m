clear all

man_annotate = load('Y:\Data_pez3000_analyzed\0053000001640292\0053000001640292_manualAnnotations.mat');
man_annotate = man_annotate.manualAnnotations;

assess_table = load('Y:\Data_pez3000_analyzed\0053000001640292\0053000001640292_rawDataAssessment.mat');
assess_table = assess_table.assessTable;

combo_data.data = {[assess_table,man_annotate]};
combo_data.data = cellfun(@(x) x(cellfun(@(y) strcmp(y,'Single'),x.Fly_Count),:),combo_data.data,'uniformoutput',false);
combo_data.data = cellfun(@(x) x(cellfun(@(y) strcmp(y,'Pass'),x.Raw_Data_Decision),:),combo_data.data,'uniformoutput',false);
combo_data.data = cellfun(@(x) x(cellfun(@(y) strcmp(y,'Good'),x.NIDAQ),:),combo_data.data,'uniformoutput',false);
combo_data.data = cellfun(@(x) x(cellfun(@(y) strcmp(y,'Good'),x.Fly_Detect_Accuracy),:),combo_data.data,'uniformoutput',false);
combo_data.data = cellfun(@(x) x(cellfun(@(y) strcmp(y,'Good'),x.Physical_Condition),:),combo_data.data,'uniformoutput',false);
combo_data.data = cellfun(@(x) x(cellfun(@(y) ~isnan(y),x.frame_of_take_off),:),combo_data.data,'uniformoutput',false);

all_data = combo_data.data{1};
all_diff = (cell2mat(all_data.frame_of_take_off) - cell2mat(all_data.frame_of_wing_movement))./6;
all_data = all_data(all_diff < 40,:);

all_wl = (cell2mat(all_data.frame_of_leg_push) - cell2mat(all_data.frame_of_wing_movement))./6;     %only 2 over 20 frames, all legit long wing lift          
all_ld = (cell2mat(all_data.wing_down_stroke) - cell2mat(all_data.frame_of_leg_push))./6;           %only 3 over 20 frames, possible legit, need to error check
all_dj = (cell2mat(all_data.frame_of_take_off) - cell2mat(all_data.wing_down_stroke))./6;           %only 4 over 6 ms, all legit long leg with short wing
all_diff = (cell2mat(all_data.frame_of_take_off) - cell2mat(all_data.frame_of_wing_movement))./6;

p = struct;

p.xylim = [0 0 10 6];
p.alpha = 0.05;

smooth_res = gkde2([all_wl,all_ld]);
figure
subplot(2,1,1)
contour(smooth_res.x,smooth_res.y,smooth_res.pdf,20);
subplot(2,1,2);
contour(smooth_res.x,smooth_res.y,smooth_res.cdf,20);


            leg_down_index = 0:1:10;
            wing_down_index = [0:1:10,50,100,1000];

            prob_matrix = zeros((length(wing_down_index)),(length(leg_down_index)));
            samp_wing = all_wl+all_ld;      samp_leg = all_ld+all_dj;
            for iterZ = 2:length(leg_down_index)
                for iterQ = 2:length(wing_down_index)
                    wing_logic = samp_wing >= wing_down_index(iterQ-1) &  samp_wing < wing_down_index(iterQ);
                    leg_logic  = samp_leg  >= leg_down_index(iterZ-1) &  samp_leg < leg_down_index(iterZ);
                    prob_matrix(iterQ-1,iterZ-1) = sum(wing_logic & leg_logic);
                end
            end
            
            figure
            prob_matrix = (prob_matrix ./ length(samp_wing)) .* 100;
            surf(1:1:length(leg_down_index),1:1:length(wing_down_index),prob_matrix);
            view([0 90]);
            set(gca,'Xlim',[1 length(leg_down_index)],'Ylim',[1 length(wing_down_index)],'Xtick',1:1:length(leg_down_index),'XtickLabel',leg_down_index,'Ytick',1:1:length(wing_down_index),'YtickLabel',wing_down_index);
            
%             h_col = colormap('jet');
%             h_col(1,:) = rgb('white');
%             colormap(h_col);
            
            colorbar('location','EastOutside');
            set(gca,'position',[0.1 0.1 .75 .85])

            xlabel('leg push to take off (ms)');
            ylabel('wing lift to wing downstroke (ms)');
            



figure
%rem_logic = all_wl > 4 | all_ld > 3;
rem_logic = all_wl > 4;

opts = statset('Display','final');
X = [all_wl(~rem_logic),all_ld(~rem_logic)];
[idx,ctrs] = kmeans(X,3,'Distance','cosine','Replicates',100,'Options',opts);
plot(X(idx==1,1),X(idx==1,2),'r.','MarkerSize',12)
hold on
plot(X(idx==2,1),X(idx==2,2),'b.','MarkerSize',12)
plot(X(idx==3,1),X(idx==3,2),'g.','MarkerSize',12)

plot(ctrs(:,1),ctrs(:,2),'kx',...
     'MarkerSize',12,'LineWidth',2)
plot(ctrs(:,1),ctrs(:,2),'ko',...
     'MarkerSize',12,'LineWidth',2)
legend('Cluster 1','Cluster 2','Centroids',...
       'Location','NW')
hold off

line([0 3.5],[0 2.0],'color',rgb('black'))
line([0 2.5],[0 3.0],'color',rgb('black'))


