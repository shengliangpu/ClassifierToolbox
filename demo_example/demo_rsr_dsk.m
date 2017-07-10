% demo.m 

close all;
clear;
clc;


%% load data
if 0
    load('../dataset/ORL_Face_img_cov.mat');

    train_num = length(TrainSet.y);
    test_num = length(TestSet.y);
    
    class_num = length(unique(TestSet.y));

    dim = size(TrainSet.GRCM2{1,1},1);
    TrainSet.X_cov = zeros(dim, dim, train_num);
    for i = 1 : train_num
        TrainSet.X_cov(:,:,i) = double(TrainSet.GRCM2{1,i});
    end

    TestSet.X_cov = zeros(dim, dim, test_num);
    for i = 1 : test_num
        TestSet.X_cov(:,:,i) = double(TestSet.GRCM2{1,i});
    end
else

    load('../dataset/toy_data_eccv12.mat');
    TrainSet.X_cov = TrainSet.X;
    TestSet.X_cov = TestSet.X;
    
    class_num = length(unique(TestSet.y));
end


%% RSR
% RSR Classifier
options.mode = 'src'; % 'src', 'ip_linear', 'ip_max'
options.original_alpha = true;
options.theta = 0.01;
options.lambda = 1e-2;
options.verbose = true;
Accuracy_rsr = rsr_classifier(TrainSet, TestSet, options);
fprintf('# RSR Accuracy = %5.5f\n', Accuracy_rsr);

% RSR-DSK (kernel alignment) 
fprintf('# RSR with DSK (KA) Classification ... ');
options.mode = 'src'; % 'src', 'ip_linear', 'ip_max'
options.theta = 0.01;
options.obj_method = 'ka'; % use kernel alignment criterion.
options.lambda = 1e-2;
options.original_alpha = 0;
options.verbose = true;
Accuracy_rsr_dsk_ka = rsr_dsk_classifier(TrainSet, TestSet, options);
fprintf('Accuracy = %5.5f\n', Accuracy_rsr_dsk_ka); 

% RSR-DSK (class seperabiliy) 
fprintf('# RSR with DSK (CS) Classification ... ');
options.mode = 'src'; % 'src', 'ip_linear', 'ip_max'
options.theta = 0.01;
options.obj_method = 'cs';
options.lambda = 1e-2;
options.original_alpha = 0;
options.verbose = true;
Accuracy_rsr_dsk_cs = rsr_dsk_classifier(TrainSet, TestSet, options);
fprintf('Accuracy = %5.5f\n', Accuracy_rsr_dsk_cs);       


%% K-NN with SK or DSK (TAPI2015)
% K-NN with SK (Stein Kernel)
fprintf('# K-NN with SK Classification ... ');
clear options;
options.theta = 0.01;
options.original_alpha = 1;
[test_kernel, train_kernel] = DSK_optimization_new(TrainSet,TestSet,options);
clear options;
options.verbose = true;
Accuracy_knn = kernel_knn_classification_new(test_kernel, TrainSet.y, class_num, TestSet.y, options); % do knn classification 
fprintf('Accuracy = %5.5f\n', Accuracy_knn);

% K-NN with DSK (Discriminative Stein Kernel)
fprintf('# K-NN with DSK (KA) Classification ... ');
clear options
options.theta = 0.01;
options.obj_method = 'ka';
options.lambda = 0.01;
options.original_alpha = 0;
[test_kernel,train_kernel,optimal_alpha] = DSK_optimization_new(TrainSet,TestSet,options);
clear options;
options.verbose = true;
Accuracy_knn_dsk_ka = kernel_knn_classification_new(test_kernel, TrainSet.y, class_num, TestSet.y,options);
fprintf('Accuracy = %5.5f\n', Accuracy_knn_dsk_ka);    


% K-NN with DSK (Discriminative Stein Kernel)
fprintf('# K-NN with DSK (CS) Classification ... ');
clear options
options.theta = 0.01;
options.obj_method = 'cs';
options.lambda = 0.01;
options.original_alpha = 0;
[test_kernel,train_kernel,optimal_alpha] = DSK_optimization_new(TrainSet,TestSet,options);
clear options;
options.verbose = true;
Accuracy_knn_dsk_cs = kernel_knn_classification_new(test_kernel,TrainSet.y,class_num,TestSet.y,options);
fprintf('Accuracy = %5.5f\n', Accuracy_knn_dsk_cs);


%% display accuracy
fprintf('\n\n## Summary of results\n\n')
fprintf('# RSR: Accuracy = %5.5f\n', Accuracy_rsr);
fprintf('# RSR-DSK-KA: Accuracy = %5.5f\n', Accuracy_rsr_dsk_ka); 
fprintf('# RSR-DSK-CS: Accuracy = %5.5f\n', Accuracy_rsr_dsk_cs);
fprintf('# kNN: Accuracy = %5.5f\n', Accuracy_knn);
fprintf('# kNN-DSK-KA: Accuracy = %5.5f\n', Accuracy_knn_dsk_ka); 
fprintf('# kNN-DSK-CS: Accuracy = %5.5f\n', Accuracy_knn_dsk_cs);
