%%% Image Classifier
% Using pretrained google net network

categories = {'rock','classical','jazz'};

location = "C:\Users\USER\Desktop\images_original";
imds = imageDatastore(location,"IncludeSubfolders",true,...
    "FileExtensions",".png","LabelSource","foldernames");

tbl = countEachLabel(imds);
% rand = randperm(299,1)
% for i = 1:1
%         img = read(imds);
%         figure,imshow(img);
% end;



minSetCount = min(tbl{:,2});
imds = splitEachLabel(imds,minSetCount,'randomize');
countEachLabel(imds)
rock = find(imds.Labels == 'rock',1);
classical = find(imds.Labels == 'classical',1);
jazz = find(imds.Labels == 'jazz',1);
figure
%Rock's spectogram
subplot(2,2,1);
imshow(readimage(imds,rock))
title("Rock")
%Classical's spectogram
subplot(2,2,2);
imshow(readimage(imds,classical))
title("Classical music")
%Jazz's spectogram
subplot(2,2,3);
imshow(readimage(imds,jazz))
title("Jazz")
net = googlenet();
net.Layers(1);
net.Layers(end);

figure
set(gca,'Ylim',[210 270])
plot(net)
title("Google net")


[trainingSet,testSet] = splitEachLabel(imds,0.3,'randomize');
imageSize = net.Layers(1).InputSize;
AugmentedTrainingset = augmentedImageDatastore(imageSize,trainingSet,...
    'ColorPreprocessing','gray2rgb');
AugmentedTestset = augmentedImageDatastore(imageSize,testSet,...
    'ColorPreprocessing','gray2rgb');

%getting the weights of the 2nd conv layers and storing them in w1
w1 =net.Layers(2).Weights;
w1 = mat2gray(w1);

% figure
% montage(w1)
% title("1st convolutional Layer weights")

featureLayer = 'data';
trainingfeatures = activations(net,AugmentedTrainingset,featureLayer,...
    'MiniBatchSize',32,'Output','columns');
trainingLabels = trainingSet.Labels;
%uses K(K-1)/2 binary support vector machine where K is 
% #unique class labels
classifier = fitcecoc(trainingfeatures,trainingLabels,'Learner','Linear','Coding',...
    'onevsall','ObservationsIn','columns');
%features of test images
testfeatures = activations(net,AugmentedTestset,featureLayer,...
    'MiniBatchSize',32,'Output','columns');

predictLabels = predict(classifier,testfeatures,'ObservationsIn','columns');
testLabels = testSet.Labels;

confMat = confusionmat(testLabels,predictLabels);

confMat_normalized = bsxfun(@rdivide,confMat,sum(confMat,2))

accuracy = mean(diag(confMat_normalized))

